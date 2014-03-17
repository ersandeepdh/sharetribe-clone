class RemoveColumnsFromBrainTreeAccount < ActiveRecord::Migration
  def change
    remove_columns :braintree_accounts, :ssn
    remove_columns :braintree_accounts, :routing_number
    remove_columns :braintree_accounts, :account_number
    remove_columns :braintree_accounts, :status
  end
end
