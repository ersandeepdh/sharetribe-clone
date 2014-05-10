class AddLinkedinLinkToPerson < ActiveRecord::Migration
  def change
    add_column :people, :linkedin_link, :string
  end
end
