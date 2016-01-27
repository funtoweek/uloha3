#!/usr/bin/env ruby
# encoding:utf-8
require 'net/http'
require 'json'
require 'uri'
require 'pp'

module Facebook
  class << self

    def error(url,results)
      unknown = 'neznámy'
      results <<
        {
          'host' => unknown, # base domain,
          'url' => url,
          'like_count' => unknown, # likes_count#
          'share_count' => unknown # shares_count#
        }
    end

    def valid_url?(url, uri, facebook_api_url, query)
      if uri.is_a?(URI::HTTP)
        begin
          URI(facebook_api_url + query.gsub(/#query#/, url))
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

      if valid_url?(url, uri, facebook_api_url, query)
          content = Net::HTTP.get(URI(facebook_api_url + query.gsub(/#query#/, url)))
          json = JSON.parse(content)
          results <<
            {
              'host' => uri.host, # base domain,
              'url' => url,
              'like_count' => json[0]['like_count'], # likes_count#
              'share_count' => json[0]['share_count'] # shares_count#
            }
        
      else
        error(url,results)
      end

      results

    end

  end
end
