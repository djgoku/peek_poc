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
      order = order_fixture(%{customer_id: customer.id})
      assert Organizations.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      customer = customer_fixture()
      order = order_fixture(%{customer_id: customer.id})
      assert Organizations.get_order!(order.id) == order
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
      assert order == Organizations.get_order!(order.id)
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
      payment = payment_fixture(%{order: order})
      assert Organizations.list_payments() == [payment]
    end

    test "get_payment!/1 returns the payment with given id" do
      payment = payment_fixture()
      assert Organizations.get_payment!(payment.id) == payment
    end

    test "create_payment/1 with valid data creates a payment" do
      valid_attrs = %{amount: 42, client_identifier: "some client_identifier"}

      assert {:ok, %Payment{} = payment} = Organizations.create_payment(valid_attrs)
      assert payment.amount == 42
      assert payment.client_identifier == "some client_identifier"
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
      payment = payment_fixture()
      update_attrs = %{amount: 43, client_identifier: "some updated client_identifier"}

      assert {:ok, %Payment{} = payment} = Organizations.update_payment(payment, update_attrs)
      assert payment.amount == 43
      assert payment.client_identifier == "some updated client_identifier"
    end

    test "update_payment/2 with invalid data returns error changeset" do
      payment = payment_fixture()
      assert {:error, %Ecto.Changeset{}} = Organizations.update_payment(payment, @invalid_attrs)
      assert payment == Organizations.get_payment!(payment.id)
    end

    test "delete_payment/1 deletes the payment" do
      payment = payment_fixture()
      assert {:ok, %Payment{}} = Organizations.delete_payment(payment)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_payment!(payment.id) end
    end

    test "change_payment/1 returns a payment changeset" do
      payment = payment_fixture()
      assert %Ecto.Changeset{} = Organizations.change_payment(payment)
    end
  end
end
