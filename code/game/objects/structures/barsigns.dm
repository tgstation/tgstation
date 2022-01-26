/obj/structure/sign/barsign // All Signs are 64 by 32 pixels, they take two tiles
	name = "bar sign"
	desc = "A bar sign which has not been initialized, somehow. Complain at a coder!"
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"
	req_access = list(ACCESS_BAR)
	max_integrity = 500
	integrity_failure = 0.5
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 50, ACID = 50)
	buildable_sign = FALSE

	var/panel_open = FALSE
	var/datum/barsign/chosen_sign

/obj/structure/sign/barsign/Initialize(mapload)
	. = ..()
	set_sign(new /datum/barsign/hiddensigns/signoff)

/obj/structure/sign/barsign/proc/set_sign(datum/barsign/sign)
	if(!istype(sign))
		return

	icon_state = sign.icon

	if(sign.name)
		name = "[initial(name)] ([sign.name])"
	else
		name = "[initial(name)]"

	if(sign.desc)
		desc = sign.desc

	if(sign.rename_area && sign.name)
		rename_area(src, sign.name)

	return sign

/obj/structure/sign/barsign/proc/set_sign_by_name(sign_name)
	for(var/d in subtypesof(/datum/barsign))
		var/datum/barsign/D = d
		if(initial(D.name) == sign_name)
			var/new_sign = new D
			return set_sign(new_sign)

/obj/structure/sign/barsign/atom_break(damage_flag)
	. = ..()
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		broken = TRUE

/obj/structure/sign/barsign/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron(drop_location(), 2)
	new /obj/item/stack/cable_coil(drop_location(), 2)
	qdel(src)

/obj/structure/sign/barsign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/sign/barsign/attack_ai(mob/user)
	return attack_hand(user)

/obj/structure/sign/barsign/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!allowed(user))
		to_chat(user, span_info("Access denied."))
		return
	if(broken)
		to_chat(user, span_danger("The controls seem unresponsive."))
		return
	pick_sign(user)

/obj/structure/sign/barsign/screwdriver_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(!panel_open)
		to_chat(user, span_notice("You open the maintenance panel."))
		set_sign(new /datum/barsign/hiddensigns/signoff)
		panel_open = TRUE
	else
		to_chat(user, span_notice("You close the maintenance panel."))
		if(!broken)
			if(!chosen_sign)
				set_sign(new /datum/barsign/hiddensigns/signoff)
			else
				set_sign(chosen_sign)
		else
			set_sign(new /datum/barsign/hiddensigns/empbarsign)
		panel_open = FALSE

/obj/structure/sign/barsign/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/cable_coil) && panel_open)
		var/obj/item/stack/cable_coil/C = I
		if(!broken)
			to_chat(user, span_warning("This sign is functioning properly!"))
			return

		if(C.use(2))
			to_chat(user, span_notice("You replace the burnt wiring."))
			broken = FALSE
		else
			to_chat(user, span_warning("You need at least two lengths of cable!"))
	else
		return ..()


/obj/structure/sign/barsign/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	set_sign(new /datum/barsign/hiddensigns/empbarsign)
	broken = TRUE

/obj/structure/sign/barsign/emag_act(mob/user)
	if(broken)
		to_chat(user, span_warning("Nothing interesting happens!"))
		return
	to_chat(user, span_notice("You load an illegal barsign into the memory buffer..."))
	sleep(10 SECONDS)
	chosen_sign = set_sign(new /datum/barsign/hiddensigns/syndibarsign)


/obj/structure/sign/barsign/proc/pick_sign(mob/user)
	var/picked_name = tgui_input_list(user, "Available Signage", "Bar Sign", sort_list(get_bar_names()))
	if(isnull(picked_name))
		return
	chosen_sign = set_sign_by_name(picked_name)
	SSblackbox.record_feedback("tally", "barsign_picked", 1, chosen_sign.type)

/proc/get_bar_names()
	var/list/names = list()
	for(var/d in subtypesof(/datum/barsign))
		var/datum/barsign/D = d
		if(initial(D.name) && !initial(D.hidden))
			names += initial(D.name)
	. = names

/datum/barsign
	var/name = "Name"
	var/icon = "Icon"
	var/desc = "desc"
	var/hidden = FALSE
	var/rename_area = TRUE

/datum/barsign/New()
	if(!desc)
		desc = "It displays \"[name]\"."

// Specific bar signs.

/datum/barsign/maltesefalcon
	name = "Maltese Falcon"
	icon = "maltesefalcon"
	desc = "The Maltese Falcon, Space Bar and Grill."

/datum/barsign/thebark
	name = "The Bark"
	icon = "thebark"
	desc = "Ian's bar of choice."

/datum/barsign/harmbaton
	name = "The Harmbaton"
	icon = "theharmbaton"
	desc = "A great dining experience for both security members and assistants."

/datum/barsign/thesingulo
	name = "The Singulo"
	icon = "thesingulo"
	desc = "Where people go that'd rather not be called by their name."

/datum/barsign/thedrunkcarp
	name = "The Drunk Carp"
	icon = "thedrunkcarp"
	desc = "Don't drink and swim."

/datum/barsign/scotchservinwill
	name = "Scotch Servin Willy's"
	icon = "scotchservinwill"
	desc = "Willy sure moved up in the world from clown to bartender."

/datum/barsign/officerbeersky
	name = "Officer Beersky's"
	icon = "officerbeersky"
	desc = "Man eat a dong, these drinks are great."

/datum/barsign/thecavern
	name = "The Cavern"
	icon = "thecavern"
	desc = "Fine drinks while listening to some fine tunes."

/datum/barsign/theouterspess
	name = "The Outer Spess"
	icon = "theouterspess"
	desc = "This bar isn't actually located in outer space."

/datum/barsign/slipperyshots
	name = "Slippery Shots"
	icon = "slipperyshots"
	desc = "Slippery slope to drunkeness with our shots!"

/datum/barsign/thegreytide
	name = "The Grey Tide"
	icon = "thegreytide"
	desc = "Abandon your toolboxing ways and enjoy a lazy beer!"

/datum/barsign/honkednloaded
	name = "Honked 'n' Loaded"
	icon = "honkednloaded"
	desc = "Honk."

/datum/barsign/thenest
	name = "The Nest"
	icon = "thenest"
	desc = "A good place to retire for a drink after a long night of crime fighting."

/datum/barsign/thecoderbus
	name = "The Coderbus"
	icon = "thecoderbus"
	desc = "A very controversial bar known for its wide variety of constantly-changing drinks."

/datum/barsign/theadminbus
	name = "The Adminbus"
	icon = "theadminbus"
	desc = "An establishment visited mainly by space-judges. It isn't bombed nearly as much as court hearings."

/datum/barsign/oldcockinn
	name = "The Old Cock Inn"
	icon = "oldcockinn"
	desc = "Something about this sign fills you with despair."

/datum/barsign/thewretchedhive
	name = "The Wretched Hive"
	icon = "thewretchedhive"
	desc = "Legally obligated to instruct you to check your drinks for acid before consumption."

/datum/barsign/robustacafe
	name = "The Robusta Cafe"
	icon = "robustacafe"
	desc = "Holder of the 'Most Lethal Barfights' record 5 years uncontested."

/datum/barsign/emergencyrumparty
	name = "The Emergency Rum Party"
	icon = "emergencyrumparty"
	desc = "Recently relicensed after a long closure."

/datum/barsign/combocafe
	name = "The Combo Cafe"
	icon = "combocafe"
	desc = "Renowned system-wide for their utterly uncreative drink combinations."

/datum/barsign/vladssaladbar
	name = "Vlad's Salad Bar"
	icon = "vladssaladbar"
	desc = "Under new management. Vlad was always a bit too trigger happy with that shotgun."

/datum/barsign/theshaken
	name = "The Shaken"
	icon = "theshaken"
	desc = "This establishment does not serve stirred drinks."

/datum/barsign/thealenath
	name = "The Ale' Nath"
	icon = "thealenath"
	desc = "All right, buddy. I think you've had EI NATH. Time to get a cab."

/datum/barsign/thealohasnackbar
	name = "The Aloha Snackbar"
	icon = "alohasnackbar"
	desc = "A tasteful, inoffensive tiki bar sign."

/datum/barsign/thenet
	name = "The Net"
	icon = "thenet"
	desc = "You just seem to get caught up in it for hours."

/datum/barsign/maidcafe
	name = "Maid Cafe"
	icon = "maidcafe"
	desc = "Welcome back, master!"

/datum/barsign/the_lightbulb
	name = "The Lightbulb"
	icon = "the_lightbulb"
	desc = "A cafe popular among moths and moffs. Once shut down for a week after the bartender used mothballs to protect her spare uniforms."

/datum/barsign/goose
	name = "The Loose Goose"
	icon = "goose"
	desc = "Drink till you puke and/or break the laws of reality!"

/datum/barsign/hiddensigns
	hidden = TRUE


//Hidden signs list below this point



/datum/barsign/hiddensigns/empbarsign
	name = null
	icon = "empbarsign"
	desc = "Something has gone very wrong."
	rename_area = FALSE

/datum/barsign/hiddensigns/syndibarsign
	name = "Syndi Cat"
	icon = "syndibarsign"
	desc = "Syndicate or die."

/datum/barsign/hiddensigns/signoff
	name = null
	icon = "empty"
	desc = "This sign doesn't seem to be on."
	rename_area = FALSE
