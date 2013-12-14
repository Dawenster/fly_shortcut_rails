class AddAddressToCity < ActiveRecord::Migration
  def change
    add_column :cities, :address, :string
  end
end
