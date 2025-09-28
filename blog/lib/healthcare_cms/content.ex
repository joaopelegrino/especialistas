# DSM:CONTENT:wordpress_core_features HEALTHCARE:medical_content_management
# DSM:AUDIT:content_versioning LGPD:data_retention_tracking
defmodule HealthcareCMS.Content do
  @moduledoc """
  WordPress Core Content Management Context

  Gerencia posts, pages, categories e media com extensões específicas
  para healthcare e compliance LGPD.

  Funcionalidades WordPress Core:
  - Posts e Pages management
  - Categories e Tags
  - Media Library
  - Content versioning para audit trail
  - Custom fields (ACF equivalent)
  """

  import Ecto.Query, warn: false
  alias HealthcareCMS.Repo

  alias HealthcareCMS.Content.{Post, Category, Media, CustomField}

  @doc """
  Lista todos os posts com filtros opcionais
  """
  def list_posts(opts \\ []) do
    Post
    |> apply_post_filters(opts)
    |> Repo.all()
    |> Repo.preload([:category, :author, :custom_fields])
  end

  @doc """
  Busca post por ID
  """
  def get_post!(id) do
    Post
    |> Repo.get!(id)
    |> Repo.preload([:category, :author, :custom_fields])
  end

  @doc """
  Busca post por slug (WordPress style)
  """
  def get_post_by_slug(slug) do
    Post
    |> where([p], p.slug == ^slug and p.status == :published)
    |> Repo.one()
    |> case do
      nil -> nil
      post -> Repo.preload(post, [:category, :author, :custom_fields])
    end
  end

  @doc """
  Cria novo post
  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, post} ->
        {:ok, Repo.preload(post, [:category, :author, :custom_fields])}
      error -> error
    end
  end

  @doc """
  Atualiza post existente
  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, post} ->
        {:ok, Repo.preload(post, [:category, :author, :custom_fields])}
      error -> error
    end
  end

  @doc """
  Remove post (soft delete para compliance)
  """
  def delete_post(%Post{} = post) do
    post
    |> Post.changeset(%{status: :deleted, deleted_at: DateTime.utc_now()})
    |> Repo.update()
  end

  @doc """
  Lista categorias
  """
  def list_categories do
    Category
    |> order_by([c], c.name)
    |> Repo.all()
  end

  @doc """
  Cria nova categoria
  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lista media files
  """
  def list_media(opts \\ []) do
    Media
    |> apply_media_filters(opts)
    |> Repo.all()
  end

  @doc """
  Upload de arquivo media
  """
  def upload_media(attrs \\ %{}) do
    %Media{}
    |> Media.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Busca custom fields para post
  """
  def get_custom_fields(post_id) do
    CustomField
    |> where([cf], cf.post_id == ^post_id)
    |> Repo.all()
  end

  @doc """
  Atualiza custom field (ACF style)
  """
  def update_custom_field(post_id, field_name, field_value) do
    case Repo.get_by(CustomField, post_id: post_id, meta_key: field_name) do
      nil ->
        %CustomField{}
        |> CustomField.changeset(%{
          post_id: post_id,
          meta_key: field_name,
          meta_value: field_value
        })
        |> Repo.insert()

      existing ->
        existing
        |> CustomField.changeset(%{meta_value: field_value})
        |> Repo.update()
    end
  end

  # Private filter functions

  defp apply_post_filters(query, opts) do
    Enum.reduce(opts, query, fn
      {:status, status}, query ->
        where(query, [p], p.status == ^status)

      {:category_id, category_id}, query ->
        where(query, [p], p.category_id == ^category_id)

      {:author_id, author_id}, query ->
        where(query, [p], p.author_id == ^author_id)

      {:search, term}, query ->
        search_term = "%#{term}%"
        where(query, [p],
          ilike(p.title, ^search_term) or
          ilike(p.content, ^search_term) or
          ilike(p.excerpt, ^search_term)
        )

      {:limit, limit}, query ->
        limit(query, ^limit)

      {:order_by, :newest}, query ->
        order_by(query, [p], desc: p.published_at)

      {:order_by, :oldest}, query ->
        order_by(query, [p], asc: p.published_at)

      _, query -> query
    end)
  end

  defp apply_media_filters(query, opts) do
    Enum.reduce(opts, query, fn
      {:type, type}, query ->
        where(query, [m], m.mime_type == ^type)

      {:author_id, author_id}, query ->
        where(query, [m], m.uploaded_by_id == ^author_id)

      _, query -> query
    end)
  end
end