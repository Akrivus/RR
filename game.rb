# String method because Ruby is retarded.
class String
  def is_i?
    self.to_i.to_s == self
  end
end

# Hash method because Ruby is retarded.
class Hash
  def except(which)
    self.tap{ |h| h.delete(which) }
  end
end

# Variable determining if we can speak or not.
$canspeak = false
$outlog = ""
$starttime = Time.now

# Are we running Windows or Mac?
def windows?
	if !!(/cygwin|mswin|mingw|bccwin|wince|emx|emc/ =~ RUBY_PLATFORM) == true
		return true
	else
		return false
	end
end

# Say a phrase using either synthetic voice or text.
def say(phrase, text = phrase)
	# Put the phrase on screen for reference.
	$outlog = $outlog + text + "\n"
	
	# Say the phrase with the Mac OS say command.
	if $canspeak == true or windows? == false
		puts text
		system('say "' + phrase + '"')
	elsif $canspeak == true and windows? == true
		text.split('').each do |char|
			putc char
			sleep 0.1
		end
		puts ""
	else
		puts text
	end
end

# Clear the screen depending on your OS.
def clear(clr = true)
	if clr == true
		if windows? == true
			system('cls')
		else
			system('clear')
		end
		$outlog = ""
	else
		say(nil, "____________________")
		say(nil, "")
	end
end

# Quit the game.
def quit(forced = false)
	if forced == true
		$outlog = $outlog + "Game was force-quit by user input.\n"
	end
	
	# Write log to file.
	file = File.open($starttime.inspect.to_s + ".txt", 'w+')
	file.write($outlog)
	file.close
	
	# Suspend runtime and kill the application.
	exit
end

# Player variables.
players = {}
last_player = nil
previous = []
prevs = 0
origi = 0
count = 0

# AI variables.
index = 0
drops = 0

# Gun variables.
rounds = 0
init = 0
bullet = 1
chance = 0
shot = false

# Clear the buffer.
clear

# Should we talk?
if windows? == false
	say("Should the game be allowed to read off dialogs? Type yes or no.", "Should the game be allowed to speak off dialogs? Type 'yes' or 'no'.")
	answer = gets.chomp

	# 'Y' sets the game to not talk, 'n' sets the game to talk.
	if answer.downcase[0,1] == "y"
		$canspeak = true
		say("The game will continue to read off dialogs.")
	else
		$canspeak = false
		say("The game will no longer read off dialogs and remain silent.")
	end
	
	# Clear the buffer.
	clear
end

# Set the amount of players.
until count > 0 and count < 48 do
	say("Enter the amount of players in your game.")
	count = gets.chomp.to_i
	origi = count

	# Populate hashes or return an exception if the user is being an idiot.
	if count > 1 and count < 48
		count.times do |i|
			# Do we have over 13 people? If so, don't ask.
			if count > 13
				name = "Player " + (i + 1).to_s
			else
				say("Enter the name of Player " + (i + 1).to_s + ".")
				name = gets.chomp
				
				# Check if the name is empty, use Player # if true.
				if name.nil? or name.strip.empty?
					name = "Player " + (i + 1).to_s
				end
			end
			
			# Actually populate the hashes.
			players[(i + 1).to_s] = {"name" => name, "score" => 0}
		end
	else
		say("The amount of players can not be less than 2 or greater than 48!")
		count = 0
	end
end

# Set the amount of rounds.
until rounds > 0 and rounds < 41 do
	say("Enter the amount of rounds you want in the barrel.")
	rounds = gets.chomp.to_i
	init = rounds
	
	# Is the round count less than one?
	if rounds < 0
		say("The amount of rounds can not be less than 1!")
	elsif rounds > 41
		say("The amount of rounds can not be more than 40!")
	end
	
	# Calculate the bullet integer.
	bullet = rand(1..rounds)
end

# Inform the user that the game is starting.
say("The game is now starting.")

# Clear the buffer.
clear

# Put in a loop.
while 1 > 0 do
	# Start the loop with a spin message.
	say("Type spin to spin the gun!", "Type 'spin' to spin the gun!")
	input = gets.chomp
	
	# Spin the gun and select a new player.
	if input == "spin"
		say("The gun is being spun!")
		time = rand(1..3)
		sleep time
		
		# Pick random player.
		player = players.keys.sample
		
		# Check if we're running 2 players.
		if players.keys.length == 2			
			until not last_player == player do
				player = players.keys.sample
			end
			last_player = player
		else
			# Iterate through to prevent duplication.
			if previous.include? player
				player = players.keys.sample
			end
			
			# Go deeper.
			index = 0
			until not previous.include? player do
				player = players.keys.sample
				index += 1
				
				# Make sure we're not going too far.
				if index > players.keys.length
					previous.clear
				end
			end
		end
		
		# Resize queue.
		previous.push(player)
		
		# Start the shoot loop.
		until shot == true
			say("The gun has been spun and pointed at" + players[player]["name"] + "! Type shoot to fire it.", "The gun has been spun and pointed at " + players[player]["name"] + "! Type 'shoot' to fire it!")
			
			# Are we an AI?
			if players[player]["name"] == "CPU" or players[player]["name"] == "AI"
				if index >= bullet
					dropshoot = rand(0..10)
					if dropshoot < 6 and drops > rand(4..8)
						"shoot".split('').each do |char|
							putc char
							sleep rand(0.1..0.3)
						end
						puts ""
						input = "shoot"
						drops = 0
					elsif dropshoot < 6
						"drop".split('').each do |char|
							putc char
							sleep rand(0.1..0.3)
						end
						puts ""
						input = "drop"
						drops = drops + 1
					else
						"shuffle".split('').each do |char|
							putc char
							sleep rand(0.1..0.3)
						end
						puts ""
						input = "shuffle"
					end
				else
					"shoot".split('').each do |char|
						putc char
						sleep rand(0.1..0.3)
					end
					puts ""
					input = "shoot"
				end
			else
				input = gets.chomp
			end
			
			# Go with the game loop.
			if input == "shoot"
				if chance >= bullet
					say("The gun fired and blew " + players[player]["name"] + "'s brains out!")
					say("They died!", "Game over!")
					players.except(player)
					sleep 2
					
					# Check if we're running Windows.
					clear(false)
				
					# Sweep through and reset the game needs.
					rounds = init
					bullet = rand(1..rounds)
				
					# Calculate whoever has the highest score in the game.
					maxs = 0
					maxn = "Nobody"
					players.each do |n, p|
						if p["score"] > maxs
							maxs = p["score"]
							maxn = p["name"]
						end
					end

					# Display who won the round/game.
					if players.keys.length == 1
						say(maxn + " wins the game with " + maxs.to_s + " point#{maxs == 1 ? '' : 's'}!")
						clear(false)
						quit
					else
						say(maxn + " wins the round with " + maxs.to_s + " point#{maxs == 1 ? '' : 's'}!")
						
						# Add an incentive so that stale games won't happen.
						players.each do |key, member|
							member["score"] = member["score"] + 1
						end
					end
					chance = 0
					clear(false)
				else
					# Add a score, deplete rounds, and tell who won.
					say(players[player]["name"] + "'s gun clicks and reveals that the slot is empty.")
					say("They survived!")
	
					players[player]["score"] = players[player]["score"] + 1
				
					# Add an incentive so that stale games won't happen.
					players.each do |key, member|
						member["score"] = member["score"] + 1
					end
				
					# Use gradual elimination.
					rounds = rounds - 1
					
					# Enable a change in chances.
					percent = rand(0..10)
					if percent < 6
						chance = chance + 1
						index = index + 1
					end
				end
				shot = true
			elsif input == "drop" or input == "spin"
				# Humiliate the cowards.
				say(players[player]["name"] + " has withdrawn their turn!")
				shot = true
			elsif input == "exit" or input == "quit"
				# Leaves the game.
				say("You can not leave the game in the middle of a round.")
			elsif input == "add"
				# Add a new player.
				clear(false)
				count = count + 1
			
				# Check if the others players could assign themselves a name.
				if origi <= 13
					say("What is the name of this new player?")
					name = gets.chomp
				
					# Check if the name is empty, use Player # if true.
					if name.nil? or name.strip.empty?
						name = "Player " + index.to_s
					end
				else
					name = "Player " + index.to_s
				end
			
				# Add the new player to our list hash.
				players[count.to_s] = {"name" => name, "score" => 0}
				say(players[count.to_s]["name"] + " has been added!")
				clear(false)
			elsif input == "shuffle"
				# Shuffle the gun, this will minimize your chances of dying, and refreshes the game.
				clear(false)
				say("Shuffling cylinder...")
				rounds = init
				bullet = rand(1..rounds)
				sleep rand(1..3)
				say("The gun has been shuffled!")
				clear(false)
			else
				# Inform the user that someone has been chosen.
				clear(false)
				say("Type shoot to fire it.", "Type 'shoot' to fire it!")
				clear(false)
			end
			prevs = player
		end
		shot = false
	elsif input == "shuffle"
		# Shuffle the gun, this will minimize your chances of dying, and refreshes the game.
		say("Shuffling cylinder...")
		rounds = init
		bullet = rand(1..rounds)
		sleep rand(1..3)
		say("The gun has been shuffled!")
	elsif input == "add"
		# Add a new player.
		count = count + 1
			
		# Check if the others players could assign themselves a name.
		if origi <= 13
			say("What is the name of this new player?")
			name = gets.chomp
			
			# Check if the name is empty, use Player # if true.
			if name.nil? or name.strip.empty?
				name = "Player " + count.to_s
			end
		else
			name = "Player " + count.to_s
		end
		
		# Add the new player to our list hash.
		players[count.to_s] = {"name" => name, "score" => 0}
		say(players[count.to_s]["name"] + " has been added!")
	elsif input == "quit"
		# Leaves the game.
		quit(true)
	end
end