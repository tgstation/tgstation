/obj/machinery/barsign // All Signs are 64 by 32 pixels, they take two tiles
	name = "bar sign"
	desc = "A bar sign which has not been initialized, somehow. Complain at a coder!"
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"
	req_access = list(ACCESS_BAR)
	max_integrity = 500
	integrity_failure = 0.5
	armor_type = /datum/armor/sign_barsign
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.15
	/// Selected barsign being used
	var/datum/barsign/chosen_sign

/datum/armor/sign_barsign
	melee = 20
	bullet = 20
	laser = 20
	energy = 100
	fire = 50
	acid = 50

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/barsign, 32)

/obj/machinery/barsign/Initialize(mapload)
	. = ..()
	set_sign(new /datum/barsign/hiddensigns/signoff)

/obj/machinery/barsign/proc/set_sign(datum/barsign/sign)
	if(!istype(sign))
		return

	if(sign.rename_area)
		rename_area(src, sign.name)

	chosen_sign = sign
	update_appearance()

/obj/machinery/barsign/update_icon_state()
	if(!(machine_stat & (NOPOWER|BROKEN)) && chosen_sign && chosen_sign.icon)
		icon_state = chosen_sign.icon
	else
		icon_state = "empty"

	return ..()

/obj/machinery/barsign/update_desc()
	. = ..()

	if(chosen_sign && chosen_sign.desc)
		desc = chosen_sign.desc

/obj/machinery/barsign/update_name()
	. = ..()
	if(chosen_sign && chosen_sign.rename_area)
		name = "[initial(name)] ([chosen_sign.name])"
	else
		name = "[initial(name)]"

/obj/machinery/barsign/update_overlays()
	. = ..()

	if(machine_stat & (NOPOWER|BROKEN))
		return

	if(chosen_sign && chosen_sign.light_mask)
		. += emissive_appearance(icon, "[chosen_sign.icon]-light-mask", src)

/obj/machinery/barsign/update_appearance(updates=ALL)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		set_light(0)
		return
	if(chosen_sign && chosen_sign.neon_color)
		set_light(MINIMUM_USEFUL_LIGHT_RANGE, 0.7, chosen_sign.neon_color)

/obj/machinery/barsign/proc/set_sign_by_name(sign_name)
	for(var/datum/barsign/sign as anything in subtypesof(/datum/barsign))
		if(initial(sign.name) == sign_name)
			var/new_sign = new sign
			set_sign(new_sign)

/obj/machinery/barsign/atom_break(damage_flag)
	. = ..()
	if((machine_stat & BROKEN) && !(flags_1 & NODECONSTRUCT_1))
		set_sign(new /datum/barsign/hiddensigns/signoff)

/obj/machinery/barsign/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron(drop_location(), 2)
	new /obj/item/stack/cable_coil(drop_location(), 2)
	qdel(src)

/obj/machinery/barsign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/machinery/barsign/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/barsign/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!allowed(user))
		balloon_alert(user, "access denied!")
		return
	if(machine_stat & (NOPOWER|BROKEN|EMPED))
		balloon_alert(user, "controls are unresponsive!")
		return
	pick_sign(user)

/obj/machinery/barsign/screwdriver_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	panel_open = !panel_open
	if(panel_open)
		balloon_alert(user, "panel opened")
		set_sign(new /datum/barsign/hiddensigns/signoff)
		return TOOL_ACT_TOOLTYPE_SUCCESS

	balloon_alert(user, "panel closed")

	if(machine_stat & (NOPOWER|BROKEN) || !chosen_sign)
		set_sign(new /datum/barsign/hiddensigns/signoff)
	else
		set_sign(chosen_sign)

	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/barsign/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/cable_coil) && panel_open)
		var/obj/item/stack/cable_coil/wire = I

		if(atom_integrity >= max_integrity)
			balloon_alert(user, "doesn't need repairs!")
			return TRUE

		if(!wire.use(2))
			balloon_alert(user, "need two cables!")
			return TRUE

		balloon_alert(user, "repaired")
		atom_integrity = max_integrity
		set_machine_stat(machine_stat & ~BROKEN)
		update_appearance()
		return TRUE

	// if barsigns ever become a craftable or techweb wall mount then remove this
	if(machine_stat & BROKEN)
		return TRUE

	return ..()

/obj/machinery/barsign/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return

	set_machine_stat(machine_stat | EMPED)
	addtimer(CALLBACK(src, PROC_REF(fix_emp), chosen_sign), 60 SECONDS)
	set_sign(new /datum/barsign/hiddensigns/empbarsign)

/// Callback to un-emp the sign some time.
/obj/machinery/barsign/proc/fix_emp(datum/barsign/sign)
	set_machine_stat(machine_stat & ~EMPED)
	if(!istype(sign))
		return

	set_sign(sign)

/obj/machinery/barsign/emag_act(mob/user)
	if(machine_stat & (NOPOWER|BROKEN|EMPED))
		balloon_alert(user, "controls are unresponsive!")
		return

	balloon_alert(user, "illegal barsign loaded")
	sleep(10 SECONDS)
	set_sign(new /datum/barsign/hiddensigns/syndibarsign)


/obj/machinery/barsign/proc/pick_sign(mob/user)
	var/picked_name = tgui_input_list(user, "Available Signage", "Bar Sign", sort_list(get_bar_names()))
	if(isnull(picked_name))
		return
	set_sign_by_name(picked_name)
	SSblackbox.record_feedback("tally", "barsign_picked", 1, chosen_sign.type)

/proc/get_bar_names()
	var/list/names = list()
	for(var/d in subtypesof(/datum/barsign))
		var/datum/barsign/D = d
		if(!initial(D.hidden))
			names += initial(D.name)
	. = names

/datum/barsign
	/// User-visible name of the sign.
	var/name
	/// Icon state associated with this sign
	var/icon
	/// Description shown in the sign's examine text.
	var/desc
	/// Hidden from list of selectable options.
	var/hidden = FALSE
	/// Rename the area when this sign is selected.
	var/rename_area = TRUE
	/// If a barsign has a light mask for emission effects
	var/light_mask = TRUE
	/// The emission color of the neon light
	var/neon_color

/datum/barsign/New()
	if(!desc)
		desc = "It displays \"[name]\"."

// Specific bar signs.

/datum/barsign/maltesefalcon
	name = "Maltese Falcon"
	icon = "maltesefalcon"
	desc = "The Maltese Falcon, Space Bar and Grill."
	neon_color = "#5E8EAC"

/datum/barsign/thebark
	name = "The Bark"
	icon = "thebark"
	desc = "Ian's bar of choice."
	neon_color = "#f7a604"

/datum/barsign/harmbaton
	name = "The Harmbaton"
	icon = "theharmbaton"
	desc = "A great dining experience for both security members and assistants."
	neon_color = "#ff7a4d"

/datum/barsign/thesingulo
	name = "The Singulo"
	icon = "thesingulo"
	desc = "Where people go that'd rather not be called by their name."
	neon_color = "#E600DB"

/datum/barsign/thedrunkcarp
	name = "The Drunk Carp"
	icon = "thedrunkcarp"
	desc = "Don't drink and swim."
	neon_color = "#a82196"

/datum/barsign/scotchservinwill
	name = "Scotch Servin Willy's"
	icon = "scotchservinwill"
	desc = "Willy sure moved up in the world from clown to bartender."
	neon_color = "#fee4bf"

/datum/barsign/officerbeersky
	name = "Officer Beersky's"
	icon = "officerbeersky"
	desc = "Man eat a dong, these drinks are great."
	neon_color = "#16C76B"

/datum/barsign/thecavern
	name = "The Cavern"
	icon = "thecavern"
	desc = "Fine drinks while listening to some fine tunes."
	neon_color = "#0fe500"

/datum/barsign/theouterspess
	name = "The Outer Spess"
	icon = "theouterspess"
	desc = "This bar isn't actually located in outer space."
	neon_color = "#30f3cc"

/datum/barsign/slipperyshots
	name = "Slippery Shots"
	icon = "slipperyshots"
	desc = "Slippery slope to drunkeness with our shots!"
	neon_color = "#70DF00"

/datum/barsign/thegreytide
	name = "The Grey Tide"
	icon = "thegreytide"
	desc = "Abandon your toolboxing ways and enjoy a lazy beer!"
	neon_color = "#00F4D6"

/datum/barsign/honkednloaded
	name = "Honked 'n' Loaded"
	icon = "honkednloaded"
	desc = "Honk."
	neon_color = "#FF998A"

/datum/barsign/thenest
	name = "The Nest"
	icon = "thenest"
	desc = "A good place to retire for a drink after a long night of crime fighting."
	neon_color = "#4d6796"

/datum/barsign/thecoderbus
	name = "The Coderbus"
	icon = "thecoderbus"
	desc = "A very controversial bar known for its wide variety of constantly-changing drinks."
	neon_color = "#ffffff"

/datum/barsign/theadminbus
	name = "The Adminbus"
	icon = "theadminbus"
	desc = "An establishment visited mainly by space-judges. It isn't bombed nearly as much as court hearings."
	neon_color = "#ffffff"

/datum/barsign/oldcockinn
	name = "The Old Cock Inn"
	icon = "oldcockinn"
	desc = "Something about this sign fills you with despair."
	neon_color = "#a4352b"

/datum/barsign/thewretchedhive
	name = "The Wretched Hive"
	icon = "thewretchedhive"
	desc = "Legally obligated to instruct you to check your drinks for acid before consumption."
	neon_color = "#26b000"

/datum/barsign/robustacafe
	name = "The Robusta Cafe"
	icon = "robustacafe"
	desc = "Holder of the 'Most Lethal Barfights' record 5 years uncontested."
	neon_color = "#c45f7a"

/datum/barsign/emergencyrumparty
	name = "The Emergency Rum Party"
	icon = "emergencyrumparty"
	desc = "Recently relicensed after a long closure."
	neon_color = "#f90011"

/datum/barsign/combocafe
	name = "The Combo Cafe"
	icon = "combocafe"
	desc = "Renowned system-wide for their utterly uncreative drink combinations."
	neon_color = "#33ca40"

/datum/barsign/vladssaladbar
	name = "Vlad's Salad Bar"
	icon = "vladssaladbar"
	desc = "Under new management. Vlad was always a bit too trigger happy with that shotgun."
	neon_color = "#306900"

/datum/barsign/theshaken
	name = "The Shaken"
	icon = "theshaken"
	desc = "This establishment does not serve stirred drinks."
	neon_color = "#dcd884"

/datum/barsign/thealenath
	name = "The Ale' Nath"
	icon = "thealenath"
	desc = "All right, buddy. I think you've had EI NATH. Time to get a cab."
	neon_color = "#ed0000"

/datum/barsign/thealohasnackbar
	name = "The Aloha Snackbar"
	icon = "alohasnackbar"
	desc = "A tasteful, inoffensive tiki bar sign."
	neon_color = ""

/datum/barsign/thenet
	name = "The Net"
	icon = "thenet"
	desc = "You just seem to get caught up in it for hours."
	neon_color = "#0e8a00"

/datum/barsign/maidcafe
	name = "Maid Cafe"
	icon = "maidcafe"
	desc = "Welcome back, master!"
	neon_color = "#ff0051"

/datum/barsign/the_lightbulb
	name = "The Lightbulb"
	icon = "the_lightbulb"
	desc = "A cafe popular among moths and moffs. Once shut down for a week after the bartender used mothballs to protect her spare uniforms."
	neon_color = "#faff82"

/datum/barsign/goose
	name = "The Loose Goose"
	icon = "goose"
	desc = "Drink till you puke and/or break the laws of reality!"
	neon_color = "#00cc33"

// Hidden signs list below this point

/datum/barsign/hiddensigns
	hidden = TRUE

/datum/barsign/hiddensigns/empbarsign
	name = "EMP'd"
	icon = "empbarsign"
	desc = "Something has gone very wrong."
	rename_area = FALSE

/datum/barsign/hiddensigns/syndibarsign
	name = "Syndi Cat"
	icon = "syndibarsign"
	desc = "Syndicate or die."
	neon_color = "#ff0000"

/datum/barsign/hiddensigns/signoff
	name = "Off"
	icon = "empty"
	desc = "This sign doesn't seem to be on."
	rename_area = FALSE
	light_mask = FALSE

// For other locations that aren't in the main bar
/obj/machinery/barsign/all_access
	req_access = null

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/barsign/all_access, 32)
