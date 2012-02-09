module ApplicationHelper
  def chameleon_stylesheet_link
    uri = CSS_URIS.last
    uri = "#{ENV['CHAMELEON_HOST'].strip.gsub(/\/+$/, '')}#{uri}"
    stylesheet_link_tag(uri)
  end
end
