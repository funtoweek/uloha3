#!/usr/bin/env ruby
# encoding:utf-8
require 'net/http'
require 'json'
require 'uri'
require 'pp'

module Facebook
  class << self
    def error(url,results)
      results <<
          {
            'host' => 'neznámy', # base domain,
            'url' => url,
            'like_count' => 'neznámy', # likes_count#
            'share_count' => 'neznámy' # shares_count#
          }
    end

    def known(url,json)
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
      facebook_api_url = 'http://api.facebook.com/'
      query = 'method/links.getStats?urls=#query#&format=json'
      results = []
      uri = URI(url)
      new_url = facebook_api_url + query.gsub(/#query#/, url)

      if valid_url?(uri, new_url)
        content = Net::HTTP.get(URI(new_url))
        json = JSON.parse(content)
        results = known(url,json)
      else
        error(url,results)
      end
      results
    end

  end
end
