require 'bundler'
require 'sinatra'
require 'sinatra/activerecord'
require 'pry'
require './config/environments'
require './lib/evernote_client.rb'
require './models/note.rb'
require './models/tag.rb'
require './models/user.rb'

enable :sessions

$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
require './evernote_config.rb'

helpers do
  def auth_token
    session[:access_token].token if session[:access_token]
  end

  def evernote_client
    @client ||= EvernoteClient.new(auth_token)
  end
end

get '/' do
  erb :index
end

get '/login' do
  erb :login
end

get '/register' do
  @username = params[:username] if params[:username]
  erb :register
end

post '/register' do
  if User.where(username: params[:username]).limit(1).count > 0
    redirect "/register?username=#{params[:username]}"
  else
    User.create!(username: params[:username], password: params[:password])
    redirect '/'
  end
end

get '/reset' do
  session.clear
  redirect '/'
end

get '/list' do
  begin
    session[:notebooks]   = evernote_client.notebooks.map(&:name)
    session[:username]    = evernote_client.user.username
    session[:total_notes] = evernote_client.total_note_count

    erb :index
  rescue => e
    @last_error = "Error listing notebooks: #{e.message}"
    erb :error
  end
end

get '/requesttoken' do
  callback_url = request.url.chomp('requesttoken').concat('callback')
  begin
    session[:request_token] = evernote_client.client.request_token(:oauth_callback => callback_url)
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
