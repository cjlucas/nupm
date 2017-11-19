defmodule NuPMWeb.PackageControllerTest do
  use NuPMWeb.ConnCase

  alias NuPM.Repo

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all packages", %{conn: conn} do
      Repo.create_package(%{title: "foobar"})

      conn = get conn, package_path(conn, :index)
      resp = json_response(conn, 200)
      package = List.first(resp["data"])

      assert length(resp["data"]) == 1
      assert package["title"] == "foobar"

      assert Map.has_key?(resp, "page_info")
      assert get_in(resp, ["page_info", "total_results"]) == 1
      refute is_nil(get_in(resp, ["page_info", "next_url"]))
    end
  end

  describe "show" do
    test "failure on invalid package", %{conn: conn} do
      conn = get conn, package_path(conn, :show, "foobar")
      assert conn.status == 404
    end

    test "single package", %{conn: conn} do
      Repo.create_package(%{title: "foobar"})

      conn = get conn, package_path(conn, :show, "foobar")
      resp = json_response(conn, 200)
      assert resp["title"] == "foobar"
    end
  end
end
