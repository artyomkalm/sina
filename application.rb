require 'sinatra'
require 'json'

get '/:greet' do
  content_type :json
  { status: 'ok', message: params[:greet] }.to_json
end