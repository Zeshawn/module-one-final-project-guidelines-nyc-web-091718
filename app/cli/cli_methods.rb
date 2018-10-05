
class Cli

require 'json'
require 'rest-client'
require 'launchy'
require 'nokogiri'
require 'colorize'
require 'addressable'

    def greeting

      puts ' Welcome to ...
   ▄████████  ▄██████▄     ▄▄▄▄███▄▄▄▄      ▄████████     ███        ▄█    █▄     ▄█  ███▄▄▄▄      ▄██████▄       ███▄▄▄▄      ▄████████  ▄█     █▄
  ███    ███ ███    ███  ▄██▀▀▀███▀▀▀██▄   ███    ███ ▀█████████▄   ███    ███   ███  ███▀▀▀██▄   ███    ███      ███▀▀▀██▄   ███    ███ ███     ███
  ███    █▀  ███    ███  ███   ███   ███   ███    █▀     ▀███▀▀██   ███    ███   ███▌ ███   ███   ███    █▀       ███   ███   ███    █▀  ███     ███
  ███        ███    ███  ███   ███   ███  ▄███▄▄▄         ███   ▀  ▄███▄▄▄▄███▄▄ ███▌ ███   ███  ▄███             ███   ███  ▄███▄▄▄     ███     ███
▀███████████ ███    ███  ███   ███   ███ ▀▀███▀▀▀         ███     ▀▀███▀▀▀▀███▀  ███▌ ███   ███ ▀▀███ ████▄       ███   ███ ▀▀███▀▀▀     ███     ███
         ███ ███    ███  ███   ███   ███   ███    █▄      ███       ███    ███   ███  ███   ███   ███    ███      ███   ███   ███    █▄  ███     ███
   ▄█    ███ ███    ███  ███   ███   ███   ███    ███     ███       ███    ███   ███  ███   ███   ███    ███      ███   ███   ███    ███ ███ ▄█▄ ███
 ▄████████▀   ▀██████▀    ▀█   ███   █▀    ██████████    ▄████▀     ███    █▀    █▀    ▀█   █▀    ████████▀        ▀█   █▀    ██████████  ▀███▀███▀
'.red
  end

  def initialize()
    @root = "http://ws.audioscrobbler.com/2.0/"
    @user = nil
    @artist = nil
  end
    def initialize_user
      puts "Would you like to connect your last.fm account? Type no if you do not have an account."
      while true
        input = gets.chomp
        if input.downcase == "no"
          puts "Enter your favorite artists below, separated by commas. (ex: Artist1, Artist2, Artist3)"
          artist_array = gets.chomp.split(", ")
          artist_array = artist_array.map do |artist| get_correction(artist) end
          artist_array.each do |artist|
            if artist != nil
              chosen_artist = Artist.find_or_create_by(name: artist)
              ua = UserArtist.create
              ua.user = @user
              ua.artist = chosen_artist
              ua.approval = true
              ua.save
            elsif artist == nil
              puts "Could not find artist #{artist}."
            end
          end
        elsif input.downcase == "yes"
          puts "Enter your lastfm username"
          lastfmusername = gets.chomp
          get_user_top_artist(lastfmusername)
          puts "Profile successfully imported!!\n\n"
              # puts "Please enter yes or no"
        else
          puts "Please enter yes or no"
        end
        break if input.downcase == "yes" || input.downcase == "no"

          # puts "Enter your lastfm username"
          # lastfmusername = gets.chomp
          # get_user_top_artist(lastfmusername)
          # puts "Profile successfully imported!!\n\n"
      end
    end

    def get_user_top_artist(username)
      url = "#{@root}?method=user.gettopartists&user=#{username}&api_key=#{ENV['API_KEY']}&format=json&limit=500"
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
          puts "Please choose a unique username for your new account."
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
      puts "4. Enter a new artist to track."
      puts "5. Log out."
      choice = gets.chomp
      if choice == "1"
        discover_something
        song = song_getter(@artist)
        youtube_search("#{@artist} #{song}")
        get_feedback
        recurring_prompt
      elsif choice == "2"
        display_artists
        recurring_prompt
      elsif choice == "3"
        top_tracks
        recurring_prompt
      elsif choice == "4"
        add_artist_to_user
        recurring_prompt
      elsif choice == '5'
        puts "Bye bye! "
      else
        puts "Please choose what you want using an integer between 1 and 5."
        recurring_prompt
      end
    end

    def discover_something
      random_liked_artist = get_liked_user_artists.sample
      select_similar_artist(random_liked_artist)
    end

    def select_similar_artist(artistname)
      # artistname = normalize(artistname)
      url = "#{@root}?method=artist.getsimilar&artist=#{artistname}&api_key=#{ENV['API_KEY']}&format=json"
      response = RestClient.get(url)
      similar_to_artist = JSON.parse(response)
      artist_array = similar_to_artist["similarartists"]["artist"].map {|artist| artist["name"]}
      get_user_artists.each do |known_artist|
        artist_array.delete_if {|newartist| newartist == known_artist}
      end
      @artist = artist_array.sample
      puts @artist
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

    def add_artist_to_user
      puts "Enter an artist that you have heard of or would like to edit."
      artist = gets.chomp
      artist = get_correction(artist)
      if artist == nil
        puts "Are you sure this artist exists?"
        return
      end
      artist = Artist.find_or_create_by(:name => artist)
      ua = UserArtist.find_or_create_by(:user_id => @user.id, :artist_id => artist.id)
      puts "Do you like this artist? (Yes/No)"
      choice = gets.chomp
      ua.approval = (choice.downcase == "yes") ? true : false
      ua.save
    end

    def display_artists
      print "Artists you like!".colorize(:color => :light_red, :background => :light_white)
      puts "*".colorize(:color => :light_red, :background => :light_white) * (50 - "Artists you like!".length)
        get_liked_user_artists.each do |artist|
          print artist.colorize(:color => :light_red, :background => :light_white)
          puts " ".colorize(:color => :light_red, :background => :light_white) * (50 - artist.length)
          sleep(0.02)
        end
      puts "\n"
      puts "\n"

      print "Artists you don't like".colorize(:color => :light_blue, :background => :light_white)
      puts "*".colorize(:color => :light_blue, :background => :light_white) * (50 - "Artists you don't like".length)
        get_disliked_user_artists.each do |artist|
          print artist.colorize(:color => :light_blue, :background => :light_white)
          puts " ".colorize(:color => :light_blue, :background => :light_white) * (50 - artist.length)
          sleep(0.02)
        end
      puts "\n \n \n"


    end

    def top_tracks
      puts "\n\n \u{1f525} Here are some top tracks that you've been missing out on! \u{1f525}".colorize(:color => :cyan, :background => :light_white)
      url =  "http://ws.audioscrobbler.com/2.0/?method=chart.gettoptracks&api_key=#{ENV['API_KEY']}&format=json"
      response = RestClient.get(url)
      top_track = JSON.parse(response)
      top_track_list = top_track["tracks"]["track"].map do |track|
        [track["name"], track["artist"]["name"]]
      end
      user_artists = get_user_artists
      top_track_list.delete_if {|track_and_artist| user_artists.include?(track_and_artist[1])}
      top_track_list.each_with_index do |track_and_artist, index|
        puts "#{index + 1}. #{track_and_artist[0]} by #{track_and_artist[1]}".colorize(:color => :cyan, :background => :light_white)
        sleep(0.2)
      end
        puts "Would you like to see any of these? Enter the number or type no"
          choice = gets.chomp
          if choice.to_i != 0
            youtube_search("#{top_track_list[choice.to_i-1][0]} #{top_track_list[choice.to_i-1][1]}")
            @artist = top_track_list[choice.to_i-1][1]
            get_feedback
          end
      end




    def youtube_search(query_term)
        query_term = query_term.split(" ").join("+")
        url = "https://www.youtube.com/results?search_query=#{query_term}"
        document = Nokogiri::HTML(RestClient.get(url))
        first_hit = document.css("a").map {|a| a['href']}.select {|link| link.include?("watch")&& link.length == 20}.first
        first_hit_url = "https://www.youtube.com/#{first_hit}"

        Launchy.open(first_hit_url)
  end

  def get_correction(artist)
    url = @root + "?method=artist.getcorrection&artist=#{artist}&api_key=#{ENV['API_KEY']}&format=json"
    response = RestClient.get(url)
    artist_correction = JSON.parse(response)
    artist_correction["corrections"].class == Hash ? artist_correction["corrections"]["correction"]["artist"]["name"] : nil
   end

   def song_getter(artist)
     url = @root + "?method=artist.gettoptracks&artist=#{artist}&api_key=#{ENV['API_KEY']}&format=json"
     response = RestClient.get(url)
     get_top_tracks = JSON.parse(response)
     get_top_tracks["toptracks"]["track"][0]["name"]
   end

   # def normalize(artist)
   #   artist = artist.unicode_normalize(:nfkd).chars
   #   alpha = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p",
   #     "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
   #  artist.delete_if {|char| !alpha.include?(char.downcase)}
   #     artist.join
   # end


end
