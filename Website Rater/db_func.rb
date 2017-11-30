require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/DataBase.db")

class User
  include DataMapper::Resource
  property :id, Serial
  property :username, String
  property :password, String
  property :permissions, Integer
  property :numVotes, Integer
  property :firstPlace, Integer
  property :firstPName, String
  property :secondPlace, Integer
  property :secondPName, String
  property :thirdPlace, Integer
  property :thirdPName, String

end

class Website
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :numVotes, Integer
end

DataMapper.finalize()
