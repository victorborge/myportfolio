class Admin::SettingsController < ApplicationController
  before_action :authenticate_admin!

  layout 'admin'

  def update
    @settings = params[:setting].to_hash

    @settings.each do |k,v|
      recursively_save_settings(k, v)
    end

    redirect_to edit_admin_settings_path, notice: 'Settings was successfully updated.'
  end

  private

  def recursively_save_settings(key, value_or_hash)
    if value_or_hash.is_a? Hash
      value_or_hash.each do |k, v|
        recursively_save_settings("#{key}.#{k}", v)
      end
    elsif value_or_hash.present?
      Setting[key.to_sym] = value_or_hash
    end
  end
end
