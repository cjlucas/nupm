defmodule NuPMWeb.VersionView do
  use NuPMWeb, :view
  alias NuPMWeb.PackageView

  def render("show.json", %{package: package, version: version}) do
    Map.take(version, [
               :description,
               :repository,
               :website,
               :author,
               :author_email,
               :license,
               :readme,
               :inserted_at,
               :updated_at,
             ])
    |> Map.put(:package, package.title)
    |> Map.put(:version, version.number)
  end
end
