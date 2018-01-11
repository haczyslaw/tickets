class Ticket < ActiveRecord::Base
  validates :title, presence: true
  validates :body, presence: true
  validates :external_id, presence: true

  after_update :remove_cache
  after_create :remove_cache
  after_destroy :remove_cache

  # it can be encapsulled in cache object for example TicketCache#all_json

  def self.all_with_cache_json
    Rails.cache.fetch('api_tickets') do
      Ticket.find_each.as_json(only: %w(title body external_id))
    end
  end

  private

  def remove_cache
    Rails.cache.delete('api_tickets')
  end
end
