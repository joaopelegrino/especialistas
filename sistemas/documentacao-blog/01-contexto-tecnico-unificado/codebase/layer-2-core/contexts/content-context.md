# Healthcare CMS - Content Context

> **Level**: 2 (Core) | **Read Time**: 25min | **Tokens**: ~8K
> **Audience**: Backend developers, content architects
> **Last Validated**: 2025-09-30

---

## 📋 Context Overview

### Purpose

**Content Context** manages WordPress-compatible content with healthcare-specific extensions:

- **Posts & Pages** - Articles, medical content, patient education
- **Categories** - Hierarchical taxonomy with medical specialties
- **Media Library** - Images, videos, documents
- **Custom Fields** - ACF-style metadata (meta_key/meta_value)
- **Medical Classification** - Compliance levels, CRM validation requirements
- **Audit Trail** - Content versioning for LGPD compliance

### Files

```
lib/healthcare_cms/content/
├── content.ex           # Public API (203 lines)
├── post.ex              # Post schema (148 lines)
├── category.ex          # Category schema (151 lines)
├── media.ex             # Media schema (~100 lines)
└── custom_field.ex      # Custom fields schema (~50 lines)
```

**Total LOC**: ~652 lines

---

## 🗄️ Database Schemas

### Posts Table

```sql
CREATE TABLE posts (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Core WordPress Fields
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  excerpt TEXT,
  status VARCHAR(20) DEFAULT 'draft',
    -- Values: draft, published, private, trash, deleted

  -- WordPress Meta Fields
  post_type VARCHAR(50) DEFAULT 'post',  -- post, page, custom_post_type
  comment_status VARCHAR(20) DEFAULT 'open',  -- open, closed
  ping_status VARCHAR(20) DEFAULT 'open',     -- open, closed

  -- SEO Fields
  meta_description VARCHAR(160),
  meta_keywords TEXT,

  -- Healthcare Specific Fields
  medical_category VARCHAR(50),
    -- Values: general, cardiology, neurology, pediatrics, surgery,
    --         pharmacy, radiology, laboratory, emergency, preventive
  compliance_level VARCHAR(20),
    -- Values: public, professional, restricted, phi
  requires_crm_validation BOOLEAN DEFAULT false,
  medical_disclaimer TEXT,

  -- Publication Fields
  published_at TIMESTAMP,
  scheduled_at TIMESTAMP,

  -- Audit Fields
  version INTEGER DEFAULT 1,
  deleted_at TIMESTAMP,

  -- Multi-Tenancy
  tenant_id UUID,

  -- Foreign Keys
  author_id UUID NOT NULL REFERENCES users(id),
  category_id UUID REFERENCES categories(id),

  -- Timestamps
  inserted_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

  -- Constraints
  CONSTRAINT posts_slug_tenant_id_index UNIQUE(slug, tenant_id)
);

CREATE INDEX idx_posts_status ON posts(status);
CREATE INDEX idx_posts_author_id ON posts(author_id);
CREATE INDEX idx_posts_category_id ON posts(category_id);
CREATE INDEX idx_posts_tenant_id ON posts(tenant_id);
CREATE INDEX idx_posts_published_at ON posts(published_at DESC);
CREATE INDEX idx_posts_medical_category ON posts(medical_category);
```

---

### Categories Table

```sql
CREATE TABLE categories (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Core Fields
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) NOT NULL,
  description TEXT,

  -- WordPress Taxonomy Fields
  count INTEGER DEFAULT 0,  -- Number of posts

  -- Hierarchy Support
  parent_id UUID REFERENCES categories(id),
  level INTEGER DEFAULT 0,  -- 0 = root, 1 = child, etc.

  -- Healthcare Specific Fields
  medical_specialty VARCHAR(50),
    -- Values: general_medicine, cardiology, neurology, pediatrics, surgery,
    --         psychiatry, dermatology, orthopedics, gynecology, urology,
    --         oncology, radiology, anesthesiology, emergency_medicine,
    --         family_medicine, internal_medicine, pharmacy, nursing,
    --         physiotherapy, nutrition, psychology, administration
  compliance_required BOOLEAN DEFAULT false,
  crm_validation_required BOOLEAN DEFAULT false,

  -- Multi-Tenancy
  tenant_id UUID,

  -- Timestamps
  inserted_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

  -- Constraints
  CONSTRAINT categories_slug_tenant_id_index UNIQUE(slug, tenant_id),
  CONSTRAINT categories_name_tenant_id_index UNIQUE(name, tenant_id)
);

CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_categories_tenant_id ON categories(tenant_id);
CREATE INDEX idx_categories_medical_specialty ON categories(medical_specialty);
```

---

### Media Table (Simplified)

```sql
CREATE TABLE media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- File Information
  filename VARCHAR(255) NOT NULL,
  original_filename VARCHAR(255),
  mime_type VARCHAR(100),
  file_size BIGINT,  -- bytes
  file_path TEXT,

  -- Image Metadata (if applicable)
  width INTEGER,
  height INTEGER,
  alt_text TEXT,

  -- Upload Information
  uploaded_by_id UUID REFERENCES users(id),
  tenant_id UUID,

  -- Timestamps
  inserted_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

---

### Custom Fields Table

```sql
CREATE TABLE custom_fields (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- WordPress ACF Style
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  meta_key VARCHAR(255) NOT NULL,
  meta_value TEXT,

  -- Timestamps
  inserted_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

  -- Constraints
  CONSTRAINT custom_fields_post_id_meta_key_index UNIQUE(post_id, meta_key)
);

CREATE INDEX idx_custom_fields_post_id ON custom_fields(post_id);
CREATE INDEX idx_custom_fields_meta_key ON custom_fields(meta_key);
```

---

## 📦 Post Schema (`post.ex`)

### Schema Definition

```elixir
defmodule HealthcareCMS.Content.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias HealthcareCMS.Accounts.User
  alias HealthcareCMS.Content.{Category, CustomField}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "posts" do
    # Core WordPress fields (5)
    field :title, :string
    field :slug, :string
    field :content, :string
    field :excerpt, :string
    field :status, Ecto.Enum, values: [:draft, :published, :private, :trash, :deleted]

    # WordPress meta fields (3)
    field :post_type, :string, default: "post"
    field :comment_status, Ecto.Enum, values: [:open, :closed], default: :open
    field :ping_status, Ecto.Enum, values: [:open, :closed], default: :open

    # SEO fields (2)
    field :meta_description, :string
    field :meta_keywords, :string

    # Healthcare specific fields (4)
    field :medical_category, Ecto.Enum, values: [
      :general, :cardiology, :neurology, :pediatrics, :surgery,
      :pharmacy, :radiology, :laboratory, :emergency, :preventive
    ]
    field :compliance_level, Ecto.Enum, values: [:public, :professional, :restricted, :phi]
    field :requires_crm_validation, :boolean, default: false
    field :medical_disclaimer, :string

    # Publication fields (2)
    field :published_at, :utc_datetime
    field :scheduled_at, :utc_datetime

    # Audit fields (2)
    field :version, :integer, default: 1
    field :deleted_at, :utc_datetime

    # Multi-tenancy (1)
    field :tenant_id, :binary_id

    # Relationships
    belongs_to :author, User, foreign_key: :author_id
    belongs_to :category, Category
    has_many :custom_fields, CustomField

    timestamps()
  end
end
```

**Total Fields**: 19 (excluding associations, timestamps)

---

### Changeset Validations

```elixir
def changeset(post, attrs) do
  post
  |> cast(attrs, @required_fields ++ @optional_fields)
  |> validate_required([:title, :content, :status, :author_id])
  |> validate_length(:title, min: 1, max: 255)
  |> validate_length(:excerpt, max: 500)
  |> validate_length(:meta_description, max: 160)
  |> generate_slug()
  |> set_published_at()
  |> validate_medical_content()
  |> unique_constraint(:slug, name: :posts_slug_tenant_id_index)
end
```

#### 1. Slug Generation

```elixir
defp generate_slug(changeset) do
  case get_change(changeset, :title) do
    nil -> changeset
    title ->
      slug = title
             |> String.downcase()
             |> String.replace(~r/[^\w\s-]/, "")  # Remove special chars
             |> String.replace(~r/\s+/, "-")       # Spaces to hyphens
             |> String.trim("-")                   # Trim edge hyphens

      put_change(changeset, :slug, slug)
  end
end
```

**Example**:
```elixir
title = "Como Prevenir Doenças Cardíacas: Guia Completo"
slug  = "como-prevenir-doencas-cardiacas-guia-completo"
```

---

#### 2. Published At Auto-Set

```elixir
defp set_published_at(changeset) do
  case get_change(changeset, :status) do
    :published ->
      if get_field(changeset, :published_at) == nil do
        put_change(changeset, :published_at, DateTime.utc_now())
      else
        changeset
      end
    _ -> changeset
  end
end
```

**Behavior**: Auto-set `published_at` when status changes to `:published`

---

#### 3. Medical Content Validation

```elixir
defp validate_medical_content(changeset) do
  compliance_level = get_field(changeset, :compliance_level)
  medical_category = get_field(changeset, :medical_category)

  changeset
  |> validate_medical_disclaimer(compliance_level)
  |> validate_crm_requirement(medical_category, compliance_level)
end
```

**Rules**:

| Compliance Level | Medical Disclaimer Required? | CRM Validation Required? |
|------------------|----------------------------|--------------------------|
| `:public` | No | No |
| `:professional` | Yes | Yes (if medical_category ≠ :general) |
| `:restricted` | Yes | Yes (if medical_category ≠ :general) |
| `:phi` | Yes | N/A (PHI always requires strict validation) |

**Example**:
```elixir
# ❌ INVALID - Professional content without disclaimer
%{
  title: "Tratamento de Arritmia Cardíaca",
  content: "...",
  compliance_level: :professional,
  medical_category: :cardiology,
  medical_disclaimer: nil  # ERROR!
}

# ✅ VALID - Professional content with disclaimer
%{
  title: "Tratamento de Arritmia Cardíaca",
  content: "...",
  compliance_level: :professional,
  medical_category: :cardiology,
  medical_disclaimer: "Este conteúdo destina-se apenas a profissionais de saúde..."
}
```

---

## 🏷️ Category Schema (`category.ex`)

### Schema Definition

```elixir
defmodule HealthcareCMS.Content.Category do
  use Ecto.Schema
  import Ecto.Changeset

  alias HealthcareCMS.Content.Post

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "categories" do
    # Core fields
    field :name, :string
    field :slug, :string
    field :description, :string

    # WordPress taxonomy
    field :count, :integer, default: 0

    # Hierarchy
    field :level, :integer, default: 0

    # Healthcare specific
    field :medical_specialty, Ecto.Enum, values: [
      :general_medicine, :cardiology, :neurology, :pediatrics, :surgery,
      :psychiatry, :dermatology, :orthopedics, :gynecology, :urology,
      :oncology, :radiology, :anesthesiology, :emergency_medicine,
      :family_medicine, :internal_medicine, :pharmacy, :nursing,
      :physiotherapy, :nutrition, :psychology, :administration
    ]

    field :compliance_required, :boolean, default: false
    field :crm_validation_required, :boolean, default: false

    # Multi-tenancy
    field :tenant_id, :binary_id

    # Relationships
    belongs_to :parent, __MODULE__, type: :binary_id
    has_many :children, __MODULE__, foreign_key: :parent_id
    has_many :posts, Post

    timestamps()
  end
end
```

---

### Hierarchical Categories

**Example Structure**:
```
Cardiologia (parent, level 0)
├── Arritmias (child, level 1)
├── Insuficiência Cardíaca (child, level 1)
└── Cardiologia Pediátrica (child, level 1)

Neurologia (parent, level 0)
├── Alzheimer (child, level 1)
└── Parkinson (child, level 1)
```

**Implementation**:
```elixir
# Create parent category
{:ok, cardiology} = Content.create_category(%{
  name: "Cardiologia",
  medical_specialty: :cardiology,
  compliance_required: true
})

# Create child category
{:ok, arrhythmia} = Content.create_category(%{
  name: "Arritmias",
  parent_id: cardiology.id,
  medical_specialty: :cardiology
})
# Automatically sets level: 1
```

---

### Medical Requirements Auto-Set

```elixir
defp set_medical_requirements(changeset) do
  case get_field(changeset, :medical_specialty) do
    nil ->
      changeset

    specialty when specialty in [:general_medicine, :administration, :pharmacy] ->
      changeset
      |> put_change(:compliance_required, false)
      |> put_change(:crm_validation_required, false)

    _medical_specialty ->
      changeset
      |> put_change(:compliance_required, true)
      |> put_change(:crm_validation_required, true)
  end
end
```

**Automatic Behavior**:
- **General categories** (general_medicine, administration, pharmacy) → No compliance required
- **Medical specialties** (cardiology, neurology, etc.) → Compliance + CRM validation required

---

### Post Counter

```elixir
def increment_count(category_id) do
  from(c in Category, where: c.id == ^category_id)
  |> Repo.update_all(inc: [count: 1])
end

def decrement_count(category_id) do
  from(c in Category, where: c.id == ^category_id and c.count > 0)
  |> Repo.update_all(inc: [count: -1])
end
```

**Usage**:
```elixir
# When creating post
{:ok, post} = Content.create_post(%{category_id: category_id, ...})
Category.increment_count(category_id)

# When deleting post
Content.delete_post(post)
Category.decrement_count(post.category_id)
```

---

## 🌐 Public API (`content.ex`)

### Posts Management

#### 1. List Posts (`list_posts/1`)

```elixir
def list_posts(opts \\ [])
```

**Filters**:
- `:status` - Filter by status (`:draft`, `:published`, etc.)
- `:category_id` - Filter by category
- `:author_id` - Filter by author
- `:search` - Full-text search (title, content, excerpt)
- `:limit` - Limit results
- `:order_by` - Order by (`:newest`, `:oldest`)

**Example**:
```elixir
# Published posts in cardiology category
posts = Content.list_posts(
  status: :published,
  category_id: cardiology_id,
  order_by: :newest,
  limit: 10
)
```

---

#### 2. Get Post by ID (`get_post!/1`)

```elixir
def get_post!(id)
```

**Returns**: Post with preloaded associations (`:category`, `:author`, `:custom_fields`)

**Raises**: `Ecto.NoResultsError` if not found

---

#### 3. Get Post by Slug (`get_post_by_slug/1`)

```elixir
def get_post_by_slug(slug)
```

**WordPress-compatible** URL routing:
```
/blog/como-prevenir-doencas-cardiacas-guia-completo
      ↓
slug: "como-prevenir-doencas-cardiacas-guia-completo"
```

**Returns**: Published post or `nil`

---

#### 4. Create Post (`create_post/1`)

```elixir
def create_post(attrs \\ %{})
```

**Example**:
```elixir
{:ok, post} = Content.create_post(%{
  title: "Como Prevenir Doenças Cardíacas",
  content: "Lorem ipsum dolor sit amet...",
  excerpt: "Guia completo sobre prevenção de doenças cardíacas",
  status: :draft,
  author_id: doctor_id,
  category_id: cardiology_id,
  medical_category: :cardiology,
  compliance_level: :professional,
  medical_disclaimer: "Este conteúdo destina-se apenas a profissionais de saúde.",
  meta_description: "Prevenção de doenças cardíacas - guia completo",
  meta_keywords: "cardiologia, prevenção, saúde do coração"
})
```

---

#### 5. Update Post (`update_post/2`)

```elixir
def update_post(%Post{} = post, attrs)
```

**Example - Publishing Draft**:
```elixir
post = Content.get_post!(post_id)

{:ok, published_post} = Content.update_post(post, %{
  status: :published
  # published_at automatically set to DateTime.utc_now()
})
```

---

#### 6. Delete Post (`delete_post/1`) ⚠️

```elixir
def delete_post(%Post{} = post)
```

**⚠️ Soft Delete** (LGPD compliance):
```elixir
def delete_post(%Post{} = post) do
  post
  |> Post.changeset(%{status: :deleted, deleted_at: DateTime.utc_now()})
  |> Repo.update()
end
```

**Not a hard delete** - preserves audit trail for 20 years (CFM Res. 1.821/2007)

---

### Categories Management

#### 1. List Categories (`list_categories/0`)

```elixir
def list_categories()
```

**Returns**: All categories ordered by name

---

#### 2. Create Category (`create_category/1`)

```elixir
def create_category(attrs \\ %{})
```

**Example**:
```elixir
{:ok, category} = Content.create_category(%{
  name: "Cardiologia",
  description: "Especialidade médica dedicada ao coração",
  medical_specialty: :cardiology
  # compliance_required: true (auto-set)
  # crm_validation_required: true (auto-set)
})
```

---

### Custom Fields (ACF-style)

#### 1. Get Custom Fields (`get_custom_fields/1`)

```elixir
def get_custom_fields(post_id)
```

**Example**:
```elixir
fields = Content.get_custom_fields(post_id)
# => [
#   %CustomField{meta_key: "reading_time", meta_value: "5 min"},
#   %CustomField{meta_key: "evidence_level", meta_value: "1"},
#   %CustomField{meta_key: "author_crm", meta_value: "CRM/SP 123456"}
# ]
```

---

#### 2. Update Custom Field (`update_custom_field/3`)

```elixir
def update_custom_field(post_id, field_name, field_value)
```

**Upsert Behavior**: Creates if doesn't exist, updates if exists

**Example**:
```elixir
# Set reading time
Content.update_custom_field(post_id, "reading_time", "5 min")

# Set evidence level (medical)
Content.update_custom_field(post_id, "evidence_level", "1")

# Set author CRM
Content.update_custom_field(post_id, "author_crm", "CRM/SP 123456")
```

---

## 🏥 Healthcare-Specific Features

### Medical Categories

**10 Predefined Categories**:
```elixir
:general         # General health information
:cardiology      # Heart-related content
:neurology       # Brain/nervous system
:pediatrics      # Children's health
:surgery         # Surgical procedures
:pharmacy        # Medications, pharmacology
:radiology       # Imaging, diagnostics
:laboratory      # Lab tests, results
:emergency       # Emergency medicine
:preventive      # Preventive care, wellness
```

---

### Compliance Levels

**4 Levels of Access Control**:

| Level | Audience | Trust Score Required | CRM Validation |
|-------|----------|---------------------|----------------|
| `:public` | General public | 30+ | No |
| `:professional` | Healthcare professionals | 75+ | Yes |
| `:restricted` | Specialists only | 85+ | Yes |
| `:phi` | Direct patient care | 90+ | Yes + Patient consent |

**Example - Professional Content**:
```elixir
post = %Post{
  title: "Protocolo de Tratamento de Arritmia Ventricular",
  compliance_level: :professional,
  requires_crm_validation: true,
  medical_disclaimer: "Conteúdo exclusivo para médicos cardiologistas."
}
```

---

### Medical Disclaimer Requirements

**Required For**:
- All `:professional` level content
- All `:restricted` level content
- All `:phi` level content
- Any medical_category except `:general`

**Template Examples**:
```elixir
# Professional content
"Este conteúdo destina-se exclusivamente a profissionais de saúde devidamente habilitados. Não substitui o julgamento clínico individual."

# Restricted content
"Protocolo clínico restrito. Aplicação requer especialização em [specialty]. Consulte sempre as diretrizes atualizadas do CFM."

# PHI content
"Informações protegidas de saúde (PHI/PII). Acesso restrito ao corpo clínico responsável. LGPD Art. 7, I aplicável."
```

---

## 📊 Usage Examples

### Example 1: Create Medical Blog Post

```elixir
defmodule HealthcareCMSWeb.PostController do
  use HealthcareCMSWeb, :controller
  alias HealthcareCMS.Content

  def create(conn, %{"post" => post_params}) do
    user = conn.assigns.current_user

    # Validate user is medical professional
    unless User.medical_professional?(user) do
      conn
      |> put_status(403)
      |> json(%{error: "Only medical professionals can create content"})
      |> halt()
    end

    attrs = Map.merge(post_params, %{
      "author_id" => user.id,
      "tenant_id" => user.tenant_id,
      "medical_category" => "cardiology",
      "compliance_level" => "professional",
      "requires_crm_validation" => true,
      "medical_disclaimer" => "Conteúdo exclusivo para profissionais de saúde."
    })

    case Content.create_post(attrs) do
      {:ok, post} ->
        json(conn, %{
          id: post.id,
          title: post.title,
          slug: post.slug,
          status: post.status
        })

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> json(%{errors: translate_errors(changeset)})
    end
  end
end
```

---

### Example 2: Public Blog Listing (WordPress-style)

```elixir
defmodule HealthcareCMSWeb.BlogController do
  use HealthcareCMSWeb, :controller
  alias HealthcareCMS.Content

  def index(conn, params) do
    category_slug = params["category"]
    page = String.to_integer(params["page"] || "1")
    per_page = 10

    filters = [
      status: :published,
      order_by: :newest,
      limit: per_page
    ]

    filters = if category_slug do
      category = Content.get_category_by_slug(category_slug)
      Keyword.put(filters, :category_id, category.id)
    else
      filters
    end

    posts = Content.list_posts(filters)

    render(conn, "index.html",
      posts: posts,
      page: page,
      category: category_slug
    )
  end

  def show(conn, %{"slug" => slug}) do
    case Content.get_post_by_slug(slug) do
      nil ->
        conn
        |> put_status(404)
        |> render("404.html")

      post ->
        # Check access level based on compliance_level
        if can_access_post?(conn.assigns[:current_user], post) do
          render(conn, "show.html", post: post)
        else
          conn
          |> put_status(403)
          |> render("restricted.html", post: post)
        end
    end
  end

  defp can_access_post?(nil, %{compliance_level: :public}), do: true
  defp can_access_post?(nil, _), do: false
  defp can_access_post?(user, post) do
    # Check via Zero Trust Policy Engine
    PolicyEngine.can_access_content?(user, post)
  end
end
```

---

### Example 3: Custom Fields for Medical Metadata

```elixir
# After creating medical post
{:ok, post} = Content.create_post(%{...})

# Add medical metadata
Content.update_custom_field(post.id, "reading_time", "8 min")
Content.update_custom_field(post.id, "evidence_level", "1")  # Systematic review
Content.update_custom_field(post.id, "author_crm", "CRM/SP 123456")
Content.update_custom_field(post.id, "peer_reviewed", "true")
Content.update_custom_field(post.id, "citations_count", "15")
Content.update_custom_field(post.id, "last_updated_date", "2025-09-30")

# Retrieve metadata
fields = Content.get_custom_fields(post.id)
|> Enum.into(%{}, fn field -> {field.meta_key, field.meta_value} end)

# => %{
#   "reading_time" => "8 min",
#   "evidence_level" => "1",
#   "author_crm" => "CRM/SP 123456",
#   ...
# }
```

---

## 🧪 Testing

### Test Coverage

**Status**: ⚠️ ~40% (Content context - needs improvement)

**Planned Tests** (`test/healthcare_cms/content_test.exs`):
```elixir
defmodule HealthcareCMS.ContentTest do
  use HealthcareCMS.DataCase

  describe "list_posts/1" do
    # Test filtering by status, category, author
    # Test search functionality
    # Test ordering
  end

  describe "create_post/1" do
    # Test valid post creation
    # Test slug auto-generation
    # Test published_at auto-set
    # Test medical disclaimer validation
    # Test CRM validation requirement
  end

  describe "Post.changeset/2" do
    # Test compliance level validation
    # Test medical category validation
    # Test title/excerpt length validation
  end

  describe "categories" do
    # Test hierarchical categories
    # Test post counter increment/decrement
    # Test medical requirements auto-set
  end

  describe "custom_fields" do
    # Test upsert behavior
    # Test meta_key uniqueness
  end
end
```

**Target Coverage**: 85%+

---

## 🔗 Related Documentation

- **Accounts Context**: `./accounts-context.md`
- **Security / Zero Trust**: `../security/zero-trust-implementation.md`
- **Main Workflows**: `../../layer-1-overview/main-workflows.md` (Content creation workflow)
- **Key Concepts**: `../../layer-1-overview/key-concepts.md` (Medical workflows S.1.1)
- **Critical Warnings**: `../../_meta/critical-warnings.md` (LGPD compliance)

---

## 🚧 Roadmap

### Sprint 1 (Current)
- [x] Core Post/Category/CustomField schemas
- [x] WordPress-compatible API
- [x] Medical classification system
- [ ] Increase test coverage to 85%+

### Sprint 2
- [ ] Content versioning (audit trail)
- [ ] Medical workflow integration (S.1.1 → S.2.1)
- [ ] LGPD Analyzer integration (PHI detection)
- [ ] Scheduled publishing (cron job)

### Sprint 3+
- [ ] Full-text search (PostgreSQL tsvector)
- [ ] Content approval workflow
- [ ] Revision history (WordPress-style)
- [ ] Media processing (image optimization, thumbnails)
- [ ] RESTful API endpoints (JSON API)

---

**Version**: 1.0.0 | **Created**: 2025-09-30 | **Status**: 🔄 Active Development
