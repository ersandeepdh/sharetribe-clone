class CreateBraintreeAccountMerchantData < ActiveRecord::Migration
  def change
    create_table :braintree_account_merchant_datas do |t|
      t.string :ssn
      t.string :routing_number
      t.string :account_number
      t.string :status
      t.string :braintree_account_id

      t.timestamps
    end
  end
end
