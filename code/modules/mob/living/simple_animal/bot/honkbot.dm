/mob/living/simple_animal/bot/secbot/honkbot
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
	hackables = "sound control systems"
	path_image_color = "#FF69B4"

	baton_type = /obj/item/bikehorn
	security_mode_flags = SECBOT_CHECK_WEAPONS | SECBOT_CHECK_RECORDS
//	Selections: SECBOT_DECLARE_ARRESTS | SECBOT_CHECK_IDS | SECBOT_CHECK_WEAPONS | SECBOT_CHECK_RECORDS | SECBOT_HANDCUFF_TARGET

	var/honksound = 'sound/items/bikehorn.ogg' //customizable sound
	var/limiting_spam = FALSE

	var/cooldowntime = 30
	var/cooldowntimehorn = 10

/mob/living/simple_animal/bot/secbot/honkbot/Initialize(mapload)
	. = ..()
	bot_mode_flags |= BOT_MODE_AUTOPATROL

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/id_trim/job/clown_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/clown]
	access_card.add_access(clown_trim.access + clown_trim.wildcard_access)
	prev_access = access_card.access.Copy()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/bot/secbot/honkbot/proc/limiting_spam_false() //used for addtimer
	limiting_spam = FALSE

/mob/living/simple_animal/bot/secbot/honkbot/bot_reset()
	..()
	limiting_spam = FALSE

/mob/living/simple_animal/bot/secbot/honkbot/emag_act(mob/user)
	..()
	if(!(bot_cover_flags & BOT_COVER_EMAGGED))
		return
	if(user)
		to_chat(user, span_danger("You short out [src]'s sound control system. It gives out an evil laugh!!"))
		oldtarget_name = user.name
	audible_message(span_danger("[src] gives out an evil laugh!"))
	playsound(src, 'sound/machines/honkbot_evil_laugh.ogg', 75, TRUE, -1) // evil laughter
	update_appearance()

/mob/living/simple_animal/bot/secbot/honkbot/proc/sensor_blink()
	icon_state = "honkbot-c"
	addtimer(CALLBACK(src, /atom/.proc/update_appearance), 0.5 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

//honkbots react with sounds.
/mob/living/simple_animal/bot/secbot/honkbot/proc/react_ping()
	playsound(src, 'sound/machines/ping.ogg', 50, TRUE, -1) //the first sound upon creation!
	limiting_spam = TRUE
	sensor_blink()
	addtimer(CALLBACK(src, .proc/limiting_spam_false), 18) // calibrates before starting the honk

/mob/living/simple_animal/bot/secbot/honkbot/proc/react_buzz()
	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE, -1)
	sensor_blink()

/mob/living/simple_animal/bot/secbot/honkbot/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(iscarbon(A))
		var/mob/living/carbon/carbon_attacked = A
		if(bot_cover_flags & BOT_COVER_EMAGGED)
			stun_attack(A)
		else
			if(!carbon_attacked.IsParalyzed() || arrest_type)
				stun_attack(A)
		..()
	else if (!limiting_spam) //honking at the ground
		bike_horn(A)

/mob/living/simple_animal/bot/secbot/honkbot/start_handcuffing(mob/living/carbon/current_target)
	if(bot_cover_flags & BOT_COVER_EMAGGED) //emagged honkbots will spam short and memorable sounds.
		if (!limiting_spam)
			playsound(src, "honkbot_e", 50, FALSE)
			limiting_spam = TRUE // prevent spam
			icon_state = "honkbot-e"
			addtimer(CALLBACK(src, /atom.proc/update_appearance), 3 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)
		addtimer(CALLBACK(src, .proc/limiting_spam_false), cooldowntimehorn)
		return
	if (!limiting_spam)
		playsound(src, honksound, 50, TRUE, -1)
		limiting_spam = TRUE //prevent spam
		sensor_blink()
		addtimer(CALLBACK(src, .proc/limiting_spam_false), cooldowntimehorn)

/mob/living/simple_animal/bot/secbot/honkbot/stun_attack(mob/living/carbon/C) // airhorn stun
	if(!limiting_spam)
		playsound(src, 'sound/items/AirHorn.ogg', 100, TRUE, -1) //HEEEEEEEEEEEENK!!
		sensor_blink()
	if(limiting_spam != 0)
		return
	if(!ishuman(C))
		C.stuttering = 20
		C.Paralyze(80)
		addtimer(CALLBACK(src, .proc/limiting_spam_false), cooldowntime)
		return
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

/mob/living/simple_animal/bot/secbot/honkbot/proc/bike_horn(mob/living/carbon/C) // horn attack
	if(!limiting_spam)
		playsound(loc, honksound, 50, TRUE, -1)
		limiting_spam = TRUE // prevent spam
		sensor_blink()
		addtimer(CALLBACK(src, .proc/limiting_spam_false), cooldowntimehorn)

/mob/living/simple_animal/bot/secbot/honkbot/look_for_perp()
	set_anchored(FALSE)
	for (var/mob/living/carbon/nearby_carbons in view(7,src))
		if((nearby_carbons.stat) || (nearby_carbons.handcuffed))
			continue

		if((nearby_carbons.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		var/judgement_criteria = judgement_criteria()
		threatlevel = nearby_carbons.assess_threat(judgement_criteria)

		if(threatlevel <= 3)
			if(nearby_carbons in view(4,src)) //keep the range short for patrolling
				if(!limiting_spam)
					bike_horn()

		else if(threatlevel >= 10)
			bike_horn() //just spam the shit outta this

		else if(threatlevel >= 4)
			if(!limiting_spam)
				target = nearby_carbons
				oldtarget_name = nearby_carbons.name
				bike_horn()
				speak("Honk!")
				visible_message("<b>[src]</b> starts chasing [nearby_carbons.name]!")
				mode = BOT_HUNT
				INVOKE_ASYNC(src, .proc/handle_automated_action)
				break

/mob/living/simple_animal/bot/secbot/honkbot/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(ismob(AM) && (bot_mode_flags & BOT_MODE_ON)) //only if its online
		if(prob(30)) //you're far more likely to trip on a honkbot
			var/mob/living/carbon/carbon_entered = AM
			if(!istype(carbon_entered) || !carbon_entered || in_range(src, target))
				return
			carbon_entered.visible_message("<span class='warning'>[pick( \
						  	"[carbon_entered] dives out of [src]'s way!", \
						  	"[carbon_entered] stumbles over [src]!", \
						  	"[carbon_entered] jumps out of [src]'s path!", \
						  	"[carbon_entered] trips over [src] and falls!", \
						  	"[carbon_entered] topples over [src]!", \
						  	"[carbon_entered] leaps out of [src]'s way!")]</span>")
			carbon_entered.Paralyze(10)
			playsound(loc, 'sound/misc/sadtrombone.ogg', 50, TRUE, -1)
			if(!client)
				INVOKE_ASYNC(src, /mob/living/simple_animal/bot/proc/speak, "Honk!")
			sensor_blink()
			return
