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
end
