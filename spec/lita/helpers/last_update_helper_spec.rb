# frozen_string_literal: false
require 'spec_helper'

describe Lita::Helpers::LastUpdateHelper do
  let(:subject) { Lita::Helpers::LastUpdateHelper }

  before do
    subject.extend(Lita::Helpers::LastUpdateHelper)
  end

  describe '#update_last_changed_data' do
    let(:service) do
      {
        name: 'service',
        customers: {
          erlinis: { quantity: 3, value: 2000 }
        }
      }
    end
    let(:fake_time) { Time.parse('2016-12-23T19:51:57.918Z') }
    let(:lita_user) { OpenStruct.new(id: '123', name: 'the-user') }

    it 'sets las updated data' do
      allow(Time).to receive(:now).and_return(fake_time)
      subject.update_last_changed_data(service, 'erlinis', lita_user)
      expect(service[:customers][:erlinis][:updated_at]).to eq(fake_time)
      expect(service[:customers][:erlinis][:updated_by]).to eq('the-user')
    end
  end
end
