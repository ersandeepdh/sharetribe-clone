#
# This class makes Braintree calls thread-safe even though we're using
# different configurations per Braintree call
#
class BraintreeService
  class << self

    @@mutex = Mutex.new
    
    def configure_for(community)
      Braintree::Configuration.environment = community.payment_gateway.braintree_environment.to_sym
      Braintree::Configuration.merchant_id = community.payment_gateway.braintree_merchant_id
      Braintree::Configuration.public_key = community.payment_gateway.braintree_public_key
      Braintree::Configuration.private_key = community.payment_gateway.braintree_private_key
    end
    
    def reset_configurations
      Braintree::Configuration.merchant_id = nil
      Braintree::Configuration.public_key = nil
      Braintree::Configuration.private_key = nil
    end
    
    # This method should be used for all actions that require setting correct
    # Merchant details for the Braintree gem
    def with_braintree_config(community, &block)
      @@mutex.synchronize {
        configure_for(community)

        return_value = block.call

        reset_configurations()

        return return_value
      }
    end


    def create_merchant_account(braintree_account, community)
      with_braintree_config(community) do
        Braintree::MerchantAccount.create(
            :applicant_details => {
              :first_name => braintree_account.first_name,
              :last_name => braintree_account.last_name,
              :email => braintree_account.email,
              :phone => braintree_account.phone,
              :address => {
                :street_address => braintree_account.address_street_address,
                :postal_code => braintree_account.address_postal_code,
                :locality => braintree_account.address_locality,
                :region => braintree_account.address_region
              },
              :date_of_birth => braintree_account.date_of_birth,
              :ssn => braintree_account.ssn,
              :routing_number => braintree_account.routing_number,
              :account_number => braintree_account.account_number
            },
            :tos_accepted => true,
            :master_merchant_account_id => master_merchant_id(community),
            :id => braintree_account.person_id
          )
      end
    end

    def transaction_sale(receiver, payment_params, amount, service_fee, community)
      with_braintree_config(community) do
        Braintree::Transaction.create(
          :type => "sale",
          :amount => amount.to_s,
          :merchant_account_id => receiver.id,
          :credit_card => {
            :number => payment_params[:credit_card_number],
            :expiration_month => payment_params[:credit_card_expiration_month],
            :expiration_year => payment_params[:credit_card_expiration_year],
            :cvv => payment_params[:cvv],
            :cardholder_name => payment_params[:cardholder_name],
          },
          :options => {
            :submit_for_settlement => true,
            :hold_in_escrow => false
          },
          :service_fee_amount => service_fee.to_s
        )
      end
    end

    def list_customer_cards(community, customer_id)
      return nil if customer_id.blank?
      with_braintree_config(community) do
        customer = Braintree::Customer.find(customer_id)
        return customer.credit_cards
      end
    end

    def add_card(community, customer_id, params)
      with_braintree_config(community) do
        result = Braintree::CreditCard.create(
          :customer_id => customer_id,
          :number => params[:number],
          :expiration_date => "#{params["date"]["month"]}/#{params["date"]["year"]}",
          :billing_address => {
            :first_name => params[:first_name],
            :last_name => params[:last_name],
            :company => params[:company],
            :street_address => params[:street_address],
            :extended_address => params[:extended_address],
            :locality => params[:locality],
            :region => params[:region],
            :postal_code => params[:postal_code],
            :country_code_alpha2 => params[:country_code_alpha2]
          }
        )
      end
    end

    def find_card(community, id)
      with_braintree_config(community) do
        return Braintree::CreditCard.find(id)
      end
    end

    def delete_card(community, id)
      with_braintree_config(community) do
        return Braintree::CreditCard.delete(id)
      end
    end

    def update_card(community, params)
      with_braintree_config(community) do
        result = Braintree::CreditCard.update(params[:id],
          :number => params[:number],
          :expiration_date => "#{params["date"]["month"]}/#{params["date"]["year"]}",
          :billing_address => {
            :first_name => params[:first_name],
            :last_name => params[:last_name],
            :company => params[:company],
            :street_address => params[:street_address],
            :extended_address => params[:extended_address],
            :locality => params[:locality],
            :region => params[:region],
            :postal_code => params[:postal_code],
            :country_code_alpha2 => params[:country_code_alpha2]
          }
        )
      end      
    end

    def make_default_card(community, id)
      with_braintree_config(community) do
        return Braintree::CreditCard.update(id, options:{make_default: true})
      end      
    end

    def create_customer(community, account)
      with_braintree_config(community) do
        return Braintree::Customer.create(
          :first_name => account.first_name,
          :last_name => account.last_name,
          :company => "ShareGrid SubMerchant",
          :email => account.email,
          :phone => account.phone,
          :fax => account.phone,
          :website => "www.sharegrid.com"
        )
      end
    end
    
    def master_merchant_id(community)
      community.payment_gateway.braintree_master_merchant_id
    end
    
    def webhook_notification_verify(community, challenge)
      with_braintree_config(community) do
        Braintree::WebhookNotification.verify(challenge)
      end
    end

    def webhook_notification_parse(community, signature, payload)
      with_braintree_config(community) do
        Braintree::WebhookNotification.parse(signature, payload)
      end
    end

    def webhook_testing_sample_notification(community, kind, id)
      with_braintree_config(community) do
        Braintree::WebhookTesting.sample_notification(kind, id)
      end
    end
    
  end
end