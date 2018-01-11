module ZenDeskService
  ENDPOINT = Rails.application.config_for(:zendesk)['endpoint']
  BASIC_AUTH = Rails.application.config_for(:zendesk)['basic_auth']
  PERMITTED_ATTRIBUTES = %w(title body)

  module_function

  def fetch_tickets
    uri = URI("http://#{ENDPOINT}/tickets")

    while uri
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new uri

        response = http.request request
        if response.code.to_i < 200 || response.code.to_i >= 300
          uri = nil
          return false
        end

        response_hash = JSON.parse(response.body)
        update_tickets(response_hash['tickets']) if response_hash['tickets']
        if response_hash['next_page']
          uri = URI(response_hash['next_page'])
        else
          uri = nil
        end
      end
    end

    Rails.cache.delete('api_tickets')
    Ticket.all_with_cache_json
  end

  def create_tickets(params)
    uri = URI("http://#{ENDPOINT}/tickets")

    request = Net::HTTP::Post.new(uri)
    request.basic_auth(*BASIC_AUTH)
    request.set_form_data(params)

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      response = http.request request
      response.code.to_i >= 200 && response.code.to_i < 300
    end
  end

  private

  def self.update_tickets(tickets)
    tickets.each do |item|
      ticket = Ticket.find_by(external_id: item['id'])

      if ticket && ticket.attributes.slice(*PERMITTED_ATTRIBUTES) != item.slice(*PERMITTED_ATTRIBUTES)
        ticket.update_attributes(item.slice(*PERMITTED_ATTRIBUTES))
      else
        item['external_id'] = item['id']
        item.delete('id')
        Ticket.create(item)
      end
    end
  end
end
