defmodule PeekPoc.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias PeekPoc.Repo
  alias Ecto.Multi

  alias PeekPoc.Organizations.Customer

  @doc """
  Returns the list of customers.

  ## Examples

      iex> list_customers()
      [%Customer{}, ...]

  """
  def list_customers do
    Repo.all(Customer)
  end

  @doc """
  Gets a single customer.

  Raises `Ecto.NoResultsError` if the Customer does not exist.

  ## Examples

      iex> get_customer!(123)
      %Customer{}

      iex> get_customer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_customer!(id), do: Repo.get!(Customer, id)

  @doc """
  Creates a customer.

  ## Examples

      iex> create_customer(%{field: value})
      {:ok, %Customer{}}

      iex> create_customer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_customer(attrs \\ %{}) do
    %Customer{}
    |> Customer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a customer.

  ## Examples

      iex> update_customer(customer, %{field: new_value})
      {:ok, %Customer{}}

      iex> update_customer(customer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_customer(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a customer.

  ## Examples

      iex> delete_customer(customer)
      {:ok, %Customer{}}

      iex> delete_customer(customer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_customer(%Customer{} = customer) do
    Repo.delete(customer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking customer changes.

  ## Examples

      iex> change_customer(customer)
      %Ecto.Changeset{data: %Customer{}}

  """
  def change_customer(%Customer{} = customer, attrs \\ %{}) do
    Customer.changeset(customer, attrs)
  end

  alias PeekPoc.Organizations.Order

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders()
      [%Order{}, ...]

  """
  def list_orders do
    Repo.all(Order) |> Enum.map(&add_order_current_balance/1)
  end

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(id), do: Repo.get!(Order, id) |> add_order_current_balance()

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order(123)
      %Order{}

      iex> get_order(456)
      ** (Ecto.NoResultsError)

  """
  def get_order(id), do: get_order!(id) |> Repo.preload(:payments)

  @doc """
  Gets all orders for a customer email.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_orders_for_customer("a@example.com")
      %Order{}

      iex> get_orders_for_customer("non-existant-customer@example.com")
      ** (Ecto.NoResultsError)

  """
  def get_orders_for_customer(email) do
    query =
      from(o in Order,
        join: c in Customer,
        on: o.customer_id == c.id,
        where: c.email == ^email,
        order_by: [desc: o.updated_at]
      )

    Repo.all(query) |> Repo.preload(:payments)
  end

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a order.

  ## Examples

      iex> update_order(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(order)
      %Ecto.Changeset{data: %Order{}}

  """
  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end

  alias PeekPoc.Organizations.Payment

  @doc """
  Returns the list of payments.

  ## Examples

      iex> list_payments()
      [%Payment{}, ...]

  """
  def list_payments do
    Repo.all(Payment)
    |> Repo.preload(:order)
  end

  @doc """
  Add a payment to an existing order.

  Raises `Ecto.NoResultsError` if the Payment does not exist.

  ## Examples

      iex> apply_payment_to_order(%Order{}, "client-identifier", 1)
      {:ok, :payment_made}

      iex> apply_payment_to_order(%Order{}, "client-identifier", 1)
      {:error, :hmm}

  """
  def apply_payment_to_order(order, payment_identifier, payment_amount) do
    order = add_order_current_balance(order) |> Repo.preload(:customer)

    # TODO we can do this better
    case order do
      o when o.current_balance + payment_amount <= o.original_cost ->
        case create_payment(%{
               order_id: order.id,
               client_identifier: payment_identifier,
               amount: payment_amount
             }) do
          {:ok, %Payment{}} -> {:ok, :payment_made}
          error -> error
        end

      o when o.current_balance + payment_amount > o.original_cost ->
        {:ok, :order_already_paid_in_full}
    end
  end

  @doc """
  Gets a single payment.

  Raises `Ecto.NoResultsError` if the Payment does not exist.

  ## Examples

      iex> get_payment!(123)
      %Payment{}

      iex> get_payment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_payment!(id), do: Repo.get!(Payment, id)

  @doc """
  Creates a payment.

  ## Examples

      iex> create_payment(%{field: value})
      {:ok, %Payment{}}

      iex> create_payment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_payment(attrs \\ %{}) do
    %Payment{}
    |> Payment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a payment.

  ## Examples

      iex> update_payment(payment, %{field: new_value})
      {:ok, %Payment{}}

      iex> update_payment(payment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_payment(%Payment{} = payment, attrs) do
    payment
    |> Payment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a payment.

  ## Examples

      iex> delete_payment(payment)
      {:ok, %Payment{}}

      iex> delete_payment(payment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_payment(%Payment{} = payment) do
    Repo.delete(payment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking payment changes.

  ## Examples

      iex> change_payment(payment)
      %Ecto.Changeset{data: %Payment{}}

  """
  def change_payment(%Payment{} = payment, attrs \\ %{}) do
    Payment.changeset(payment, attrs)
  end

  def add_order_current_balance(%Order{} = order) do
    order = order |> Repo.preload(:payments)

    current_balance =
      order.payments
      |> Enum.reduce(0, fn payment, acc -> payment.amount + acc end)

    %{order | current_balance: current_balance}
  end

  def create_order_and_pay(
        %Customer{} =
          customer,
        order_params,
        payment_params
      ),
      do: create_order_and_pay(customer |> Map.from_struct(), order_params, payment_params)

  def create_order_and_pay(customer, order_params, payment_params) do
    order_params = Map.put(order_params, :customer_id, customer.id)

    Multi.new()
    |> Multi.insert(:order, Order.changeset(%Order{}, order_params))
    |> Multi.insert(:payment, fn %{order: order} ->
      payment_params = Map.put(payment_params, :order_id, order.id)
      Payment.changeset(%Payment{}, payment_params)
    end)
    |> PeekPoc.Repo.transaction()
  end
end
