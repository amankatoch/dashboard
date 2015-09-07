class AddTransferInfoToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :transfer_id, :string
    add_column :payments, :transferred_at, :datetime
  end
end
