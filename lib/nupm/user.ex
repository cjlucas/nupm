defmodule NuPM.User do
  use NuPM.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    cs =
      user
      |> cast(params, [:email, :password, :password_hash])
      |> validate_required([:email, :password])
      |> unique_constraint(:email)
      |> add_hash
  end

  def add_hash(%Ecto.Changeset{valid?: true, changes: %{password: pw}} = cs) do
    change(cs, Comeonin.Bcrypt.add_hash(pw))
  end
  def add_hash(cs), do: cs
end
