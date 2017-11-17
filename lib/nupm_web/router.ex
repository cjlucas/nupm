defmodule NuPMWeb.Router do
  use NuPMWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", NuPMWeb do
    pipe_through :api
  end
end
