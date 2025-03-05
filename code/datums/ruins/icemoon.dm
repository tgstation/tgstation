// Hey! Listen! Update \config\iceruinblacklist.txt with your new ruins!

/datum/map_template/ruin/icemoon
	prefix = "_maps/RandomRuins/IceRuins/"
	allow_duplicates = FALSE
	cost = 5
	ruin_type = ZTRAIT_ICE_RUINS
	default_area = /area/icemoon/surface/outdoors/unexplored
	has_ceiling = TRUE
	ceiling_turf = /turf/closed/mineral/snowmountain/do_not_chasm
	ceiling_baseturfs = list(/turf/open/misc/asteroid/snow/icemoon/do_not_chasm)

// above ground only

/datum/map_template/ruin/icemoon/gas
	name = "Ice-Ruin Lizard Gas Station"
	id = "lizgasruin"
	description = "A gas station. It appears to have been recently open and is in mint condition."
	suffix = "icemoon_surface_gas.dmm"

/datum/map_template/ruin/icemoon/lust
	name = "Ice-Ruin Ruin of Lust"
	id = "lust"
	description = "Not exactly what you expected."
	suffix = "icemoon_surface_lust.dmm"

/datum/map_template/ruin/icemoon/asteroid
	name = "Ice-Ruin Asteroid Site"
	id = "asteroidsite"
	description = "Surprised to see us here?"
	suffix = "icemoon_surface_asteroid.dmm"

/datum/map_template/ruin/icemoon/engioutpost
	name = "Ice-Ruin Engineer Outpost"
	id = "engioutpost"
	description = "Blown up by an unfortunate accident."
	suffix = "icemoon_surface_engioutpost.dmm"

/datum/map_template/ruin/icemoon/fountain
	name = "Ice-Ruin Fountain Hall"
	id = "ice_fountain"
	description = "The fountain has a warning on the side. DANGER: May have undeclared side effects that only become obvious when implemented."
	prefix = "_maps/RandomRuins/AnywhereRuins/"
	suffix = "fountain_hall.dmm"

/datum/map_template/ruin/icemoon/abandoned_homestead
	name = "Ice-Ruin Abandoned Homestead"
	id = "abandoned_homestead"
	description = "This homestead was once host to a happy homesteading family. It's now host to hungry bears."
	suffix = "icemoon_underground_abandoned_homestead.dmm"

/datum/map_template/ruin/icemoon/entemology
	name = "Ice-Ruin Insect Research Station"
	id = "bug_habitat"
	description = "An independently funded research outpost, long abandoned. Their mission, to boldly go where no insect life would ever live, ever, and look for bugs."
	suffix = "icemoon_surface_bughabitat.dmm"

/datum/map_template/ruin/icemoon/pizza
	name = "Ice-Ruin Moffuchi's Pizzeria"
	id = "pizzeria"
	description = "Moffuchi's Family Pizzeria chain has a reputation for providing affordable artisanal meals of questionable edibility. This particular pizzeria seems to have been abandoned for some time."
	suffix = "icemoon_surface_pizza.dmm"

/datum/map_template/ruin/icemoon/Lodge
	name = "Ice-Ruin Hunters Lodge"
	id = "lodge"
	description = "An old hunting lodge. I wonder if anyone is still home?"
	suffix = "icemoon_surface_lodge.dmm"

/datum/map_template/ruin/icemoon/frozen_phonebooth
	name = "Ice-Ruin Frozen Phonebooth"
	id = "frozen_phonebooth"
	description = "A venture by Nanotrasen to help popularize the use of holopads. This one was sent to an ice moon."
	suffix = "icemoon_surface_phonebooth.dmm"

/datum/map_template/ruin/icemoon/smoking_room
	name = "Ice-Ruin Smoking Room"
	id = "smoking_room"
	description = "Here lies Charles Morlbaro. He died the way he lived."
	suffix = "icemoon_surface_smoking_room.dmm"

// above and below ground together

/datum/map_template/ruin/icemoon/mining_site
	name = "Ice-Ruin Mining Site"
	id = "miningsite"
	description = "Ruins of a site where people once mined with primitive tools for ore."
	suffix = "icemoon_surface_mining_site.dmm"
	always_place = TRUE
	always_spawn_with = list(/datum/map_template/ruin/icemoon/underground/mining_site_below = PLACE_BELOW)

/datum/map_template/ruin/icemoon/underground/mining_site_below
	name = "Ice-Ruin Mining Site Underground"
	id = "miningsite-underground"
	description = "Who knew ladders could be so useful?"
	suffix = "icemoon_underground_mining_site.dmm"
	has_ceiling = FALSE
	unpickable = TRUE

// below ground only

/datum/map_template/ruin/icemoon/underground
	name = "Ice-Ruin underground ruin"
	ruin_type = ZTRAIT_ICE_RUINS_UNDERGROUND
	default_area = /area/icemoon/underground/unexplored

/datum/map_template/ruin/icemoon/underground/abandonedvillage
	name = "Ice-Ruin Abandoned Village"
	id = "abandonedvillage"
	description = "Who knows what lies within?"
	suffix = "icemoon_underground_abandoned_village.dmm"

/datum/map_template/ruin/icemoon/underground/library
	name = "Ice-Ruin Buried Library"
	id = "buriedlibrary"
	description = "A once grand library, now lost to the confines of the Ice Moon."
	suffix = "icemoon_underground_library.dmm"

/datum/map_template/ruin/icemoon/underground/wrath
	name = "Ice-Ruin Ruin of Wrath"
	id = "wrath"
	description = "You'll fight and fight and just keep fighting."
	suffix = "icemoon_underground_wrath.dmm"

/datum/map_template/ruin/icemoon/underground/hermit
	name = "Ice-Ruin Frozen Shack"
	id = "hermitshack"
	description = "A place of shelter for a lone hermit, scraping by to live another day."
	suffix = "icemoon_underground_hermit.dmm"

/datum/map_template/ruin/icemoon/underground/lavaland
	name = "Ice-Ruin Lavaland Incursion"
	id = "lavalandsite"
	description = "I guess we never really left you huh?"
	suffix = "icemoon_underground_lavaland.dmm"

/datum/map_template/ruin/icemoon/underground/puzzle
	name = "Ice-Ruin Ancient Puzzle"
	id = "puzzle"
	description = "Mystery to be solved."
	suffix = "icemoon_underground_puzzle.dmm"

/datum/map_template/ruin/icemoon/underground/bathhouse
	name = "Ice-Ruin Bath House"
	id = "bathhouse"
	description = "A warm, safe place."
	suffix = "icemoon_underground_bathhouse.dmm"

/datum/map_template/ruin/icemoon/underground/wendigo_cave
	name = "Ice-Ruin Wendigo Cave"
	id = "wendigocave"
	description = "Into the jaws of the beast."
	suffix = "icemoon_underground_wendigo_cave.dmm"

/datum/map_template/ruin/icemoon/underground/free_golem
	name = "Ice-Ruin Free Golem Ship"
	id = "golem-ship"
	description = "Lumbering humanoids, made out of precious metals, move inside this ship. They frequently leave to mine more minerals, which they somehow turn into more of them. \
	Seem very intent on research and individual liberty, and also geology-based naming?"
	prefix = "_maps/RandomRuins/AnywhereRuins/"
	suffix = "golem_ship.dmm"

/datum/map_template/ruin/icemoon/underground/mailroom
	name = "Ice-Ruin Frozen-over Post Office"
	id = "mailroom"
	description = "This is where all of your paychecks went. Signed, the management."
	suffix = "icemoon_underground_mailroom.dmm"

/datum/map_template/ruin/icemoon/underground/biodome
	name = "Ice-Ruin Syndicate Bio-Dome"
	id = "biodome"
	description = "Unchecked experimentation gone awry."
	suffix = "icemoon_underground_syndidome.dmm"

/datum/map_template/ruin/icemoon/underground/frozen_comms
	name = "Ice-Ruin Frozen Communicatons Outpost"
	id = "frozen_comms"
	description = "3 Peaks Radio, where the 2000's live forever."
	suffix = "icemoon_underground_frozen_comms.dmm"

/datum/map_template/ruin/icemoon/underground/comms_agent
	name = "Ice-Ruin Listening Post"
	id = "icemoon_comms_agent"
	description = "Radio signals are being detected and the source is this completely innocent pile of snow."
	suffix = "icemoon_underground_comms_agent.dmm"

/datum/map_template/ruin/icemoon/underground/syndie_lab
	name = "Ice-Ruin Syndicate Lab"
	id = "syndie_lab"
	description = "A small laboratory and living space for Syndicate agents."
	suffix = "icemoon_underground_syndielab.dmm"

/datum/map_template/ruin/icemoon/underground/o31
	name = "Ice-Ruin Outpost 31"
	id = "o31"
	description = "Suspiciously dead silent. May or may not contain megafauna"
	suffix = "icemoon_underground_outpost31.dmm"

//TODO: Bottom-Level ONLY Spawns after Refactoring Related Code
/datum/map_template/ruin/icemoon/underground/plasma_facility
	name = "Ice-Ruin Abandoned Plasma Facility"
	id = "plasma_facility"
	description = "Rumors have developed over the many years of Freyja plasma mining. These rumors suggest that the ghosts of dead mistreated excavation staff have returned to \
	exact revenge on their (now former) employers. Coorperate reminds all staff that rumors are just that: Old Housewife tales meant to scare misbehaving kids to bed."
	suffix = "icemoon_underground_abandoned_plasma_facility.dmm"

/datum/map_template/ruin/icemoon/underground/hotsprings
	name = "Ice-Ruin Hot Springs"
	id = "hotsprings"
	description = "Just relax and take a dip, nothing will go wrong, I swear!"
	suffix = "icemoon_underground_hotsprings.dmm"

/datum/map_template/ruin/icemoon/underground/vent
	name = "Ice-Ruin Icemoon Ore Vent"
	id = "ore_vent_i"
	description = "A vent that spews out ore. Seems to be a natural phenomenon." //Make this a subtype that only spawns medium and large vents. Some smalls will go to the top level.
	suffix = "icemoon_underground_ore_vent.dmm"
	allow_duplicates = TRUE
	cost = 0
	mineral_cost = 1
	always_place = TRUE

/datum/map_template/ruin/icemoon/ruin/vent
	name = "Ice-Ruin Surface Icemoon Ore Vent"
	id = "ore_vent_i"
	description = "A vent that spews out ore. Seems to be a natural phenomenon. Smaller than the underground ones."
	suffix = "icemoon_surface_ore_vent.dmm"
	allow_duplicates = TRUE
	cost = 0
	mineral_cost = 1
	always_place = TRUE
