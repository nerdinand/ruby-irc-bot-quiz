#############################################
# Standard IRC bot stuff, don't change this #
#############################################

# We tell Ruby we want to use the 'socket' part of the
# standard library in this file
require "socket"

require_relative 'trivia_bot_question_parser'
require_relative 'mox_quizz_question_parser'

# We declare an instance variable called "joined" with the value false
@joined = false

# A method that lets us connect to a server
def connect
  # We open a new socket connection to the server @server on port @port
  @socket = TCPSocket.open(@server, @port)

  # We send an IRC message that's sets the bot's nickname to @name
  irc_send("NICK #{@name}")

  # We send an IRC message that's sets users usename and real name to @name
  irc_send("USER #{@name} 0 * :#{@name}")
end

# A method that sends a command to join an IRC channel.
# It takes the channel as a method argument. The channel name must begin with a "#"
def irc_send_join(channel)
  # We send an IRC message that joins a channel
  irc_send("JOIN #{channel}")
end

# A method that sends an IRC-protocol message to the server and also puts it to the terminal
def irc_send(message)
  puts("Sending: #{message}")

  # We can call "puts" on the socket we opened earlier. Instead of outputting something on the
  # terminal, this will send the message accross the internet to the IRC server we are connected to
  @socket.puts(message)
end

# The server will regularly ask if our bot is still around using "PING" messages. This method allows
# us to respond to the PINGs with a PONG, so our connection does not get closed accidentally.
def handle_ping_message(message)
  # The last part of the PING message is the so-called "challenge". The server expects that we reply
  # back with this exact string. Therefore we extract it here.
  challenge = message.split(" ").last

  # We send back an IRC "PONG" message with the challenge that came from the server.
  irc_send "PONG #{challenge}"
end

# The main method of our bot. It connects to the server and then keeps the connection
# open in a loop and reacts to different kinds of incoming messages.
def run
  parse_quiz_questions

  # First thing to do is to connect to the server
  connect

  # Here we keep the connection open, as long as it's not getting closed by the server (that would result in
  # @socket.eof? returning true).
  until @socket.eof? do

    # We read the next incoming message from the socket connection.
    message = @socket.gets

    # We ouput the message on the terminal, so we can see what our bot's input is.
    puts message

    # If the message we are getting is a "PING" message...
    if message.start_with?("PING")
      # ...then we need to react to that PING, so as to not get disconnected accidentally.
      handle_ping_message(message)

    # If the message is a private message sent inside our channel...
    elsif message.include?("PRIVMSG #{@channel}")
      # ...then we react in some way to that message.
      handle_channel_message(message)

    # If we haven't joined our channel yet and the message includes "MODE" and the bot's name...
    elsif !@joined && message.include?("MODE #{@name}")
      # ...then the server is ready for us to join the channel.
      irc_send_join(@channel)
      # We set @joined to true, so we don't try to join the channel twice accidentally.
      @joined = true
    end
  end
end

###############################################
# Implement your own ideas below this comment #
###############################################

# This method gets called, whenever a message is sent to our IRC channel. In it you can react to
# the users' inputs in whatever way you like...
def handle_channel_message(message)
  if (match = message.match(/^:(\w+)!.*?:(.*)$/))
    captures = match.captures
    nickname = captures[0]
    message = captures[1].chomp

    if mentioned?(message) && message.downcase.include?('hello')
      send_channel_message("Why hello there, #{nickname}!")
    elsif (match = message.match(/^!(\w+) ?(.*)$/))
      captures = match.captures
      command = captures[0]
      arguments = captures[1]

      command_method_name = "handle_command_#{command}"

      if respond_to?(command_method_name, true)
        send(command_method_name, arguments)
      end
    else
      if @quiz_running
        process_quiz_guess(nickname, message)
      end
    end
  else
    # weird stuff is happening, we'll ignore this
  end
end

def mentioned?(message)
  message.include?(@name)
end

def send_channel_message(message)
  irc_send("PRIVMSG #{@channel} :#{message}")
end

def handle_command_time(arguments)
  send_channel_message("The current time is #{Time.now}")
end

def parse_quiz_questions
  @quiz_items = []

  Dir.glob("quiz_data/triviabot/*") do |file|
    puts "Parsing #{file}"
    @quiz_items += TriviaBotQuestionParser.new(file).parse
  end

  Dir.glob("quiz_data/moxquizz/*") do |file|
    puts "Parsing #{file}"
    @quiz_items += MoxQuizzQuestionParser.new(file).parse
  end

  puts "Parsed #{@quiz_items.size} questions."
end

def ask_quiz_question
  @current_quiz_item = @quiz_items.sample
  @current_quiz_item.reset
  send_channel_message(@current_quiz_item.question)
  puts "Answers are: #{@current_quiz_item.answers}"
  puts "Tips are: #{@current_quiz_item.tips}"
end

def process_quiz_guess(username, message)
  correct = @current_quiz_item.correct?(message)

  if correct
    @score[username] += 1

    send_channel_message("#{username} is correct! #{message} is the right answer! #{username} has #{@score[username]} points.")
    ask_quiz_question
  end
end

def handle_command_startquiz(arguments)
  return if @quiz_running

  send_channel_message("Quiz is starting!")
  ask_quiz_question
  @quiz_running = true
end

def handle_command_stopquiz(arguments)
  return unless @quiz_running

  @quiz_running = false
  send_channel_message("Quiz is stopped.")
end

def handle_command_tip(arguments)
  send_channel_message("Here's a tip for you: #{@current_quiz_item.give_tip}")
end

# The host name of the IRC server we want to connect to
@server = "irc.freenode.net"

# The port on the server we want to connect to with our bot
@port = 6667

# The name of your bot. Choose something that ends in -bot, so we know it's a bot ;)
@name = "nerdinand-bot"

# The name of our channel we want to join on the IRC server
@channel = "#rubymonstas"

@quiz_running = false
@score = Hash.new(0)

# After setting all the variables and defining the necessary methods, we can call the "run" method,
# which will start our bot and make the magic happen!
run
