defmodule PeekPoc.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :amount, :integer
      add :client_identifier, :string
      add :order_id, references(:orders)

      timestamps()
    end

    create unique_index(:payments, [:order_id, :client_identifier])
  end
end
