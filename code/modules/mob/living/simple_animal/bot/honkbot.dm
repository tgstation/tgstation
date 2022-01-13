/mob/living/simple_animal/bot/secbot/honkbot
	name = "\improper Honkbot"
	desc = "A little robot. It looks happy with its bike horn."
	icon_state = "honkbot"
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	combat_mode = FALSE

	maints_access_required = list(ACCESS_ROBOTICS, ACCESS_THEATRE)
	radio_key = /obj/item/encryptionkey/headset_service //doesn't have security key
	radio_channel = RADIO_CHANNEL_SERVICE //Doesn't even use the radio anyway.
	bot_type = HONK_BOT
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED | BOT_MODE_PAI_CONTROLLABLE | BOT_MODE_AUTOPATROL
	hackables = "sound control systems"
	path_image_color = "#FF69B4"
	data_hud_type = null

	baton_type = /obj/item/bikehorn
	security_mode_flags = SECBOT_CHECK_WEAPONS | SECBOT_CHECK_RECORDS

	///Keeping track of how much we honk to prevent spamming it
	var/limiting_spam = FALSE
	///Sound played when HONKing someone
	var/honksound = 'sound/items/bikehorn.ogg'
	///Cooldown between honks
	var/cooldowntime = 30
	///Cooldown between ear-breaking horn sounds
	var/cooldowntimehorn = 10

/mob/living/simple_animal/bot/secbot/honkbot/Initialize(mapload)
	. = ..()

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/id_trim/job/clown_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/clown]
	//We're doing set_access instead to overwrite the sec access they get.
	access_card.set_access(clown_trim.access + clown_trim.wildcard_access)
	prev_access = access_card.access.Copy()

/mob/living/simple_animal/bot/secbot/honkbot/on_entered(datum/source, atom/movable/AM)
	if(!ismob(AM) || !(bot_mode_flags & BOT_MODE_ON))
		return
	if(prob(70))
		return
	var/mob/living/carbon/entered_carbon = AM
	if(!istype(entered_carbon) || !entered_carbon || in_range(src, target))
		return
	knockOver(entered_carbon)

/mob/living/simple_animal/bot/secbot/honkbot/knockOver(mob/living/carbon/tripped_target)
	..()
	INVOKE_ASYNC(src, /mob/living/simple_animal/bot.proc/speak, "Honk!")
	playsound(loc, 'sound/misc/sadtrombone.ogg', 50, TRUE, -1)
	icon_state = "[initial(icon_state)]-c"
	addtimer(CALLBACK(src, /atom.proc/update_appearance), 0.2 SECONDS)

/mob/living/simple_animal/bot/secbot/honkbot/bot_reset()
	..()
	limiting_spam = FALSE

/mob/living/simple_animal/bot/secbot/honkbot/stun_attack(mob/living/carbon/current_target, harm = FALSE) // airhorn stun
	if(limiting_spam)
		return

	playsound(src, 'sound/items/AirHorn.ogg', 100, TRUE, -1) //HEEEEEEEEEEEENK!!
	icon_state = "[initial(icon_state)]-c"
	addtimer(CALLBACK(src, /atom.proc/update_appearance), 0.2 SECONDS)
	if(!ishuman(current_target))
		current_target.stuttering = 20
		current_target.Paralyze(8 SECONDS)
		addtimer(CALLBACK(src, .proc/limiting_spam_false), cooldowntime)
		return
	current_target.stuttering = 20
	var/obj/item/organ/ears/target_ears = current_target.getorganslot(ORGAN_SLOT_EARS)
	if(target_ears && !HAS_TRAIT_FROM(current_target, TRAIT_DEAF, CLOTHING_TRAIT))
		target_ears.adjustEarDamage(0, 5) //far less damage than the H.O.N.K.
	current_target.Jitter(5 SECONDS)
	current_target.Paralyze(6 SECONDS)
	if(client) //prevent spam from players
		limiting_spam = TRUE

	if(bot_cover_flags & BOT_COVER_EMAGGED) // you really don't want to hit an emagged honkbot
		threatlevel = 6 // will never let you go
	else
		//HONK once, then leave
		var/judgement_criteria = judgement_criteria()
		if(ishuman(current_target))
			var/mob/living/carbon/human/human_target = current_target
			threatlevel = human_target.assess_threat(judgement_criteria)
		threatlevel -= 6
	addtimer(CALLBACK(src, .proc/limiting_spam_false), cooldowntime)

	log_combat(src, current_target, "honked")

	current_target.visible_message(
		span_danger("[src] honks [current_target]!"), \
		span_userdanger("[src] honks you!"), \
	)

	target_lastloc = target.loc
	back_to_idle()

/mob/living/simple_animal/bot/secbot/honkbot/retaliate(mob/living/carbon/human/attacking_human)
	..()
	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE, -1)
	icon_state = "[initial(icon_state)]-c"
	addtimer(CALLBACK(src, /atom.proc/update_appearance), 0.2 SECONDS)

/mob/living/simple_animal/bot/secbot/honkbot/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	if(!limiting_spam)
		bike_horn(attack_target)
	. = ..()

/mob/living/simple_animal/bot/secbot/honkbot/handle_automated_action()
	. = ..()
	if(!limiting_spam && prob(30))
		bike_horn(attack_target)

/mob/living/simple_animal/bot/secbot/honkbot/start_handcuffing(mob/living/carbon/current_target)
	if(bot_cover_flags & BOT_COVER_EMAGGED) //emagged honkbots will spam short and memorable sounds.
		if(!limiting_spam)
			playsound(src, "honkbot_e", 50, FALSE)
			icon_state = "honkbot-e"
	else if(!limiting_spam)
		playsound(src, honksound, 50, TRUE, -1)
		icon_state = "[initial(icon_state)]-c"

	limiting_spam = TRUE // prevent spam
	addtimer(CALLBACK(src, .proc/limiting_spam_false), cooldowntimehorn)
	addtimer(CALLBACK(src, /atom.proc/update_appearance), 3 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)
	back_to_idle()

//Honkbots don't care for NAP violations
/mob/living/simple_animal/bot/secbot/honkbot/check_nap_violations()
	return TRUE

/mob/living/simple_animal/bot/secbot/honkbot/proc/limiting_spam_false() //used for addtimer
	limiting_spam = FALSE

/mob/living/simple_animal/bot/secbot/honkbot/proc/bike_horn(mob/living/carbon/attack_target) // horn attack
	if(limiting_spam)
		return
	playsound(loc, honksound, 50, TRUE, -1)
	limiting_spam = TRUE // prevent spam
	icon_state = "[initial(icon_state)]-c"
	addtimer(CALLBACK(src, /atom.proc/update_appearance), 0.2 SECONDS)
	addtimer(CALLBACK(src, .proc/limiting_spam_false), cooldowntimehorn)
