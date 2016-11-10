# frozen_string_literal: false
require 'spec_helper'

describe Lita::Helpers::MessagesHelper do
  let(:subject) { Object.new }
  let(:service) { 'TheService' }

  before do
    subject.extend(Lita::Helpers::MessagesHelper)
  end

  it '#duplicated' do
    msg = I18n.t('lita.handlers.service.errors.duplicated', service_name: service)
    expect(subject.msg_duplicated(service_name: service)).to eq msg
  end

  it '#not_found' do
    msg = I18n.t('lita.handlers.service.errors.not_found', service_name: service)
    expect(subject.msg_not_found(service_name: service)).to eq msg
  end

  it '#customer_not_found' do
    msg = I18n.t('lita.handlers.service.customer.not_found', service_name: service,
                                                             customer_name: 'erlinis')
    expect(subject.msg_customer_not_found(service_name: service,
                                          customer_name: 'erlinis')).to eq msg
  end
  it '#customer_duplicated' do
    msg = I18n.t('lita.handlers.service.customer.duplicated', service_name: service,
                                                              customer_name: 'erlinis')
    expect(subject.msg_customer_duplicated(service_name: service,
                                           customer_name: 'erlinis')).to eq msg
  end
end
