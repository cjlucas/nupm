defmodule NuPM.Version do
  use Ecto.Schema

  schema "versions" do
    field :number, :string
    field :readme, :string

    belongs_to :package, NuPM.Package
  end
end
