defmodule PeekPoc.Organizations.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :original_cost, :integer
    field :customer_id, :id

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:original_cost])
    |> validate_required([:original_cost])
  end
end
