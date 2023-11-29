defmodule PeekPoc.OrganizationsTest do
  use PeekPoc.DataCase

  alias PeekPoc.Organizations

  defp create_order() do
    import PeekPoc.OrganizationsFixtures

    customer = customer_fixture()

    order_fixture(%{customer_id: customer.id})
    |> Map.from_struct()
    |> Map.take([:id, :customer_id, :original_cost])
  end

  defp create_payment_with_order(order) do
    import PeekPoc.OrganizationsFixtures

    payment_fixture(%{order_id: order.id})
  end

  describe "customers" do
    alias PeekPoc.Organizations.Customer

    import PeekPoc.OrganizationsFixtures

    @invalid_attrs %{email: nil}

    test "list_customers/0 returns all customers" do
      customer = customer_fixture()
      assert Organizations.list_customers() == [customer]
    end

    test "get_customer!/1 returns the customer with given id" do
      customer = customer_fixture()
      assert Organizations.get_customer!(customer.id) == customer
    end

    test "create_customer/1 with valid data creates a customer" do
      valid_attrs = %{email: "some email"}

      assert {:ok, %Customer{} = customer} = Organizations.create_customer(valid_attrs)
      assert customer.email == "some email"
    end

    test "create_customer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organizations.create_customer(@invalid_attrs)
    end

    test "update_customer/2 with valid data updates the customer" do
      customer = customer_fixture()
      update_attrs = %{email: "some updated email"}

      assert {:ok, %Customer{} = customer} = Organizations.update_customer(customer, update_attrs)
      assert customer.email == "some updated email"
    end

    test "update_customer/2 with invalid data returns error changeset" do
      customer = customer_fixture()
      assert {:error, %Ecto.Changeset{}} = Organizations.update_customer(customer, @invalid_attrs)
      assert customer == Organizations.get_customer!(customer.id)
    end

    test "delete_customer/1 deletes the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{}} = Organizations.delete_customer(customer)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_customer!(customer.id) end
    end

    test "change_customer/1 returns a customer changeset" do
      customer = customer_fixture()
      assert %Ecto.Changeset{} = Organizations.change_customer(customer)
    end
  end

  describe "orders" do
    alias PeekPoc.Organizations.Order

    import PeekPoc.OrganizationsFixtures

    @invalid_attrs %{original_cost: nil}

    test "list_orders/0 returns all orders" do
      customer = customer_fixture()
      order = order_fixture(%{customer_id: customer.id}) |> PeekPoc.Repo.preload(:payments)
      assert Organizations.list_orders() == [%{order | current_balance: 0}]
    end

    test "get_order!/1 returns the order with given id" do
      customer = customer_fixture()
      order = order_fixture(%{customer_id: customer.id})
      assert Organizations.get_order!(order.id) == %{order | current_balance: 0}
    end

    test "get_order/1 returns the order with given id" do
      customer = customer_fixture()
      order = order_fixture(%{customer_id: customer.id})
      assert Organizations.get_order!(order.id) == %{order | current_balance: 0}
    end

    test "get_orders_for_customer/1 returns all orders for a given email" do
      customer = customer_fixture()
      order = order_fixture(%{customer_id: customer.id})
      assert Organizations.get_orders_for_customer(customer.email) == [order]
    end

    test "create_order/1 with valid data creates a order" do
      customer = customer_fixture()
      valid_attrs = %{original_cost: 42, customer_id: customer.id}

      assert {:ok, %Order{} = order} = Organizations.create_order(valid_attrs)
      assert order.original_cost == 42
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organizations.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      customer = customer_fixture()
      order = order_fixture(%{customer_id: customer.id})
      update_attrs = %{original_cost: 43}

      assert {:ok, %Order{} = order} = Organizations.update_order(order, update_attrs)
      assert order.original_cost == 43
    end

    test "update_order/2 with invalid data returns error changeset" do
      customer = customer_fixture()
      order = order_fixture(%{customer_id: customer.id})
      assert {:error, %Ecto.Changeset{}} = Organizations.update_order(order, @invalid_attrs)
      assert %{order | current_balance: 0} == Organizations.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      customer = customer_fixture()
      order = order_fixture(%{customer_id: customer.id})
      assert {:ok, %Order{}} = Organizations.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      customer = customer_fixture()
      order = order_fixture(%{customer_id: customer.id})
      assert %Ecto.Changeset{} = Organizations.change_order(order)
    end
  end

  describe "payments" do
    alias PeekPoc.Organizations.Payment

    import PeekPoc.OrganizationsFixtures

    @invalid_attrs %{amount: nil, client_identifier: nil}

    test "list_payments/0 returns all payments" do
      order = create_order()
      payment = create_payment_with_order(order)
      [payment] = Organizations.list_payments()
      assert order.id == payment.order_id
    end

    test "get_payment!/1 returns the payment with given id" do
      payment = create_order() |> create_payment_with_order()
      assert Organizations.get_payment!(payment.id) == payment
    end

    test "create_payment/1 with valid data creates a payment" do
      order = create_order()
      valid_attrs = %{amount: 42, client_identifier: "some client_identifier", order_id: order.id}

      assert {:ok, %Payment{} = payment} = Organizations.create_payment(valid_attrs)
      assert payment.amount == 42
      assert payment.client_identifier == "some client_identifier"
      assert order.id == payment.order_id
    end

    test "create_payment/1 when an existing payment has the same client_identifier does not create a payment" do
      order = create_order()
      valid_attrs = %{amount: 42, client_identifier: "some client_identifier", order_id: order.id}

      assert {:ok, %Payment{} = payment} = Organizations.create_payment(valid_attrs)

      assert {:error, changeset} = Organizations.create_payment(valid_attrs)
      assert "has already been taken" in errors_on(changeset).order_id
    end

    test "create_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organizations.create_payment(@invalid_attrs)
    end

    test "update_payment/2 with valid data updates the payment" do
      payment = create_order() |> create_payment_with_order()
      update_attrs = %{amount: 43, client_identifier: "some updated client_identifier"}

      assert {:ok, %Payment{} = payment} = Organizations.update_payment(payment, update_attrs)
      assert payment.amount == 43
      assert payment.client_identifier == "some updated client_identifier"
    end

    test "update_payment/2 with invalid data returns error changeset" do
      payment = create_order() |> create_payment_with_order()
      assert {:error, %Ecto.Changeset{}} = Organizations.update_payment(payment, @invalid_attrs)
      assert payment == Organizations.get_payment!(payment.id)
    end

    test "delete_payment/1 deletes the payment" do
      order = create_order()
      payment = create_payment_with_order(order)
      assert {:ok, %Payment{}} = Organizations.delete_payment(payment)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_payment!(payment.id) end
    end

    test "change_payment/1 returns a payment changeset" do
      payment = create_order() |> create_payment_with_order()
      assert %Ecto.Changeset{} = Organizations.change_payment(payment)
    end
  end

  describe "apply_payments_to_order" do
    import PeekPoc.OrganizationsFixtures

    test "apply_payment_to_order/3 successful pay an order" do
      customer = customer_fixture()
      order = order_fixture(%{customer_id: customer.id})

      assert {:ok, :payment_made} = Organizations.apply_payment_to_order(order, "payment-1", 10)

      order = Organizations.get_order(order.id)
      assert order.current_balance == 10
      assert Enum.count(order.payments) == 1

      assert {:ok, :payment_made} = Organizations.apply_payment_to_order(order, "payment-2", 10)
      order = Organizations.get_order(order.id)
      assert order.current_balance == 20
      assert Enum.count(order.payments) == 2

      Organizations.apply_payment_to_order(order, "payment-2", 10)

      assert {:ok, :payment_made} = Organizations.apply_payment_to_order(order, "payment-3", 22)
      order = Organizations.get_order(order.id)
      assert order.current_balance == 42
      assert Enum.count(order.payments) == 3

      assert {:ok, :order_already_paid_in_full} =
               Organizations.apply_payment_to_order(order, "payment-4", 1)

      order = Organizations.get_order(order.id)
      assert order.current_balance == 42
      assert Enum.count(order.payments) == 3
    end
  end

  describe "create_order_and_pay" do
    import PeekPoc.OrganizationsFixtures

    test "create_order_and_pay/3 happy path" do
      customer = customer_fixture()

      assert {:ok, %{order: order, payment: payment}} =
               Organizations.create_order_and_pay(customer, %{original_cost: 30}, %{
                 amount: 30,
                 client_identifier: "payment-1"
               })

      assert order.original_cost == 30
      assert order.customer_id == customer.id
      assert payment.client_identifier == "payment-1"
      assert payment.amount == 30
    end
  end
end
