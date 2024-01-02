// Hey! Listen! Update \config\voidcrew\wastelandruins.txt with your new ruins!

/datum/map_template/ruin/wasteland
	prefix = "_maps/voidcrew/RandomRuins/WastelandRuins/"

/datum/map_template/ruin/wasteland/solgov_crash
	name = "Crashed SolGov Transport"
	id = "solgov-crash"
	description = "Not too long ago, a SolGov transporter shuttle needed to get from point A to point B, and not too long after getting near, someone decided \
					to see how maneuverable the famously unmaneuverable shuttles were."
	suffix = "wasteland_surface_solgovcrash.dmm"
	cost = 10
	allow_duplicates = FALSE

/datum/map_template/ruin/wasteland/hermit
	name = "Sandstone Cave"
	id = "hermitsandcave"
	description = "A place of shelter for a lone hermit, scraping by to live another day."
	suffix = "wasteland_surface_hermit.dmm"
	allow_duplicates = FALSE
	cost = 10

/datum/map_template/ruin/wasteland/abductor_crash
	name = "Crashed Abductor Ship"
	id = "ws-abductor-crash"
	description = "Turns out that keeping your abductees unconscious is really important. Who knew?"
	suffix = "wasteland_surface_abductor_crash.dmm"
	allow_duplicates = FALSE
	cost = 5

/datum/map_template/ruin/wasteland/blood_drunk_miner
	name = "Blood-Drunk Miner"
	id = "blooddrunk"
	description = "A strange arrangement of stone tiles and an insane, beastly miner contemplating them."
	suffix = "wasteland_surface_blooddrunk1.dmm"
	cost = 0
	allow_duplicates = FALSE //will only spawn one variant of the ruin

/datum/map_template/ruin/wasteland/blood_drunk_miner/guidance
	name = "Blood-Drunk Miner (Guidance)"
	suffix = "wasteland_surface_blooddrunk2.dmm"

/datum/map_template/ruin/wasteland/blood_drunk_miner/hunter
	name = "Blood-Drunk Miner (Hunter)"
	suffix = "wasteland_surface_blooddrunk3.dmm"

/datum/map_template/ruin/wasteland/seed_vault
	name = "Seed Vault"
	id = "seed-vault"
	description = "The creators of these vaults were a highly advanced and benevolent race, and launched many into the stars, hoping to aid fledgling civilizations. \
	However, all the inhabitants seem to do is grow drugs and guns."
	suffix = "wasteland_surface_seed_vault.dmm"
	cost = 10
	allow_duplicates = FALSE

/datum/map_template/ruin/wasteland/sin/envy
	name = "Ruin of Envy"
	id = "envy"
	description = "When you get what they have, then you'll finally be happy."
	suffix = "wasteland_surface_envy.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/wasteland/water
	name = "Abandoned Water Extraction Facility"
	id = "waterplant"
	description = "An abandoned building that seems to have once used prisoner labour to extract water for a colony."
	suffix = "wasteland_surface_waterplant.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/wasteland/starfury_crash
	name = "Starfury Crash"
	id = "starfurycrash"
	description = "The remains of an unidentified syndicate battleship has crashed here."
	suffix = "wasteland_surface_starfurycrash.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/wasteland/golem_hijack
	name = "Crashed Golem Ship"
	id = "golemcrash"
	description = "The remains of a mysterious ship, inhabited by strange lizardpeople and golems of some sort. Who knows what happened here."
	suffix = "wasteland_surface_golemhijack.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/wasteland/medipen_plant
	name = "Abandoned Medipen Factory"
	id = "medipenplant"
	description = "A once prosperous autoinjector manufacturing plant."
	suffix = "wasteland_surface_medipen_plant.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/wasteland/youreinsane
	name = "Lost Engine"
	id = "ws-youreinsane"
	description = "Nanotrasen would like to remind all employees that the Pi\[REDACTED\]er is not real."
	suffix = "wasteland_surface_youreinsane.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/wasteland/assaultpodcrash
	name = "Crashed Syndicate Assault Drop Pod"
	id = "ws-assaultpodcrash"
	description = "The fauna of desert planets can be deadly even to equipped Syndicate Operatives."
	suffix = "wasteland_surface_assaultpodcrash.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/wasteland/conveniencestore
	name = "Conveniently Abandoned Convenience Store"
	id = "ws-conveniencestore"
	description = "Pretty convenient that they have a convenience store out here, huh?"
	suffix = "wasteland_surface_conveniencestore.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/wasteland/onlyaspoonful
	name = "Abandoned Spoon Factory"
	id = "ws-onlyaspoonful"
	description = "Literally a fucking spoon factory"
	suffix = "wasteland_surface_onlyaspoonful.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/wasteland/chokepoint
	name = "Chokepoint"
	id = "ws-chokepoint"
	description = "Some sort of survivors, brandishing old nanotrasen security gear."
	suffix = "wasteland_surface_chokepoint.dmm"
	allow_duplicates = FALSE

//////////OUTSIDE SETTLEMENTS/RUINS//////////

/datum/map_template/ruin/wasteland/survivors/adobe
	name = "Native Adobe"
	id = "ws-survivors-adobe"
	description = "A semi-permanent settlement of survivors of the First Colony, and their descendants. Places like this often stash gear and supplies for their bretheren."
	suffix = "wasteland_surface_camp_adobe.dmm"
	cost = 10
	placement_weight = 0.5
	allow_duplicates = FALSE

/datum/map_template/ruin/wasteland/survivors/farm
	name = "Abandoned Farm"
	id = "ws-farm"
	description = "A abandoned farm, destroyed from years of shootouts and lack of maintenance."
	cost = 1
	placement_weight = 0.5
	suffix = "wasteland_surface_camp_farm.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/wasteland/survivors/drugstore
	name = "Abandoned Store"
	id = "ws-drugstore"
	description = "A store that once sold a variety of items and equipment."
	cost = 1
	placement_weight = 0.5
	suffix = "wasteland_surface_camp_drugstore.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/wasteland/survivors/saloon
	name = "Abandoned Saloon"
	id = "ws-saloon"
	description = "A western style saloon that has not been touched in years"
	cost = 1
	placement_weight = 0.5
	suffix = "wasteland_surface_camp_saloon.dmm"
	allow_duplicates = FALSE

//Crashed Shiptests//
/datum/map_template/ruin/wasteland/crash_bar
	name = "Crashed Bar"
	description = "A crashed part of some unlucky ship. Was once a bar."
	id = "crash-bar"
	suffix = "wasteland_surface_crash_bar.dmm"

/datum/map_template/ruin/wasteland/crash_cargo
	name = "Crashed Cargo Bay"
	description = "A crashed part of some unlucky ship. Has been taken over by pirates"
	id = "crash-cargo"
	suffix = "wasteland_surface_crash_cargo.dmm"

/datum/map_template/ruin/wasteland/soviets
	name = "Rock Soviets"
	id = "rocksoviets"
	description = "a nice little outpost."
	suffix = "wasteland_soviet.dmm"

/datum/map_template/ruin/wasteland/heirophant
	name = "Ancient Heirophant"
	id = "rockheiro"
	description = "something dangerous"
	suffix = "wasteland_heirophant.dmm"

/datum/map_template/ruin/wasteland/clock
	name = "Clockcult base"
	id = "clockcultrock"
	description = "the last remnants of a clockcult base on wasteland."
	suffix = "wasteland_clock.dmm"

/datum/map_template/ruin/wasteland/clowncrash
	name = "Crashed clown trading ship"
	id = "clowncrash"
	description = "some asshole decided to prank the pilot."
	suffix = "wasteland_clowncrash.dmm"

/datum/map_template/ruin/wasteland/cult
	name = "Cult base"
	id = "rockcult"
	description = "Cultists seem to have gotten here too."
	suffix = "wasteland_cult.dmm"


/datum/map_template/ruin/wasteland/dangerpod
	name = "Dangerous pod"
	id = "dangerpod"
	description = "A pod holding a dangerous threat."
	suffix = "wasteland_dangerpod.dmm"

/*	//TODO: MAKE THIS A MINOR RUIN
/datum/map_template/ruin/wasteland/pioneer
	name = "Krusty Krab Pizza"
	id = "pioneer"
	description = "The pioneers used to ride these babies for miles!"
	suffix = "wasteland_pioneer.dmm"
*/
/datum/map_template/ruin/wasteland/pod
	name = "Derelict pod"
	id = "oldpod"
	description = "A large, old pod."
	suffix = "wasteland_pod.dmm"

/datum/map_template/ruin/wasteland/tradepost
	name = "Tradepost"
	id = "oldpod"
	description = "A crashed tradepost."
	suffix = "wasteland_tradepost.dmm"

/datum/map_template/ruin/wasteland/wizard
	name = "wasteland wizard den"
	id = "rockwizard"
	description = "Wizards have reached all the ways out here too."
	suffix = "wasteland_wizard.dmm"

/datum/map_template/ruin/wasteland/house
	name = "baracaded house"
	id = "house"
	description = "Some sort of house, baracaded in. It must be baracaded for a reason.."
	suffix = "wasteland_house.dmm"

/datum/map_template/ruin/wasteland/moth
	name = "Storage Facility"
	id = "rockstorage"
	description = "Some sort of warehouse. It looks like somwhere down the line a ship full of moth plushes blew up."
	suffix = "wasteland_moth.dmm"

/datum/map_template/ruin/wasteland/daniel
	name = "Oh Hi Daniel"
	id = "daniel"
	description = "Mistakes were made.."
	suffix = "wasteland_daniel.dmm"

/datum/map_template/ruin/wasteland/mining_expedition
	name = "Mining Expedition"
	id = "expedition"
	description = "A mining operation gone wrong."
	suffix = "wasteland_miningexpedition.dmm"

/datum/map_template/ruin/wasteland/fortress
	name = "Fortress of Solitide"
	id = "solitude"
	description = "A fortress, although one you are probably more familiar with."
	suffix = "wasteland_fortress_of_solitide.dmm"

/datum/map_template/ruin/wasteland/oreprocess
	name = "Ore Processing Facility"
	id = "oreprocess"
	description = "A fortress, although one you are probably more familiar with.."
	suffix = "wasteland_ore_proccessing_facility.dmm"

/datum/map_template/ruin/wasteland/weaponstest
	name = "Weapons testing facility"
	id = "guntested"
	description = "A abandoned Nanotrasen weapons facility, presumably the place where the X-01 was manufactured."
	suffix = "wasteland_lab.dmm"

/datum/map_template/ruin/wasteland/radiation
	name = "Honorable deeds storage"
	id = "wasteland_radiation"
	description = "A dumping ground for nuclear waste."
	suffix = "wasteland_unhonorable.dmm"

/datum/map_template/ruin/wasteland/boxsci
	name = "Honorable deeds storage"
	id = "Abandoned science wing"
	description = "A chunk of a station that broke off.."
	suffix = "wasteland_boxsci.dmm"

/datum/map_template/ruin/wasteland/cult_templar
	id = "cult_templar"
	suffix = "wasteland_chaosmarine.dmm"
	name = "Bloody Lair"
	description = "Some old base. Besides the rust, it looks almost perfectly intact. But why was it abandoned?"

/datum/map_template/ruin/wasteland/rd_god
	id = "rd_god"
	suffix = "wasteland_rd_god.dmm"
	name = "Science experiment"
	description = "Research Director? The experiment to become god has fai-"

/datum/map_template/ruin/wasteland/pandora
	id = "pandora_arena"
	suffix = "wasteland_pandora.dmm"
	name = "Pandora Arena"
	description = "Some... thing has settled here."

/datum/map_template/ruin/wasteland/crash_kitchen
	name = "Crashed Kitchen"
	description = "A crashed part of some unlucky ship."
	id = "crash_kitchen"
	suffix = "wasteland_crash_kitchen.dmm"

/datum/map_template/ruin/wasteland/crash_cult
	name = "Crashed Cult Ship"
	description = "A crashed part of some unlucky ship. Has been occupied by a cult."
	id = "crash_cult"
	suffix = "wasteland_crash_cult.dmm"
