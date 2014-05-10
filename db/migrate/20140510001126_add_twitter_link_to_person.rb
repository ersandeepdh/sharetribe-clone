class AddTwitterLinkToPerson < ActiveRecord::Migration
  def change
    add_column :people, :twitter_link, :string
  end
end
