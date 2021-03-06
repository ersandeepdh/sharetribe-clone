Given /^there is (item|favor|housing) (offer|request) with title "([^"]*)"(?: from "([^"]*)")?(?: and with share type "([^"]*)")?(?: and with price "([^"]*)")?$/ do |category, type, title, author, share_type, price|
  share_type ||= type
  @listing = FactoryGirl.create(:listing, 
                               :category => find_or_create_category(category),
                               :title => title,
                               :share_type => find_or_create_share_type(share_type),
                               :author => (@people && @people[author] ? @people[author] : Person.first),
                               :communities => [Community.find_by_domain("test")],
                               :privacy => "public"
                               )
  if price
    @listing.update_attribute(:price, price) 
  end
  
end

Given /^there is rideshare (offer|request) from "([^"]*)" to "([^"]*)" by "([^"]*)"$/ do |type, origin, destination, author|
  @listing = FactoryGirl.create(:listing,
                               :category => find_or_create_category("rideshare"),
                               :origin => origin,
                               :destination => destination,
                               :author => @people[author],
                               :communities => [Community.find_by_domain("test")],
                               :share_type => find_or_create_share_type(type),
                               :privacy => "public"
                               )
end

Given /^that listing is closed$/ do
  @listing.update_attribute(:open, false)
end

Given /^visibility of that listing is "([^"]*)"$/ do |visibility|
  @listing.update_attribute(:visibility, visibility)
end

Given /^privacy of that listing is "([^"]*)"$/ do |privacy|
  @listing.update_attribute(:privacy, privacy)
end

Given /^that listing is visible to members of community "([^"]*)"$/ do |domain|
  @listing.communities << Community.find_by_domain(domain)
end

Given /^that listing has a description "(.*?)"$/ do |description|
  @listing.update_attribute(:description, description)
end

Then /^There should be a rideshare (offer|request) from "([^"]*)" to "([^"]*)" starting at "([^"]*)"$/ do |share_type, origin, destination, time|
  listings = Listing.find_all_by_title("#{origin} - #{destination}")
end

When /^there is one comment to the listing from "([^"]*)"$/ do |author|
  @comment = FactoryGirl.create(:comment, :listing => @listing, :author => @people[author])
end

Then /^the total number of comments should be (\d+)$/ do |no_of_comments|
  Comment.all.count.should == no_of_comments.to_i
end

When /^there are some custom categories$/ do
  community = Community.first
  parent_share_type = ShareType.find_by_name("request")
  parent_category = Category.find_by_name("item")
  top_category = Category.create(:name => "wood", :icon => "other")
  child_category = Category.create(:name => "doll", :icon => "other", :parent_id => parent_category.id)
  child_category2 = Category.create(:name => "record", :icon => "other", :parent_id => parent_category.id)
  child_category3 = Category.create(:name => "bottle", :icon => "other", :parent_id => parent_category.id)
  child_share_type = ShareType.create(:name => "lost", :icon => "other", :parent_id => parent_share_type.id)
  child_share_type2 = ShareType.create(:name => "found", :icon => "other", :parent_id => parent_share_type.id)
  
  CommunityCategory.create(:category_id => parent_category.id, :share_type_id => parent_share_type.id)
  CommunityCategory.create(:category_id => top_category.id, :share_type_id => parent_share_type.id)
  CommunityCategory.create(:category_id => top_category.id, :share_type_id => child_share_type.id)
  CommunityCategory.create(:category_id => top_category.id, :share_type_id => child_share_type2.id)
  CommunityCategory.create(:category_id => child_category.id)
  CommunityCategory.create(:category_id => child_category2.id)
  CommunityCategory.create(:category_id => child_category3.id)
  Rails.cache.clear
end

When /^all categories are custom categories$/ do
  CategoriesHelper.remove_all_categories_from_db
  community = Community.first
  parent_share_type = ShareType.create(:name => "offer", :icon => "offer")
  parent_category = Category.create(:name => "plastic", :icon => "other")
  top_category = Category.create(:name => "wood", :icon => "other")
  child_category = Category.create(:name => "doll", :icon => "other", :parent_id => parent_category.id)
  child_category2 = Category.create(:name => "record", :icon => "other", :parent_id => parent_category.id)
  child_category3 = Category.create(:name => "bottle", :icon => "other", :parent_id => parent_category.id)
  child_share_type = ShareType.create(:name => "lost", :icon => "other", :parent_id => parent_share_type.id)
  child_share_type2 = ShareType.create(:name => "found", :icon => "other", :parent_id => parent_share_type.id)
  
  CommunityCategory.create(:community_id => community.id, :category_id => parent_category.id, :share_type_id => parent_share_type.id)
  CommunityCategory.create(:community_id => community.id, :category_id => top_category.id, :share_type_id => parent_share_type.id)
  CommunityCategory.create(:community_id => community.id, :category_id => top_category.id, :share_type_id => child_share_type.id)
  CommunityCategory.create(:community_id => community.id, :category_id => top_category.id, :share_type_id => child_share_type2.id)
  CommunityCategory.create(:community_id => community.id, :category_id => child_category.id)
  CommunityCategory.create(:community_id => community.id, :category_id => child_category2.id)
  CommunityCategory.create(:community_id => community.id, :category_id => child_category3.id)
  Rails.cache.clear
end

Then /^add default categories back$/ do
  reset_categories_to_default
  Rails.cache.clear
end

When /^I save the listing$/ do
  steps %Q{
    And I press "Save listing"
  }
end

When /^I create a new listing "([^"]*)" with price$/ do |title|
  steps %Q{
    Given I am on the home page
    When I follow "new-listing-link"
    And I follow "I have something to offer to others"
    And I follow "An item"
    And I follow "Tools" within "#option-groups"
    And I follow "I'm selling it"
    And I fill in "listing_title" with "#{title}"
    And I fill in "listing_price" with "dsfsdf"
    And I press "Save listing"
    Then I should see "Price must be a whole number."
    When I fill in "listing_price" with "20"
    And I save the listing
  }
end

When /^I select that I want to sell housing$/ do
  steps %Q{
    And I follow "I have something to offer"
    And I follow "A space"
    And I follow "I'm selling it"
    Then I should see "Space you offer"
  }
end

When /^I fill in listing form with housing information$/ do
  steps %Q{
    And I fill in "listing_title" with "Nice appartment in the city centre"
    And I fill in "listing_price" with "10000"
  }
end

When /^I choose to view only share type "(.*?)"$/ do |share_type_name|
  steps %Q{
    When I click "#home_toolbar-select-share-type"
    And I follow "#{share_type_name}" within ".home-toolbar-share-type-menu"
  }
end


Given /^there is a dropdown field "(.*?)" for category "(.*?)" in community "(.*?)" with options:$/ do |field_title, category_name, community_domain, opts_table|
  @community = Community.find_by_domain(community_domain)
  @category = Category.find_by_name(category_name)
  @custom_field = FactoryGirl.build(:custom_dropdown_field, :community => @community)
  @custom_field.category_custom_fields << FactoryGirl.build(:category_custom_field, :category => @category, :custom_field => @custom_field)
  @custom_field.names << CustomFieldName.create(:value => field_title, :locale => "en")
  
  opts_table.hashes.each do |hash|
    title = CustomFieldOptionTitle.create(:value => hash[:title], :locale => "en")
    option = FactoryGirl.build(:custom_field_option, :titles => [title])
    @custom_field.options << option
  end

  @custom_field.save!
end


Given /^that listing has custom field "(.*?)" with value "(.*?)"$/ do |field_title, option_title|
  field = CustomFieldName.find_by_value!(field_title).custom_field
  option = CustomFieldOptionTitle.find_by_value!(option_title).custom_field_option
  value = FactoryGirl.build(:custom_field_value, :listing => @listing, :question => field)
  selection = CustomFieldOptionSelection.create!(:custom_field_value => value, :custom_field_option => option)
  value.custom_field_option_selections << selection
  value.save!
end

Given /^listing comments are in use in community "(.*?)"$/ do |community_domain|
  community = Community.find_by_domain(community_domain)
  community.update_attribute(:listing_comments_in_use, true)
end