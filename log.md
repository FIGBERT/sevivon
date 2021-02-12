# Ruleset
## Game Setup
- Each player receives a set amount of gelt
  - Initially this is set to 10, but in the final game players will choose
  between a number of options.
- The pot starts with 5 gelt
## Each Spin
- The spin order is the order clients joined the lobby
- Each player takes/gives gelt to the pot based on spin
  - Gimel - take all
  - Hey - take half (floored)
  - Nun - take nothing
  - Shin - put one in
- If the pot has less than two pieces of gelt, everyone puts in one piece
  - If a player cannot put in a piece, they are out
## Win Condition
- A winner is determined once everybody else is out

# Multiplayer Documentation
## Networking
1. [High-Level Multiplayer](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)
2. [Making HTTP Requests](https://docs.godotengine.org/en/stable/tutorials/networking/http_request_class.html)
3. [SSL Certificates](https://docs.godotengine.org/en/stable/tutorials/networking/ssl_certificates.html)
4. [Coroutines with yield](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#coroutines-with-yield)
## Server Exports
1. [Exporting for Dedicated Servers](https://docs.godotengine.org/en/stable/getting_started/workflow/export/exporting_for_dedicated_servers.html)
2. [Compiling a Server Build for macOS](https://docs.godotengine.org/en/stable/development/compiling/compiling_for_osx.html#compiling-a-headless-server-build)
3. [Compiling a Server build for Linux](https://docs.godotengine.org/en/stable/development/compiling/compiling_for_x11.html#compiling-a-headless-server-build)
## GDScript
1.  [GDScript Style Guide](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_styleguide.html)

# Daily Journaling
## 2021-01-30 Sat

Today I took the time to read through the Godot multiplayer
documentation and implement the basic lobby structure. Each client
initializes itself, checking whether or not it's a server or client,
and connect to a hard-coded IP address `SERVER_IP` currently pointing to
my laptop on the local network. It probably isn't considered a security
issue to have that in a public repo, but I'm not sure.

The code is a little rough right now, but it's supposed to be. The
current version is just there to do the basics (literally text-based)
and then I can spend as much time as I want refining and adding graphics
and such.

At the end of the day today, the game can:

- Run as a headless server
- Connect to the server, and alert the user of a successfull or failed
connection
- Alert the user when another client joins or leaves the lobby, and output
their `id`.

Tommorrow I am going to work on:

- Defining a dreidel rule set
- Outlining how the data is passed around over the network
  - How is the game data structured?
  - Does the client take actions and the server validate them, or does the
  server request actions from the client?
- Starting the game when the lobby is full

## 2021-01-31 Sun

I spent the first part of today's work writing a ruleset for dreidel,
outlined above. It's based on the rules found on Wikipedia, Chabad.org,
and my personal experience. It also should be fairly easy to implement!

I also butted heads with the multiplayer code a bit - it's hard to make
a game - but I've got a bit of a general strategy defined now. The
client should do as little thinking of its own as possible: it's
primary function should be to respond to calls from the server.
Additionally, the code for client and server should be kept as separate
as possible. I considered having functions for each section always begin
with a prefix of some sort (i.e. `client_*` or `server_*`). I have
passed on this for now, but may change that decision later if I can make
certain that all names retain their clarity.

Tomorrow, I have to start implementing the actual game - working on the
lobby code is not the goal of this project! Mastering `rpc` calls will
be difficult, but I am confident that I can get a strong start on the
gameplay if I focus.

## 2021-02-01 Mon

This project is moving at the speed of light. Today, I basically
finished the backend code. Players now take turns spinning the dreidel,
gaining and losing gelt, and everything works flawlessly. It's really
exciting.

The main change I implemented today was inserting a step between roll
decection (`client_spun`) and moving on to the next player
(`_iterate_turn`) which chooses a random side of the dreidel and
performs actions on the pot and players' gelt (`_spin_dreidel`).

One of the more interesting problems I encountered in making this
functions was how to implement the randomness. At first, I defined it as
such:

``` gdscript
round(rand_range(0, 3))
```

This block generates a random float (decimal) between 0 and 3 and rounds
it to the nearest integer, which I use to select a dreidel face from an
array. Do you see the problem? The problem lies in the function I used -
`round`. The numbers at the end of the range have only have the change
of getting selected as those in the middle! With that implementation, 0
would only be selected if the number generated was between 0 and 0.5.
The same applies for 3: it would only be selected if the number
generated was between 2.5 and 3. These both are less than the chance of
getting a 1 or a 2, which have a range of 1 each - double the range of 0
and 3!

So how did I fix it? Like this:

``` gdscript
floor(rand_range(0, 4))
```

This new version ensure that each number has an equal change of being
selected, instead of being biased toward the center.

Tomorrow, I'm going to focus on polishing the text output. The
operations on the pot need to be more clear, and I am considering
splitting the processes of spinning and anteing up. Most importantly,
however, I must add a win condition!

## 2021-02-02 Tue

Well, three cheers for unexpected challenges. Adding a win/lose system
was incredibly difficult. I expected it to be a breeze. I actually had
to implement it twice, because my first attempt was unsalvagable. The
second time around, I walked through the whole codebase piece by piece
with my dad, and we worked it out together. The most interesting thing
he suggested was a cool trick in boolean math: to figure out if there is
only one true value in an array of booleans, convert them all to binary,
and if the sum is 1 then there's only one `true`. Pretty useful.

With that final system implemented, it's time to polish off the textual
interface before moving on to add some real graphics. By Friday, I need
to:

- Increase the font size
- Get running on Android
- Split and request the ante
  - It's currently lumped in with the rest of the spin, which makes the math a
  little confusing.
- Add usernames
  - Judah
  - Yochanan
  - Shimon
  - Elazar
  - Yonatan
- Add auditory or haptic feedback to dreidel spins
- Increase lobby max size and add start/restart mechanisms

## 2021-02-06 Sat

When I said Friday I meant the 12th... I promise. I've been hard at
work implementing the features I discussed above. I knocked out the font
size patch on the first day - that one was a freebie - and then spent
the rest of the day and half of the next trying to get the game running
on a Pixel 4a. Now it does! Turns out, the only real problem I
encountered was myself. I had enabled Kill Switch with my VPN app, and
thus when I disabled it to access the local network it prevented me from
connecting to my laptop - tad of a facepalm there.

The next while I spent implementing, failing, and reimplementing the
ante and usernames. I've noticed that when designing new features, I
tend to get 85% of the way there and then decide that I want to start
over and do it another way. Both the ante and username systems are
currently almost complete, but not quite there yet. With antes, I
initially struggled to figure out how to implement some sort of waiting
system - how to get the spin function to pause until everybody has
confirmed the ante. The current design ignores that, but will allow me
to extend the current implementation to add a delay with `yield` and
coroutines - I just need to learn how to use them. A similar caveat
exists with the username system: all five have been added, but because
the lobby size is currently limited to two players (which itself is
because I haven't implemented a start mechanism), only Judah and
Yochanan are ever used.

Regardless, some incredible strides have been made in the last couple
days. I'll continue working on rounding out the feature set, and then
polishing the textual interface before I get to actual graphics. A
non-exhaustive list of some things I have to get done:

- Add confirmation to the ante process with `yield`
- Increase the lobby max size to five and make starting manual
- Add auditory or haptic feedback to dreidel spins
- Polish textual interface
  - Make sure it looks nice on both iOS and Android
  - Add little delays between messages (also with `yield`)
  - Make sure all the message are charismatic and expressive
    - Less like logs for a programmer and more like fun messages for a player

## 2021-02-11 Thu

Over the past couple days, I achieved *most* of the above goals! Not bad.
Yesterday, I increased the maximum lobby size to five (which is where it will
stay) – now the first player to join must shake their phone once to start a
match. In doing so, I encountered a weird issue with `yield` that caused the
0.5 second delay I was implementing to not fire depending on where I placed
it within a function. Odd, but I worked it out in the end.

I've also added haptic/vibrational feedback to dreidel spins. However, I'm not
sure this will make it into the final game. Once I start adding graphics, I
plan on also adding in a dreidel spinning sound effect which may replace the
current system or operate alongside it.

For the final change I've made so far, I did some research into responsive
design with the Godot 2D editor and have made the `Label` element much more
adaptable to a variety of different screens.

Current todos (not many left):

- Go over ruleset one more time
  - Lately I've been thinking that games are going on for too long. Potential
  ways to fix this include changing up the gelt amounts, anteing after every
  turn, and rounding up instead of down when you roll hey.
- Add confirmation to the ante process
- Polish messsages
  - Add short delays between messages
  - Make sure all messages make sense

