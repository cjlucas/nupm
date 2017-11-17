defmodule NuPM.Package do
  use NuPM.Schema
  import Ecto.Changeset

  schema "packages" do
    field :title, :string
    field :description, :string
    field :repository, :string
    field :website, :string
    field :author, :string
    field :author_email, :string
    field :license, :string

    has_many :versions, NuPM.Version
    
    timestamps()
  end

  def changeset(package, params \\ %{}) do
    package
    |> cast(params, [
      :title,
      :description,
      :repository,
      :website,
      :author,
      :author_email,
      :license
    ])
    |> validate_required([:title])
    |> unique_constraint(:title)
  end
end
