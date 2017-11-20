defmodule NuPM.Package do
  use NuPM.Schema
  import Ecto.Changeset

  @module_doc """
  A Package represents the entire history of a package, including every release
  of the package.
  """

  schema "packages" do
    field :title, :string

    has_many :versions, NuPM.Version

    timestamps()
  end

  def changeset(package, params \\ %{}) do
    package
    |> cast(params, [:title])
    |> validate_required([:title])
    |> unique_constraint(:title)
  end

  @spec latest_version(Package.t) :: Version.t | nil
  def latest_version(package) do
    package.versions
    |> Enum.sort_by(&(&1.inserted_at))
    |> Enum.reverse
    |> List.first
  end
end
