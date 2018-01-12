class Api::V1::TicketsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    tickets = Ticket.all_with_cache_json

    render json: tickets
  end

  def create
    response = ZenDeskService.create_ticket(ticket_params)
    create_if_success(response.ticket, response.code)
    render status: response.code, json: response.body
  end

  private

  def create_if_success(ticket, code)
    return if code != 201

    Ticket.create(subject: ticket['subject'], description: ticket['description'], external_id: ticket['id'])
    FetchTicketsCacheWorker.perform_async
  end

  def ticket_params
    params.slice(:subject, :description)
  end
end
