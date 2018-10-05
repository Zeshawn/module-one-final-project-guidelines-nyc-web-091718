################# Something New ####################

Something New is a CLI-based music platform allowing the user to discover a new artist upon request.
It will scan through the artists previously declared as "liked" or "not liked" by the particular user,
look for artists that are similar to the liked artists using the Last.fm API, and filter from the results of
this query any artists that the user has already expressed an opinion about. The app is designed to launch in the
user's default browser the first video returned when searching YouTube for the artist name along with their top song,
if available. The user can manually add artists to their own account and express their opinion on the artist upon
doing so, i.e the user must "like" or "dislike" the artist upon adding it to their list. If the user enters the name
of an artist which already exists in their database, they have the option to change their opinion of this artist by
disliking a previously liked artist or vice versa, giving the user additional control on what Something New will
select from when picking something to play for the user.

Upon starting the app, the user may make a new account and choose a unique username, or return to an old one by entering
the username of an existing profile. The accounts are not password protected - any user can log on to any profile by
entering the username, even if it is not "theirs." Upon starting a new account, the user is prompted offered the option
 to import known artists from a Last.fm profile, automatically generating a list of artists with at least one listen, and defaulting them to being "liked." If the user opts out of connecting a last.fm account, they are asked to enter three
 artists that they like to provide a platform for the recommendation service to base off of.

As an additional feature, the user may request a list of popular songs which belong to an artist that is not on
their list of known artists. In other words, a list of popular songs is fetched using the Last.fm API, and each return
value is deleted if the user has previously expressed an opinion on the artist. The user may choose a song from this
list by integer, prompting it to be launched in their default browser, allowing the user to view the video
and express their opinion on the artist (or to "pass"), adding the artist to their known list.

At any time the user may view their list of known artists, separated by "liked" or "disliked" by selecting the appropriate
action in the app's main menu.


################# Installation Instructions ####################
Copy or clone the files into a file on your computer. Navigate to the file in your computer's terminal and execute
the command "bundle install" to install all required packages that support this platform. The functionality of the
app requires use of an API key for the Last.fm API, and at this time a user must request a key from the API ("https://www.last.fm/api/account/create/"). Upon obtaining the key, the user must create a file named .env in
the root directory of the program with a single line:

API_KEY = "PASTE_API_KEY_HERE"

Now the program is ready for use. Execute the run file by typing "ruby <filepath ending in run.rb>".


################# Known Bugs // TODO ####################

The program will not correctly perform an API query if the artist returned from the program's main tools has a name
that includes a non-ASCII character, such as "Beyoncé". This will cause a fatal error and the application must be restarted.
