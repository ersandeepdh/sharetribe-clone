Feature: User creates a new listing
  In order to perform a certain task using an item, a skill, or a transport, or to help others
  As a person who does not have the required item, skill, or transport, or has them and wants offer them to others
  I want to be able to offer and request an item, a favor, a transport or housing
  
  @phantomjs_skip
  @javascript
  Scenario: Creating a new item request with image successfully
    Given I am logged in
    And I am on the home page
    When I follow "new-listing-link"
    And I follow "I need something"
    And I follow "An item"
    And I should see "What kind of an item are we talking about?"
    And I follow "Tools" within "#option-groups"
    And I should see "How do you want to get it?"
    And I follow "buy it"
    And I fill in "listing_title" with "Sledgehammer"
    And I fill in "listing_description" with "My description"
    And I attach a valid image file to "listing_listing_images_attributes_0_image"
    And I press "Save listing"
    Then I should see "Sledgehammer" within "#listing-title"
    And I should see the image I just uploaded
  
  @javascript
  Scenario: Creating a new item request without image successfully
    Given I am logged in
    And I am on the home page
    When I follow "new-listing-link"
    And I follow "I need something"
    And I follow "An item"
    And I should see "What kind of an item are we talking about?"
    And I follow "Tools" within "#option-groups"
    And I should see "How do you want to get it?"
    And I follow "buy it"
    And I fill in "listing_title" with "Sledgehammer"
    And I fill in "listing_description" with "My description"
    And I press "Save listing"
    Then I should see "Sledgehammer" within "#listing-title"

  @javascript
  Scenario: Creating a new item offer successfully
    Given I am logged in
    And I am on the home page
    When I follow "new-listing-link"
    And I follow "offer to others"
    And I follow "An item"
    And I follow "Tools" within "#option-groups"
    And I should see "How do you want to share it?"
    And I follow "lend"
    And I fill in "listing_title" with "My offer"
    And I fill in "listing_description" with "My description"
    And I press "Save listing"
    Then I should see "My offer" within "#listing-title"
  
  @javascript
  Scenario: Creating a new service request successfully
    Given I am logged in
    And I am on the home page
    When I follow "new-listing-link"
    And I follow "I need something"
    And I follow "a service"
    And I fill in "listing_title" with "Massage"
    And I fill in "listing_description" with "My description"
    And I press "Save listing"
    Then I should see "Massage" within "#listing-title"
  
  @javascript  
  Scenario: Creating a new rideshare request successfully
    Given I am logged in
    And I am on the home page
    When I follow "new-listing-link"
    And I follow "I need something"
    And I follow "shared ride"
    And I fill in "listing_origin" with "Otaniemi"
    And I fill in "listing_destination" with "Turku"
    And wait for 2 seconds
    And I press "Save listing"
    Then I should see "Otaniemi - Turku" within "#listing-title"
  
  @javascript  
  Scenario: Trying to create a new request without being logged in
    Given I am not logged in
    And I am on the home page
    When I follow "new-listing-link"
    And I should see "Log in to Sharetribe" within "h1"

  @phantomjs_skip
  @javascript
  Scenario: Trying to create a new item request with insufficient information
    Given I am logged in
    And I am on the home page
    When I follow "new-listing-link"
    And I follow "I need something"
    And I follow "An item"
    And I follow "Sports"
    And I follow "borrow it"
    And I attach an image with invalid extension to "listing_listing_images_attributes_0_image"
    And I select "31" from "listing_valid_until_3i"
    And I select "December" from "listing_valid_until_2i"
    And I select "2014" from "listing_valid_until_1i"
    And I press "Save listing"
    Then I should see "This field is required." 
    And I should see "This date must be between current time and 6 months from now." 
    And I should see "The image file must be either in GIF, JPG or PNG format." 
    
  @javascript  
  Scenario: Trying to create a new rideshare request with insufficient information
    Given I am logged in
    And I am on the home page
    When I follow "new-listing-link"
    And I follow "I need something"
    And I follow "shared ride"
    And I fill in "Origin" with "Test"
    And I choose "valid_until_select_date"
    And I select "31" from "listing_valid_until_3i"
    And I select "December" from "listing_valid_until_2i"
    And I select "2014" from "listing_valid_until_1i"
    And I press "Save listing"
    Then I should see "This field is required."
    And I should see "Departure time must be between current time and one year from now." 

  @javascript
  Scenario: User creates a listing and it is not visible in communities user joins
    Given there are following users:
      | person | 
      | kassi_testperson3 |
    And there is item request with title "Hammer" from "kassi_testperson3" and with share type "buy"
    And visibility of that listing is "all_communities"
    And I am on the homepage
    Then I should see "Hammer"
    When I move to community "test2"
    And I am on the homepage
    Then I should not see "Hammer"
    And I log in as "kassi_testperson3"
    And I check "community_membership_consent"
    And I press "Join community"
    And the system processes jobs
    And I am on the homepage
    Then I should not see "Hammer"

  @javascript
  Scenario: Create a new listing successfully after going back and forth in the listing form
    Given I am logged in
    And I am on the home page
    When I follow "new-listing-link"
    And I follow "I need something"
    And I should see "What do you need?"
    And I should see "Listing type: Request"
    And I follow "An item"
    And I should see "Listing type: Request"
    And I should see "Category: Item"
    And I should see "What kind of an item are we talking about?"
    And I follow "Tools" within "#option-groups"
    And I should see "Listing type: Request"
    And I should see "Category: Item"
    And I should see "Subcategory: Tools"
    And I should see "How do you want to get it?"
    And I follow "buy it"
    And I should see "Share type: Buying"
    And I should see "Item you need*"
    And I follow "Listing type: Request"
    And I should not see "Listing type: Request"
    And I should not see "Category: Item"
    And I should not see "Item you need*"
    And I should not see "Subcategory: Tools"
    And I should not see "Share type: Buying"
    And I follow "I have something to offer to others"
    And I follow "A shared ride"
    And I should see "Origin*"
    And I follow "Category: Rideshare"
    And I follow "A space"
    And I follow "I'm sharing it for free"
    And I follow "Share type: Sharing for free"
    And I follow "I'm selling it"
    And I should see "Space you offer*"
    And I fill in "listing_title" with "My offer"
    And I fill in "listing_price" with "20"
    And I fill in "listing_description" with "My description"
    And I press "Save listing"
    Then I should see "My offer" within "#listing-title"
  
  @javascript
  Scenario: User creates a new listing in a tribe with some custom categories
    Given I am logged in
    And I am on the home page
    When there are some custom categories
    And I follow "Post a new listing"
    Then I should see "I need something"
    And I should see "I have something to offer to others"
    When I follow "I need something"
    And I follow "An item - something tangible"
    Then I should see "Tools"
    And I should see "doll"
    When I follow "bottle"
    And I follow "buy it"
    Then I should see "Item you need*"
    When I follow "Category: Item"
    And I follow "wood"
    Then I should not see "doll"
    And I should see "lost"
    When I follow "found"
    Then I should see "Listing title*"
    And add default categories back
    
  @javascript
  Scenario: User creates a new listing in a tribe with only custom categories
    Given I am logged in
    And I am on the home page   
    When all categories are custom categories
    And I follow "Post a new listing"
    Then I should not see "I need something"
    And I should not see "I have something to offer to others"
    And I should see "plastic"
    And I should see "wood"
    When I follow "plastic"
    Then I should see "doll"
    And I should see "record"
    And I should see "bottle"
    When I follow "doll"
    Then I should see "Listing title*"
    When I follow "Category: plastic"
    And I follow "wood"
    Then I should not see "doll"
    And I should see "lost"
    And I should see "found"
    When I follow "lost"
    Then I should see "Listing title*"
    And add default categories back
  
  @javascript
  Scenario: User creates a new listing with price
    Given I am logged in
    When I create a new listing "Sledgehammer" with price
    Then I should see "Sledgehammer" within "#listing-title"
  
  @javascript
  Scenario: User creates a new listing with custom dropdown fields
    Given I am logged in
    And community "test" has custom fields enabled
    And there is a custom dropdown field "House type" in community "test" in category "housing" with options:
      | en             | fi                   |
      | Big house      | Iso talo             |
      | Small house    | Pieni talo           |
    And there is a custom dropdown field "Balcony type" in community "test" in category "housing" with options:
      | en             | fi                   |
      | No balcony     | Ei parveketta        |
      | French balcony | Ranskalainen parveke |
      | Backyard       | Takapiha             |
    And there is a custom dropdown field "Service type" in community "test" in category "favor" with options:
      | en             | fi                   |
      | Cleaning       | Siivous              |
      | Delivery       | Kuljetus             |
    And I am on the home page
    When I follow "new-listing-link"
    And I follow "offer to others"
    And I follow "A space"
    And I follow "I'm selling it"
    Then I should see "House type"
    And I should see "Balcony type"
    And I should not see "Service type"  
    When I fill in "listing_title" with "My house"
    And I press "Save listing"
    Then I should see 2 validation errors
    When custom field "Balcony type" is not required
    And I am on the home page
    And I follow "new-listing-link"
    And I follow "offer to others"
    And I follow "A space"
    And I follow "I'm selling it"
    And I fill in "listing_title" with "My house"
    And I press "Save listing"
    Then I should see 1 validation errors
    When I select "Big house" from dropdown "House type"
    And I press "Save listing"
    Then I should see "House type: Big house"
    
  @javascript
  Scenario: User creates a new listing with custom text field
    Given I am logged in
    And community "test" has custom fields enabled
    And there is a custom text field "Details" in community "test" in category "housing"
    When I follow "new-listing-link"
    And I follow "offer to others"
    And I follow "A space"
    And I follow "I'm selling it"
    And I fill in "listing_title" with "My house"
    And I fill in text field "Details" with "Test details"
    And I press "Save listing"
    And the Listing indexes are processed
    When I go to the home page
    And I fill in "q" with "Test details"
    And I press "search-button"
    Then I should see "My house"

  @javascript
  Scenario: User creates a new listing in private community
    Given I am logged in
    And community "test" is private
    And I am on the home page
    When I follow "new-listing-link"
    And I follow "I need something"
    And I follow "An item"
    And I should see "What kind of an item are we talking about?"
    And I follow "Tools" within "#option-groups"
    And I should see "How do you want to get it?"
    And I follow "buy it"
    Then I should not see "Privacy*"
    And I fill in "listing_title" with "Sledgehammer"
    And I fill in "listing_description" with "My description"
    And I press "Save listing"
    Then I should see "Sledgehammer" within "#listing-title"
    When I go to the home page
    Then I should see "Sledgehammer"
    When I log out
    And I go to the home page
    Then I should not see "Sledgehammer"
