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
      :package_id])
    |> validate_required([:number, :package_id])
    |> assoc_constraint(:package)
    |> foreign_key_constraint(:package_id)
    |> unique_constraint(:pkey, name: :versions_number_package_id_index)
  end

  def from_package_json(package_json) when is_map(package_json) do
    %{
      number: package_json["version"],
      description: package_json["description"],
      website: package_json["homepage"],
      author: author_name(package_json),
      author_email: author_email(package_json),
      license: package_json["license"],
    }
  end

  def author_name(metadata) do
    case metadata["author"] do
      %{"name" => name} -> name
      name -> name
    end
  end

  def author_email(metadata) do
    case metadata["author"] do
      %{"email" => email} -> email
      _ -> nil
    end
  end
end
