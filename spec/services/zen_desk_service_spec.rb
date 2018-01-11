require 'rails_helper'

RSpec.describe ZenDeskService do
  after { Ticket.delete_all }

  describe '.fetch_tickets' do
    subject { ZenDeskService.fetch_tickets }

    before do
      stub_const('ZenDeskService::ENDPOINT', 'www.zendesk.com')
      stub_request(:get, 'www.zendesk.com/tickets').to_return(body: ticket_response_mock_1)
      stub_request(:get, 'www.zendesk.com/tickets?page=2').to_return(body: ticket_response_mock_2)
    end

    let!(:ticket_response_mock_1) do
      { next_page: 'http://www.zendesk.com/tickets?page=2', tickets: [{ body: 'body 1', title: 'title 1', id: 1 }] }.to_json
    end

    let!(:ticket_response_mock_2) do
      { tickets: [{ body: 'body 2', title: 'title 2', id: 2 }] }.to_json
    end

    context 'creacting new tickets' do
      it 'creates two tickets' do
        subject

        expect(Ticket.count).to eq(2)
      end
    end

    context 'updating existing ticket' do
      let(:ticket_attributes) {  { title: 'Lorem', body: 'Ipsum', external_id: 2 } }
      let!(:ticket) { Ticket.create(ticket_attributes) }
      let(:ticket_after_update) { Ticket.find_by(external_id: 2) }

      it 'creates and updates tickets' do
        subject

        expect(ticket_after_update.title).to eq('title 2')
        expect(ticket_after_update.body).to eq('body 2')
        expect(Ticket.count).to eq(2)
      end
    end
  end

  describe '.create_tickets' do
    subject { ZenDeskService.create_tickets(ticket_request_hash) }

    before do
      stub_const('ZenDeskService::ENDPOINT', 'www.zendesk.com')
      stub_const('ZenDeskService::BASIC_AUTH', %w(test test))
      stub_request(:post, 'http://test:test@www.zendesk.com/tickets').with(body: hash_including(ticket_request_hash))
    end

    let(:ticket_request_hash) do
      { body: 'body', title: 'title' }
    end

    it { is_expected.to be }

    it 'calls API endpoint' do
      expect_any_instance_of(Net::HTTP::Post).to receive(:basic_auth).with('test', 'test').and_call_original
      expect_any_instance_of(Net::HTTP::Post).to receive(:set_form_data).with(ticket_request_hash).and_call_original
      expect_any_instance_of(Net::HTTP).to receive(:request).with(an_instance_of(Net::HTTP::Post)).and_call_original
      subject
    end
  end
end
