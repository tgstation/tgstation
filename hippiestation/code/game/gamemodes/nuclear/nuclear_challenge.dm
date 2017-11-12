#define CHALLENGE_SHUTTLE_DELAY 15000

/obj/item/device/nuclear_challenge/attack_self(mob/living/user)
	var/n_players = GLOB.player_list.len
	if(!check_allowed(user))
		return

	declaring_war = TRUE
	var/are_you_sure = alert(user, "Consult your team carefully before you declare war on [station_name()]]. Are you sure you want to alert the enemy crew? You have [-round((world.time-SSticker.round_start_time - CHALLENGE_TIME_LIMIT)/10)] seconds to decide", "Declare war?", "Yes", "No")
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(are_you_sure == "No")
		to_chat(user, "On second thought, the element of surprise isn't so bad after all.")
		return

	var/war_declaration = "[user.real_name] has declared his intent to utterly destroy [station_name()] with a nuclear device, and dares the crew to try and stop them."

	declaring_war = TRUE
	var/custom_threat = alert(user, "Do you want to customize your declaration?", "Customize?", "Yes", "No")
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(custom_threat == "Yes")
		declaring_war = TRUE
		war_declaration = stripped_input(user, "Insert your custom declaration", "Declaration")
		declaring_war = FALSE

	if(!check_allowed(user) || !war_declaration)
		return

	priority_announce(war_declaration, title = "Declaration of War", sound = 'sound/machines/alarm.ogg')

	to_chat(user, "You've attracted the attention of powerful forces within the syndicate. A bonus bundle of telecrystals has been granted to your team. Great things await you if you complete the mission.")

	for(var/V in GLOB.syndicate_shuttle_boards)
		var/obj/item/circuitboard/computer/syndicate_shuttle/board = V
		board.challenge = TRUE

	var/obj/item/device/radio/uplink/nuclear/U = new(get_turf(user))
	U.hidden_uplink.owner = "[user.key]"
	U.hidden_uplink.telecrystals = (n_players * 6) //by default is 280 for 50 players, 280 / 50 = 5.6, I rounded it up because nukeops need a little love these days...
	U.hidden_uplink.set_gamemode(/datum/game_mode/nuclear)
	CONFIG_SET(number/shuttle_refuel_delay, max(CONFIG_GET(number/shuttle_refuel_delay), CHALLENGE_SHUTTLE_DELAY))
	SSblackbox.set_val("nuclear_challenge_mode",1)
	qdel(src)

/obj/item/device/nuclear_challenge/check_allowed(mob/living/user)
	if(declaring_war)
		to_chat(user, "You are already in the process of declaring war! Make your mind up.")
		return 0
	if(user.z != ZLEVEL_CENTCOM)
		to_chat(user, "You have to be at your base to use this.")
		return 0
	if(world.time-SSticker.round_start_time > CHALLENGE_TIME_LIMIT)
		to_chat(user, "It's too late to declare hostilities. Your benefactors are already busy with other schemes. You'll have to make do with what you have on hand.")
		return 0
	for(var/V in GLOB.syndicate_shuttle_boards)
		var/obj/item/circuitboard/computer/syndicate_shuttle/board = V
		if(board.moved)
			to_chat(user, "The shuttle has already been moved! You have forfeit the right to declare war.")
			return 0
	return 1

#undef CHALLENGE_SHUTTLE_DELAY