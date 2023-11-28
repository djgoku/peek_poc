defmodule PeekPoc.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :original_cost, :integer
      add :customer_id, references(:customers, on_delete: :nothing)

      timestamps()
    end

    create index(:orders, [:customer_id])
  end
end
