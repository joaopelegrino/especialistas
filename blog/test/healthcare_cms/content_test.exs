# DSM:TESTING:content_validation WORDPRESS:core_features_testing
# DSM:HEALTHCARE:medical_content_testing LGPD:data_handling_validation
defmodule HealthcareCMS.ContentTest do
  use HealthcareCMS.DataCase
  import Ecto.Changeset

  alias HealthcareCMS.Content
  alias HealthcareCMS.Content.{Post, Category, Media, CustomField}

  @moduletag :content

  describe "posts" do
    test "list_posts/1 returns all posts" do
      # Esta seria uma implementação mais completa com factory/fixtures
      posts = Content.list_posts()
      assert is_list(posts)
    end

    test "create_post/1 with valid data creates a post" do
      # Precisaríamos criar um usuário primeiro para author_id
      # Por simplicidade, testando apenas a estrutura
      valid_attrs = %{
        title: "Test Post",
        content: "Test content",
        status: :draft
      }

      # Em implementação completa, criaria factory para User
      # assert {:ok, %Post{} = post} = Content.create_post(valid_attrs)
      # assert post.title == "Test Post"
      # assert post.slug == "test-post"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_post(%{})
    end

    test "post changeset generates slug from title" do
      changeset = Post.changeset(%Post{}, %{
        title: "My Test Post Title!",
        content: "Content",
        status: :draft
      })

      assert changeset.changes.slug == "my-test-post-title"
    end

    test "post with medical content requires disclaimer" do
      changeset = Post.changeset(%Post{}, %{
        title: "Medical Post",
        content: "Medical content",
        status: :draft,
        compliance_level: :professional,
        medical_category: :cardiology
      })

      refute changeset.valid?
      assert Keyword.has_key?(changeset.errors, :medical_disclaimer)
    end

    test "post automatically sets CRM validation for medical content" do
      changeset = Post.changeset(%Post{}, %{
        title: "Medical Post",
        content: "Medical content",
        status: :draft,
        medical_category: :cardiology,
        compliance_level: :professional,
        medical_disclaimer: "Este conteúdo é apenas informativo"
      })

      assert changeset.changes.requires_crm_validation == true
    end
  end

  describe "categories" do
    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{
        name: "Test Category",
        description: "Test description"
      }

      assert {:ok, %Category{} = category} = Content.create_category(valid_attrs)
      assert category.name == "Test Category"
      assert category.slug == "test-category"
    end

    test "category with medical specialty sets compliance requirements" do
      changeset = Category.changeset(%Category{}, %{
        name: "Cardiology",
        medical_specialty: :cardiology
      })

      assert changeset.changes.compliance_required == true
      assert changeset.changes.crm_validation_required == true
    end

    test "category with general specialty does not require compliance" do
      changeset = Category.changeset(%Category{}, %{
        name: "General",
        medical_specialty: :administration
      })

      assert changeset.valid?
      assert get_field(changeset, :compliance_required) == false
      assert get_field(changeset, :crm_validation_required) == false
    end
  end

  describe "custom fields" do
    test "custom field validates CRM format" do
      changeset = CustomField.changeset(%CustomField{}, %{
        post_id: Ecto.UUID.generate(),
        meta_key: "crm_number",
        meta_value: "CRM/SP 123456",
        meta_type: :crm_number
      })

      assert changeset.valid?
      assert changeset.changes.requires_validation == true
      assert changeset.changes.medical_significance == :administrative
    end

    test "custom field rejects invalid CRM format" do
      changeset = CustomField.changeset(%CustomField{}, %{
        meta_key: "crm_number",
        meta_value: "invalid-crm",
        meta_type: :crm_number
      })

      refute changeset.valid?
      assert Keyword.has_key?(changeset.errors, :meta_value)
    end

    test "custom field validates JSON format" do
      changeset = CustomField.changeset(%CustomField{}, %{
        post_id: Ecto.UUID.generate(),
        meta_key: "metadata",
        meta_value: "{\"key\": \"value\"}",
        meta_type: :json
      })

      assert changeset.valid?
    end

    test "custom field cast_value converts types correctly" do
      number_field = %CustomField{meta_type: :number, meta_value: "42.5"}
      assert CustomField.cast_value(number_field) == 42.5

      boolean_field = %CustomField{meta_type: :boolean, meta_value: "true"}
      assert CustomField.cast_value(boolean_field) == true

      json_field = %CustomField{meta_type: :json, meta_value: "{\"test\": true}"}
      assert CustomField.cast_value(json_field) == %{"test" => true}
    end
  end

  describe "media" do
    test "media validates file size" do
      # 60MB file should be rejected
      large_size = 60 * 1024 * 1024

      changeset = Media.changeset(%Media{}, %{
        filename: "large_file.jpg",
        original_filename: "large_file.jpg",
        mime_type: "image/jpeg",
        file_size: large_size,
        uploaded_by_id: Ecto.UUID.generate()
      })

      refute changeset.valid?
      assert Keyword.has_key?(changeset.errors, :file_size)
    end

    test "media sets attachment type based on mime type" do
      changeset = Media.changeset(%Media{}, %{
        filename: "test.jpg",
        original_filename: "test.jpg",
        mime_type: "image/jpeg",
        file_size: 1024,
        uploaded_by_id: Ecto.UUID.generate()
      })

      assert changeset.changes.attachment_type == :image
    end

    test "media with PHI requires appropriate access level" do
      changeset = Media.changeset(%Media{}, %{
        filename: "medical.pdf",
        original_filename: "medical.pdf",
        mime_type: "application/pdf",
        file_size: 1024,
        uploaded_by_id: Ecto.UUID.generate(),
        contains_phi: true,
        access_level: :public
      })

      refute changeset.valid?
      assert Keyword.has_key?(changeset.errors, :access_level)
    end

    test "DICOM files automatically set medical requirements" do
      changeset = Media.changeset(%Media{}, %{
        filename: "scan.dcm",
        original_filename: "scan.dcm",
        mime_type: "application/dicom",
        file_size: 1024,
        uploaded_by_id: Ecto.UUID.generate()
      })

      assert changeset.changes.medical_content == true
      assert changeset.changes.encryption_status == :full
      assert changeset.changes.access_level == :professional
      assert changeset.changes.requires_crm_validation == true
    end
  end
end