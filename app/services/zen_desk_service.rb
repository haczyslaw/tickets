module ZenDeskService
  ENDPOINT = Rails.config_for(:zendesk)['endpoint']
  BASIC_AUTH = Rails.config_for(:zendesk)['basic_auth']
  PERMITTED_ATTRIBUTES = %w(title body)

  module_function

  def fetch_tickets
    uri = URI("#{ENDPOINT}/tickets")

    while uri
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new uri

        response = http.request request
        if response.status < 200 || response.status >= 300
          uri = nil
          return
        end

        update_tickets(response.body['tickets']) if response.body['tickets']
        if response.body['next_page']
          uri = URI(response.body['next_page'])
        else
          uri = nil
        end
      end
    end

    Rails.cache.delete('api_tickets')
    Ticket.all_with_cache_json
  end

  def create_tickets(params)
    uri = URI("#{ENDPOINT}/tickets")

    request = Net::HTTP::Post.new(uri)
    request.basic_auth *BASIC_AUTH
    request.set_form_data(params)

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      response = http.request request
      response.status < 200 || response.status >= 300
    end
  end

  private

  def update_tickets(tickets)
    tickets.each do |item|
      ticket = Ticket.find_by(external_id: item['id'])

      if ticket && ticket.attributes.slice(*PERMITTED_ATTRIBUTES) != item.slice(*PERMITTED_ATTRIBUTES)
        ticket.update_attributes(item.slice(*PERMITTED_ATTRIBUTES))
      else
        item['external_id'] = item['id']
        Ticket.create(item.delete['id'])
      end
    end
  end
end
