var/list/ruins = list()

/proc/load_all_ruins()
	for(var/item in subtypesof(/datum/ruin/lavaland))
		var/datum/ruin/lavaland/R = new item()
		R.load_template()

		ruins += R

/datum/ruin/lavaland
	var/name = "A Chest of Doubloons"
	var/id = null // For blacklisting purposes
	var/description = "In the middle of a clearing in the rockface, there's a \
		chest filled with gold coins with Spanish engravings. How is there a \
		wooden container filled with 18th century coinage in the middle of a \
		lavawracked hellscape? It is clearly a mystery."
	var/cost = null
	var/prefix = "_maps/RandomRuins/LavaRuins/"
	var/map = null
	var/datum/map_template/template

/datum/ruin/lavaland/New()
	map = prefix + map

/datum/ruin/lavaland/proc/load_template()
	template = new(path = src.map, rename = src.name)

/datum/ruin/lavaland/biodome
	cost = 15

/datum/ruin/lavaland/biodome/beach
	name = "Biodome Beach"
	id = "biodome-beach"
	description = "Seemingly plucked from a tropical destination, this beach \
		is calm and cool, with the salty waves roaring softly in the \
		background. Comes with a rustic wooden bar and suicidal bartender."
	map = "lavaland_biodome_beach.dmm"

/datum/ruin/lavaland/biodome/winter
	name = "Biodome Winter"
	id = "biodome-winter"
	description = "For those getaways where you want to get back to nature, \
		but you don't want to leave the fortified military compound where you \
		spend your days. Includes a unique(*) laser pistol display case, \
		and the recently introduced I.C.E(tm)."
	map = "lavaland_surface_biodome_winter.dmm"

/datum/ruin/lavaland/biodome/clown
	name = "Biodome Clown Planet"
	id = "biodome-clown"
	description = "WELCOME TO CLOWN PLANET! HONK HONK HONK etc.!"
	map = "lavaland_biodome_clown_planet.dmm"

/datum/ruin/lavaland/biodome/cube
	name = "Biodome Cube"
	id = "biodome-cube"
	description = "It's a cube?"
	map = "lavaland_surface_cube.dmm"

/datum/ruin/lavaland/prisoners
	name = "Prisoner Crash"
	id = "prisoner-crash"
	description = "This incredibly high security shuttle clearly didn't have \
		'avoiding lavafilled hellscapes' as a design priority. As such, it \
		has crashed, waking the prisoners from their cryostatis, and setting \
		them loose on the wastes. If they live long enough, that is."
	map = "lavaland_surface_prisoner_crash.dmm"
	cost = 20

/datum/ruin/lavaland/seed_vault
	name = "Seed Vault"
	id = "seed-vault"
	description = "The creators of these vaults were a highly advanced and \
		benevolent race, and launched many into the stars, hoping to aid \
		fledgling civilizations. However, all the inhabitants seem to do is \
		grow drugs and guns."
	map = "lavaland_surface_seed_vault.dmm"
	cost = 20

/datum/ruin/lavaland/ash_walker
	name = "Ash Walker Nest"
	id = "ash-walker"
	description = "A race of unbreathing lizards live here, that run faster \
		than a human can, worship a broken dead city, and are capable of \
		reproducing by something involving tentacles? Probably best to \
		stay clear."
	map = "lavaland_surface_ash_walker1.dmm"
	cost = 20

/datum/ruin/lavaland/free_golem
	name = "Free Golem Ship"
	id = "golem-ship"
	description = "Lumbering humanoids, made out of precious metals, move \
		inside this ship. They frequently leave to mine more minerals, \
		which they somehow turn into more of them. Seem very intent on \
		research and individual liberty, and also geology based naming?"
	cost = 20
	map = "lavaland_surface_golem_ship.dmm"

/datum/ruin/lavaland/animal_hospital
	name = "Animal Hospital"
	id = "animal-hospital"
	description = "Rats with cancer do not live very long. And the ones that \
		wake up from cryostasis seem to commit suicide out of boredom."
	cost = 10
	map = "lavaland_surface_animal_hospital.dmm"

/datum/ruin/lavaland/sin
	cost = 10

/datum/ruin/lavaland/sin/envy
	name = "Ruin of Envy"
	id = "envy"
	description = "When you get what they have, then you'll finally be happy."
	map = "lavaland_surface_envy.dmm"

/datum/ruin/lavaland/sin/gluttony
	name = "Ruin of Gluttony"
	id = "gluttony"
	description = "If you eat enough, then eating will be all that you do."
	map = "lavaland_surface_gluttony.dmm"

/datum/ruin/lavaland/sin/greed
	name = "Ruin of Greed"
	id = "greed"
	description = "Sure you don't need magical powers, but you WANT them, and \
		that's what's important."
	map = "lavaland_surface_greed.dmm"

/datum/ruin/lavaland/sin/pride
	name = "Ruin of Pride"
	id = "pride"
	description = "Wormhole lifebelts are for LOSERS, who you are better than."
	map = "lavaland_surface_pride.dmm"

/datum/ruin/lavaland/sin/sloth
	name = "Ruin of Sloth"
	id = "sloth"
	description = "..."
	map = "lavaland_surface_sloth.dmm"

/datum/ruin/lavaland/ato
	name = "Automated Trade Outpost"
	id = "ato"
	description = "A sign at the front says 'Stealing is bad.'"
	map = "lavaland_surface_automated_trade_outpost.dmm"
	cost = 5

/datum/ruin/lavaland/ufo_crash
	name = "UFO Crash"
	id = "ufo-crash"
	description = "Turns out that keeping your abductees unconcious is really \
		important. Who knew?"
	map = "lavaland_surface_ufo_crash.dmm"
	cost = 15

/datum/ruin/lavaland/ww_vault
	name = "ww_vault"
	id = "ww-vault"
	description = "I don't know what this is."
	map = "lavaland_surface_ww_vault.dmm"
	cost = 20

/datum/ruin/lavaland/xeno_nest
	name = "Xenomorph Nest"
	id = "xeno-nest"
	description = "These xenomorphs got bored of horrifically slaughtering \
		people on space stations, and have settled down on a nice lava filled \
		hellscape to focus on what's really important in life. Quality memes."
	map = "lavaland_surface_xeno_nest.dmm"
	cost = 20

/datum/ruin/lavaland/fountain
	name = "Fountain Hall"
	id = "fountain"
	description = "The fountain has a warning on the side. DANGER: May have \
		undeclared side effects that only become obvious when implemented."
	map = "lavaland_fountain_hall.dmm"
	cost = 5

/datum/ruin/lavaland/zombie_gym
	name = "Zombie Gym"
	id = "zombie-gym"
	description = "The patrons at this gym are serious about health, and \
		making sure people work on their cardio."
	map = "lavaland_gym.dmm"
	cost = 25

