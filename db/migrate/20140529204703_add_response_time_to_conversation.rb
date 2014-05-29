class AddResponseTimeToConversation < ActiveRecord::Migration
  def change
    add_column :conversations, :response_time, :float
  end
end
