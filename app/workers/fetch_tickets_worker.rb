class FetchTicketsWorker
  include Sidekiq::Worker

  def perform
    ZenDeskService.fetch_tickets
  end
end
