class BraintreeAccountMerchantData < ActiveRecord::Base
  belongs_to :braintree_account
  attr_accessible :account_number, :braintree_account_id, :routing_number, :ssn, :status
end