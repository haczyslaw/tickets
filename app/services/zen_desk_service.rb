module ZenDeskService
  ENDPOINT = Rails.application.config_for(:zendesk)['endpoint']
  BASIC_AUTH = Rails.application.config_for(:zendesk)['basic_auth'] + Array(ENV['ZENDESK_TOKEN'])
  PERMITTED_ATTRIBUTES = %w(subject description)

  module_function

  def fetch_tickets
    uri = URI("https://#{ENDPOINT}/tickets")

    while uri
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new uri
        request.basic_auth(*BASIC_AUTH)

        response = http.request request
        if response.code.to_i < 200 || response.code.to_i >= 300
          uri = nil
          return false
        end

        response_hash = JSON.parse(response.body)
        update_tickets(response_hash['tickets']) if response_hash['tickets']
        uri = response_hash['next_page'] ? URI(response_hash['next_page']) : nil
      end
    end

    Rails.cache.delete('api_tickets')
    Ticket.all_with_cache_json
  end

  def create_ticket(params)
    uri = URI("https://#{ENDPOINT}/tickets")

    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    request.basic_auth(*BASIC_AUTH)
    request.body = { ticket: params }.to_json

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      response = http.request request
      OpenStruct.new(body: response.body, ticket: JSON.parse(response.body)['ticket'], code: response.code.to_i)
    end
  end

  private

  def self.update_tickets(tickets)
    tickets.each do |item|
      ticket = Ticket.find_by(external_id: item['id'])

      if ticket && ticket.attributes.slice(*PERMITTED_ATTRIBUTES) != item.slice(*PERMITTED_ATTRIBUTES)
        ticket.update_attributes(item.slice(*PERMITTED_ATTRIBUTES))
      elsif !ticket
        item['external_id'] = item['id']
        item.delete('id')
        Ticket.create(item.slice(*PERMITTED_ATTRIBUTES + ['external_id']))
      end
    end
  end
end
