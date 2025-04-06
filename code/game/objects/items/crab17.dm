/obj/item/suspiciousphone
	name = "suspicious phone"
	desc = "This device raises pink levels to unknown highs."
	icon = 'icons/obj/antags/syndicate_tools.dmi'
	icon_state = "suspiciousphone"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb_continuous = list("dumps")
	attack_verb_simple = list("dump")
	var/dumped = FALSE

/obj/item/suspiciousphone/attack_self(mob/living/user)
	if(!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("This device is too advanced for you!"))
		return
	if(dumped)
		to_chat(user, span_warning("You already activated Protocol CRAB-17."))
		return FALSE
	if(tgui_alert(user, "Are you sure you want to crash this market with no survivors?", "Protocol CRAB-17", list("Yes", "No")) == "Yes")
		if(dumped || QDELETED(src)) //Prevents fuckers from cheesing alert
			return FALSE
		var/turf/targetturf = get_safe_random_station_turf()
		if (!targetturf)
			return FALSE
		var/list/accounts_to_rob = flatten_list(SSeconomy.bank_accounts_by_id)
		var/mob/living/L
		if(isliving(user))
			L = user
			accounts_to_rob -= L.get_bank_account()
		for(var/i in accounts_to_rob)
			var/datum/bank_account/B = i
			B.being_dumped = TRUE
		new /obj/effect/dumpeet_target(targetturf, L)

		to_chat(user, span_notice("You have activated Protocol CRAB-17."))
		message_admins("[ADMIN_LOOKUPFLW(user)] has activated Protocol CRAB-17.")
		user.log_message("activated Protocol CRAB-17.", LOG_GAME)

		dumped = TRUE

/obj/structure/checkoutmachine
	name = "\improper Nanotrasen Space-Coin Market"
	desc = "This is good for spacecoin because"
	icon = 'icons/obj/machines/money_machine.dmi'
	icon_state = "bogdanoff"
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	pixel_z = -8
	max_integrity = 5000
	var/list/accounts_to_rob
	var/mob/living/bogdanoff
	/// Are we able to start moving?
	var/canwalk = FALSE

/obj/structure/checkoutmachine/examine(mob/living/user)
	. = ..()
	. += span_info("It has a flashing <b>ID card reader</b> for convenient cashing out.")

/obj/structure/checkoutmachine/proc/check_if_finished()
	for(var/i in accounts_to_rob)
		var/datum/bank_account/B = i
		if (B.being_dumped)
			return FALSE
	return TRUE

/obj/structure/checkoutmachine/attackby(obj/item/attacking_item, mob/user, params)
	if(!canwalk)
		balloon_alert(user, "not ready to accept transactions!")
		return

	if(check_if_finished())
		qdel(src)
		return

	var/obj/item/card/id/card = attacking_item.GetID()
	if(!card)
		balloon_alert(user, "your [attacking_item.name] gets repelled by the id card reader")

		var/throwtarget = get_step(user, get_dir(src, user))
		user.safe_throw_at(throwtarget, 1, 1, force = MOVE_FORCE_EXTREMELY_STRONG)
		playsound(get_turf(src),'sound/effects/magic/repulse.ogg', 100, TRUE)

		return

	if(!card.registered_account)
		balloon_alert(user, "card has no registered account!")
		return

	if(!card.registered_account.being_dumped)
		balloon_alert(user, "funds are already safe!")
		return

	to_chat(user, span_warning("You quickly cash out your funds to a more secure banking location. Funds are safu.")) // This is a reference and not a typo
	card.registered_account.being_dumped = FALSE

	if(check_if_finished())
		qdel(src)
		return

/obj/structure/checkoutmachine/Initialize(mapload, mob/living/user)
	. = ..()
	if(QDELETED(src))
		return
	bogdanoff = user
	add_overlay("flaps")
	add_overlay("hatch")
	add_overlay("legs_retracted")
	addtimer(CALLBACK(src, PROC_REF(startUp)), 5 SECONDS)
	QDEL_IN(src, 8 MINUTES) //Self-destruct after 8 min
	ADD_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING, REF(src))


/obj/structure/checkoutmachine/proc/startUp() //very VERY snowflake code that adds a neat animation when the pod lands.
	start_dumping() //The machine doesnt move during this time, giving people close by a small window to grab their funds before it starts running around
	sleep(1 SECONDS)
	if(QDELETED(src))
		return
	playsound(src, 'sound/machines/click.ogg', 15, TRUE, -3)
	cut_overlay("flaps")
	sleep(1 SECONDS)
	if(QDELETED(src))
		return
	playsound(src, 'sound/machines/click.ogg', 15, TRUE, -3)
	cut_overlay("hatch")
	sleep(3 SECONDS)
	if(QDELETED(src))
		return
	playsound(src,'sound/machines/beep/twobeep.ogg',50,FALSE)
	var/mutable_appearance/hologram = mutable_appearance(icon, "hologram")
	hologram.pixel_y = 16
	add_overlay(hologram)
	var/mutable_appearance/holosign = mutable_appearance(icon, "holosign")
	holosign.pixel_y = 16
	add_overlay(holosign)
	add_overlay("legs_extending")
	cut_overlay("legs_retracted")
	pixel_z += 4
	sleep(0.5 SECONDS)
	if(QDELETED(src))
		return
	add_overlay("legs_extended")
	cut_overlay("legs_extending")
	pixel_z += 4
	sleep(2 SECONDS)
	if(QDELETED(src))
		return
	add_overlay("screen_lines")
	sleep(0.5 SECONDS)
	if(QDELETED(src))
		return
	cut_overlay("screen_lines")
	sleep(0.5 SECONDS)
	if(QDELETED(src))
		return
	add_overlay("screen_lines")
	add_overlay("screen")
	sleep(0.5 SECONDS)
	if(QDELETED(src))
		return
	playsound(src,'sound/machines/beep/triple_beep.ogg',50,FALSE)
	add_overlay("text")
	sleep(1 SECONDS)
	if(QDELETED(src))
		return
	add_overlay("legs")
	cut_overlay("legs_extended")
	cut_overlay("screen")
	add_overlay("screen")
	cut_overlay("screen_lines")
	add_overlay("screen_lines")
	cut_overlay("text")
	add_overlay("text")
	START_PROCESSING(SSfastprocess, src) // we only start doing economy draining stuff once our machinery is initialized, thematically
	canwalk = TRUE

/obj/structure/checkoutmachine/Destroy()
	stop_dumping()
	STOP_PROCESSING(SSfastprocess, src)
	priority_announce("The credit deposit machine at [get_area(src)] has been destroyed. Station funds have stopped draining!", sender_override = "CRAB-17 Protocol")
	explosion(src, light_impact_range = 1, flame_range = 2)
	REMOVE_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING, REF(src))
	return ..()

/obj/structure/checkoutmachine/proc/start_dumping()
	accounts_to_rob = flatten_list(SSeconomy.bank_accounts_by_id)
	accounts_to_rob -= bogdanoff?.get_bank_account()
	for(var/i in accounts_to_rob)
		var/datum/bank_account/B = i
		B.dumpeet()
	dump()

/obj/structure/checkoutmachine/proc/dump()
	var/percentage_lost = (rand(5, 15) / 100)
	for(var/i in accounts_to_rob)
		var/datum/bank_account/B = i
		if(!(B?.being_dumped))
			accounts_to_rob -= B
			continue
		var/amount = round(B.account_balance * percentage_lost) // We don't want fractions of a credit stolen. That's just agony for everyone.
		var/datum/bank_account/account = bogdanoff?.get_bank_account()
		if (account) // get_bank_account() may return FALSE
			account.transfer_money(B, amount, "?VIVA¿: !LA CRABBE¡")
			B.bank_card_talk("You have lost [percentage_lost * 100]% of your funds! A spacecoin credit deposit machine is located at: [get_area(src)].")
	addtimer(CALLBACK(src, PROC_REF(dump)), 15 SECONDS) //Drain every 15 seconds

/obj/structure/checkoutmachine/process()
	var/anydir = pick(GLOB.cardinals)
	if(Process_Spacemove(anydir))
		Move(get_step(src, anydir), anydir)

/obj/structure/checkoutmachine/proc/stop_dumping()
	for(var/i in accounts_to_rob)
		var/datum/bank_account/B = i
		if(B)
			B.being_dumped = FALSE

/obj/effect/dumpeet_fall //Falling pod
	name = ""
	icon = 'icons/obj/machines/money_machine_64.dmi'
	pixel_z = 300
	desc = "Get out of the way!"
	layer = FLY_LAYER//that wasn't flying, that was falling with style!
	plane = ABOVE_GAME_PLANE
	icon_state = "missile_blur"

/obj/effect/dumpeet_target
	name = "Landing Zone Indicator"
	desc = "A holographic projection designating the landing zone of something. It's probably best to stand back."
	icon = 'icons/mob/telegraphing/telegraph_holographic.dmi'
	icon_state = "target_circle"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	light_range = 2
	var/obj/effect/dumpeet_fall/DF
	var/obj/structure/checkoutmachine/dump
	var/mob/living/bogdanoff

/obj/effect/dumpeet_target/Initialize(mapload, user)
	. = ..()
	bogdanoff = user
	addtimer(CALLBACK(src, PROC_REF(startLaunch)), 10 SECONDS)
	sound_to_playing_players('sound/items/dump_it.ogg', 20)
	deadchat_broadcast("Protocol CRAB-17 has been activated. A space-coin market has been launched at the station!", turf_target = get_turf(src), message_type=DEADCHAT_ANNOUNCEMENT)

/obj/effect/dumpeet_target/proc/startLaunch()
	DF = new /obj/effect/dumpeet_fall(drop_location())
	dump = new /obj/structure/checkoutmachine(null, bogdanoff)
	priority_announce("The spacecoin bubble has popped! Get to the credit deposit machine at [get_area(src)] and cash out before you lose all of your funds!", sender_override = "CRAB-17 Protocol")
	animate(DF, pixel_z = -8, time = 5, , easing = LINEAR_EASING)
	playsound(src,  'sound/items/weapons/mortar_whistle.ogg', 70, TRUE, 6)
	addtimer(CALLBACK(src, PROC_REF(endLaunch)), 5, TIMER_CLIENT_TIME) //Go onto the last step after a very short falling animation



/obj/effect/dumpeet_target/proc/endLaunch()
	QDEL_NULL(DF) //Delete the falling machine effect, because at this point its animation is over. We dont use temp_visual because we want to manually delete it as soon as the pod appears
	playsound(src, SFX_EXPLOSION, 80, TRUE)
	dump.forceMove(get_turf(src))
	qdel(src) //The target's purpose is complete. It can rest easy now
