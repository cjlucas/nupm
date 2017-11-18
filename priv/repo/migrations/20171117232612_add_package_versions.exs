defmodule NuPM.Repo.Migrations.AddPackageVersions do
  use Ecto.Migration

  def change do
    create table(:packages) do
      add :title, :string

      timestamps()
    end

    create index(:packages, [:title], unique: true)

		create table(:versions) do
			add :number, :string
      add :metafile, :text
			add :readme, :text
      add :description, :text
      add :repository, :string
      add :website, :string
      add :author, :string
      add :author_email, :string
      add :license, :string

			add :package_id, references(:packages)

			timestamps()
		end

    create index(:versions, [:number, :package_id], unique: true)
  end
end
