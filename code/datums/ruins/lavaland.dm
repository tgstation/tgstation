// Hey! Listen! Update \config\lavaruinblacklist.txt with your new ruins!

/datum/map_template/ruin/lavaland
	ruin_type = ZTRAIT_LAVA_RUINS
	prefix = "_maps/RandomRuins/LavaRuins/"
	default_area = /area/lavaland/surface/outdoors/unexplored

/datum/map_template/ruin/lavaland/biodome
	cost = 5
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/biodome/beach
	name = "Lava-Ruin Biodome Beach"
	id = "biodome-beach"
	description = "Seemingly plucked from a tropical destination, this beach is calm and cool, with the salty waves roaring softly in the background. \
	Comes with a rustic wooden bar and suicidal bartender."
	suffix = "lavaland_biodome_beach.dmm"

/datum/map_template/ruin/lavaland/biodome/winter
	name = "Lava-Ruin Biodome Winter"
	id = "biodome-winter"
	description = "For those getaways where you want to get back to nature, but you don't want to leave the fortified military compound where you spend your days. \
	Includes a unique(*) laser pistol display case, and the recently introduced I.C.E(tm)."
	suffix = "lavaland_surface_biodome_winter.dmm"

/datum/map_template/ruin/lavaland/biodome/clown
	name = "Lava-Ruin Biodome Clown Planet"
	id = "biodome-clown"
	description = "WELCOME TO CLOWN PLANET! HONK HONK HONK etc.!"
	suffix = "lavaland_biodome_clown_planet.dmm"

/datum/map_template/ruin/lavaland/lizgas
	name = "Lava-Ruin The Lizard's Gas"
	id = "lizgas2"
	description = "A recently opened gas station from the Lizard's Gas franchise."
	suffix = "lavaland_surface_gas.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/cube
	name = "Lava-Ruin The Wishgranter Cube"
	id = "wishgranter-cube"
	description = "Nothing good can come from this. Learn from their mistakes and turn around."
	suffix = "lavaland_surface_cube.dmm"
	cost = 10
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/seed_vault
	name = "Lava-Ruin Seed Vault"
	id = "seed-vault"
	description = "The creators of these vaults were a highly advanced and benevolent race, and launched many into the stars, hoping to aid fledgling civilizations. \
	However, all the inhabitants seem to do is grow drugs and guns."
	suffix = "lavaland_surface_seed_vault.dmm"
	cost = 10
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/ash_walker
	name = "Lava-Ruin Ash Walker Nest"
	id = "ash-walker"
	description = "A race of unbreathing lizards live here, that run faster than a human can, worship a broken dead city, and are capable of reproducing by something involving tentacles? \
	Probably best to stay clear."
	suffix = "lavaland_surface_ash_walker1.dmm"
	cost = 20
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/syndicate_base
	name = "Lava-Ruin Syndicate Lava Base"
	id = "lava-base"
	description = "A secret base researching illegal bioweapons, it is closely guarded by an elite team of syndicate agents."
	suffix = "lavaland_surface_syndicate_base1.dmm"
	cost = 20
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/free_golem
	name = "Lava-Ruin Free Golem Ship"
	id = "golem-ship"
	description = "Lumbering humanoids, made out of precious metals, move inside this ship. They frequently leave to mine more minerals, which they somehow turn into more of them. \
	Seem very intent on research and individual liberty, and also geology-based naming?"
	cost = 20
	prefix = "_maps/RandomRuins/AnywhereRuins/"
	suffix = "golem_ship.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/gaia
	name = "Lava-Ruin Patch of Eden"
	id = "gaia"
	description = "Who would have thought that such a peaceful place could be on such a horrific planet?"
	cost = 5
	suffix = "lavaland_surface_gaia.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/sin
	cost = 10
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/sin/envy
	name = "Lava-Ruin Ruin of Envy"
	id = "envy"
	description = "When you get what they have, then you'll finally be happy."
	suffix = "lavaland_surface_envy.dmm"

/datum/map_template/ruin/lavaland/sin/gluttony
	name = "Lava-Ruin Ruin of Gluttony"
	id = "gluttony"
	description = "If you eat enough, then eating will be all that you do."
	suffix = "lavaland_surface_gluttony.dmm"

/datum/map_template/ruin/lavaland/sin/greed
	name = "Lava-Ruin Ruin of Greed"
	id = "greed"
	description = "Sure you don't need magical powers, but you WANT them, and \
		that's what's important."
	suffix = "lavaland_surface_greed.dmm"

/datum/map_template/ruin/lavaland/sin/pride
	name = "Lava-Ruin Ruin of Pride"
	id = "pride"
	description = "Wormhole lifebelts are for LOSERS, whom you are better than."
	suffix = "lavaland_surface_pride.dmm"

/datum/map_template/ruin/lavaland/sin/sloth
	name = "Lava-Ruin Ruin of Sloth"
	id = "sloth"
	description = "..."
	suffix = "lavaland_surface_sloth.dmm"
	// Generates nothing but atmos runtimes and salt
	cost = 0

/datum/map_template/ruin/lavaland/ratvar
	name = "Lava-Ruin Dead God"
	id = "ratvar"
	description = "Ratvar's final resting place."
	suffix = "lavaland_surface_dead_ratvar.dmm"
	cost = 0
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/hierophant
	name = "Lava-Ruin Hierophant's Arena"
	id = "hierophant"
	description = "A strange, square chunk of metal of massive size. Inside awaits only death and many, many squares."
	suffix = "lavaland_surface_hierophant.dmm"
	always_place = TRUE
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/blood_drunk_miner
	name = "Lava-Ruin Blood-Drunk Miner"
	id = "blooddrunk"
	description = "A strange arrangement of stone tiles and an insane, beastly miner contemplating them."
	suffix = "lavaland_surface_blooddrunk1.dmm"
	cost = 0
	allow_duplicates = FALSE //will only spawn one variant of the ruin

/datum/map_template/ruin/lavaland/blood_drunk_miner/guidance
	name = "Lava-Ruin Blood-Drunk Miner (Guidance)"
	suffix = "lavaland_surface_blooddrunk2.dmm"

/datum/map_template/ruin/lavaland/blood_drunk_miner/hunter
	name = "Lava-Ruin Blood-Drunk Miner (Hunter)"
	suffix = "lavaland_surface_blooddrunk3.dmm"

/datum/map_template/ruin/lavaland/blood_drunk_miner/random
	name = "Lava-Ruin Blood-Drunk Miner (Random)"
	suffix = null
	always_place = TRUE

/datum/map_template/ruin/lavaland/blood_drunk_miner/random/New()
	suffix = pick("lavaland_surface_blooddrunk1.dmm", "lavaland_surface_blooddrunk2.dmm", "lavaland_surface_blooddrunk3.dmm")
	return ..()

/datum/map_template/ruin/lavaland/ufo_crash
	name = "Lava-Ruin UFO Crash"
	id = "ufo-crash"
	description = "Turns out that keeping your abductees unconscious is really important. Who knew?"
	suffix = "lavaland_surface_ufo_crash.dmm"
	cost = 5

/datum/map_template/ruin/lavaland/xeno_nest
	name = "Lava-Ruin Xenomorph Nest"
	id = "xeno-nest"
	description = "These xenomorphs got bored of horrifically slaughtering people on space stations, and have settled down on a nice lava-filled hellscape to focus on what's really important in life. \
	Quality memes."
	suffix = "lavaland_surface_xeno_nest.dmm"
	cost = 20

/datum/map_template/ruin/lavaland/fountain
	name = "Lava-Ruin Fountain Hall"
	id = "lava_fountain"
	description = "The fountain has a warning on the side. DANGER: May have undeclared side effects that only become obvious when implemented."
	prefix = "_maps/RandomRuins/AnywhereRuins/"
	suffix = "fountain_hall.dmm"
	cost = 5

/datum/map_template/ruin/lavaland/survivalcapsule
	name = "Lava-Ruin Survival Capsule Ruins"
	id = "survivalcapsule"
	description = "What was once sanctuary to the common miner, is now their tomb."
	suffix = "lavaland_surface_survivalpod.dmm"
	cost = 5

/datum/map_template/ruin/lavaland/pizza
	name = "Lava-Ruin Ruined Pizza Party"
	id = "pizza"
	description = "Little Timmy's birthday pizza bash took a turn for the worse when a bluespace anomaly passed by."
	suffix = "lavaland_surface_pizzaparty.dmm"
	allow_duplicates = FALSE
	cost = 5

/datum/map_template/ruin/lavaland/cultaltar
	name = "Lava-Ruin Summoning Ritual"
	id = "cultaltar"
	description = "A place of vile worship, the scrawling of blood in the middle glowing eerily. A demonic laugh echoes throughout the caverns."
	suffix = "lavaland_surface_cultaltar.dmm"
	allow_duplicates = FALSE
	cost = 10

/datum/map_template/ruin/lavaland/hermit
	name = "Lava-Ruin Makeshift Shelter"
	id = "hermitcave"
	description = "A place of shelter for a lone hermit, scraping by to live another day."
	suffix = "lavaland_surface_hermit.dmm"
	allow_duplicates = FALSE
	cost = 10

/datum/map_template/ruin/lavaland/miningripley
	name = "Lava-Ruin Ripley"
	id = "ripley"
	description = "A heavily-damaged mining ripley, property of a very unfortunate miner. You might have to do a bit of work to fix this thing up."
	suffix = "lavaland_surface_random_ripley.dmm"
	allow_duplicates = FALSE
	cost = 5

/datum/map_template/ruin/lavaland/dark_wizards
	name = "Lava-Ruin Dark Wizard Altar"
	id = "dark_wizards"
	description = "A ruin with dark wizards. What secret do they guard?"
	suffix = "lavaland_surface_wizard.dmm"
	cost = 5

/datum/map_template/ruin/lavaland/strong_stone
	name = "Lava-Ruin Strong Stone"
	id = "strong_stone"
	description = "A stone that seems particularly powerful."
	suffix = "lavaland_strong_rock.dmm"
	allow_duplicates = FALSE
	cost = 2

/datum/map_template/ruin/lavaland/puzzle
	name = "Lava-Ruin Ancient Puzzle"
	id = "puzzle"
	description = "Mystery to be solved."
	suffix = "lavaland_surface_puzzle.dmm"
	cost = 5

/datum/map_template/ruin/lavaland/elite_tumor
	name = "Lava-Ruin Pulsating Tumor"
	id = "tumor"
	description = "A strange tumor which houses a powerful beast..."
	suffix = "lavaland_surface_elite_tumor.dmm"
	cost = 5
	always_place = TRUE
	allow_duplicates = TRUE

/datum/map_template/ruin/lavaland/elephant_graveyard
	name = "Lava-Ruin Elephant Graveyard"
	id = "Graveyard"
	description = "An abandoned graveyard, calling to those unable to continue."
	suffix = "lavaland_surface_elephant_graveyard.dmm"
	allow_duplicates = FALSE
	cost = 10

/datum/map_template/ruin/lavaland/bileworm_nest
	name = "Lava-Ruin Bileworm Nest"
	id = "bileworm_nest"
	description = "A small sanctuary from the harsh wilderness... if you're a bileworm, that is."
	cost = 5
	suffix = "lavaland_surface_bileworm_nest.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/lava_phonebooth
	name = "Lava-Ruin Phonebooth"
	id = "lava_phonebooth"
	description = "A venture by nanotrasen to help popularize the use of holopads. This one somehow made its way here."
	suffix = "lavaland_surface_phonebooth.dmm"
	allow_duplicates = FALSE
	cost = 5

/datum/map_template/ruin/lavaland/battle_site
	name = "Lava-Ruin Battle Site"
	id = "battle_site"
	description = "The long past site of a battle between beast and humanoids. The victor is unknown, but the losers are clear."
	suffix = "lavaland_battle_site.dmm"
	allow_duplicates = TRUE
	cost = 3

/datum/map_template/ruin/lavaland/vent
	name = "Lava-Ruin Ore Vent"
	id = "ore_vent"
	description = "A vent that spews out ore. Seems to be a natural phenomenon."
	suffix = "lavaland_surface_ore_vent.dmm"
	allow_duplicates = TRUE
	cost = 0
	mineral_cost = 1
	always_place = TRUE

/datum/map_template/ruin/lavaland/watcher_grave
	name = "Lava-Ruin Watchers' Grave"
	id = "watcher-grave"
	description = "A lonely cave where an orphaned child awaits a new parent."
	suffix = "lavaland_surface_watcher_grave.dmm"
	cost = 5
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/mook_village
	name = "Lava-Ruin Mook Village"
	id = "mook_village"
	description = "A village hosting a community of friendly mooks!"
	suffix = "lavaland_surface_mookvillage.dmm"
	allow_duplicates = FALSE
	cost = 5

/datum/map_template/ruin/lavaland/shuttle_wreckage
	name = "Lava-Ruin Shuttle Wreckage"
	id = "shuttle_wreckage"
	description = "Not every shuttle makes it back to CentCom."
	suffix = "lavaland_surface_shuttle_wreckage.dmm"
	allow_duplicates = FALSE
