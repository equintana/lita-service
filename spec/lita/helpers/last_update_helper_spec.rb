# frozen_string_literal: false
require 'spec_helper'

describe Lita::Helpers::LastUpdateHelper do
  let(:subject) { Lita::Helpers::LastUpdateHelper }
  let(:fake_time) { Time.parse('2016-12-23T19:51:57.918Z') }

  before do
    subject.extend(Lita::Helpers::LastUpdateHelper)
    allow(Time).to receive(:now).and_return(fake_time)
  end

  it '#update_last_changed_data' do
    # expect(subject.current_time).to eq "23/12/2016 19:51"
  end
end
