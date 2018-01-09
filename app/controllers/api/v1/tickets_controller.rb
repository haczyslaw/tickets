class Api::V1::TicketsController < ApplicationController
  def index
    @tickets = Ticket.all_with_cache_json

    render json: @tickets
  end

  def create
    ZenDeskService.create_ticket(ticket_params)
  end

  private

  def ticket_params
    params.slice(:title, :body)
  end
end
