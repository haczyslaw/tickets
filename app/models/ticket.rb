class Ticket < ActiveRecord::Base
  validates :title, presence: true
  validates :body, presence: true
  validates :external_id, presence: true

  # it can be encapsulled in cache object for example TicketCache#all_json

  def self.all_with_cache_json
    Rails.cache.fetch('api_tickets') do
      Ticket.find_each.as_json(only: %w(title body external_id))
    end
  end
end
