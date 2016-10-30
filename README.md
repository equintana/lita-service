# lita-service

[![Build Status](https://travis-ci.org/equintana/lita-service.png?branch=master)](https://travis-ci.org/equintana/lita-service)

TODO: Add a description of the plugin.

## Installation

Add lita-service to your Lita instance's Gemfile:

``` ruby
gem "lita-service"
```

## Configuration

TODO: Describe any configuration attributes the plugin exposes.

## Usage

First create a service with the command `create`, it accepts two parameters,
name and value*. The parameter value is optional, it will be set to 0 if nothing was passed.

```
 lita-service create < NAME > < *VALUE >

 lita-service create awesome-service
 lita-service create awesome-service 200
```
