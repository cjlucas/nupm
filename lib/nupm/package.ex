defmodule NuPM.Package do
  use Ecto.Schema

  schema "packages" do
    field :title, :string
    field :description, :string
    field :repository, :string
    field :website, :string
    field :author, :string
    field :author_email, :string
    field :license, :string

    has_many :versions, NuPM.Version
  end
end
