// Hey! Listen! Update \config\iceruinblacklist.txt with your new ruins!

/datum/map_template/ruin/icemoon
	prefix = "_maps/RandomRuins/IceRuins/"
	allow_duplicates = FALSE

// above ground only

/datum/map_template/ruin/icemoon/seed_vault
	name = "Seed Vault"
	id = "seed-vault"
	description = "The creators of these vaults were a highly advanced and benevolent race, and launched many into the stars, hoping to aid fledgling civilizations. \
	However, all the inhabitants seem to do is grow drugs and guns."
	suffix = "icemoon_surface_seed_vault.dmm"
	cost = 10

/datum/map_template/ruin/icemoon/ufo_crash
	name = "UFO Crash"
	id = "ufo-crash"
	description = "Turns out that keeping your abductees unconscious is really important. Who knew?"
	suffix = "icemoon_surface_ufo_crash.dmm"
	cost = 5

/datum/map_template/ruin/icemoon/ash_walker
	name = "Ash Walker Nest"
	id = "ash-walker"
	description = "A race of unbreathing lizards live here, that run faster than a human can, worship a broken dead city, and are capable of reproducing by something involving tentacles? \
	Probably best to stay clear."
	suffix = "icemoon_surface_ash_walker1.dmm"
	cost = 20
	allow_duplicates = FALSE

/datum/map_template/ruin/icemoon/cultaltar
	name = "Summoning Ritual"
	id = "cultaltar"
	description = "A place of vile worship, the scrawling of blood in the middle glowing eerily. A demonic laugh echoes throughout the caverns."
	suffix = "icemoon_surface_cultaltar.dmm"
	allow_duplicates = FALSE
	cost = 5

/datum/map_template/ruin/icemoon/elite_tumor
	name = "Pulsating Tumor"
	id = "tumor"
	description = "A strange tumor which houses a powerful beast..."
	suffix = "icemoon_surface_elite_tumor.dmm"
	cost = 5
	always_place = TRUE
	allow_duplicates = TRUE

/datum/map_template/ruin/icemoon/fountain
	name = "Fountain Hall"
	id = "fountain"
	description = "The fountain has a warning on the side. DANGER: May have undeclared side effects that only become obvious when implemented."
	suffix = "icemoon_surface_fountain_hall.dmm"
	cost = 5

/datum/map_template/ruin/icemoon/gaia
	name = "Patch of Eden"
	id = "gaia"
	description = "Who would have thought that such a peaceful place could be on such a horrific planet?"
	cost = 5
	suffix = "icemoon_surface_gaia.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/icemoon/hierophant
	name = "Hierophant's Arena"
	id = "hierophant"
	description = "A strange, square chunk of metal of massive size. Inside awaits only death and many, many squares."
	suffix = "icemoon_surface_hierophant.dmm"
	always_place = TRUE
	allow_duplicates = FALSE

/datum/map_template/ruin/icemoon/puzzle
	name = "Ancient Puzzle"
	id = "puzzle"
	description = "Mystery to be solved."
	suffix = "icemoon_surface_puzzle.dmm"
	cost = 5

/datum/map_template/ruin/icemoon/miningripley
	name = "Ripley"
	id = "ripley"
	description = "A heavily-damaged mining ripley, property of a very unfortunate miner. You might have to do a bit of work to fix this thing up."
	suffix = "icemoon_surface_random_ripley.dmm"
	allow_duplicates = FALSE
	cost = 5

// above and below ground together

/datum/map_template/ruin/icemoon/mining_site
	name = "Mining Site"
	id = "miningsite"
	description = "Ruins of a site where people once mined with primitive tools for ore."
	suffix = "icemoon_surface_mining_site.dmm"
	always_place = TRUE // we need a ladder up and down don't we?
	always_spawn_with = list(/datum/map_template/ruin/icemoon/underground/mining_site_below = PLACE_BELOW)

/datum/map_template/ruin/icemoon/underground/mining_site_below
	name = "Mining Site Underground"
	id = "miningsite-underground"
	description = "Who knew ladders could be so useful?"
	suffix = "icemoon_underground_mining_site.dmm"
	unpickable = TRUE

// below ground only

/datum/map_template/ruin/icemoon/underground
	name = "underground ruin"

/datum/map_template/ruin/icemoon/underground/survivalcapsule
	name = "Survival Capsule Ruins"
	id = "survivalcapsule"
	description = "What was once sanctuary to the common miner, is now their tomb."
	suffix = "icemoon_underground_survivalpod.dmm"
	cost = 5

/datum/map_template/ruin/icemoon/underground/abandonedvillage
	name = "Abandoned Village"
	id = "abandonedvillage"
	description = "Who knows what lies within?"
	suffix = "icemoon_underground_abandoned_village.dmm"
	cost = 5

/datum/map_template/ruin/icemoon/underground/biodome
	cost = 5
	allow_duplicates = FALSE

/datum/map_template/ruin/icemoon/underground/biodome/beach
	name = "Biodome Beach"
	id = "biodome-beach"
	description = "Seemingly plucked from a tropical destination, this beach is calm and cool, with the salty waves roaring softly in the background. \
	Comes with a rustic wooden bar and suicidal bartender."
	suffix = "icemoon_biodome_beach.dmm"

/datum/map_template/ruin/icemoon/underground/biodome/clown
	name = "Biodome Clown Planet"
	id = "biodome-clown"
	description = "WELCOME TO CLOWN PLANET! HONK HONK HONK etc.!"
	suffix = "icemoon_biodome_clown_planet.dmm"

/datum/map_template/ruin/icemoon/underground/free_golem
	name = "Free Golem Ship"
	id = "golem-ship"
	description = "Lumbering humanoids, made out of precious metals, move inside this ship. They frequently leave to mine more minerals, which they somehow turn into more of them. \
	Seem very intent on research and individual liberty, and also geology-based naming?"
	cost = 20
	suffix = "icemoon_underground_golem_ship.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/icemoon/underground/hermit
	name = "Makeshift Shelter"
	id = "hermitcave"
	description = "A place of shelter for a lone hermit, scraping by to live another day."
	suffix = "icemoon_underground_hermit.dmm"
	allow_duplicates = FALSE
	cost = 10

/datum/map_template/ruin/icemoon/underground/syndicate_base
	name = "Syndicate Lava Base"
	id = "lava-base"
	description = "A secret base researching illegal bioweapons, it is closely guarded by an elite team of syndicate agents."
	suffix = "icemoon_underground_syndicate_base1.dmm"
	cost = 20
	allow_duplicates = FALSE