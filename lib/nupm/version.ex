defmodule NuPM.Version do
  use NuPM.Schema
  import Ecto.Changeset

  schema "versions" do
    field :number, :string
    field :readme, :string

    belongs_to :package, NuPM.Package

    timestamps()
  end

  def changeset(version, params \\ %{}) do
    version
    |> cast(params, [:number, :readme])
    |> validate_required([:number])
  end
end
