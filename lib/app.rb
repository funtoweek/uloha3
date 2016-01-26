# encoding: utf-8
require 'sequel'
require 'sinatra'
require 'slim'
require 'database'
require_relative './helpers/facebook'

class FacebookStats < Sinatra::Base
  include Facebook
  set :views, './views'
  set :public_folder, './public'
  set :method_override, true
  tlinks = DB[:Links]
  tstats = DB[:Stats]

  before do
    @author = 'Vlado'
    @year   = Time.now.year
  end

  helpers do
    def all_links
      @links = DB[:Links].all
    end
  end

  helpers do
    def edit_link(id)
      @link = DB[:Links].where('id=?', id).all[0]
    end
  end

  helpers do
    def stats
      @stats = DB[:Stats].all
    end
  end

  not_found do
    '404'
  end

  # #GET - homepage - get all links and form for adding new link
  get '/' do
    all_links
    slim :index
  end

  # #POST - add link
  post '/links' do
    link_id = tlinks.insert(:url => params[:url], :domain => Facebook.url_stats(params[:url])[0]['host'])
    link_stats = Facebook.url_stats(params[:url])[0]
    tstats.insert(:link_id => link_id, :like_count => link_stats['like_count'],
      :share_count => link_stats['share_count'])
    @stats = tstats
    all_links
    redirect back
  end

  # #DELETE - delete link
  delete '/link/:link' do
    tstats.where('link_id = ?', params['link']).delete
    tlinks.where('id =?', params['link']).delete
    all_links
    slim :index
  end

  # #GET - get links statistics
  get '/link/:link/stats' do
    @stats = tstats.where('link_id = ?', params['link'])
    slim :stats
  end

  # #GET - get form for edit link informations
  get '/link/:link' do
    edit_link(params['link'])
    slim :link_form
  end

  # #PUT - edit link information
  put '/link/:link' do
    tlinks.where('id=?', params['link']).update(:url => params[:url],
      :domain => Facebook.url_stats(params[:url])[0]['host'])
    link_stats = Facebook.url_stats(params[:url])[0]
    tstats.where('link_id = ?', params['link']).update(:like_count => link_stats['like_count'],
      :share_count => link_stats['share_count'])
    all_links
    slim :index
  end
end
