defmodule NuPM.PackageTest do
  use ExUnit.Case, async: true

  alias NuPM.{Repo,Package}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "create package" do
    params = %{title: "foobar"}
    cs = Package.changeset(%Package{}, params)

    assert {:ok, %Package{} = package} = Repo.insert(cs)

    assert is_binary(package.id)
    assert package.title == params[:title]
  end

  test "create package w/o title" do
    cs = Package.changeset(%Package{}, %{})
    assert {:error, _} = Repo.insert(cs)
  end

  test "create package w/ duplicate name" do
    cs = Package.changeset(%Package{}, %{title: "foobar"})
    {:ok, _} = Repo.insert(cs)

    assert {:error, _} = Repo.insert(cs)
  end
end
