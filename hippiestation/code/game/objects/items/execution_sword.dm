#define MUSIC_CD 300

/obj/item/melee/execution_sword
	name = "Executioners sword."
	desc = "Not much good in a fight but perfect for making an example of your enemies."
	force = 10
	icon_state = "cutlass1"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	sharpness = IS_SHARP_ACCURATE
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/rapierhit.ogg'
	var/execute_infidel = 300
	var/execution_faction = "The Syndicate"
	var/faction_chosen = FALSE
	var/executing = FALSE
	var/playing_nasheed = FALSE
	var/nasheed_list = list('hippiestation/sound/misc/nasheed.ogg', 'hippiestation/sound/misc/nasheed2.ogg')

obj/item/melee/execution_sword/attack_self(mob/living/user)
	if(faction_chosen == TRUE)
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



/obj/item/melee/execution_sword/attack(mob/living/target, mob/living/user)
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
		var/area/A = get_area(src)
		priority_announce("[user] is preparing to execute [target] at [A.map_name] in the name of [execution_faction]!","Message from [execution_faction]!", 'sound/misc/notice1.ogg')
		log_admin("[key_name(user)] attempted to execute [key_name(target)] with [src]")
		message_admins("[key_name(user)] is attempting to execute [key_name(target)] with [src]")
		if(!playing_nasheed)
			for(var/mob/M in GLOB.player_list)
				var/nasheed_chosen = pick(nasheed_list)
				M.playsound_local(get_turf(M), nasheed_chosen, 150, 0, pressure_affected = FALSE)
				playing_nasheed = TRUE
				addtimer(CALLBACK(src, .proc/nasheed_end), MUSIC_CD)
		if(do_after(user,execute_infidel, target = target))
			log_admin("[key_name(user)] executed [key_name(target)] with [src]")
			message_admins("[key_name(user)] executed [key_name(target)] with [src]")
			infidel_head.dismember()
			priority_announce("[user] has executed [target] in the name of [execution_faction]!","Message from [execution_faction]!", 'sound/misc/notice1.ogg')
			executing = FALSE
		else
			priority_announce("[user] has failed to execute [target] and has brought shame to [execution_faction]!","Message from [execution_faction]!", 'sound/misc/compiler-failure.ogg')
			executing = FALSE


/obj/item/melee/execution_sword/proc/nasheed_end()
	playing_nasheed = FALSE

#undef MUSIC_CD