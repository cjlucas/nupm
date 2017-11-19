defmodule NuPMWeb.UserView do
  use NuPMWeb, :view

  def render("show.json", %{user: user}) do
    Map.take(user, [
             :id,
             :email,
             :inserted_at,
             :updated_at,
         ])
  end
end
