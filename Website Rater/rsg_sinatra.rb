require 'sinatra'
require 'sinatra/reloader' if development?

session = 0
get '/' do
  if(session != 0)
    erb :home
  else
    erb :signin
  end
end

get '/:name' do
  if(session != 0)
    erb :home
  else
    erb :signin
  end
end

