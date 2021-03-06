# -*- encoding : utf-8 -*-
RSpec.shared_examples 'a contract' do
  before do
    Pacto.configuration.adapter = adapter
    allow(consumer_driver).to receive(:respond_to?).with(:execute).and_return true
    allow(provider_actor).to receive(:respond_to?).with(:build_response).and_return true
    Pacto.configuration.default_consumer.driver = consumer_driver
    Pacto.configuration.default_provider.actor = provider_actor
  end

  it 'is a type of Contract' do
    expect(subject).to be_a_kind_of(Pacto::Contract)
  end

  describe '#stub_contract!' do
    it 'register a stub for the contract' do
      expect(adapter).to receive(:stub_request!).with(contract)
      contract.stub_contract!
    end
  end

  context 'investigations' do
    let(:request) { Pacto.configuration.default_consumer.build_request contract }
    let(:fake_response) { Fabricate(:pacto_response) } # double('fake response') }
    let(:cop) { double 'cop' }
    let(:investigation_citations) { [double('investigation result')] }

    before do
      Pacto::Cops.active_cops.clear
      Pacto::Cops.active_cops << cop
      allow(cop).to receive(:investigate).with(an_instance_of(Pacto::PactoRequest), fake_response, contract).and_return investigation_citations
    end

    describe '#simulate_request' do
      before do
        allow(consumer_driver).to receive(:execute).with(an_instance_of(Pacto::PactoRequest)).and_return fake_response
      end

      it 'generates the response' do
        expect(consumer_driver).to receive(:execute).with(an_instance_of(Pacto::PactoRequest))
        contract.simulate_request
      end

      it 'returns the result of the validating the generated response' do
        expect(cop).to receive(:investigate).with(an_instance_of(Pacto::PactoRequest), fake_response, contract)
        investigation = contract.simulate_request
        expect(investigation.citations).to eq investigation_citations
      end
    end
  end

  describe '#matches?' do
    let(:request_pattern)  { double('request_pattern') }
    let(:request_signature)  { double('request_signature') }

    it 'delegates to the request pattern' do
      expect(Pacto::RequestPattern).to receive(:for).and_return(request_pattern)
      expect(request_pattern).to receive(:matches?).with(request_signature)

      contract.matches?(request_signature)
    end
  end
end
