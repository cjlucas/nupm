defmodule NuPMWeb.VersionController do
  use NuPMWeb, :controller

  alias NuPM.{Repo, Package, Version}
  import Ecto.Query

  def show(conn, %{"name" => name, "version" => "latest"}) do
    case Repo.get_latest_version(name) do
      {:ok, %Version{package: package} = version} ->
        render conn, "show.json", package: package, version: version
      {:error, :not_found} ->
        send_resp(conn, :not_found, "")
    end
  end

  def show(conn, %{"name" => name, "version" => version}) do
    case Repo.get_version(name, version) do
      {:ok, %Version{package: package} = version} ->
        render conn, "show.json", package: package, version: version
      {:error, :not_found} ->
        send_resp(conn, :not_found, "")
    end
  end
end
