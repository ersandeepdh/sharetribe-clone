class InsertMockItemsToDb < ActiveRecord::Migration
  def self.up
    item_data = []
    item_data[0] = {
      :owner_id => "Julia",  
      :title => "Kakkuvatkain", 
      :payment => 3
    }
    item_data[1] = {
      :owner_id => "Antti",
      :title => "Ketjunkatkaisin",
      :payment => 2
      
    }
    item_data[2] = {
      :owner_id => "Antti",
      :title => "Teltta",
      :payment => 3
    }
    item_data[3] = {
      :owner_id => "Julia",
      :title => "Teltta",
      :payment => 5
    }
    
    item_data.each do |info|
      item = Item.create(info)
    end
  end

  def self.down
  end
end