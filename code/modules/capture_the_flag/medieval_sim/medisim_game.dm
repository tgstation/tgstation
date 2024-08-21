///These are for the medisim shuttle

#define REDFIELD_TEAM "Red"
#define BLUESWORTH_TEAM "Blue"

///Variant of the CTF spawner used for the medieval simulation shuttle.
/obj/machinery/ctf/spawner/medisim
	game_id = CTF_MEDISIM_CTF_GAME_ID
	ammo_type = null
	player_traits = list()

/obj/machinery/ctf/spawner/medisim/Initialize(mapload)
	. = ..()
	ctf_game.setup_rules(victory_rejoin_text = "Teams have been cleared. The next game is starting automatically. Rejoin a team if you wish!", auto_restart = TRUE)

/obj/machinery/ctf/spawner/medisim/post_machine_initialize()
	. = ..()
	ctf_game.start_ctf()

/obj/machinery/ctf/spawner/medisim/spawn_team_member(client/new_team_member)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/human_knight = .
	randomize_human_normie(human_knight)
	human_knight.dna.add_mutation(/datum/mutation/human/medieval, MUT_OTHER)
	var/oldname = human_knight.name
	var/title = "error"
	switch (human_knight.gender)
		if (MALE)
			title = pick(list("Sir", "Lord"))
		if (FEMALE)
			title = pick(list("Dame", "Lady"))
		else
			title = "Noble"
	human_knight.real_name = "[title] [oldname]"
	human_knight.name = human_knight.real_name

/obj/machinery/ctf/spawner/medisim/red
	name = "\improper Redfield Data Realizer"
	icon_state = "syndbeacon"
	team = REDFIELD_TEAM
	team_span = "redteamradio"
	ctf_gear = list("knight" = /datum/outfit/ctf/medisim, "archer" = /datum/outfit/ctf/medisim/archer)

/obj/machinery/ctf/spawner/medisim/blue
	name = "\improper Bluesworth Data Realizer"
	icon_state = "bluebeacon"
	team = BLUESWORTH_TEAM
	team_span = "blueteamradio"
	ctf_gear = list("knight" = /datum/outfit/ctf/medisim/blue, "archer" = /datum/outfit/ctf/medisim/archer/blue)

/obj/item/ctf_flag/red/medisim
	name = "\improper Redfield Castle Fair Maiden"
	desc = "Protect your maiden, and capture theirs!"
	icon = 'icons/obj/toys/plushes.dmi'
	icon_state = "plushie_nuke"
	force = 0
	movement_type = FLOATING //there are chasms, and resetting when they fall in is really lame so lets minimize that
	game_id = CTF_MEDISIM_CTF_GAME_ID

/obj/item/ctf_flag/blue/medisim
	name = "\improper Bluesworth Hold Fair Maiden"
	desc = "Protect your maiden, and capture theirs!"
	icon = 'icons/obj/toys/plushes.dmi'
	icon_state = "map_plushie_slime"
	greyscale_config = /datum/greyscale_config/plush_slime
	greyscale_colors = "#3399ff#000000"
	force = 0
	movement_type = FLOATING //there are chasms, and resetting when they fall in is really lame so lets minimize that
	game_id = CTF_MEDISIM_CTF_GAME_ID

#undef REDFIELD_TEAM
#undef BLUESWORTH_TEAM
