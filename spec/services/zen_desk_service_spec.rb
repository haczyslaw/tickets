require 'rails_helper'

RSpec.describe ZenDeskService do
  after { Ticket.delete_all }

  describe '.fetch_tickets' do
    subject { ZenDeskService.fetch_tickets }

    before do
      stub_const('ZenDeskService::ENDPOINT', 'www.zendesk.com')
      stub_const('ZenDeskService::BASIC_AUTH', %w(test test))
      stub_request(:get, 'https://test:test@www.zendesk.com/tickets').to_return(body: ticket_response_mock_1)
      stub_request(:get, 'https://test:test@www.zendesk.com/tickets?page=2').to_return(body: ticket_response_mock_2)
    end

    let!(:ticket_response_mock_1) do
      { next_page: 'https://www.zendesk.com/tickets?page=2', tickets: [{ description: 'description 1', subject: 'subject 1', id: 1 }] }.to_json
    end

    let!(:ticket_response_mock_2) do
      { tickets: [{ description: 'description 2', subject: 'subject 2', id: 2 }] }.to_json
    end

    context 'creacting new tickets' do
      it 'creates two tickets' do
        subject

        expect(Ticket.count).to eq(2)
      end
    end

    context 'updating existing ticket' do
      let(:ticket_attributes) {  { subject: 'Lorem', description: 'Ipsum', external_id: 2 } }
      let!(:ticket) { Ticket.create(ticket_attributes) }
      let(:ticket_after_update) { Ticket.find_by(external_id: 2) }

      it 'creates and updates tickets' do
        subject

        expect(ticket_after_update.subject).to eq('subject 2')
        expect(ticket_after_update.description).to eq('description 2')
        expect(Ticket.count).to eq(2)
      end
    end
  end

  describe '.create_ticket' do
    subject { ZenDeskService.create_ticket(ticket_request_hash) }

    before do
      stub_const('ZenDeskService::ENDPOINT', 'www.zendesk.com')
      stub_const('ZenDeskService::BASIC_AUTH', %w(test test))
      stub_request(:post, 'https://test:test@www.zendesk.com/tickets').
        with(body: hash_including(ticket_hash_mock)).
        to_return(body: ticket_hash_mock.to_json, status: 201)
    end

    let(:ticket_hash_mock) { { ticket: ticket_request_hash } }
    let(:ticket_request_hash) { { description: 'description', subject: 'subject' } }
    let(:struct_response) do
      OpenStruct.new(body: ticket_hash_mock.to_json, ticket: ticket_request_hash.stringify_keys, code: 201)
    end

    it { is_expected.to eq(struct_response) }

    it 'calls API endpoint' do
      expect_any_instance_of(Net::HTTP::Post).to receive(:basic_auth).with('test', 'test').and_call_original
      expect_any_instance_of(Net::HTTP::Post).to receive(:body=).with(ticket_hash_mock.to_json).and_call_original
      expect_any_instance_of(Net::HTTP).to receive(:request).with(an_instance_of(Net::HTTP::Post)).and_call_original
      subject
    end
  end
end
