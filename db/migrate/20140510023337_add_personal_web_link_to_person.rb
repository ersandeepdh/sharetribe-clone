class AddPersonalWebLinkToPerson < ActiveRecord::Migration
  def change
    add_column :people, :personal_web_link, :string
  end
end
