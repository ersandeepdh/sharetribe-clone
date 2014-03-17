class AddRetailValueToListing < ActiveRecord::Migration
  def change
    add_column :listings, :retail_value, :integer
  end
end
