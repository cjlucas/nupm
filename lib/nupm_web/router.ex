defmodule NuPMWeb.Router do
  use NuPMWeb, :router

  alias NuPMWeb.FileController

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug NuPMWeb.APIAuth
  end

  scope "/api", NuPMWeb do
    pipe_through :api

    post "/users", UserController, :create
    post "/sessions", SessionController, :create

    scope "/" do
      pipe_through :api_auth

      get "/packages", PackageController, :index
      get "/packages/:name", PackageController, :show
      get "/packages/:name/:version", VersionController, :show
    end
  end

  get "/downloads/:name/:version", FileController, :download
  post "/upload", FileController, :upload
end
