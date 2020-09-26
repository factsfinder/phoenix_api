# Todo: instead of this, refactor the Uploads.File to process
# thumbnailing of images and leave other file types as it is.

defmodule API.Uploads.Image do
  use Arc.Definition
  use Arc.Ecto.Definition

  @acl :authenticated_read
  @versions [:original, :thumb]
  @extension_whitelist ~w(.jpg .jpeg .gif .png .svg)

  def validate({file, _}) do
    file_extension = get_file_name(file)
    Enum.member?(@extension_whitelist, file_extension)
  end

  def transform(:thumb, {file, scope}) do
    is_gif = get_file_name(file) == ".gif"
    is_svg = get_file_name(file) == ".svg"

    if !is_gif and !is_svg do
      {:convert, "-thumbnail 100x100^ -gravity center -extent 100x100 -format png", :png}
    else
      :noaction
    end
  end

  def filename(version, {file, scope}) do
    file_name = Path.basename(file.file_name, Path.extname(file.file_name))
    "#{scope.id}_#{version}_#{file_name}"
  end

  # To make the destination file the same as the version:
  def filename(version, _), do: version

  def default_url(:thumb) do
    "https://placehold.it/100x100"
  end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  def s3_object_headers(version, {file, scope}) do
    [content_type: MIME.from_path(file.file_name)]
  end

  defp get_file_name(file) do
    file.file_name |> Path.extname() |> String.downcase()
  end
end
