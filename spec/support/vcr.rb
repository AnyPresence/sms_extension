require 'vcr'

VCR.config do |c|
  c.stub_with :webmock
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.allow_http_connections_when_no_cassette = true
end