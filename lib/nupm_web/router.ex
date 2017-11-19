defmodule NuPMWeb.Router do
  use NuPMWeb, :router

  alias NuPMWeb.FileController

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", NuPMWeb do
    pipe_through :api

    get "/packages", PackageController, :index
    get "/packages/:name", PackageController, :show
    get "/packages/:name/:version", VersionController, :show

    post "/users", UserController, :create

    post "/sessions", SessionController, :create
  end

  get "/downloads/:name/:version", FileController, :download
  post "/upload", FileController, :upload
end
