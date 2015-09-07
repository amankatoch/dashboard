class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.float :amount
      t.integer :status
      t.string :stripe_charge_id
      t.references :session_request, index: true

      t.timestamps
    end
  end
end
