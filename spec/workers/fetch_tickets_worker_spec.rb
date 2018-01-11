require 'rails_helper'

describe FetchTicketsWorker do
  describe "#perform" do
    subject { FetchTicketsWorker.new.perform }

    it "calls ZenDeskService" do
      expect(ZenDeskService).to receive(:fetch_tickets).and_return(true)

      subject
    end
  end
end
