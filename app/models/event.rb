class Event < ActiveRecord::Base
  validates :title, :content, :starts_at, presence: true

  alias_attribute :start, :starts_at
  alias_attribute :end, :ends_at
end
