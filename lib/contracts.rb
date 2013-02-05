require "contracts/version"

require "hash_deep_merge"
require "json"
require "json-generator"
require "webmock"
require "ostruct"

require "contracts/request"
require "contracts/response"
require "contracts/instantiated_contract"
require "contracts/contract"

module Contracts
  def self.register(host, contract_name, contract_path)
    definition = JSON.parse(File.read(contract_path))
    request = Request.new(host, definition["request"])
    response = Response.new(definition["response"])
    registered[contract_name] = Contract.new(request, response)
  end

  def self.use(contract_name, values = {})
    raise ArgumentError unless registered.has_key?(contract_name)
    instantiated_contract = registered[contract_name].instantiate(values)
    instantiated_contract.stub!
    instantiated_contract.response_body
  end

  def self.registered
    @registered ||= {}
  end
end
