#!/usr/bin/env ruby
# encoding:utf-8
require 'net/http'
require 'json'
require 'uri'
require 'pp'

module Facebook
  class << self
    FACEBOOK_API_URL = 'http://api.facebook.com/'
    QUERY = 'method/links.getStats?urls=#query#&format=json'
    def error(url, results)
      results <<
        {
          'host' => 'neznámy', # base domain,
          'url' => url,
          'like_count' => 'neznámy', # likes_count#
          'share_count' => 'neznámy' # shares_count#
        }
    end

    def known(url, json, results)
      results <<
        {
          'host' => URI(url).host, # base domain,
          'url' => url,
          'like_count' => json[0]['like_count'], # likes_count#
          'share_count' => json[0]['share_count'] # shares_count#
        }
    end

    def valid_url?(uri, new_url)
      if uri.is_a?(URI::HTTP)
        begin
          URI(new_url)
        rescue URI::InvalidURIError
          false
        end
      else
        false
      end
    end

    def url_stats(url)
      results = []
      uri = URI(url)
      new_url = FACEBOOK_API_URL + QUERY.gsub(/#query#/, url)

      if valid_url?(uri, new_url)
        content = Net::HTTP.get(URI(new_url))
        json = JSON.parse(content)
        known(url, json, results)
      else
        error(url, results)
      end
      results
    end
  end
end
