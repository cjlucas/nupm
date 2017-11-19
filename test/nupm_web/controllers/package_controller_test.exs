defmodule NuPMWeb.PackageControllerTest do
  use NuPMWeb.ConnCase

  alias NuPM.Foo
  alias NuPM.Foo.Package

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  def fixture(:package) do
    {:ok, package} = Foo.create_package(@create_attrs)
    package
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all packages", %{conn: conn} do
      conn = get conn, package_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create package" do
    test "renders package when data is valid", %{conn: conn} do
      conn = post conn, package_path(conn, :create), package: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, package_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "title" => "some title"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, package_path(conn, :create), package: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update package" do
    setup [:create_package]

    test "renders package when data is valid", %{conn: conn, package: %Package{id: id} = package} do
      conn = put conn, package_path(conn, :update, package), package: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, package_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "title" => "some updated title"}
    end

    test "renders errors when data is invalid", %{conn: conn, package: package} do
      conn = put conn, package_path(conn, :update, package), package: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete package" do
    setup [:create_package]

    test "deletes chosen package", %{conn: conn, package: package} do
      conn = delete conn, package_path(conn, :delete, package)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, package_path(conn, :show, package)
      end
    end
  end

  defp create_package(_) do
    package = fixture(:package)
    {:ok, package: package}
  end
end
