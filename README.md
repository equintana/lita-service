# lita-service

[![Build Status](https://travis-ci.org/equintana/lita-service.png?branch=master)](https://travis-ci.org/equintana/lita-service)
[![Coverage Status](https://coveralls.io/builds/8637437/badge)](https://coveralls.io/builds/8637437)

Plugin to create a service with value or custom value per client and to manage how many times a customer use or consume this service.

## Installation

Add lita-service to your Lita instance's Gemfile:

``` ruby
gem "lita-service"
```

## Usage

``` sh
 lita service list
 lita service create        <NAME> <*VALUE>                 # Value will be set to 0 if empty.
 lita service show          <NAME>
 lita service delete|remove <NAME>

 lita service <NAME> inscribe      <CUSTOMER> <*VALUE>      # Value will be set to service's value if empty.
 lita service <NAME> delete|remove <CUSTOMER>
 lita service <NAME> add|sum       <CUSTOMER> <*QUANTITY>   # Quantity will be set to 1 if empty.
 lita service <NAME> add|sum all   <*QUANTITY>              # Quantity will be set to 1 if empty.
 lita service <NAME> value         <CUSTOMER> <VALUE>
 lita service <NAME> reset         <CUSTOMER>
```

To show the available commands
```
 lito help service
```

## Example

``` sh
 lita service list
 lita service create awesome-service 200
 lita service show awesome-service
 lita service delete awesome-service
 lita service remove awesome-service

 lita service awesome-service inscribe erlinis
 lita service awesome-service add erlinis 2
 lita service awesome-service sum erlinis 2
 lita service awesome-service add all 3
 lita service awesome-service sum all 3
 lita service awesome-service delete erlinis
 lita service awesome-service remove erlinis
 lita service awesome-service value erlinis 300
 lita service awesome-service reset erlinis
```
