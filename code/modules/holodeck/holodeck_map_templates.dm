
/datum/map_template/holodeck
	/// id
	var/template_id
	/// Is this an emag program
	var/restricted = FALSE

	should_place_on_top = FALSE
	returns_created_atoms = TRUE
	keep_cached_map = TRUE

/datum/map_template/holodeck/offline
	name = "Holodeck - Offline"
	template_id = "holodeck_offline"
	mappath = "_maps/templates/holodeck_offline.dmm"

/datum/map_template/holodeck/emptycourt
	name = "Holodeck - Empty Court"
	template_id = "holodeck_emptycourt"
	mappath = "_maps/templates/holodeck_emptycourt.dmm"

/datum/map_template/holodeck/dodgeball
	name = "Holodeck - Dodgeball Court"
	template_id = "holodeck_dodgeball"
	mappath = "_maps/templates/holodeck_dodgeball.dmm"

/datum/map_template/holodeck/basketball
	name = "Holodeck - Basketball Court"
	template_id = "holodeck_basketball"
	mappath = "_maps/templates/holodeck_basketball.dmm"

/datum/map_template/holodeck/thunderdome
	name = "Holodeck - Thunderdome Arena"
	template_id = "holodeck_thunderdome"
	mappath = "_maps/templates/holodeck_thunderdome.dmm"

/datum/map_template/holodeck/beach
	name = "Holodeck - Beach"
	template_id = "holodeck_beach"
	mappath = "_maps/templates/holodeck_beach.dmm"

/datum/map_template/holodeck/lounge
	name = "Holodeck - Lounge"
	template_id = "holodeck_lounge"
	mappath = "_maps/templates/holodeck_lounge.dmm"

/datum/map_template/holodeck/petpark
	name = "Holodeck - Pet Park"
	template_id = "holodeck_petpark"
	mappath = "_maps/templates/holodeck_petpark.dmm"

/datum/map_template/holodeck/firingrange
	name = "Holodeck - Firing Range"
	template_id = "holodeck_firingrange"
	mappath = "_maps/templates/holodeck_firingrange.dmm"

/datum/map_template/holodeck/anime_school
	name = "Holodeck - Anime School"
	template_id = "holodeck_animeschool"
	mappath = "_maps/templates/holodeck_animeschool.dmm"

/datum/map_template/holodeck/chapelcourt
	name = "Holodeck - Chapel Courtroom"
	template_id = "holodeck_chapelcourt"
	mappath = "_maps/templates/holodeck_chapelcourt.dmm"

/datum/map_template/holodeck/spacechess
	name = "Holodeck - Space Chess"
	template_id = "holodeck_spacechess"
	mappath = "_maps/templates/holodeck_spacechess.dmm"

/datum/map_template/holodeck/spacecheckers
	name = "Holodeck - Space Checkers"
	template_id = "holodeck_spacecheckers"
	mappath = "_maps/templates/holodeck_spacecheckers.dmm"

/datum/map_template/holodeck/kobayashi
	name = "Holodeck - Kobayashi Maru"
	template_id = "holodeck_kobayashi"
	mappath = "_maps/templates/holodeck_kobayashi.dmm"

/datum/map_template/holodeck/winterwonderland
	name = "Holodeck - Winter Wonderland"
	template_id = "holodeck_winterwonderland"
	mappath = "_maps/templates/holodeck_winterwonderland.dmm"

/datum/map_template/holodeck/photobooth
	name = "Holodeck - Photobooth"
	template_id = "holodeck_photobooth"
	mappath = "_maps/templates/holodeck_photobooth.dmm"

/datum/map_template/holodeck/skatepark
	name = "Holodeck - Skatepark"
	template_id = "holodeck_skatepark"
	mappath = "_maps/templates/holodeck_skatepark.dmm"

/datum/map_template/holodeck/microwave
	name = "Holodeck - Microwave Paradise"
	template_id = "holodeck_microwave"
	mappath = "_maps/templates/holodeck_microwave.dmm"

/datum/map_template/holodeck/baseball
	name = "Holodeck - Baseball Field"
	template_id = "holodeck_baseball"
	mappath = "_maps/templates/holodeck_baseball.dmm"

/datum/map_template/holodeck/card_battle
	name = "Holodeck - TGC Battle Arena"
	template_id = "holodeck_card_battle"
	mappath = "_maps/templates/holodeck_card_battle.dmm"

//bad evil no good programs

/datum/map_template/holodeck/medicalsim
	name = "Holodeck - Emergency Medical"
	template_id = "holodeck_medicalsim"
	mappath = "_maps/templates/holodeck_medicalsim.dmm"
	restricted = TRUE

/datum/map_template/holodeck/thunderdome1218
	name = "Holodeck - 1218 AD"
	template_id = "holodeck_thunderdome1218"
	mappath = "_maps/templates/holodeck_thunderdome1218.dmm"
	restricted = TRUE

/datum/map_template/holodeck/burntest
	name = "Holodeck - Atmospheric Burn Test"
	template_id = "holodeck_burntest"
	mappath = "_maps/templates/holodeck_burntest.dmm"
	restricted = TRUE

/datum/map_template/holodeck/wildlifesim
	name = "Holodeck - Wildlife Simulation"
	template_id = "holodeck_wildlifesim"
	mappath = "_maps/templates/holodeck_wildlifesim.dmm"
	restricted = TRUE

/datum/map_template/holodeck/holdoutbunker
	name = "Holodeck - Holdout Bunker"
	template_id = "holodeck_holdoutbunker"
	mappath = "_maps/templates/holodeck_holdoutbunker.dmm"
	restricted = TRUE

/datum/map_template/holodeck/anthophillia
	name = "Holodeck - Anthophillia"
	template_id = "holodeck_anthophillia"
	mappath = "_maps/templates/holodeck_anthophillia.dmm"
	restricted = TRUE

/datum/map_template/holodeck/refuelingstation
	name = "Holodeck - Refueling Station"
	template_id = "holodeck_refuelingstation"
	mappath = "_maps/templates/holodeck_refuelingstation.dmm"
	restricted = TRUE
