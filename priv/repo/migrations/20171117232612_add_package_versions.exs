defmodule NuPM.Repo.Migrations.AddPackageVersions do
  use Ecto.Migration

  def change do
    create table(:packages) do
      add :title, :string
      add :description, :string
      add :repository, :string
      add :website, :string
      add :author, :string
      add :author_email, :string
      add :license, :string

      timestamps()
    end

		create table(:versions) do
			add :number, :string
			add :readme, :string

			add :package_id, references(:packages)

			timestamps()
		end
  end
end
