defmodule NuPM.Repo.Migrations.AddVersionUploadPath do
  use Ecto.Migration

  def change do
    alter table(:versions) do
      add :upload_path, :string
    end
  end
end
