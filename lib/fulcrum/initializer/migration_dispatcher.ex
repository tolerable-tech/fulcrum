defmodule Fulcrum.Initializer.MigrationDispatcher do
  def run do
    repo = Application.get_env(:fulcrum, Fulcrum.Repo)

    acc_request = %{
      "type" => "ecto_migrator",
      "migration_repo" => "https://github.com/tolerable-tech/fulcrum",
      "password" => Keyword.get(repo, :password),
      "user" => Keyword.get(repo, :username),
      "database" => Keyword.get(repo, :database),
      "url" => Keyword.get(repo, :hostname)
    }

    owner_opts = %AccompanimentManager.AccompaniableSpecification{owner_id: "fulcrum",
      component_name: "postgres",
      container_name: "fulcrum_postgresql",
      fleet_name: "postgresql.service"
    }

    AccompanimentManager.Api.launch(acc_request, owner_opts)
  end
end
