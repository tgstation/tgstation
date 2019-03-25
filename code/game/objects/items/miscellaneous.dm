/obj/item/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("warned", "cautioned", "smashed")

/obj/item/choice_beacon
	name = "choice beacon"
	desc = "Hey, why are you viewing this?!! Please let Centcom know about this odd occurance."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-blue"
	item_state = "radio"
	var/uses = 1

/obj/item/choice_beacon/attack_self(mob/user)
	if(canUseBeacon(user))
		generate_options(user)

/obj/item/choice_beacon/proc/generate_display_names() // return the list that will be used in the choice selection. entries should be in (type.name = type) fashion. see choice_beacon/hero for how this is done.
	return list()

/obj/item/choice_beacon/proc/canUseBeacon(mob/living/user)
	if(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return TRUE
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, 1)
		return FALSE

/obj/item/choice_beacon/proc/generate_options(mob/living/M)
	var/list/display_names = generate_display_names()
	if(!display_names.len)
		return
	var/choice = input(M,"Which item would you like to order?","Select an Item") as null|anything in display_names
	if(!choice || !M.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	spawn_option(display_names[choice],M)
	uses--
	if(!uses)
		qdel(src)
	else
		to_chat(M, "<span class='notice'>[uses] use[uses > 1 ? "s" : ""] remaining on the [src].</span>")

/obj/item/choice_beacon/proc/spawn_option(obj/choice,mob/living/M)
	var/obj/new_item = new choice()
	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	pod.explosionSize = list(0,0,0,0)
	new_item.forceMove(pod)
	var/msg = "<span class=danger>After making your selection, you notice a strange target on the ground. It might be best to step back!</span>"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(istype(H.ears, /obj/item/radio/headset))
			msg = "You hear something crackle in your ears for a moment before a voice speaks.  \"Please stand by for a message from Central Command.  Message as follows: <span class='bold'>Item request received. Your package is inbound, please stand back from the landing site.</span> Message ends.\""
	to_chat(M, msg)

	new /obj/effect/DPtarget(get_turf(src), pod)

/obj/item/choice_beacon/hero
	name = "heroic beacon"
	desc = "To summon heroes from the past to protect the future."

/obj/item/choice_beacon/hero/generate_display_names()
	var/static/list/hero_item_list
	if(!hero_item_list)
		hero_item_list = list()
		var/list/templist = typesof(/obj/item/storage/box/hero) //we have to convert type = name to name = type, how lovely!
		for(var/V in templist)
			var/atom/A = V
			hero_item_list[initial(A.name)] = A
	return hero_item_list


/obj/item/storage/box/hero
	name = "Courageous Tomb Raider - 1940's."

/obj/item/storage/box/hero/PopulateContents()
	new /obj/item/clothing/head/fedora/curator(src)
	new /obj/item/clothing/suit/curator(src)
	new /obj/item/clothing/under/rank/curator/treasure_hunter(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/melee/curator_whip(src)

/obj/item/storage/box/hero/astronaut
	name = "First Man on the Moon - 1960's."

/obj/item/storage/box/hero/astronaut/PopulateContents()
	new /obj/item/clothing/suit/space/nasavoid(src)
	new /obj/item/clothing/head/helmet/space/nasavoid(src)
	new /obj/item/tank/internals/oxygen(src)
	new /obj/item/gps(src)

/obj/item/storage/box/hero/scottish
	name = "Braveheart, the Scottish rebel - 1300's."

/obj/item/storage/box/hero/scottish/PopulateContents()
	new /obj/item/clothing/under/kilt(src)
	new /obj/item/claymore/weak/ceremonial(src)
	new /obj/item/toy/crayon/spraycan(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/choice_beacon/augments
	name = "augment beacon"
	desc = "Summons augmentations. Can be used 3 times!"
	uses = 3

/obj/item/choice_beacon/augments/generate_display_names()
	var/static/list/augment_list
	if(!augment_list)
		augment_list = list()
		var/list/templist = list(
		/obj/item/organ/cyberimp/brain/anti_drop,
		/obj/item/organ/cyberimp/arm/toolset,
		/obj/item/organ/cyberimp/arm/surgery,
		/obj/item/organ/cyberimp/chest/thrusters,
		/obj/item/organ/lungs/cybernetic/upgraded,
		/obj/item/organ/liver/cybernetic/upgraded) //cyberimplants range from a nice bonus to fucking broken bullshit so no subtypesof
		for(var/V in templist)
			var/atom/A = V
			augment_list[initial(A.name)] = A
	return augment_list

/obj/item/choice_beacon/augments/spawn_option(obj/choice,mob/living/M)
	new choice(get_turf(M))
	to_chat(M, "You hear something crackle from the beacon for a moment before a voice speaks.  \"Please stand by for a message from S.E.L.F. Message as follows: <span class='bold'>Item request received. Your package has been transported, use the autosurgeon supplied to apply the upgrade.</span> Message ends.\"")

/obj/item/skub
	desc = "It's skub."
	name = "skub"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "skub"
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("skubbed")

/obj/item/skub/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] has declared themself as anti-skub! The skub tears them apart!</span>")

	user.gib()
	playsound(src, 'sound/items/eatfood.ogg', 50, 1, -1)
	return MANUAL_SUICIDE


/obj/item/suspiciousphone
	name = "suspicious phone"
	desc = "This device raises pink levels to unknown highs."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "suspiciousphone"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("dumped")
	var/dumped = FALSE
	var/mob/living/carbon/human/bogdanoff

/obj/item/suspiciousphone/attack_self(mob/user)
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>This device is too advanced for you!</span>")
		return
	if(dumped)
		to_chat(user, "<span class='warning'>You already activated Protocol CRAB-17.</span>")
		return FALSE

	if(alert(user, "Are you sure you want to crash this market with no survivors?", "Protocol CRAB-17", "Yes", "No") == "Yes")
		if(dumped) //Prevents fuckers from cheesing alert
			return FALSE
		sound_to_playing_players('sound/items/dump_it.ogg', 75)
		bogdanoff = user
		var/turf/targetturf = get_random_station_turf()
		var/obj/effect/dumpeetTarget/target = new(targetturf)
		target.bogdanoff = src.bogdanoff
		dumped = TRUE

/obj/structure/checkoutmachine
	name = "Nanotrasen Space-Coin Market"
	desc = "This is good for spacecoin because"
	icon = 'icons/obj/money_machine.dmi'
	icon_state = "bogdanoff"
	layer = TABLE_LAYER //So that the crate inside doesn't appear underneath
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 100, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 80)
	density = TRUE
	var/list/accounts_to_rob
	var/mob/living/carbon/human/bogdanoff
	var/canwalk = FALSE

/obj/structure/checkoutmachine/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/card/id))
		var/obj/item/card/id/card = W
		if(!card.registered_account)
			return
		if(!card.registered_account.being_dumped)
			to_chat(user, "<span class='warning'>It appears that your funds are safe from draining!</span>")
			return
		if(do_after(user, 40, target = src))
			if(!card.registered_account.being_dumped)
				return
			to_chat(user, "<span class='warning'>You quickly cash out your funds to a more secure banking location. Funds are safu.</span>")
			card.registered_account.being_dumped = FALSE	
	else
		return ..()

/obj/structure/checkoutmachine/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)
	add_overlay("fins")
	add_overlay("hatch")
	add_overlay("legs_retracted")
	addtimer(CALLBACK(src, .proc/startUp), 50)

/obj/structure/checkoutmachine/proc/startUp()
	playsound(src, 'sound/machines/click.ogg', 15, 1, -3)
	priority_announce("The spacecoin bubble has popped! Get to the credit deposit machine at [get_area(src).name] and cash out before you lose all of your funds!", sender_override = "CRAB-17 Protocol")
	start_dumping()
	cut_overlay("fins")
	sleep(10)
	playsound(src, 'sound/machines/click.ogg', 15, 1, -3)
	cut_overlay("hatch")
	sleep(30)
	playsound(src,'sound/machines/twobeep.ogg',50,0)
	var/mutable_appearance/hologram = mutable_appearance(icon, "hologram")
	hologram.pixel_y = 16
	add_overlay(hologram)
	var/mutable_appearance/holosign = mutable_appearance(icon, "holosign")
	holosign.pixel_y = 16
	add_overlay(holosign)
	cut_overlay("legs_retracted")
	add_overlay("legs")
	canwalk = TRUE
	sleep(20)
	var/mutable_appearance/screenlines = mutable_appearance(icon, "screen_lines")
	screenlines.pixel_y = 8
	add_overlay(screenlines)
	sleep(5)
	var/mutable_appearance/screen = mutable_appearance(icon, "screen")
	screen.pixel_y = 8
	add_overlay(screen)
	sleep(5)
	playsound(src,'sound/machines/triple_beep.ogg',50,0)
	add_overlay("text")

/obj/structure/checkoutmachine/Destroy(var/force)
	if (!force)
		return QDEL_HINT_LETMELIVE
	stop_dumping()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/structure/checkoutmachine/proc/start_dumping()
	accounts_to_rob = SSeconomy.bank_accounts.Copy()
	accounts_to_rob -= bogdanoff.get_bank_account()
	for(var/i in accounts_to_rob)
		var/datum/bank_account/B = i
		B.being_dumped = TRUE
	dump()	

/obj/structure/checkoutmachine/proc/dump()
	var/percentage_lost = (rand(1, 10) / 100)
	for(var/i in accounts_to_rob)
		var/datum/bank_account/B = i
		if(!B.being_dumped)
			continue
		var/amount = B.account_balance * percentage_lost 
		bogdanoff.get_bank_account().transfer_money(B, amount)
		B.bank_card_talk("You have lost [percentage_lost * 100]% of your funds!")
	addtimer(CALLBACK(src, .proc/dump), 150) //Drain every 15 seconds

/obj/structure/checkoutmachine/process()
	if(!canwalk)
		return
	var/anydir = pick(GLOB.cardinals)
	if(Process_Spacemove(anydir))
		Move(get_step(src, anydir), anydir)

/obj/structure/checkoutmachine/proc/stop_dumping()
	for(var/i in accounts_to_rob)
		var/datum/bank_account/B = i
		B.being_dumped = FALSE

/obj/effect/dumpeetFall //Falling pod
	name = ""
	icon = 'icons/obj/money_machine.dmi'
	pixel_z = 300
	desc = "Get out of the way!"
	layer = FLY_LAYER//that wasnt flying, that was falling with style!
	icon_state = "missile_blur"

/obj/effect/dumpeetTarget
	name = "Landing Zone Indicator"
	desc = "A holographic projection designating the landing zone of something. It's probably best to stand back."
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	light_range = 2
	var/obj/effect/dumpeetFall/DF
	var/obj/structure/checkoutmachine/dump
	var/mob/living/carbon/human/bogdanoff

/obj/effect/ex_act()
	return

/obj/effect/dumpeetTarget/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/startLaunch), 20)

/obj/effect/dumpeetTarget/proc/startLaunch()
	DF = new /obj/effect/dumpeetFall(drop_location())
	dump = new /obj/structure/checkoutmachine()
	dump.bogdanoff = src.bogdanoff
	animate(DF, pixel_z = 0, time = 5, , easing = LINEAR_EASING) //Make the pod fall! At an angle!
	addtimer(CALLBACK(src, .proc/endLaunch), 5, TIMER_CLIENT_TIME) //Go onto the last step after a very short falling animation
	addtimer(CALLBACK(src, .proc/playFallingSound), 1, TIMER_CLIENT_TIME) //Go onto the last step after a very short falling animation

/obj/effect/dumpeetTarget/proc/playFallingSound()
	playsound(src,  'sound/weapons/mortar_whistle.ogg', 80, 1, 6)

/obj/effect/dumpeetTarget/proc/endLaunch()
	QDEL_NULL(DF) //Delete the falling pod effect, because at this point its animation is over. We dont use temp_visual because we want to manually delete it as soon as the pod appears
	playsound(src, "explosion", 80, 1)
	dump.forceMove(get_turf(src))
	qdel(src) //The target's purpose is complete. It can rest easy now
