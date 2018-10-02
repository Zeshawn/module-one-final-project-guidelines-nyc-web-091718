
class Cli



require 'json'
require 'rest-client'
  def initialize()
    @root = "http://ws.audioscrobbler.com/2.0/"
    @user = nil
    @artist = nil
  end
    def initialize_user
      puts "Would you like to connect your last.fm account? Type no if you do not have an account."
      input = gets.chomp
      if input.downcase == "no"
        puts "Enter your favorite three artists below, separated by commas."
        artist_array = gets.chomp.split(", ")
        artist_array.each do |artist|
          chosen_artist = Artist.find_or_create_by(name: artist)
          ua = UserArtist.create
          ua.user = @user
          ua.artist = chosen_artist
          ua.approval = true
          ua.save
        end
      else
        puts "Enter your lastfm username"
        lastfmusername = gets.chomp
        # puts "Please enter your lastfm username"
        get_user_top_artist(lastfmusername)
        puts "Ok!"
      end
    end

    def get_user_top_artist(username)
      url = "#{@root}?method=user.gettopartists&user=#{username}&api_key=b2fc3323fc5e2df08d58b06990466169&format=json"
      anything = RestClient.get(url)
      result = JSON.parse(anything)
      artist_array = result['topartists']["artist"].map {|artist| artist["name"]}
      artist_array.each do |artist|
        artist = Artist.find_or_create_by(name: artist)
        ua = UserArtist.create
        ua.user = @user
        ua.artist = artist
        ua.approval = true
        ua.save
      end
    end

    def returning_user?
      puts "Welcome! Do you already have an account?"
      input = gets.chomp
      if input.downcase == "yes"
        puts "What is your username?"
        username1 = gets.chomp
        @user = User.find_by(name: username1)
        puts "welcome back #{@user.name}!!"
      else input.downcase == 'no'
        found_user = 1
        while found_user != nil
          puts "Please choose a username for your new account."
          username1 = gets.chomp
          found_user = User.find_by(name: username1)
        end
        @user = User.create(:name => username1)
        initialize_user
      end
    end

    def recurring_prompt
      puts "What would you like to do?"
      puts "1. Discover something new."
      puts "2. Learn about yourself." #output user's favorite and least favorite genres
      puts "3. See what's hot now." #most liked artists
      puts "4. Log out."
      choice = gets.chomp
      if choice == "1"
        discover_something
        get_feedback
        recurring_prompt
      elsif choice == "2"
        user_genres
        recurring_prompt
      elsif choice == "3"
        most_popular_artists
        recurring_prompt
      elsif choice == '4'
        puts "Bye bye !"
      else
        "Please choose what you want using an integer between 1 and 3."
        recurring_prompt
      end
    end

    def discover_something
      random_liked_artist = get_liked_user_artists.sample
      select_similar_artist(random_liked_artist)
    end

    def select_similar_artist(artistname)
      url = "#{@root}?method=artist.getsimilar&artist=#{artistname}&api_key=b2fc3323fc5e2df08d58b06990466169&format=json"
      response = RestClient.get(url)
      similar_to_artist = JSON.parse(response)
      artist_array = similar_to_artist["similarartists"]["artist"].map {|artist| artist["name"]}
      get_user_artists.each do |known_artist|
        artist_array.delete_if {|newartist| newartist == known_artist}
      end
      @artist = artist_array.sample
      puts @artist
      ##then use API to get a top track, maybe selecting at random
    end

    def get_user_artists
      UserArtist.where(:user_id => @user.id).map {|ua| ua.artist.name}
    end

    def get_liked_user_artists
      UserArtist.where(:user_id => @user.id, :approval => true).map {|ua| ua.artist.name}
    end

    def get_disliked_user_artists
      UserArtist.where(:user_id => @user.id, :approval => false).map {|ua| ua.artist.name}
    end

    def get_feedback
      puts "Do you like this artist? Y/N or 'skip'"
      feedback = gets.chomp
      if feedback.downcase == "y"
        artist = Artist.find_or_create_by(:name => @artist)
        newua = UserArtist.create
        newua.user = @user
        newua.artist = artist
        newua.approval = true
        newua.save
      else feedback.downcase == "n"
        artist = Artist.find_or_create_by(:name => @artist)
        newua = UserArtist.create
        newua.user = @user
        newua.artist = artist
        newua.approval = false
        newua.save
      end
    end


end