class Api::V1::TicketsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @tickets = Ticket.all_with_cache_json

    render json: @tickets
  end

  def create
    created = ZenDeskService.create_ticket(ticket_params)
    FetchTicketsWorker.perform_async if created
    render json: { created: created }
  end

  private

  def ticket_params
    params.slice(:title, :body)
  end
end
