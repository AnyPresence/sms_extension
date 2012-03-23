## Description

This is a Rails Engine gem for building out extensions for AnyPresence's extensions; it also provides plumbing for extensions to access Anypresence's platform API.

## Installation (only locally for now)

Build the gem with:
% rake install 

Copy the gem over to your project and unpack it into vendor/gems/

## Usage

A simple example can be done from IRB. 

@ap_client = AnypresenceExtension::Client.new('http://localhost:500', 'some_api_token', 'some_application_id', 'application_version')

### List available objects
@ap_client.metadata.fetch.to_json

Example:

stuff = @ap_client.metadata.fetch.to_json
names = stuff.map {|x| x["name"] }
 => ["Outage", "Department", "IncomingContact"]

### List metadata for a particular object definition

@ap_client.metadata('outage').fetch.to_json

- List object instances for a particular object definition
@ap_client.data('outage').fetch.to_json

Get next page:
@ap_client.resource.next_page

@ap_client.resource.fetch.to_json



