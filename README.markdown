AnyPresence SMS Extension.

This extension makes it possible to send and receive SMS. It interacts with Twilio to provide this service.
Lifecycle events on object definitions can be set on the platform which allows outgoing SMS to be sent.

The user can configure what the message to be sent should look like and on what object definition. The 
message can be set using Liquid template's variable interpolation scheme, e.g. 
"outage at {{outage.zipcode}}" may evaluate to "outage at 02115" if "zipcode" is a valid attribute on an 
outage object definition.

Note: It will only work with the non-rails3 api version of the platform.

## Installation

### Resque
This extension uses resque. 

Start it with:

bundle exec rake resque:work QUEUE=*
