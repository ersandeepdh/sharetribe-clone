class BraintreeAccount < ActiveRecord::Base
  belongs_to :person
  has_one :braintree_account_merchant_data

  accepts_nested_attributes_for :braintree_account_merchant_data, allow_destroy: true

  validates_presence_of :person
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :address_street_address
  validates_presence_of :address_postal_code
  validates_presence_of :address_locality
  validates_presence_of :address_region

end