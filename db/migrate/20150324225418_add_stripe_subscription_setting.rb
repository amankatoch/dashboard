class AddStripeSubscriptionSetting < ActiveRecord::Migration
  def up
    Settings.create_with(value: nil).find_or_create_by(key: 'stripe_subscription_plan')
  end

  def down
    Settings.find_by(key: 'stripe_subscription_plan').destroy
  end
end
