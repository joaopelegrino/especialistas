# DSM:CONTENT:media_schema WORDPRESS:media_library_compatibility
# DSM:SECURITY:file_validation HEALTHCARE:medical_image_compliance
defmodule HealthcareCMS.Content.Media do
  @moduledoc """
  Media Schema - WordPress Media Library Compatible

  Gerenciamento de arquivos media com funcionalidades WordPress:
  - Upload e armazenamento de imagens, documentos
  - Metadata automático (dimensões, tamanho)
  - Attachment support para posts
  - Healthcare-specific file validation
  - DICOM image support preparado
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias HealthcareCMS.Accounts.User
  alias HealthcareCMS.Content.Post

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "media" do
    field :title, :string
    field :filename, :string
    field :original_filename, :string
    field :mime_type, :string
    field :file_size, :integer  # bytes

    # File paths
    field :file_path, :string
    field :url, :string

    # Image metadata
    field :width, :integer
    field :height, :integer
    field :alt_text, :string
    field :caption, :string
    field :description, :string

    # WordPress compatibility
    field :attachment_type, Ecto.Enum, values: [
      :image, :document, :video, :audio, :archive, :other
    ]

    # Healthcare specific fields
    field :medical_content, :boolean, default: false
    field :contains_phi, :boolean, default: false  # Protected Health Information
    field :dicom_metadata, :map  # For medical imaging
    field :encryption_status, Ecto.Enum, values: [:none, :at_rest, :full], default: :none

    # Access control
    field :access_level, Ecto.Enum, values: [:public, :authenticated, :professional, :restricted]
    field :requires_crm_validation, :boolean, default: false

    # Tenant support
    field :tenant_id, :binary_id

    # Relationships
    belongs_to :uploaded_by, User, foreign_key: :uploaded_by_id
    belongs_to :attached_to_post, Post, foreign_key: :post_id

    timestamps()
  end

  @required_fields [:filename, :original_filename, :mime_type, :file_size, :uploaded_by_id]
  @optional_fields [
    :title, :file_path, :url, :width, :height, :alt_text, :caption, :description,
    :attachment_type, :medical_content, :contains_phi, :dicom_metadata,
    :encryption_status, :access_level, :requires_crm_validation,
    :tenant_id, :post_id
  ]

  # Allowed MIME types for healthcare
  @allowed_mime_types [
    # Images
    "image/jpeg", "image/png", "image/gif", "image/webp", "image/svg+xml",
    # Documents
    "application/pdf", "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "application/vnd.ms-excel",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    # Medical formats
    "application/dicom", "application/x-dicom",
    # Archives
    "application/zip", "application/x-rar-compressed"
  ]

  @max_file_size 50 * 1024 * 1024  # 50MB

  @doc false
  def changeset(media, attrs) do
    media
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:filename, min: 1, max: 255)
    |> validate_length(:original_filename, min: 1, max: 255)
    |> validate_length(:alt_text, max: 255)
    |> validate_length(:caption, max: 500)
    |> validate_file_size()
    |> validate_mime_type()
    |> set_attachment_type()
    |> set_healthcare_requirements()
    |> generate_title()
    |> unique_constraint(:filename)
  end

  defp validate_file_size(changeset) do
    case get_field(changeset, :file_size) do
      size when is_integer(size) and size > @max_file_size ->
        add_error(changeset, :file_size, "arquivo muito grande (máximo 50MB)")
      _ -> changeset
    end
  end

  defp validate_mime_type(changeset) do
    case get_field(changeset, :mime_type) do
      mime_type when mime_type in @allowed_mime_types ->
        changeset
      mime_type when is_binary(mime_type) ->
        add_error(changeset, :mime_type, "tipo de arquivo não permitido")
      _ ->
        add_error(changeset, :mime_type, "tipo de arquivo obrigatório")
    end
  end

  defp set_attachment_type(changeset) do
    case get_field(changeset, :mime_type) do
      "image/" <> _ -> put_change(changeset, :attachment_type, :image)
      "application/pdf" -> put_change(changeset, :attachment_type, :document)
      "application/" <> _ -> put_change(changeset, :attachment_type, :document)
      "video/" <> _ -> put_change(changeset, :attachment_type, :video)
      "audio/" <> _ -> put_change(changeset, :attachment_type, :audio)
      _ -> put_change(changeset, :attachment_type, :other)
    end
  end

  defp set_healthcare_requirements(changeset) do
    medical_content = get_field(changeset, :medical_content)
    contains_phi = get_field(changeset, :contains_phi)
    mime_type = get_field(changeset, :mime_type)

    changeset = if mime_type in ["application/dicom", "application/x-dicom"] do
      changeset
      |> put_change(:medical_content, true)
      |> put_change(:encryption_status, :full)
      |> put_change(:access_level, :professional)
      |> put_change(:requires_crm_validation, true)
    else
      changeset
    end

    if contains_phi or medical_content do
      changeset
      |> put_change(:encryption_status, :at_rest)
      |> validate_access_level_for_phi()
    else
      changeset
    end
  end

  defp validate_access_level_for_phi(changeset) do
    case get_field(changeset, :access_level) do
      level when level in [:public, :authenticated] ->
        add_error(changeset, :access_level,
          "conteúdo médico/PHI requer nível de acesso profissional ou restrito")
      _ -> changeset
    end
  end

  defp generate_title(changeset) do
    case get_field(changeset, :title) do
      nil ->
        filename = get_field(changeset, :original_filename)
        if filename do
          title = filename
                  |> Path.basename()
                  |> Path.rootname()
                  |> String.replace(~r/[_-]/, " ")
                  |> String.trim()

          put_change(changeset, :title, title)
        else
          changeset
        end
      _ -> changeset
    end
  end

  @doc """
  Verifica se arquivo é uma imagem
  """
  def image?(%__MODULE__{attachment_type: :image}), do: true
  def image?(_), do: false

  @doc """
  Verifica se arquivo contém PHI (Protected Health Information)
  """
  def contains_phi?(%__MODULE__{contains_phi: true}), do: true
  def contains_phi?(%__MODULE__{medical_content: true}), do: true
  def contains_phi?(_), do: false

  @doc """
  Retorna URL completa do arquivo
  """
  def full_url(%__MODULE__{url: url}) when is_binary(url), do: url
  def full_url(%__MODULE__{file_path: path}) when is_binary(path) do
    # Em produção, construiria URL baseada na configuração
    "/uploads/#{path}"
  end
  def full_url(_), do: nil
end