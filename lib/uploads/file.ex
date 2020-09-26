defmodule API.Uploads.File do
  use Arc.Definition
  use Arc.Ecto.Definition

  @acl :authenticated_read
  @versions [:original]
  @extension_whitelist ~w(.mp4, .mkv, .mp3, .doc, .docx, .ppt, .pptx, .pdf, .xls, .xlsx)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end

  def filename(version, {file, scope}) do
    file_name = Path.basename(file.file_name, Path.extname(file.file_name))
    "#{scope.id}_#{version}_#{file_name}"
  end

  # To make the destination file the same as the version:
  def filename(version, _), do: version

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  def s3_object_headers(version, {file, scope}) do
    [content_type: MIME.from_path(file.file_name)]
  end
end
