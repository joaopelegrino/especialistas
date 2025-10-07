# File Upload Handling - Phoenix LiveView Upload

**DSM**: `L1_DOMAIN:ui_ux` | `L2_SUBDOMAIN:healthcare` | `L3_TECHNICAL:implementation`
**Layer**: 2 (Core) - File Upload & Storage
**Status**: ✅ Production (Sprint 0-1)
**Read Time**: ~10 minutes
**Codebase Evidence**: `lib/healthcare_cms_web/live/`, `config/config.exs`

---

## Overview

Healthcare CMS uses **Phoenix.LiveView.Upload** for file uploads with S3 storage integration. All medical images, DICOM files, and attachments are handled with PHI protection, virus scanning, and LGPD compliance.

**Key Features**:
- **Direct Upload**: Browser → S3 (no server intermediary)
- **Progress Tracking**: Real-time upload progress with LiveView
- **File Validation**: Size limits, MIME types, virus scanning
- **PHI Protection**: Encrypted storage, access control, audit logging
- **DICOM Support**: Medical imaging format (DICOM 3.0)
- **LGPD Compliance**: Data retention, consent verification, deletion

---

## Phoenix LiveView Upload Configuration

### 1. Upload Configuration

**LiveView module** with upload setup:
```elixir
defmodule HealthcareCMSWeb.PostLive.Form do
  use HealthcareCMSWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:images,
       accept: ~w(.jpg .jpeg .png .gif .webp),
       max_entries: 10,
       max_file_size: 10_000_000,  # 10 MB
       auto_upload: true,
       external: &presign_upload/2  # S3 presigned URL
     )
     |> allow_upload(:dicom,
       accept: ~w(.dcm .dicom),
       max_entries: 1,
       max_file_size: 100_000_000,  # 100 MB (DICOM files are large)
       auto_upload: true,
       external: &presign_dicom_upload/2
     )}
  end

  # S3 presigned URL for direct upload
  defp presign_upload(entry, socket) do
    uploads = socket.assigns.uploads
    bucket = "healthcare-cms-media-#{Mix.env()}"
    key = "posts/#{socket.assigns.post.id}/#{entry.client_name}"

    config = %{
      region: "us-east-1",
      access_key_id: Application.get_env(:ex_aws, :access_key_id),
      secret_access_key: Application.get_env(:ex_aws, :secret_access_key)
    }

    {:ok, presigned_url} =
      ExAws.Config.new(:s3, config)
      |> ExAws.S3.presigned_url(:put, bucket, key, expires_in: 3600)

    meta = %{
      uploader: "S3",
      key: key,
      url: presigned_url
    }

    {:ok, meta, socket}
  end

  defp presign_dicom_upload(entry, socket) do
    # Similar to presign_upload but for DICOM files
    # Store in separate bucket with stricter access controls
    bucket = "healthcare-cms-dicom-#{Mix.env()}"
    key = "dicom/#{socket.assigns.patient_id}/#{entry.client_name}"

    # ... (same presigned URL logic)
  end
end
```

### 2. Upload Template (HEEx)

**lib/healthcare_cms_web/live/post_live/form.html.heex**:
```heex
<div>
  <h2>Upload Medical Images</h2>

  <!-- Image Upload -->
  <div class="upload-section">
    <form id="image-upload-form" phx-submit="save" phx-change="validate">
      <div phx-drop-target={@uploads.images.ref} class="dropzone">
        <.live_file_input upload={@uploads.images} class="hidden" />

        <div class="upload-prompt">
          <svg><!-- Upload icon --></svg>
          <p>Drag and drop images here, or click to select</p>
          <p class="text-sm text-gray-500">
            Accepted formats: JPG, PNG, GIF, WebP (max 10 MB)
          </p>
        </div>
      </div>

      <!-- Upload Progress -->
      <%= for entry <- @uploads.images.entries do %>
        <div class="upload-entry">
          <div class="file-info">
            <p><%= entry.client_name %> (<%= format_bytes(entry.client_size) %>)</p>
            <.live_img_preview entry={entry} width="100" />
          </div>

          <!-- Progress Bar -->
          <div class="progress-bar">
            <div class="progress-fill" style={"width: #{entry.progress}%"}></div>
          </div>
          <p class="progress-text"><%= entry.progress %>%</p>

          <!-- Cancel Upload -->
          <button
            type="button"
            phx-click="cancel-upload"
            phx-value-ref={entry.ref}
            class="cancel-btn"
          >
            ✕ Cancel
          </button>

          <!-- Upload Errors -->
          <%= for err <- upload_errors(@uploads.images, entry) do %>
            <p class="error-message"><%= error_to_string(err) %></p>
          <% end %>
        </div>
      <% end %>

      <button type="submit" disabled={length(@uploads.images.entries) == 0}>
        Upload Images
      </button>
    </form>
  </div>

  <!-- DICOM Upload (Medical Imaging) -->
  <div class="upload-section mt-8">
    <h3>Upload DICOM Files (Medical Imaging)</h3>

    <div phx-drop-target={@uploads.dicom.ref} class="dropzone-dicom">
      <.live_file_input upload={@uploads.dicom} />
      <p>Drop DICOM file here (.dcm, .dicom) - Max 100 MB</p>
    </div>

    <%= for entry <- @uploads.dicom.entries do %>
      <div class="dicom-entry">
        <p><%= entry.client_name %></p>
        <div class="progress-bar">
          <div class="progress-fill" style={"width: #{entry.progress}%"}></div>
        </div>
      </div>
    <% end %>
  </div>

  <!-- Uploaded Files List -->
  <div class="uploaded-files mt-8">
    <h3>Uploaded Files</h3>
    <%= for file <- @uploaded_files do %>
      <div class="uploaded-file">
        <img src={file.url} alt={file.name} width="100" />
        <p><%= file.name %></p>
        <button phx-click="delete-file" phx-value-id={file.id}>Delete</button>
      </div>
    <% end %>
  </div>
</div>
```

### 3. LiveView Event Handlers

```elixir
defmodule HealthcareCMSWeb.PostLive.Form do
  # ... (mount and presign functions above)

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :images, fn %{key: key}, entry ->
        # File is already in S3 (direct upload)
        # Create database record
        {:ok, file} =
          HealthcareCMS.Content.create_media(%{
            filename: entry.client_name,
            content_type: entry.client_type,
            size: entry.client_size,
            s3_key: key,
            s3_bucket: "healthcare-cms-media-#{Mix.env()}",
            post_id: socket.assigns.post.id,
            uploaded_by_id: socket.assigns.current_user.id
          })

        # Audit logging (PHI access)
        HealthcareCMS.Audit.log_phi_access(
          socket.assigns.current_user.id,
          "media",
          file.id,
          "upload"
        )

        # Enqueue virus scan
        %{media_id: file.id}
        |> HealthcareCMS.Workers.VirusScanWorker.new()
        |> Oban.insert()

        {:ok, file}
      end)

    {:noreply,
     socket
     |> update(:uploaded_files, &(&1 ++ uploaded_files))
     |> put_flash(:info, "#{length(uploaded_files)} file(s) uploaded successfully")}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :images, ref)}
  end

  @impl true
  def handle_event("delete-file", %{"id" => id}, socket) do
    file = HealthcareCMS.Content.get_media!(id)

    # Delete from S3
    ExAws.S3.delete_object(file.s3_bucket, file.s3_key)
    |> ExAws.request()

    # Soft delete in database (LGPD compliance)
    HealthcareCMS.Content.delete_media(file)

    # Audit logging
    HealthcareCMS.Audit.log_phi_access(
      socket.assigns.current_user.id,
      "media",
      file.id,
      "delete"
    )

    {:noreply,
     socket
     |> update(:uploaded_files, &Enum.reject(&1, fn f -> f.id == id end))
     |> put_flash(:info, "File deleted successfully")}
  end

  # Error message helper
  defp error_to_string(:too_large), do: "File is too large (max 10 MB)"
  defp error_to_string(:not_accepted), do: "File type not accepted"
  defp error_to_string(:too_many_files), do: "Too many files (max 10)"
  defp error_to_string(:external_client_failure), do: "Upload failed (S3 error)"
  defp error_to_string(err), do: "Upload error: #{inspect(err)}"

  # Format bytes helper
  defp format_bytes(bytes) when bytes < 1024, do: "#{bytes} B"
  defp format_bytes(bytes) when bytes < 1_048_576, do: "#{Float.round(bytes / 1024, 1)} KB"
  defp format_bytes(bytes), do: "#{Float.round(bytes / 1_048_576, 1)} MB"
end
```

---

## S3 Integration

### 1. ExAws Configuration

**mix.exs**:
```elixir
defp deps do
  [
    {:ex_aws, "~> 2.5"},
    {:ex_aws_s3, "~> 2.5"},
    {:hackney, "~> 1.20"},
    {:sweet_xml, "~> 0.7"}
  ]
end
```

**config/runtime.exs**:
```elixir
if config_env() == :prod do
  config :ex_aws,
    access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
    secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
    region: System.get_env("AWS_REGION") || "us-east-1"

  config :ex_aws, :s3,
    scheme: "https://",
    host: "s3.amazonaws.com",
    region: System.get_env("AWS_REGION") || "us-east-1"
end
```

### 2. S3 Bucket Setup

**Bucket configuration** (via AWS CLI or Terraform):
```bash
# Create bucket
aws s3api create-bucket \
  --bucket healthcare-cms-media-prod \
  --region us-east-1

# Enable versioning (LGPD compliance - data retention)
aws s3api put-bucket-versioning \
  --bucket healthcare-cms-media-prod \
  --versioning-configuration Status=Enabled

# Enable encryption (PHI protection)
aws s3api put-bucket-encryption \
  --bucket healthcare-cms-media-prod \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Set lifecycle policy (LGPD retention - 20 years for medical records)
aws s3api put-bucket-lifecycle-configuration \
  --bucket healthcare-cms-media-prod \
  --lifecycle-configuration file://s3-lifecycle.json
```

**s3-lifecycle.json**:
```json
{
  "Rules": [
    {
      "Id": "DeleteOldVersions",
      "Status": "Enabled",
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 7300
      },
      "Filter": {
        "Prefix": ""
      }
    },
    {
      "Id": "ArchiveToColdStorage",
      "Status": "Enabled",
      "Transitions": [
        {
          "Days": 90,
          "StorageClass": "INTELLIGENT_TIERING"
        },
        {
          "Days": 365,
          "StorageClass": "GLACIER"
        }
      ],
      "Filter": {
        "Prefix": ""
      }
    }
  ]
}
```

### 3. S3 CORS Configuration

**Allow direct uploads from browser**:
```json
[
  {
    "AllowedHeaders": ["*"],
    "AllowedMethods": ["PUT", "POST", "GET"],
    "AllowedOrigins": [
      "https://healthcare-cms.example.com",
      "http://localhost:4000"
    ],
    "ExposeHeaders": ["ETag"],
    "MaxAgeSeconds": 3600
  }
]
```

**Apply CORS**:
```bash
aws s3api put-bucket-cors \
  --bucket healthcare-cms-media-prod \
  --cors-configuration file://s3-cors.json
```

---

## File Validation & Security

### 1. Virus Scanning (ClamAV)

**Background worker** for virus scanning:
```elixir
defmodule HealthcareCMS.Workers.VirusScanWorker do
  @moduledoc """
  Scan uploaded files for viruses using ClamAV.
  """

  use Oban.Worker,
    queue: :security,
    max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"media_id" => media_id}}) do
    media = HealthcareCMS.Content.get_media!(media_id)

    # Download file from S3
    {:ok, %{body: file_data}} =
      ExAws.S3.get_object(media.s3_bucket, media.s3_key)
      |> ExAws.request()

    # Scan with ClamAV
    case scan_file(file_data) do
      {:ok, :clean} ->
        HealthcareCMS.Content.update_media(media, %{virus_scanned: true, virus_found: false})
        :ok

      {:ok, :infected} ->
        # Delete infected file
        ExAws.S3.delete_object(media.s3_bucket, media.s3_key)
        |> ExAws.request()

        HealthcareCMS.Content.update_media(media, %{
          virus_scanned: true,
          virus_found: true,
          deleted_at: DateTime.utc_now()
        })

        # Alert security team
        HealthcareCMS.Alerts.send_security_alert(:virus_detected, media)

        {:error, :virus_detected}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp scan_file(file_data) do
    # ClamAV integration (via clamd socket or HTTP API)
    # Example using clamd TCP socket:
    case :gen_tcp.connect(~c"localhost", 3310, [:binary, active: false]) do
      {:ok, socket} ->
        :ok = :gen_tcp.send(socket, "zINSTREAM\0")
        :ok = :gen_tcp.send(socket, <<byte_size(file_data)::32>> <> file_data)
        :ok = :gen_tcp.send(socket, <<0::32>>)

        case :gen_tcp.recv(socket, 0, 5000) do
          {:ok, "stream: OK\0"} ->
            :gen_tcp.close(socket)
            {:ok, :clean}

          {:ok, response} ->
            :gen_tcp.close(socket)
            if String.contains?(response, "FOUND"), do: {:ok, :infected}, else: {:error, response}

          {:error, reason} ->
            :gen_tcp.close(socket)
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end
```

### 2. File Type Validation

**MIME type verification** (beyond file extension):
```elixir
defmodule HealthcareCMS.Content.FileValidator do
  @moduledoc """
  Validate file types using magic bytes (MIME type detection).
  """

  @allowed_image_types ~w(image/jpeg image/png image/gif image/webp)
  @allowed_dicom_types ~w(application/dicom)

  def validate_image_type(file_data) do
    case :mimerl.detect(file_data) do
      mime_type when mime_type in @allowed_image_types -> {:ok, mime_type}
      _ -> {:error, :invalid_mime_type}
    end
  end

  def validate_dicom_type(file_data) do
    # DICOM files start with "DICM" at byte offset 128
    case file_data do
      <<_::binary-size(128), "DICM", _::binary>> ->
        {:ok, "application/dicom"}

      _ ->
        {:error, :invalid_dicom_file}
    end
  end
end
```

### 3. Image Optimization

**Compress and resize images** before storage:
```elixir
defmodule HealthcareCMS.Content.ImageProcessor do
  @moduledoc """
  Process uploaded images (resize, compress, generate thumbnails).
  """

  def process_image(file_data, entry) do
    # Resize to max width 2000px (preserve aspect ratio)
    {:ok, resized} = Mogrify.open(file_data)
      |> Mogrify.resize_to_limit("2000x2000")
      |> Mogrify.format("jpg")
      |> Mogrify.quality("85")
      |> Mogrify.save()

    # Generate thumbnail (300x300)
    {:ok, thumbnail} = Mogrify.open(file_data)
      |> Mogrify.resize_to_fill("300x300")
      |> Mogrify.format("jpg")
      |> Mogrify.quality("80")
      |> Mogrify.save()

    {:ok, %{original: resized, thumbnail: thumbnail}}
  end
end
```

---

## DICOM File Handling

### 1. DICOM Parser

**Extract metadata from DICOM files**:
```elixir
defmodule HealthcareCMS.Medical.DICOMParser do
  @moduledoc """
  Parse DICOM files and extract medical metadata.
  """

  def parse_dicom(file_data) do
    # DICOM parsing (simplified - use a library like `dicom_ex` in production)
    case extract_metadata(file_data) do
      {:ok, metadata} ->
        # Validate medical metadata
        if valid_dicom_metadata?(metadata) do
          {:ok, metadata}
        else
          {:error, :invalid_dicom_metadata}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp extract_metadata(file_data) do
    # Extract DICOM tags (Patient Name, Study Date, Modality, etc.)
    # This is a simplified example - use a proper DICOM library
    {:ok, %{
      patient_id: extract_tag(file_data, "0010,0020"),
      study_date: extract_tag(file_data, "0008,0020"),
      modality: extract_tag(file_data, "0008,0060"),
      institution: extract_tag(file_data, "0008,0080")
    }}
  end

  defp extract_tag(file_data, tag) do
    # DICOM tag extraction logic
    # ...
  end

  defp valid_dicom_metadata?(metadata) do
    # Validate required DICOM fields
    metadata.patient_id != nil and metadata.study_date != nil
  end
end
```

### 2. DICOM Anonymization (PHI Protection)

**Remove PHI from DICOM files**:
```elixir
defmodule HealthcareCMS.Medical.DICOMAnonymizer do
  @moduledoc """
  Anonymize DICOM files by removing PHI tags.
  """

  @phi_tags [
    "0010,0010",  # Patient Name
    "0010,0020",  # Patient ID
    "0010,0030",  # Patient Birth Date
    "0010,0040",  # Patient Sex
    "0010,1010",  # Patient Age
    "0010,2160",  # Patient Ethnic Group
    "0010,21B0",  # Patient Religious Preference
    "0008,0080",  # Institution Name
    "0008,0081",  # Institution Address
    "0008,0090",  # Referring Physician Name
  ]

  def anonymize_dicom(file_data) do
    # Remove or redact PHI tags
    Enum.reduce(@phi_tags, file_data, fn tag, acc ->
      remove_tag(acc, tag)
    end)
  end

  defp remove_tag(file_data, tag) do
    # DICOM tag removal logic
    # ...
  end
end
```

---

## PHI Protection & LGPD Compliance

### 1. Access Control (Presigned URLs)

**Generate time-limited presigned URLs** for file access:
```elixir
defmodule HealthcareCMS.Content do
  def get_media_url(media, expires_in \\ 3600) do
    # Check user permission (Zero Trust)
    if can_access_media?(media) do
      # Generate presigned URL (expires in 1 hour)
      {:ok, url} =
        ExAws.S3.presigned_url(
          ExAws.Config.new(:s3),
          :get,
          media.s3_bucket,
          media.s3_key,
          expires_in: expires_in
        )

      {:ok, url}
    else
      {:error, :unauthorized}
    end
  end

  defp can_access_media?(media) do
    # Zero Trust policy check
    HealthcareCMS.ZeroTrust.PolicyEngine.authorize?(
      current_user(),
      :read,
      media
    )
  end
end
```

### 2. Audit Logging

**Log all PHI file access**:
```elixir
defmodule HealthcareCMS.Audit do
  def log_phi_access(user_id, resource_type, resource_id, action) do
    Repo.insert!(%AuditLog{
      user_id: user_id,
      resource_type: resource_type,
      resource_id: resource_id,
      action: action,
      ip_address: get_client_ip(),
      user_agent: get_user_agent(),
      timestamp: DateTime.utc_now()
    })
  end
end
```

---

## Best Practices

### ✅ DO

1. **Use direct uploads**: Browser → S3 (reduce server load)
2. **Validate file types**: Check MIME types, not just extensions
3. **Scan for viruses**: Use ClamAV or similar before storing
4. **Encrypt at rest**: Enable S3 server-side encryption (AES256)
5. **Generate thumbnails**: Optimize for faster loading
6. **Use presigned URLs**: Time-limited access to files
7. **Audit PHI access**: Log all file uploads/downloads (LGPD Art. 37)
8. **Implement retention**: S3 lifecycle policies (20 years for medical records)
9. **Anonymize DICOM**: Remove PHI tags from medical images
10. **Test upload limits**: Ensure max file size works in production

### ❌ DON'T

1. **Don't store files in application server**: Use S3, not local filesystem
2. **Don't trust file extensions**: Validate MIME types with magic bytes
3. **Don't skip virus scanning**: Malicious uploads can compromise system
4. **Don't allow unlimited uploads**: Set max file size (10 MB images, 100 MB DICOM)
5. **Don't expose S3 keys directly**: Use presigned URLs with expiration
6. **Don't forget CORS**: Configure S3 bucket for direct uploads
7. **Don't skip PHI sanitization**: Remove sensitive data from DICOM files
8. **Don't ignore failed uploads**: Implement retry logic with error messages
9. **Don't allow public S3 buckets**: All buckets should be private
10. **Don't forget LGPD deletion**: Implement hard delete after retention period

---

## References

- **[Phoenix.LiveView.Upload](https://hexdocs.pm/phoenix_live_view/uploads.html)** (L0_CANONICAL) - Upload system
- **[ExAws.S3](https://hexdocs.pm/ex_aws_s3)** (L0_CANONICAL) - S3 integration
- **[DICOM Standard](https://www.dicomstandard.org/)** (L0_CANONICAL) - Medical imaging format
- **[AWS S3 Encryption](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingEncryption.html)** (L0_CANONICAL) - Server-side encryption

---

**Status**: Production (Sprint 0-1)
**Healthcare Compliance**: PHI encryption, DICOM anonymization, LGPD retention (20 years)
**Storage**: AWS S3 with versioning, encryption, lifecycle policies
**File Types**: Images (JPG, PNG, GIF, WebP), DICOM (.dcm)
**Security**: Virus scanning (ClamAV), MIME validation, presigned URLs
