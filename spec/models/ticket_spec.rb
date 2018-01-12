require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:external_id) }
  end
end
