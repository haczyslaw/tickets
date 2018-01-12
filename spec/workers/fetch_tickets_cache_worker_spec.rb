require 'rails_helper'

describe FetchTicketsCacheWorker do
  describe "#perform" do
    subject { FetchTicketsCacheWorker.new.perform }

    it "calls Ticket#all_with_cache_json" do
      expect(Ticket).to receive(:all_with_cache_json)

      subject
    end
  end
end
