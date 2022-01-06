/mob/living/simple_animal/bot/honkbot
	name = "\improper honkbot"
	desc = "A little robot. It looks happy with its bike horn."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "honkbot"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	pass_flags = PASSMOB | PASSFLAPS

	maints_access_required = list(ACCESS_ROBOTICS, ACCESS_THEATRE)
	radio_key = /obj/item/encryptionkey/headset_service //doesn't have security key
	radio_channel = RADIO_CHANNEL_SERVICE //Doesn't even use the radio anyway.
	bot_type = HONK_BOT
	data_hud_type = DATA_HUD_SECURITY_BASIC // show jobs
	hackables = "sound control systems"
	path_image_color = "#FF69B4"

	var/honksound = 'sound/items/bikehorn.ogg' //customizable sound
	var/limiting_spam = FALSE
	var/cooldowntime = 30
	var/cooldowntimehorn = 10
	var/mob/living/carbon/target
	var/oldtarget_name
	var/target_lastloc = FALSE //Loc of target when arrested.
	var/last_found = FALSE //There's a delay
	var/threatlevel = FALSE
	var/declare_arrests = FALSE // speak, you shall not, unless to Honk
	var/idcheck = TRUE
	var/fcheck = TRUE
	var/check_records = TRUE
	var/arrest_type = FALSE
	var/weaponscheck = TRUE
	var/bikehorn = /obj/item/bikehorn

/mob/living/simple_animal/bot/honkbot/Initialize(mapload)
	. = ..()
	update_appearance()
	bot_mode_flags |= BOT_MODE_AUTOPATROL

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/id_trim/job/clown_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/clown]
	access_card.add_access(clown_trim.access + clown_trim.wildcard_access)
	prev_access = access_card.access.Copy()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/bot/honkbot/proc/limiting_spam_false() //used for addtimer
	limiting_spam = FALSE

/mob/living/simple_animal/bot/honkbot/proc/sensor_blink()
	icon_state = "honkbot-c"
	addtimer(CALLBACK(src, /atom/.proc/update_appearance), 0.5 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

//honkbots react with sounds.
/mob/living/simple_animal/bot/honkbot/proc/react_ping()
	playsound(src, 'sound/machines/ping.ogg', 50, TRUE, -1) //the first sound upon creation!
	limiting_spam = TRUE
	sensor_blink()
	addtimer(CALLBACK(src, .proc/limiting_spam_false), 18) // calibrates before starting the honk

/mob/living/simple_animal/bot/honkbot/proc/react_buzz()
	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE, -1)
	sensor_blink()

/mob/living/simple_animal/bot/honkbot/bot_reset()
	..()
	target = null
	oldtarget_name = null
	set_anchored(FALSE)
	walk_to(src,0)
	last_found = world.time
	limiting_spam = FALSE

/mob/living/simple_animal/bot/honkbot/proc/judgement_criteria()
	var/final = NONE
	if(check_records)
		final |= JUDGE_RECORDCHECK
	if(bot_cover_flags & BOT_COVER_EMAGGED)
		final |= JUDGE_EMAGGED
	return final

/mob/living/simple_animal/bot/honkbot/proc/retaliate(mob/living/carbon/human/H)
	var/judgement_criteria = judgement_criteria()
	threatlevel = H.assess_threat(judgement_criteria)
	threatlevel += 6
	if(threatlevel >= 4)
		target = H
		mode = BOT_HUNT

/mob/living/simple_animal/bot/honkbot/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(user.combat_mode)
		retaliate(user)
		addtimer(CALLBACK(src, .proc/react_buzz), 5)
	return ..()


/mob/living/simple_animal/bot/honkbot/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour != TOOL_SCREWDRIVER && (W.force) && (!target) && (W.damtype != STAMINA) )
		retaliate(user)
		addtimer(CALLBACK(src, .proc/react_buzz), 5)
	..()

/mob/living/simple_animal/bot/honkbot/emag_act(mob/user)
	..()
	if(!(bot_cover_flags & BOT_COVER_EMAGGED))
		return
	if(user)
		to_chat(user, span_danger("You short out [src]'s sound control system. It gives out an evil laugh!!"))
		oldtarget_name = user.name
	audible_message(span_danger("[src] gives out an evil laugh!"))
	playsound(src, 'sound/machines/honkbot_evil_laugh.ogg', 75, TRUE, -1) // evil laughter
	update_appearance()

/mob/living/simple_animal/bot/honkbot/bullet_act(obj/projectile/Proj)
	if((istype(Proj,/obj/projectile/beam)) || (istype(Proj,/obj/projectile/bullet) && (Proj.damage_type == BURN))||(Proj.damage_type == BRUTE) && (!Proj.nodamage && Proj.damage < health && ishuman(Proj.firer)))
		retaliate(Proj.firer)
	return ..()

/mob/living/simple_animal/bot/honkbot/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(bot_cover_flags & BOT_COVER_EMAGGED)
			honk_attack(A)
		else
			if(!C.IsParalyzed() || arrest_type)
				stun_attack(A)
		..()
	else if (!limiting_spam) //honking at the ground
		bike_horn(A)


/mob/living/simple_animal/bot/honkbot/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(istype(AM, /obj/item))
		playsound(src, honksound, 50, TRUE, -1)
		var/obj/item/I = AM
		var/mob/thrown_by = I.thrownby?.resolve()
		if(I.throwforce < health && thrown_by && (istype(thrown_by, /mob/living/carbon/human)))
			var/mob/living/carbon/human/H = thrown_by
			retaliate(H)
	..()

/mob/living/simple_animal/bot/honkbot/proc/bike_horn() //use bike_horn
	if (bot_cover_flags & BOT_COVER_EMAGGED) //emagged honkbots will spam short and memorable sounds.
		if (!limiting_spam)
			playsound(src, "honkbot_e", 50, FALSE)
			limiting_spam = TRUE // prevent spam
			icon_state = "honkbot-e"
			addtimer(CALLBACK(src, /atom/.proc/update_appearance), 3 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)
		addtimer(CALLBACK(src, .proc/limiting_spam_false), cooldowntimehorn)
		return
	if (!limiting_spam)
		playsound(src, honksound, 50, TRUE, -1)
		limiting_spam = TRUE //prevent spam
		sensor_blink()
		addtimer(CALLBACK(src, .proc/limiting_spam_false), cooldowntimehorn)

/mob/living/simple_animal/bot/honkbot/proc/honk_attack(mob/living/carbon/C) // horn attack
	if(!limiting_spam)
		playsound(loc, honksound, 50, TRUE, -1)
		limiting_spam = TRUE // prevent spam
		sensor_blink()
		addtimer(CALLBACK(src, .proc/limiting_spam_false), cooldowntimehorn)

/mob/living/simple_animal/bot/honkbot/proc/stun_attack(mob/living/carbon/C) // airhorn stun
	if(!limiting_spam)
		playsound(src, 'sound/items/AirHorn.ogg', 100, TRUE, -1) //HEEEEEEEEEEEENK!!
		sensor_blink()
	if(limiting_spam == 0)
		if(ishuman(C))
			C.stuttering = 20
			var/obj/item/organ/ears/ears = C.getorganslot(ORGAN_SLOT_EARS)
			if (ears && !HAS_TRAIT_FROM(C, TRAIT_DEAF, CLOTHING_TRAIT))
				ears.adjustEarDamage(0, 5) //far less damage than the H.O.N.K.
			C.Jitter(50)
			C.Paralyze(60)
			var/mob/living/carbon/human/H = C
			if(client) //prevent spam from players..
				limiting_spam = TRUE
			if (bot_cover_flags & BOT_COVER_EMAGGED) // you really don't want to hit an emagged honkbot
				threatlevel = 6 // will never let you go
			else
				//HONK once, then leave
				var/judgement_criteria = judgement_criteria()
				threatlevel = H.assess_threat(judgement_criteria)
				threatlevel -= 6
				target = oldtarget_name
			addtimer(CALLBACK(src, .proc/limiting_spam_false), cooldowntime)

			log_combat(src,C,"honked")

			C.visible_message(span_danger("[src] honks [C]!"),\
					span_userdanger("[src] honks you!"))
		else
			C.stuttering = 20
			C.Paralyze(80)
			addtimer(CALLBACK(src, .proc/limiting_spam_false), cooldowntime)


/mob/living/simple_animal/bot/honkbot/handle_automated_action()
	if(!..())
		return

	switch(mode)

		if(BOT_IDLE) // idle

			walk_to(src,0)
			look_for_perp()
			if(!mode && bot_mode_flags & BOT_MODE_AUTOPATROL)
				mode = BOT_START_PATROL

		if(BOT_HUNT)

			// if can't reach perp for long enough, go idle
			if(frustration >= 5) //gives up easier than beepsky
				walk_to(src,0)
				back_to_idle()
				return

			if(target) // make sure target exists
				if(Adjacent(target) && isturf(target.loc))

					if(threatlevel <= 4)
						honk_attack(target)
					else
						if(threatlevel >= 6)
							set waitfor = 0
							stun_attack(target)
							set_anchored(FALSE)
							target_lastloc = target.loc
					return

				else // not next to perp
					var/turf/olddist = get_dist(src, target)
					walk_to(src, target,1,4)
					if((get_dist(src, target)) >= (olddist))
						frustration++
					else
						frustration = 0
			else
				back_to_idle()


		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			look_for_perp()
			bot_patrol()

	return

/mob/living/simple_animal/bot/honkbot/proc/back_to_idle()
	set_anchored(FALSE)
	mode = BOT_IDLE
	target = null
	last_found = world.time
	frustration = 0
	INVOKE_ASYNC(src, .proc/handle_automated_action) //responds quickly

/mob/living/simple_animal/bot/honkbot/proc/back_to_hunt()
	set_anchored(FALSE)
	frustration = 0
	mode = BOT_HUNT
	INVOKE_ASYNC(src, .proc/handle_automated_action) // responds quickly

/mob/living/simple_animal/bot/honkbot/proc/look_for_perp()
	set_anchored(FALSE)
	for (var/mob/living/carbon/C in view(7,src))
		if((C.stat) || (C.handcuffed))
			continue

		if((C.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		var/judgement_criteria = judgement_criteria()
		threatlevel = C.assess_threat(judgement_criteria)

		if(threatlevel <= 3)
			if(C in view(4,src)) //keep the range short for patrolling
				if(!limiting_spam)
					bike_horn()

		else if(threatlevel >= 10)
			bike_horn() //just spam the shit outta this

		else if(threatlevel >= 4)
			if(!limiting_spam)
				target = C
				oldtarget_name = C.name
				bike_horn()
				speak("Honk!")
				visible_message("<b>[src]</b> starts chasing [C.name]!")
				mode = BOT_HUNT
				INVOKE_ASYNC(src, .proc/handle_automated_action)
				break
			else
				continue

/mob/living/simple_animal/bot/honkbot/explode()

	walk_to(src,0)
	visible_message(span_boldannounce("[src] blows apart!"))
	var/atom/Tsec = drop_location()
	//doesn't drop cardboard nor its assembly, since its a very frail material.
	new bikehorn(Tsec)
	new /obj/item/assembly/prox_sensor(Tsec)

	var/datum/effect_system/spark_spread/s = new
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/oil(loc)
	..()

/mob/living/simple_animal/bot/honkbot/attack_alien(mob/living/carbon/alien/user, list/modifiers)
	..()
	if(!isalien(target))
		target = user
		mode = BOT_HUNT

/mob/living/simple_animal/bot/honkbot/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(ismob(AM) && (bot_mode_flags & BOT_MODE_ON)) //only if its online
		if(prob(30)) //you're far more likely to trip on a honkbot
			var/mob/living/carbon/C = AM
			if(!istype(C) || !C || in_range(src, target))
				return
			C.visible_message("<span class='warning'>[pick( \
						  	"[C] dives out of [src]'s way!", \
						  	"[C] stumbles over [src]!", \
						  	"[C] jumps out of [src]'s path!", \
						  	"[C] trips over [src] and falls!", \
						  	"[C] topples over [src]!", \
						  	"[C] leaps out of [src]'s way!")]</span>")
			C.Paralyze(10)
			playsound(loc, 'sound/misc/sadtrombone.ogg', 50, TRUE, -1)
			if(!client)
				INVOKE_ASYNC(src, /mob/living/simple_animal/bot/proc/speak, "Honk!")
			sensor_blink()
			return
