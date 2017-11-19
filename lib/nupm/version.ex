defmodule NuPM.Version do
  use NuPM.Schema
  import Ecto.Changeset

  schema "versions" do
    field :number, :string, primary_key: true
    field :description, :string
    field :repository, :string
    field :website, :string
    field :author, :string
    field :author_email, :string
    field :license, :string
    field :metafile, :string
    field :readme, :string
    field :upload_path, :string

    belongs_to :package, NuPM.Package, primary_key: true

    timestamps()
  end

  def changeset(version, params \\ %{}) do
    version
    |> cast(params, [
      :description,
      :repository,
      :website,
      :author,
      :author_email,
      :license,
      :number,
      :readme,
      :package_id,
      :upload_path,
    ])
    |> validate_required([:number, :package_id, :upload_path])
    |> assoc_constraint(:package)
    |> foreign_key_constraint(:package_id)
    |> unique_constraint(:pkey, name: :versions_number_package_id_index)
  end

  def from_package_json(package_json) when is_map(package_json) do
    %{
      number: version(package_json),
      description: package_json["description"],
      website: package_json["homepage"],
      author: author_name(package_json),
      author_email: author_email(package_json),
      license: package_json["license"],
    }
  end

  defp version(%{"version" => version}) when is_binary(version), do: version
  defp version(_), do: "0.0.0"

  defp author_name(metadata) do
    case metadata["author"] do
      %{"name" => name} -> name
      name -> name
    end
  end

  defp author_email(metadata) do
    case metadata["author"] do
      %{"email" => email} -> email
      _ -> nil
    end
  end
end
