require 'rails_helper'

RSpec.describe Api::V1::TicketsController, type: :controller do
  after { Ticket.delete_all }

  describe 'GET #index' do
    subject { get :index }

    let(:ticket_attributes) {  { subject: 'subject', description: 'description', external_id: 200 } }
    let!(:ticket) { Ticket.create(ticket_attributes) }

    it 'renders ticket list with one ticket' do
      subject

      expect(response.body).to eql([ticket_attributes].to_json)
      expect(response).to be_success
    end
  end

  describe 'POST #create' do
    subject { post :create, ticket_attributes }

    let(:ticket_attributes) {  { subject: 'subject', description: 'description' } }
    let(:ticket_hash_mock) { { ticket: ticket_attributes } }

    before do
      stub_const('ZenDeskService::ENDPOINT', 'www.zendesk.com')
      stub_const('ZenDeskService::BASIC_AUTH', %w(test test))
      stub_request(:post, 'https://test:test@www.zendesk.com/tickets').
        with(body: hash_including(ticket_hash_mock)).
        to_return(body: ticket_hash_mock.to_json, status: 201)
    end

    it 'calls ZenDesk Service' do
      expect(ZenDeskService).to receive(:create_ticket).with(ticket_attributes).and_call_original
      expect(FetchTicketsCacheWorker).to receive(:perform_async)

      subject
      expect(response).to be_success
    end
  end
end

