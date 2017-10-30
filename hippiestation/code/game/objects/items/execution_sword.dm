#define EXECUTE_INFIDEL 300
#define EXECUTE_COOLDOWN 50

/obj/item/melee/execution_sword
	name = "Executioners sword"
	desc = "Not much good in a fight but perfect for making an example of your enemies."
	force = 10
	icon_state = "cutlass1"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	sharpness = IS_SHARP_ACCURATE
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/rapierhit.ogg'
	var/execution_faction = "The Syndicate"
	var/faction_chosen = FALSE
	var/executing = FALSE
	var/can_execute = TRUE
	var/static/earrape_time = 0
	var/nasheed_list = list('hippiestation/sound/misc/nasheed.ogg', 'hippiestation/sound/misc/nasheed2.ogg')

obj/item/melee/execution_sword/attack_self(mob/living/user)
	if(faction_chosen == TRUE && execution_faction) //Just in case someone presses cancel when typing and ends up with a null declared faction.
		to_chat(user, "<span class='notice'>You have already pledged your allegiance to [execution_faction]!</span>")
		return
	else
		var/custom_faction = alert(user, "Do you want to pledge allegiance to a new faction?", "Customize?", "Yes", "No")

		if(custom_faction == "No")
			to_chat(user, "You decide to stick with [execution_faction], all glory to [execution_faction]!")
			faction_chosen = TRUE
			return

		if(custom_faction == "Yes")
			execution_faction = stripped_input(user, "Insert your new faction", "Faction")
			faction_chosen = TRUE
	..()


/obj/item/melee/execution_sword/attack(mob/living/target, mob/living/user)
	if(!can_execute)
		to_chat(user, "<span class='notice'>The internal transmitters need time to recharge.</span>")
		return
	if(executing)
		to_chat(user, "<span class='notice'>You are already executing someone.</span>")
		return
	if(user.a_intent != INTENT_HARM || user.zone_selected != "head" || !ishuman(target))
		return ..()
	var/obj/item/bodypart/head/infidel_head = target.get_bodypart("head")
	if(!infidel_head || target.stat == DEAD)
		to_chat(user, "Little late to the execution there brother...")
	else
		executing = TRUE
		can_execute = FALSE
		var/area/A = get_area(src)
		priority_announce("[user] is preparing to execute [target] at [A.map_name] in the name of [execution_faction]!","Message from [execution_faction]!", 'sound/misc/notice1.ogg')
		log_admin("[key_name(user)] attempted to execute [key_name(target)] with [src]")
		message_admins("[key_name(user)] is attempting to execute [key_name(target)] with [src]")
		if(!GLOB.nasheed_playing && world.time > earrape_time)
			var/nasheed_chosen = pick(nasheed_list)
			earrape_time = world.time + 250 //25 seconds between each
			var/sound/nasheed = new()
			nasheed.file = nasheed_chosen
			nasheed.channel = CHANNEL_NASHEED
			nasheed.frequency = 1
			nasheed.wait = 1
			nasheed.repeat = 0
			nasheed.status = SOUND_STREAM
			nasheed.volume = 100
			for(var/mob/M in GLOB.player_list)
				if(M.client.prefs.toggles & SOUND_MIDI)
					var/user_vol = M.client.chatOutput.adminMusicVolume
					if(user_vol)
						nasheed.volume = 100 * (user_vol / 100)
					SEND_SOUND(M, nasheed)
					nasheed.volume = 100
			GLOB.nasheed_playing = TRUE
			addtimer(CALLBACK(src, .proc/nasheed_end), EXECUTE_INFIDEL)
		if(do_after(user,EXECUTE_INFIDEL, target = target))
			log_admin("[key_name(user)] executed [key_name(target)] with [src]")
			message_admins("[key_name(user)] executed [key_name(target)] with [src]")
			infidel_head.dismember()
			priority_announce("[user] has executed [target] in the name of [execution_faction]!","Message from [execution_faction]!", 'sound/misc/notice1.ogg')
			executing = FALSE
			addtimer(CALLBACK(src, .proc/recharge_execute), EXECUTE_COOLDOWN)
		else
			priority_announce("[user] has failed to execute [target] and has brought shame to [execution_faction]!","Message from [execution_faction]!", 'sound/misc/compiler-failure.ogg')
			executing = FALSE
			nasheed_end()
			addtimer(CALLBACK(src, .proc/recharge_execute), EXECUTE_COOLDOWN)


/obj/item/melee/execution_sword/proc/nasheed_end()
	for(var/mob/M in GLOB.player_list)
		M.stop_sound_channel(CHANNEL_NASHEED)
	if(GLOB.nasheed_playing)
		GLOB.nasheed_playing = FALSE

/obj/item/melee/execution_sword/proc/recharge_execute()
	if(!can_execute)
		can_execute = TRUE

#undef EXECUTE_INFIDEL
#undef EXECUTE_COOLDOWN