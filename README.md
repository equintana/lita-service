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
 lita service create <NAME> <*VALUE>                 # Value will be set to 0 if empty.
 lita service show   <NAME>
 lita service delete <NAME>

 lita service <NAME> inscribe <CUSTOMER> <*VALUE>    # Value will set to service's value if empty.
```

## Example

``` sh
 lita service create awesome-service 200
 lita service show awesome-service
 lita service delete awesome-service

 lita service awesome-service inscribe erlinis
```
