GLOBAL_VAR_INIT(nasheed_playing, FALSE) //prevent double nasheed

/obj/item/melee/execution_sword
	name = "Executioners sword"
	desc = "Not much good in a fight but perfect for making an example of your enemies."
	icon = 'icons/obj/weapons/transforming_energy.dmi'
	icon_state = "e_cutlass_on"
	inhand_icon_state = "e_cutlass_on"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 10
	throwforce = 9
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("slashes", "cuts", "hacks", "bleeds")
	attack_verb_simple = list("slash", "cut", "hack", "bleed")
	hitsound = 'sound/weapons/rapierhit.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	var/cooldown_time = 120
	var/death_tally = 0
	var/executing = FALSE
	var/execution_cooldown_on = FALSE
	var/execution_faction = "The Syndicate"
	var/faction_chosen = FALSE

/obj/item/melee/execution_sword/attack_self(mob/living/user)
	if(faction_chosen)
		to_chat(user, span_notice("You have already pledged your allegiance to [execution_faction]!"))
		return ..()
	execution_faction = tgui_input_text(user, "Insert your new faction to pledge to.", "Faction", max_length = MAX_BROADCAST_LEN)
	if(!execution_faction) //if they press cancel set it to default and let them try again
		execution_faction = "The Syndicate"
	else
		faction_chosen = TRUE

/obj/item/melee/execution_sword/attack(mob/living/target_mob, mob/living/user, params)
	if(!ishuman(target_mob) || executing || !target_mob.mind || target_mob == user)
		return ..()
	if(execution_cooldown_on)
		to_chat(user, span_notice("The internal transmitters need time to recharge"))
		return
	var/obj/item/bodypart/head/target_head = target_mob.get_bodypart("head")
	if(!target_head || target_mob.stat == DEAD)
		to_chat(user, span_notice("Little late to the execution there brother..."))
		return
	executing = TRUE
	execution_cooldown_on = TRUE
	var/area/area_name = get_area(src)
	priority_announce("[user] is preparing to execute [target_mob] near [area_name] in the name of [execution_faction]!", "LiveLeak Announcement", 'sound/misc/notice1.ogg')
	var/sound/nasheed = new()
	nasheed.file = pick('sound/misc/nasheed0.ogg', 'ssound/misc/nasheed1.ogg')
	nasheed.channel = CHANNEL_WALKMAN // AH
	nasheed.frequency = 1
	nasheed.wait = 1
	nasheed.repeat = FALSE
	nasheed.status = SOUND_STREAM
	nasheed.volume = 100
	for(var/mob/M in GLOB.player_list)
		SEND_SOUND(M, nasheed)
	GLOB.nasheed_playing = TRUE
	if(do_after(user, 300, target = target_mob))
		target_head.dismember()
		executing = FALSE
		nasheed_end()
		priority_announce("[user] has executed [target_mob] in the name of [execution_faction]","LiveLeak Announcement", 'sound/misc/notice1.ogg')
		addtimer(CALLBACK(src, PROC_REF(recharge_execute)), cooldown_time)
		add_tally()
	else
		nasheed_end()
		executing = FALSE
		priority_announce("[user] has to failed to execute [target_mob] and has brought shame to [execution_faction]", "LiveLeak Announcement", 'sound/misc/compiler-failure.ogg')
		addtimer(CALLBACK(src, PROC_REF(recharge_execute)), cooldown_time)

/obj/item/melee/execution_sword/proc/nasheed_end()
	for(var/mob/M in GLOB.player_list)
		M.stop_client_sounds(CHANNEL_WALKMAN) // AH
	GLOB.nasheed_playing = FALSE

/obj/item/melee/execution_sword/proc/recharge_execute()
	execution_cooldown_on = FALSE
	playsound(loc, 'sound/machines/ping.ogg', 50, FALSE, -1)

/obj/item/melee/execution_sword/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is holding the [src] to [user.p_their()] neck! It looks like [user.p_theyre()] trying to commit suicide!"))
	var/obj/item/bodypart/head/target_head = user.get_bodypart("head")
	if(!target_head)
		return(BRUTELOSS)
	user.say(";MY LIFE FOR [execution_faction]!!", forced = "execution sword")
	priority_announce("[user] has taken their own life in the name of [execution_faction]", "LiveLeak Announcement", 'sound/misc/notice1.ogg')
	target_head.dismember()
	return(BRUTELOSS)

/obj/item/melee/execution_sword/proc/add_tally()
	death_tally ++
	desc = "Not much good in a fight but perfect for making an example of your enemies. a digit display on the handle displays [death_tally]"
	cooldown_time = clamp(cooldown_time*1.2, 120, 500)
	//if(death_tally == 8)
		//priority_announce("We are sending in our finest", "United Nations", 'sound/misc/notice1.ogg')
		//INVOKE_ASYNC(src, TYPE_PROC_REF(datum/admins, makeEmergencyresponseteam), datum/ert/marine)
		//achievement("TotalNasheedDeath")
