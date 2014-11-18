Feature: Validation

  Validation ensures that a external service conform to a Contract.

  Scenario: Validation via a rake task
    Given a file named "contracts/simple_contract.json" with:
      """
          {
          "request": {
            "http_method": "GET",
            "path": "/hello",
            "headers": { "Accept": "application/json" },
            "params": {}
          },

          "response": {
            "status": 200,
            "headers": { "Content-Type": "application/json" },
            "schema": {
              "description": "A simple response",
              "type": "object",
              "properties": {
                "message": { "type": "string" }
              }
            }
          }
        }
      """
      When I successfully run `bundle exec rake pacto:validate['http://localhost:8000','tmp/aruba/contracts/simple_contract.json']`
      Then the stdout should contain:
        """"
        Validating contracts against host http://localhost:8000
                 OK!  simple_contract.json
        1 valid contract
        """
