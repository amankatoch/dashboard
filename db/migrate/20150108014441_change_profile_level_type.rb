class ChangeProfileLevelType < ActiveRecord::Migration
  def up
    change_column :profiles, :level, :decimal, precision: 2, scale: 1
  end
  def down
    change_column :profiles, :level, :integer, limit: 1
  end
end
