/obj/item/suspiciousphone
	name = "suspicious phone"
	desc = "This device raises pink levels to unknown highs."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "suspiciousphone"
	atom_size = WEIGHT_CLASS_SMALL
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
		dumped = TRUE

/obj/structure/checkoutmachine
	name = "\improper Nanotrasen Space-Coin Market"
	desc = "This is good for spacecoin because"
	icon = 'icons/obj/money_machine.dmi'
	icon_state = "bogdanoff"
	layer = LARGE_MOB_LAYER
	armor = list(MELEE = 80, BULLET = 30, LASER = 30, ENERGY = 60, BOMB = 90, BIO = 0, FIRE = 100, ACID = 80)
	density = TRUE
	pixel_z = -8
	max_integrity = 5000
	var/list/accounts_to_rob
	var/mob/living/bogdanoff
	var/canwalk = FALSE

/obj/structure/checkoutmachine/examine(mob/living/user)
	. = ..()
	. += span_info("It's integrated integrity meter reads: <b>HEALTH: [atom_integrity]</b>.")

/obj/structure/checkoutmachine/proc/check_if_finished()
	for(var/i in accounts_to_rob)
		var/datum/bank_account/B = i
		if (B.being_dumped)
			return FALSE
	return TRUE

/obj/structure/checkoutmachine/attackby(obj/item/W, mob/user, params)
	if(check_if_finished())
		qdel(src)
		return
	if(istype(W, /obj/item/card/id))
		var/obj/item/card/id/card = W
		if(!card.registered_account)
			to_chat(user, span_warning("This card does not have a registered account!"))
			return
		if(!card.registered_account.being_dumped)
			to_chat(user, span_warning("It appears that your funds are safe from draining!"))
			return
		if(do_after(user, 40, target = src))
			if(!card.registered_account.being_dumped)
				return
			to_chat(user, span_warning("You quickly cash out your funds to a more secure banking location. Funds are safu.")) // This is a reference and not a typo
			card.registered_account.being_dumped = FALSE
			if(check_if_finished())
				qdel(src)
				return
	else
		return ..()

/obj/structure/checkoutmachine/Initialize(mapload, mob/living/user)
	. = ..()
	if(QDELETED(src))
		return
	bogdanoff = user
	add_overlay("flaps")
	add_overlay("hatch")
	add_overlay("legs_retracted")
	addtimer(CALLBACK(src, .proc/startUp), 50)
	QDEL_IN(src, 8 MINUTES) //Self-destruct after 8 min
	ADD_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING, REF(src))


/obj/structure/checkoutmachine/proc/startUp() //very VERY snowflake code that adds a neat animation when the pod lands.
	start_dumping() //The machine doesnt move during this time, giving people close by a small window to grab their funds before it starts running around
	sleep(10)
	if(QDELETED(src))
		return
	playsound(src, 'sound/machines/click.ogg', 15, TRUE, -3)
	cut_overlay("flaps")
	sleep(10)
	if(QDELETED(src))
		return
	playsound(src, 'sound/machines/click.ogg', 15, TRUE, -3)
	cut_overlay("hatch")
	sleep(30)
	if(QDELETED(src))
		return
	playsound(src,'sound/machines/twobeep.ogg',50,FALSE)
	var/mutable_appearance/hologram = mutable_appearance(icon, "hologram")
	hologram.pixel_y = 16
	add_overlay(hologram)
	var/mutable_appearance/holosign = mutable_appearance(icon, "holosign")
	holosign.pixel_y = 16
	add_overlay(holosign)
	add_overlay("legs_extending")
	cut_overlay("legs_retracted")
	pixel_z += 4
	sleep(5)
	if(QDELETED(src))
		return
	add_overlay("legs_extended")
	cut_overlay("legs_extending")
	pixel_z += 4
	sleep(20)
	if(QDELETED(src))
		return
	add_overlay("screen_lines")
	sleep(5)
	if(QDELETED(src))
		return
	cut_overlay("screen_lines")
	sleep(5)
	if(QDELETED(src))
		return
	add_overlay("screen_lines")
	add_overlay("screen")
	sleep(5)
	if(QDELETED(src))
		return
	playsound(src,'sound/machines/triple_beep.ogg',50,FALSE)
	add_overlay("text")
	sleep(10)
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
	canwalk = TRUE
	START_PROCESSING(SSfastprocess, src)

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
		var/amount = B.account_balance * percentage_lost
		var/datum/bank_account/account = bogdanoff?.get_bank_account()
		if (account) // get_bank_account() may return FALSE
			account.transfer_money(B, amount)
			B.bank_card_talk("You have lost [percentage_lost * 100]% of your funds! A spacecoin credit deposit machine is located at: [get_area(src)].")
	addtimer(CALLBACK(src, .proc/dump), 150) //Drain every 15 seconds

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
	icon = 'icons/obj/money_machine_64.dmi'
	pixel_z = 300
	desc = "Get out of the way!"
	layer = FLY_LAYER//that wasn't flying, that was falling with style!
	icon_state = "missile_blur"

/obj/effect/dumpeet_target
	name = "Landing Zone Indicator"
	desc = "A holographic projection designating the landing zone of something. It's probably best to stand back."
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	light_range = 2
	var/obj/effect/dumpeet_fall/DF
	var/obj/structure/checkoutmachine/dump
	var/mob/living/bogdanoff

/obj/effect/dumpeet_target/Initialize(mapload, user)
	. = ..()
	bogdanoff = user
	addtimer(CALLBACK(src, .proc/startLaunch), 100)
	sound_to_playing_players('sound/items/dump_it.ogg', 20)
	deadchat_broadcast("Protocol CRAB-17 has been activated. A space-coin market has been launched at the station!", turf_target = get_turf(src), message_type=DEADCHAT_ANNOUNCEMENT)

/obj/effect/dumpeet_target/proc/startLaunch()
	DF = new /obj/effect/dumpeet_fall(drop_location())
	dump = new /obj/structure/checkoutmachine(null, bogdanoff)
	priority_announce("The spacecoin bubble has popped! Get to the credit deposit machine at [get_area(src)] and cash out before you lose all of your funds!", sender_override = "CRAB-17 Protocol")
	animate(DF, pixel_z = -8, time = 5, , easing = LINEAR_EASING)
	playsound(src,  'sound/weapons/mortar_whistle.ogg', 70, TRUE, 6)
	addtimer(CALLBACK(src, .proc/endLaunch), 5, TIMER_CLIENT_TIME) //Go onto the last step after a very short falling animation



/obj/effect/dumpeet_target/proc/endLaunch()
	QDEL_NULL(DF) //Delete the falling machine effect, because at this point its animation is over. We dont use temp_visual because we want to manually delete it as soon as the pod appears
	playsound(src, "explosion", 80, TRUE)
	dump.forceMove(get_turf(src))
	qdel(src) //The target's purpose is complete. It can rest easy now
