defmodule NuPM.VersionTest do
  use ExUnit.Case, async: true

  alias NuPM.{Repo, Package, Version}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    cs = Package.changeset(%Package{}, %{title: "foobar"})
    package = Repo.insert!(cs)

    {:ok, %{package: package}}
  end

  test "create version", %{package: package} do
    cs = Version.changeset(%Version{}, %{package_id: package.id, number: "1.0.0"})
    assert {:ok, %Version{id: id}} = Repo.insert(cs)

    # Ensure our package.version relationship works
    package = Repo.preload(package, :versions)
    assert length(package.versions) == 1
    assert List.first(package.versions).id == id
  end

  test "create version w/ existing number", %{package: package} do
    cs = Version.changeset(%Version{}, %{package_id: package.id, number: "1.0.0"})
    assert {:ok, _} = Repo.insert(cs)
    assert {:error, _} = Repo.insert(cs)
  end

  test "create multiple versions for existing package", %{package: package} do
    cs1 = Version.changeset(%Version{}, %{package_id: package.id, number: "1.0.0"})
    cs2 = Version.changeset(%Version{}, %{package_id: package.id, number: "1.0.1"})
    assert {:ok, _} = Repo.insert(cs1)
    assert {:ok, _} = Repo.insert(cs2)

    package = Repo.preload(package, :versions)
    assert length(package.versions) == 2
  end

  test "create version w/o valid number", %{package: package} do
    cs = Version.changeset(%Version{}, %{package_id: package.id})
    assert {:error, _} = Repo.insert(cs)
  end

  test "create version w/ invalid reference to package" do
    cs = Version.changeset(%Version{}, %{package_id: "a7ac0e4f-485e-48a0-a831-50756dac64f6", number: "1.0.0"})
    assert {:error, _} = Repo.insert(cs)
  end
end
