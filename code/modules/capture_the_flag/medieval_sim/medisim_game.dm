///These are for the medisim shuttle

#define REDFIELD_TEAM "Red"
#define BLUESWORTH_TEAM "Blue"

/obj/machinery/capture_the_flag/medisim
	game_id = "medieval"
	game_area = /area/shuttle/escape/simulation
	ammo_type = null //no guns, no need
	victory_rejoin_text = "<span class='userdanger'>Teams have been cleared. The next game is starting automatically. Rejoin a team if you wish!</span>"
	player_traits = list()

/obj/machinery/capture_the_flag/medisim/Initialize(mapload)
	. = ..()
	start_ctf() //both machines initialize, so both will call start_ctf instead of toggle_id_ctf calling it for both, twice.

/obj/machinery/capture_the_flag/medisim/victory()
	. = ..()
	toggle_id_ctf(null, game_id, automated = TRUE)//only one machine runs the victory proc, start_ctf proc would break the other machine

// We don't clean up for the medisim.
/obj/machinery/capture_the_flag/medisim/reset_the_arena()
	return

/obj/machinery/capture_the_flag/medisim/spawn_team_member(client/new_team_member)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/human_knight = .
	randomize_human(human_knight)
	human_knight.dna.update_dna_identity()
	human_knight.dna.add_mutation(MEDIEVAL, MUT_OTHER)
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

/obj/machinery/capture_the_flag/medisim/red
	name = "\improper Redfield Data Realizer"
	icon_state = "syndbeacon"
	team = REDFIELD_TEAM
	team_span = "redteamradio"
	ctf_gear = list("knight" = /datum/outfit/ctf/medisim, "archer" = /datum/outfit/ctf/medisim/archer)

/obj/machinery/capture_the_flag/medisim/blue
	name = "\improper Bluesworth Data Realizer"
	icon_state = "bluebeacon"
	team = BLUESWORTH_TEAM
	team_span = "blueteamradio"
	ctf_gear = list("knight" = /datum/outfit/ctf/medisim/blue, "archer" = /datum/outfit/ctf/medisim/archer/blue)

/obj/item/ctf/red/medisim
	name = "\improper Redfield Castle Fair Maiden"
	desc = "Protect your maiden, and capture theirs!"
	icon = 'icons/obj/plushes.dmi'
	icon_state = "plushie_nuke"
	force = 0
	game_area = /area/shuttle/escape
	movement_type = FLOATING //there are chasms, and resetting when they fall in is really lame so lets minimize that

/obj/item/ctf/blue/medisim
	name = "\improper Bluesworth Hold Fair Maiden"
	desc = "Protect your maiden, and capture theirs!"
	icon = 'icons/obj/plushes.dmi'
	icon_state = "plushie_slime"
	force = 0
	game_area = /area/shuttle/escape
	movement_type = FLOATING //there are chasms, and resetting when they fall in is really lame so lets minimize that

#undef REDFIELD_TEAM
#undef BLUESWORTH_TEAM
