class BraintreeAccountsController < ApplicationController

  LIST_OF_STATES = [
      ['Alabama', 'AL'],
      ['Alaska', 'AK'],
      ['Arizona', 'AZ'],
      ['Arkansas', 'AR'],
      ['California', 'CA'],
      ['Colorado', 'CO'],
      ['Connecticut', 'CT'],
      ['Delaware', 'DE'],
      ['District of Columbia', 'DC'],
      ['Florida', 'FL'],
      ['Georgia', 'GA'],
      ['Hawaii', 'HI'],
      ['Idaho', 'ID'],
      ['Illinois', 'IL'],
      ['Indiana', 'IN'],
      ['Iowa', 'IA'],
      ['Kansas', 'KS'],
      ['Kentucky', 'KY'],
      ['Louisiana', 'LA'],
      ['Maine', 'ME'],
      ['Maryland', 'MD'],
      ['Massachusetts', 'MA'],
      ['Michigan', 'MI'],
      ['Minnesota', 'MN'],
      ['Mississippi', 'MS'],
      ['Missouri', 'MO'],
      ['Montana', 'MT'],
      ['Nebraska', 'NE'],
      ['Nevada', 'NV'],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      ['Ohio', 'OH'],
      ['Oklahoma', 'OK'],
      ['Oregon', 'OR'],
      ['Pennsylvania', 'PA'],
      ['Puerto Rico', 'PR'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      ['Tennessee', 'TN'],
      ['Texas', 'TX'],
      ['Utah', 'UT'],
      ['Vermont', 'VT'],
      ['Virginia', 'VA'],
      ['Washington', 'WA'],
      ['West Virginia', 'WV'],
      ['Wisconsin', 'WI'],
      ['Wyoming', 'WY']
    ]

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_change_payment_settings")
  end

  # Commonly used paths
  before_filter do |controller|
    @create_path = create_braintree_settings_payment_path(@current_user)
    @show_path = show_braintree_settings_payment_path(@current_user)
    @new_path = new_braintree_settings_payment_path(@current_user)
  end

  # New/create
  before_filter :ensure_user_does_not_have_account, :only => [:new, :create]

  # Edit/update
  before_filter :ensure_user_has_account, :only => [:show]

  before_filter :ensure_user_does_not_have_account_for_another_community

  skip_filter :dashboard_only

  def new
    @list_of_states = LIST_OF_STATES
    @braintree_account = create_new_account_object
    render locals: { form_action: @create_path }
  end

  def show
    @list_of_states = LIST_OF_STATES
    @braintree_account = BraintreeAccount.find_by_person_id(@current_user.id)

    if @braintree_account.present?
      @credit_cards = BraintreeService.list_customer_cards(@current_community, @braintree_account.customer_id)
    end

    @state_name, _ = LIST_OF_STATES.find do |state|
      name, code = state
      code == @braintree_account.address_region
    end

    render locals: { form_action: @create_path }
  end

  def create
    @list_of_states = LIST_OF_STATES
    braintree_params = params[:braintree_account]
      .merge(person: @current_user)
      .merge(community_id: @current_community.id)

    @braintree_account = BraintreeAccount.new(braintree_params)
    if @braintree_account.valid?
      merchant_account_result = BraintreeService.create_merchant_account(@braintree_account, @current_community)
    else
      flash[:error] = @braintree_account.errors.full_messages
      render :new, locals: { form_action: @create_path } and return
    end

    if merchant_account_result.success?
      log_info("Successfully created Braintree account for person id #{@current_user.id}")
      @braintree_account.status = merchant_account_result.merchant_account.status
      success = @braintree_account.save!
    else
      log_error("Failed to created Braintree account for person id #{@current_user.id}: #{merchant_account_result.message}")

      success = false
      error_string = "Your payout details could not be saved, because of following errors: "
      merchant_account_result.errors.each do |e|
        error_string << e.message + " "
      end
      flash[:error] = error_string
    end

    if success
      flash[:notice] = t("layouts.notifications.payment_details_add_successful")
      redirect_to @show_path
    else
      flash[:error] ||= t("layouts.notifications.payment_details_add_error")
      render :new, locals: { form_action: @create_path }
    end
  end

  def add_card
    @braintree_account = BraintreeAccount.find_by_person_id(@current_user.id)
    BraintreeService.add_card(@current_community, get_customer_id, params)

    render text: "ok"
  end

  private

  def get_customer_id
    if @braintree_account.customer_id.blank?
      new_customer_id = BraintreeService.create_customer(@current_community, @braintree_account).customer.id 
      @braintree_account.customer_id = new_customer_id
      @braintree_account.save
    end
    return @braintree_account.customer_id
  end

  # Before filter
  def ensure_user_does_not_have_account
    braintree_account = BraintreeAccount.find_by_person_id(@current_user.id)

    unless braintree_account.blank?
      flash[:error] = "Can not create a new Braintree account. You already have one"
      redirect_to @show_path
    end
  end

  # Before filter
  def ensure_user_has_account
    @braintree_account = BraintreeAccount.find_by_person_id(@current_user.id)

    if @braintree_account.blank?
      flash[:error] = "Illegal Braintree accout id"
      redirect_to @new_path
    end
  end

  # Before filter
  #
  # Support for multiple Braintree account in multipe communities
  # is not implemented. Show error.
  def ensure_user_does_not_have_account_for_another_community
    @braintree_account = BraintreeAccount.find_by_person_id(@current_user.id)

    if @braintree_account
      # Braintree account exists
      if @braintree_account.community_id.present? && @braintree_account.community_id != @current_community.id
        # ...but is associated to different community
        account_community = Community.find(@braintree_account.community_id)
        flash[:error] = "You have payment account for community #{account_community.name(I18n.locale)}. Unfortunately, you can not have payment accounts for multiple communities. You are unable to receive money from transactions in community #{@current_community.name(I18n.locale)}. Please contact administrators."

        error_msg = "User #{@current_user.id} tried to create a Braintree payment account for community #{@current_community.name(I18n.locale)} even though she has existing account for #{account_community.name(I18n.locale)}"
        log_error(error_msg)
        ApplicationHelper.send_error_notification(error_msg, "BraintreePaymentAccountError")
        redirect_to profile_person_settings_path
      end
    end
  end

  def create_new_account_object
    person = @current_user
    person_details = {
      first_name: person.given_name,
      last_name: person.family_name,
      email: person.confirmed_notification_email_to, # Our best guess for "primary" email
      phone: person.phone_number
    }

    BraintreeAccount.new(person_details)
  end

  def log_info(msg)
    logger.info "[Braintree] #{msg}"
  end

  def log_error(msg)
    logger.error "[Braintree] #{msg}"
  end
end