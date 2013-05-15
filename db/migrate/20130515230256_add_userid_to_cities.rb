class AddUseridToCities < ActiveRecord::Migration
  def change
    add_column :cities, :user_id, :integer
  end
end
