class AddCustomerIdToBraintreeAccount < ActiveRecord::Migration
  def change
    add_column :braintree_accounts, :customer_id, :string
  end
end
