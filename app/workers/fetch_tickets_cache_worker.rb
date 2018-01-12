class FetchTicketsCacheWorker
  include Sidekiq::Worker

  def perform
    Ticket.all_with_cache_json
  end
end
