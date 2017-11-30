require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader' if development?
require 'zip'
require 'rubygems'
require 'fileutils'
require './db_func.rb'
require 'bcrypt'
require 'csv'


configure do
  enable :sessions
end


get '/' do
  @analytics = 0
  @files = []
  @filesnum = []
  @twoloop = []
  @websites = Website.all
  @websites.each do |webname|
    @files.push(webname.name)
    @filesnum.push(webname.numVotes)
  end
  @twoloop = @files.zip @filesnum
  @files.shuffle!

  if(session[:admin])
    redirect to("/Home")
  else
    erb :signin
  end
end



get '/Home' do
  @analytics = 0
  @userpn1 = []
  @setoff = 0
  @user = User.first(username: session[:name])
  if(@user)
    @usernumv = @user.numVotes
    @userp1 = @user.firstPlace
    @userp2 = @user.secondPlace
    @userp3 = @user.thirdPlace
    @userpn1.push(@user.firstPName)
    @userpn1.push(@user.secondPName)
    @userpn1.push(@user.thirdPName)
  end
  @files = []
  @filesnum = []
  @twoloop = []
  @websites = Website.all
  @websites.each do |webname|
    @files.push(webname.name)
    @filesnum.push(webname.numVotes)
  end
  @twoloop = @files.zip @filesnum

  if(session[:admin])
    erb :home
  else
    erb :signin
  end
end

get '/Members' do
  @analytics = 0
  @names = []
  @users = User.all
  @users.each do |person|
    if !(@names.include? person.username)
      if(person.username != 'admin')
        @names.push(person.username)
      end
    end
  end

  if(session[:admin])
    erb :members
  else
    erb :signin
  end
end

get '/Analytics' do
  @analytics = 1
  @files = []
  @filesnum = []
  @twoloop = []
  @websites = Website.all
  @websites.each do |webname|
    @files.push(webname.name)
    @filesnum.push(webname.numVotes)
  end
  @twoloop = @files.zip @filesnum
  @usernames = []
  @uservotes1 = []
  @uservotes2 = []
  @uservotes3 = []
  @uservotes11 = []
  @uservotes22 = []
  @uservotes33 = []
  @users = User.all
  session[:vote] = false
  @users.each do |person|
    if (person.numVotes < 3)
      session[:vote] = true
      @usernames.push(person.username)
      if (person.firstPName != "")
        @uservotes1.push(person.firstPName)
      else
        @uservotes1.push(nil)
      end
      if (person.secondPName != "")
        @uservotes2.push(person.secondPName)
      else
        @uservotes2.push(nil)
      end
      if (person.thirdPName != "")
        @uservotes3.push(person.thirdPName)
      else
        @uservotes3.push(nil)
      end
    end
  end
  print @uservotes1
  puts
  print @usernames
  puts
  @uservotes11 = @usernames.zip @uservotes1
  @uservotes22 = @usernames.zip @uservotes2
  @uservotes33 = @usernames.zip @uservotes3
  print @uservotes11
  puts

  if(session[:admin])
    erb :analytics
  else
    erb :signin
  end
end

get '/Uploads' do
  @analytics = 0
  if(session[:admin])
    erb :upload
  else
    erb :signin
  end
end

post '/Signin' do
  @analytics = 0
  web_user = User.first(username: params[:username])
  if params[:password] != '' and web_user
    password = BCrypt::Password.new(web_user.password)
    if web_user.username == params[:username] && password == params[:password]
      if(web_user.permissions == 1)
        session[:permissions] = true
      end
      session[:name] = web_user.username
      session[:admin] = true
      redirect to('/Home')
    else
      erb :signin
    end
  else
    erb :signin
  end
end

get '/Signout' do
  @analytics = 0
  session.clear
  erb :signin
end

post '/save_file' do
  if(params[:file])
    Dir.mkdir('uploads') unless File.exist?('uploads')
    File.open('uploads/file.zip', "w") do |f|
      f.write(params['file'][:tempfile].read)
    end
    Website.destroy
    @users = User.all
    @users.each do |person|
      person.numVotes = 3
      person.firstPlace = 0
      person.firstPName = ''
      person.secondPlace = 0
      person.secondPName = ''
      person.thirdPlace = 0
      person.thirdPName = ''
    end
    @users.save
    file = 'uploads/file.zip'
    FileUtils.remove_dir('uploads/' + params['file']) if File.exist?('uploads/file')
    extract_zip(file, 'uploads/')
    File.delete(file)
    FileUtils.remove_dir('uploads/__MACOSX') if File.exist?('uploads/__MACOSX')
    FileUtils.remove_dir('uploads/file/__MACOSX') if File.exist?('uploads/file/__MACOSX')
    FileUtils.remove_dir('uploads/.DS_Store') if File.exist?('uploads/.DS_Store')
    FileUtils.remove_dir('uploads/file/.DS_Store') if File.exist?('uploads/file/.DS_Store')
    @websites = Website.all
    @webnames = []
    @websites.each do |webname|
      @webnames.push(webname.name)
    end
    Dir['**/*'].each { |f|
      if f.include?(".html")
        puts f
        if @webnames.include?(f)
        else
         Website.create(name: f, numVotes: 0)
        end
      end
    }
    redirect to("/Home")
  else
    redirect to("/Uploads")
  end
end


post '/save_file2' do
  if(params[:file])
    Dir.mkdir('uploads') unless File.exist?('uploads')
    File.open('uploads/file.csv', "w") do |f|
      f.write(params['file'][:tempfile].read)
    end

    CSV.foreach('uploads/file.csv', quote_char: '"', col_sep: ',', row_sep: :auto, headers: true) do |row|
      puts row.length
      puts row[0]
      if (row.length == 3)
        if((row[0] == nil and row[1] == nil and row[2] == nil) or (row[0] == '' and row[1] == ''))
        else
          @users = User.all
          @usernames1 = []
          @users.each do |person|
            @usernames1.push(person.username)
          end

          if @usernames1.include?(row[0])
          else
            my_password = BCrypt::Password.create(row[1])
            User.create(username: row[0], password: my_password, permissions: row[2].to_i, numVotes: 3, firstPlace: 0, firstPName: '', secondPlace: 0, secondPName: '', thirdPlace: 0, thirdPName: '')
          end
        end
      end
    end
    redirect to("/Members")
  else
    redirect to("/Uploads")
  end
end


get '/uploads/:folder/:subfolder/:file' do
  @names
  @folder = params[:folder]
  @subfolder = params[:subfolder]
  @file = params[:file]

  File.read("uploads/#{@folder}/#{@subfolder}/#{@file}")
end

post '/vote/:name1/:name2/:name3/:file' do
  name1 = params[:name1]
  name2 = params[:name2]
  name3 = params[:name3]
  file = params[:file]
  @namedir = params[:name3]
  @vote = params[@namedir]

  @user = User.first(username: session[:name])
  if @user.numVotes != 0
    if @vote == '5'
      number = @user.numVotes.to_i
      @user.update(numVotes: number - 1)
      @user.update(firstPlace: 1)
      @user.update(firstPName: @namedir)
    end

    if @vote == '3'
      number = @user.numVotes.to_i
      @user.update(numVotes: number - 1)
      @user.update(secondPlace: 1)
      @user.update(secondPName: @namedir)
    end

    if @vote == '1'
      number = @user.numVotes.to_i
      @user.update(numVotes: number - 1)
      @user.update(thirdPlace: 1)
      @user.update(thirdPName: @namedir)
    end

    web = Website.first(name: name1 + '/' + name2 + '/' + name3 + '/'+ file )
    @vote = web.numVotes.to_i + @vote.to_i
    web.update(numVotes: @vote.to_i)
  end

  redirect to("/Home")
end

post '/downloadCsv' do
  CSV.open("download/report.csv", "wb") do |csv|
    csv << ["Student", "First Place", "Second Place", "Third Place"]
    @users = User.all
    @users.each do |person|
      if(person.firstPName == "" and person.secondPName == "" and person.thirdPName == "" )
      else
        csv << [person.username, person.firstPName, person.secondPName, person.thirdPName]
      end
    end
  end
  filename = "report.csv"
  send_file "download/report.csv", :filename => filename, :type => 'Application/octet-stream'
  redirect to("/Analytics")
end

post '/distroyUsers' do
  User.destroy
  my_password = BCrypt::Password.create('1')
  User.create(username: 'admin', password: my_password, permissions: 1, numVotes: 3, firstPlace: 0, firstPName: '', secondPlace: 0, secondPName: '', thirdPlace: 0, thirdPName: '')
  redirect to("/Uploads")
end
post '/distroyWebs' do
  Website.destroy
  redirect to("/Uploads")
end


#This code is used from https://stackoverflow.com/a/37195623
def extract_zip(file, destination)
  FileUtils.mkdir_p(destination)
  Zip::File.open(file) do |zip_file|
    zip_file.each do |f|
      fpath = File.join(destination, f.name)
      zip_file.extract(f, fpath) unless File.exist?(fpath)
    end
  end
end

