/*
 * GAMEMODES (by Rastaf0)
 * 
 * In the new mode system all special roles are fully supported.
 * You can have proper wizards/traitors/changelings/cultists during any mode.
 * Only two things really depends on gamemode:
 * 1. Starting roles, equipment and preparations
 * 2. Conditions of finishing the round.
 * 
 */


/datum/game_mode
	var/name = "invalid"
	var/config_tag = null
	var/intercept_hacked = 0
	var/list/datum/mind/modePlayer = new
	var/votable = 1
	var/probability = 1
	var/station_was_nuked = 0 //see nuclearbomb.dm and malfunction.dm
	var/explosion_in_progress = 0 //sit back and relax

/datum/game_mode/proc/announce() //to be calles when round starts
	world << "<B>Notice</B>: [src] did not define announce()"

/datum/game_mode/proc/can_start() //to help game select mode
	return 0

/datum/game_mode/proc/pre_setup() //select players for special roles
	return 1

/datum/game_mode/proc/post_setup() //do irreversible preparations
	return 1

/datum/game_mode/proc/process()

/datum/game_mode/proc/check_finished() //to be called by ticker
	if(emergency_shuttle.location==2 || station_was_nuked)
		return 1
	return 0

/datum/game_mode/proc/declare_completion()
	return

/datum/game_mode/proc/check_win() //universal trigger to be called at mob death, nuke explosion, etc. To be called from everywhere.

/datum/game_mode/proc/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested staus information:</FONT><HR>"
	intercepttext += "<B> Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:</B>"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "malf", "changeling", "cult")
	possible_modes -= "[ticker.mode]"
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))

	if(!intercept_hacked)
		possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	shuffle(possible_modes)

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		if(modePlayer.len == 0)
			intercepttext += i_text.build(A)
		else
			intercepttext += i_text.build(A, pick(modePlayer))

	for (var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")
	world << sound('intercept.ogg')

/datum/game_mode/proc/get_players_for_role(var/role, override_jobbans=1)
	var/list/candidates = list()
	for(var/mob/new_player/player in world)
		if (player.client && player.ready)
			if(player.preferences.be_special & role)
				if(!jobban_isbanned(player, "Syndicate"))
					candidates += player.mind

	if(candidates.len == 0)
		for(var/mob/new_player/player in world)
			if (player.client && player.ready)
				if(!jobban_isbanned(player, "Syndicate"))
					candidates += player.mind

	if(candidates.len == 0 && override_jobbans) //just to be safe. Ignored jobbans are better than broken round. Shouldn't happen usually. --rastaf0
		for(var/mob/new_player/player in world)
			if (player.client && player.ready)
				candidates += player.mind

	return candidates


/datum/game_mode/proc/num_players()
	. = 0
	for(var/mob/new_player/P in world)
		if(P.client && P.ready)
			. ++

///////////////////////////////////
//Keeps track of all living heads//
///////////////////////////////////
/datum/game_mode/proc/get_living_heads()
	var/list/heads = list()
	for(var/mob/living/carbon/human/player in world)
		if(player.stat!=2 && player.mind && (player.mind.assigned_role in head_positions))
			heads += player.mind
	return heads

////////////////////////////
//Keeps track of all heads//
////////////////////////////
/datum/game_mode/proc/get_all_heads()
	var/list/heads = list()
	for(var/mob/player in world)
		if(player.mind && (player.mind.assigned_role in head_positions))
			heads += player.mind
	return heads
