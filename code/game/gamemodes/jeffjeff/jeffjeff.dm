/datum/game_mode/jeffjeff
	name = "jeffjeff"
	config_tag = "jeffjeff"
	required_players = 0

	announce_span = "danger"
	announce_text = "This must be the work of an enemy guardian!"

/datum/game_mode/jeffjeff/post_setup()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(H.client && H.mind)
			var/datum/antagonist/joejoe/guardian_user = new()
			H.mind.add_antag_datum(guardian_user)
	..()
