require 'bundler'
require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './lib/evernote_client.rb'
require './models/note.rb'
require 'pry'
enable :sessions

$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
require './evernote_config.rb'

before do
  if OAUTH_CONSUMER_KEY.empty? || OAUTH_CONSUMER_SECRET.empty?
    halt '<span style="color:red">Before using this sample code you must edit evernote_config.rb /</a>.</span>'
  end
end

helpers do
  def auth_token
    session[:access_token].token if session[:access_token]
  end

  def client
    @client ||= EvernoteClient.instance.client(auth_token)
  end

  def en_user
    user_store.getUser(auth_token)
  end
end

get '/' do
  erb :index
end

get '/reset' do
  session.clear
  redirect '/'
end

get '/list' do
  begin
    # Get notebooks
    session[:notebooks] = client.notebooks.map(&:name)
    # Get username
    session[:username] = en_user.username
    # Get total note count
    session[:total_notes] = client.total_note_count
    erb :index
  rescue => e
    @last_error = "Error listing notebooks: #{e.message}"
    erb :error
  end
end

get '/requesttoken' do
  callback_url = request.url.chomp('requesttoken').concat('callback')
  begin
    session[:request_token] = client.request_token(:oauth_callback => callback_url)
    redirect '/authorize'
  rescue => e
    @last_error = "error obtaining temporary credentials: #{e.message}"
    erb :error
  end
end

get '/authorize' do
  if session[:request_token]
    redirect session[:request_token].authorize_url
  else
    @last_error = 'Request token not set.'
    erb :error
  end
end

get '/callback' do
  unless params['oauth_verifier'] || session['request_token']
    @last_error = "content owner did not authorize the temporary credentials"
    halt erb :error
  end
  session[:oauth_verifier] = params['oauth_verifier']
  begin
    session[:access_token] = session[:request_token].get_access_token(:oauth_verifier => session[:oauth_verifier])
    redirect '/list'
  rescue => e
    @last_error = 'Error extracting access token'
    erb :error
  end
end
