require 'bundler'
require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require 'pry'

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'evernote_config.rb'

Dir[File.join(File.dirname(__FILE__), 'lib', '**', '*.rb')].each { |file| require file }
Dir[File.join(File.dirname(__FILE__), 'models', '**', '*.rb')].each { |file| require file }

enable :sessions

helpers do
  def auth_token
    session[:access_token].token if session[:access_token]
  end

  def evernote_client
    @client ||= EvernoteClient.new(auth_token)
  end

  def current_user
    User.find(session[:user_id]) if session[:user_id]
  end
end

# GET REQUESTS
get '/' do
  erb :index
end

get '/login' do
  error = params[:error] if params[:error]
  case error
  when /unmatching/
    @error = 'Email and password did not match'
  when /existence/
    error = error.split('-')
    @error = "Account with email, #{error[1]}, does not exist"
  when /unauthorized/
    @error = 'You attempted an action that requires authorization. Please log in first.'
  end

  erb :login
end

get '/logout' do
  session[:user_id] = nil
  redirect '/'
end

get '/register' do
  @email_taken = params[:email_taken] if params[:email_taken]
  erb :register
end

get '/sync_account' do
  @notebooks = Hash.new
  evernote_client.notebooks.each do |notebook|
    @notebooks[notebook.name.to_sym] = notebook.guid
  end

  erb :sync_account
end

get '/compare-tag-to-tag' do
  @tags = Tag.joins(:taggings)
    .where(user_id: session[:user_id])
    .select('tags.id, tags.name, COUNT(taggings.note_id) as count')
    .group('tags.id')
    .order('count desc').to_a

  erb :tag_to_tag_diagrams
end

get '/api' do
  content_type :json
  DiagramServices::CompareTagsAggregator.new(Tag.where(name: "game of thrones").first).test_method.to_json
end

# POST REQUESTS
post '/login' do
  begin
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      redirect '/'
    else
      redirect '/login?error=unmatching'
    end
  rescue ActiveRecord::RecordNotFound
    redirect "/login?error=existence-#{params[:email]}"
  end
end

post '/register' do
  if !User.find_by_email(params[:email])
    User.create!(email: params[:email], password: params[:password])
    redirect '/'
  else
    redirect "/register?username_taken=#{params[:email]}"
  end
end

post '/sync_account' do
  notebook_ids = params.values
  EvernoteAccountSyncer.new(evernote_client, session[:user_id],  notebook_ids).sync_account
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



# EVERNOTE AUTHENTICATION

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
    redirect '/sync_account'
  rescue => e
    @last_error = 'Error extracting access token'
    erb :error
  end
end
