class AddAgreementTokenToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :agreement_token, :string
  end
end
