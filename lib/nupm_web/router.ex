defmodule NuPMWeb.Router do
  use NuPMWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", NuPMWeb do
    pipe_through :api

    get "/packages", PackageController, :index
    get "/packages/:name", PackageController, :show
    get "/packages/:name/:version", VersionController, :show
  end
end
