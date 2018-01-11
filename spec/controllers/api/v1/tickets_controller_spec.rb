require 'rails_helper'

RSpec.describe Api::V1::TicketsController, type: :controller do
  after { Ticket.delete_all }

  describe 'GET #index' do
    let(:ticket_attributes) {  { title: 'title', body: 'body', external_id: 200 } }
    let!(:ticket) { Ticket.create(ticket_attributes) }
    subject { get :index }

    it 'renders ticket list with one ticket' do
      subject

      expect(response.body).to eql([ticket_attributes].to_json)
      expect(response).to be_success
    end
  end

  describe 'POST #create' do
    let(:ticket_attributes) {  { title: 'title', body: 'body' } }
    subject { post :create, ticket_attributes }

    it 'calls ZenDesk Service' do
      expect(ZenDeskService).to receive(:create_ticket).with(ticket_attributes).and_return(true)
      expect(FetchTicketsWorker).to receive(:perform_async)

      subject
      expect(response).to be_success
    end
  end
end

