defmodule NuPMWeb.PackageView do
  use NuPMWeb, :view
  alias NuPMWeb.PackageView

  def render("page.json", %{packages: packages, page_info: page_info}) do
    %{
      data: render_many(packages, __MODULE__, "show.json", as: :package),
      page_info: page_info,
    }
  end

  def render("show.json", %{package: package}) do
    Map.take(package, [
             :id,
             :title,
             :inserted_at,
             :updated_at,
         ])
    |> Map.put(:versions, Enum.map(package.versions, &Map.get(&1, :number)))
  end
end
