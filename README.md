# RR
Russian Roulette; sophomore year classic and first thing I ever wrote in Ruby.

## How to play
Run `ruby game.rb` and it should start up for you.

**NOTE:** It will read off lines if you tell it to on Mac using the TTS, this was a design choice because during my high school heydays, I'd be playing this on a round table with a group of up to 6 friends, and passing the Macbook around to random people got meddlesome really fast.

The game only allows between 2 to 48 people. If you're alone, the names `CPU` and `AI` create a "fake player" instance. You can even put them both together, it's pretty cool actually.

The "amount of rounds you want in the barrel" question is how many total slots you want, with one of them being a real bullet. My friend wanted to pretend to he was playing Russian Roulette with an AK-47 (get it, Russian Roulette with an actual Russian weapon?) even though it isn't logically possible. Either way, default is six if you don't know your guns.

## Commands
These commands can be typed when the gun isn't in someone's hand.
* `spin` - spins the gun to someone.
* `shuffle` - shuffles the bullet's position in the gun.
* `add` - adds a new player.
* `quit` - quits the game.


The commands can be typed whe the gun is in someone's hand.
* `shoot` - shoots the gun, is it a real bullet? Hope not.
* `drop` - passes the gun to the next person.
* `add` - adds a new player.
* `quit` - you'd be better off just doing Ctrl+C, bro.

