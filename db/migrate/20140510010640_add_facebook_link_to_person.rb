class AddFacebookLinkToPerson < ActiveRecord::Migration
  def change
    add_column :people, :facebook_link, :string
  end
end
