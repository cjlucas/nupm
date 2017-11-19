defmodule NuPMWeb.VersionController do
  use NuPMWeb, :controller

  alias NuPM.{Repo, Package, Version}
  import Ecto.Query

  def show(conn, %{"name" => name, "version" => "latest"}) do
    case Repo.get_by(Package, title: name) do
      %Package{id: package_id} = package ->
        query = from v in Version,
          select: v.number,
          where: v.package_id == ^package_id,
          order_by: [desc: v.inserted_at],
          limit: 1

        case Repo.all(query) do
          nil ->
            send_resp conn, :not_found, ""
          [version_number] ->
            show(conn, %{"name" => name, "version" => version_number})
        end
      nil ->
        send_resp conn, :not_found, ""
    end
  end

  def show(conn, %{"name" => name, "version" => version}) do
    case Repo.get_by(Package, title: name) do
      %Package{id: package_id} = package ->
        case Repo.get_by(Version, package_id: package_id, number: version) do
          nil ->
            send_resp conn, :not_found, ""
          version ->
            render conn, "show.json", package: package, version: version
        end
      nil ->
        send_resp conn, :not_found, ""
    end
  end
end
