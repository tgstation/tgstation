/obj/machinery/barsign // All Signs are 64 by 32 pixels, they take two tiles
	name = "bar sign"
	desc = "A bar sign which has not been initialized, somehow. Complain at a coder!"
	icon = 'icons/obj/machines/barsigns.dmi'
	icon_state = "empty"
	req_access = list(ACCESS_BAR)
	max_integrity = 500
	integrity_failure = 0.5
	armor_type = /datum/armor/sign_barsign
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.15
	/// Selected barsign being used
	var/datum/barsign/chosen_sign
	/// Do we attempt to rename the area we occupy when the chosen sign is changed?
	var/change_area_name = FALSE
	/// What kind of sign do we drop upon being disassembled?
	var/disassemble_result = /obj/item/wallframe/barsign

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
	//Roundstart/map specific barsigns "belong" in their area and should be renaming it, signs created from wallmounts will not.
	change_area_name = mapload
	set_sign(new /datum/barsign/hiddensigns/signoff)
	find_and_hang_on_wall()

/obj/machinery/barsign/proc/set_sign(datum/barsign/sign)
	if(!istype(sign))
		return

	var/area/bar_area = get_area(src)
	if(change_area_name && sign.rename_area)
		rename_area(bar_area, sign.name)

	chosen_sign = sign
	update_appearance()

/obj/machinery/barsign/update_icon_state()
	if(!(machine_stat & BROKEN) && (!(machine_stat & NOPOWER) || machine_stat & EMPED) && chosen_sign && chosen_sign.icon_state)
		icon_state = chosen_sign.icon_state
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

	if(((machine_stat & NOPOWER) && !(machine_stat & EMPED)) || (machine_stat & BROKEN))
		return

	if(chosen_sign && chosen_sign.light_mask)
		. += emissive_appearance(icon, "[chosen_sign.icon_state]-light-mask", src)

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
	if(machine_stat & BROKEN)
		set_sign(new /datum/barsign/hiddensigns/signoff)

/obj/machinery/barsign/on_deconstruction(disassembled)
	if(disassembled)
		new disassemble_result(drop_location())
	else
		new /obj/item/stack/sheet/iron(drop_location(), 2)
		new /obj/item/stack/cable_coil(drop_location(), 2)

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
		return ITEM_INTERACT_SUCCESS

	balloon_alert(user, "panel closed")

	if(machine_stat & (NOPOWER|BROKEN) || !chosen_sign)
		set_sign(new /datum/barsign/hiddensigns/signoff)
	else
		set_sign(chosen_sign)

	return ITEM_INTERACT_SUCCESS

/obj/machinery/barsign/wrench_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		balloon_alert(user, "open the panel first!")
		return ITEM_INTERACT_BLOCKING

	tool.play_tool_sound(src)
	if(!do_after(user, (10 SECONDS), target = src))
		return ITEM_INTERACT_BLOCKING

	tool.play_tool_sound(src)
	deconstruct(disassembled = TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/barsign/attackby(obj/item/attacking_item, mob/user)

	if(istype(attacking_item, /obj/item/blueprints) && !change_area_name)
		if(!panel_open)
			balloon_alert(user, "open the panel first!")
			return TRUE

		change_area_name = TRUE
		balloon_alert(user, "sign registered")
		return TRUE

	if(istype(attacking_item, /obj/item/stack/cable_coil) && panel_open)
		var/obj/item/stack/cable_coil/wire = attacking_item

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

/obj/machinery/barsign/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(machine_stat & (NOPOWER|BROKEN|EMPED))
		balloon_alert(user, "controls are unresponsive!")
		return FALSE

	balloon_alert(user, "illegal barsign loaded")
	addtimer(CALLBACK(src, PROC_REF(finish_emag_act)), 10 SECONDS)
	return TRUE

/// Timer proc, called after ~10 seconds after [emag_act], since [emag_act] returns a value and cannot sleep
/obj/machinery/barsign/proc/finish_emag_act()
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
	var/icon_state
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
	icon_state = "maltesefalcon"
	desc = "The Maltese Falcon, Space Bar and Grill."
	neon_color = "#5E8EAC"

/datum/barsign/thebark
	name = "The Bark"
	icon_state = "thebark"
	desc = "Ian's bar of choice."
	neon_color = "#f7a604"

/datum/barsign/harmbaton
	name = "The Harmbaton"
	icon_state = "theharmbaton"
	desc = "A great dining experience for both security members and assistants."
	neon_color = "#ff7a4d"

/datum/barsign/thesingulo
	name = "The Singulo"
	icon_state = "thesingulo"
	desc = "Where people go that'd rather not be called by their name."
	neon_color = "#E600DB"

/datum/barsign/thedrunkcarp
	name = "The Drunk Carp"
	icon_state = "thedrunkcarp"
	desc = "Don't drink and swim."
	neon_color = "#a82196"

/datum/barsign/scotchservinwill
	name = "Scotch Servin Willy's"
	icon_state = "scotchservinwill"
	desc = "Willy sure moved up in the world from clown to bartender."
	neon_color = "#fee4bf"

/datum/barsign/officerbeersky
	name = "Officer Beersky's"
	icon_state = "officerbeersky"
	desc = "Man eat a dong, these drinks are great."
	neon_color = "#16C76B"

/datum/barsign/thecavern
	name = "The Cavern"
	icon_state = "thecavern"
	desc = "Fine drinks while listening to some fine tunes."
	neon_color = "#0fe500"

/datum/barsign/theouterspess
	name = "The Outer Spess"
	icon_state = "theouterspess"
	desc = "This bar isn't actually located in outer space."
	neon_color = "#30f3cc"

/datum/barsign/slipperyshots
	name = "Slippery Shots"
	icon_state = "slipperyshots"
	desc = "Slippery slope to drunkeness with our shots!"
	neon_color = "#70DF00"

/datum/barsign/thegreytide
	name = "The Grey Tide"
	icon_state = "thegreytide"
	desc = "Abandon your toolboxing ways and enjoy a lazy beer!"
	neon_color = "#00F4D6"

/datum/barsign/honkednloaded
	name = "Honked 'n' Loaded"
	icon_state = "honkednloaded"
	desc = "Honk."
	neon_color = "#FF998A"

/datum/barsign/le_cafe_silencieux
	name = "Le Café Silencieux"
	icon_state = "le_cafe_silencieux"
	desc = "..."
	neon_color = "#ffffff"

/datum/barsign/thenest
	name = "The Nest"
	icon_state = "thenest"
	desc = "A good place to retire for a drink after a long night of crime fighting."
	neon_color = "#4d6796"

/datum/barsign/thecoderbus
	name = "The Coderbus"
	icon_state = "thecoderbus"
	desc = "A very controversial bar known for its wide variety of constantly-changing drinks."
	neon_color = "#ffffff"

/datum/barsign/theadminbus
	name = "The Adminbus"
	icon_state = "theadminbus"
	desc = "An establishment visited mainly by space-judges. It isn't bombed nearly as much as court hearings."
	neon_color = "#ffffff"

/datum/barsign/oldcockinn
	name = "The Old Cock Inn"
	icon_state = "oldcockinn"
	desc = "Something about this sign fills you with despair."
	neon_color = "#a4352b"

/datum/barsign/thewretchedhive
	name = "The Wretched Hive"
	icon_state = "thewretchedhive"
	desc = "Legally obligated to instruct you to check your drinks for acid before consumption."
	neon_color = "#26b000"

/datum/barsign/robustacafe
	name = "The Robusta Cafe"
	icon_state = "robustacafe"
	desc = "Holder of the 'Most Lethal Barfights' record 5 years uncontested."
	neon_color = "#c45f7a"

/datum/barsign/emergencyrumparty
	name = "The Emergency Rum Party"
	icon_state = "emergencyrumparty"
	desc = "Recently relicensed after a long closure."
	neon_color = "#f90011"

/datum/barsign/combocafe
	name = "The Combo Cafe"
	icon_state = "combocafe"
	desc = "Renowned system-wide for their utterly uncreative drink combinations."
	neon_color = "#33ca40"

/datum/barsign/vladssaladbar
	name = "Vlad's Salad Bar"
	icon_state = "vladssaladbar"
	desc = "Under new management. Vlad was always a bit too trigger happy with that shotgun."
	neon_color = "#306900"

/datum/barsign/theshaken
	name = "The Shaken"
	icon_state = "theshaken"
	desc = "This establishment does not serve stirred drinks."
	neon_color = "#dcd884"

/datum/barsign/thealenath
	name = "The Ale' Nath"
	icon_state = "thealenath"
	desc = "All right, buddy. I think you've had EI NATH. Time to get a cab."
	neon_color = "#ed0000"

/datum/barsign/thealohasnackbar
	name = "The Aloha Snackbar"
	icon_state = "alohasnackbar"
	desc = "A tasteful, inoffensive tiki bar sign."
	neon_color = ""

/datum/barsign/thenet
	name = "The Net"
	icon_state = "thenet"
	desc = "You just seem to get caught up in it for hours."
	neon_color = "#0e8a00"

/datum/barsign/maidcafe
	name = "Maid Cafe"
	icon_state = "maidcafe"
	desc = "Welcome back, master!"
	neon_color = "#ff0051"

/datum/barsign/the_lightbulb
	name = "The Lightbulb"
	icon_state = "the_lightbulb"
	desc = "A cafe popular among moths and moffs. Once shut down for a week after the bartender used mothballs to protect her spare uniforms."
	neon_color = "#faff82"

/datum/barsign/goose
	name = "The Loose Goose"
	icon_state = "goose"
	desc = "Drink till you puke and/or break the laws of reality!"
	neon_color = "#00cc33"

/datum/barsign/maltroach
	name = "Maltroach"
	icon_state = "maltroach"
	desc = "Mothroaches politely greet you into the bar, or are they greeting each other?"
	neon_color = "#649e8a"

/datum/barsign/rock_bottom
	name = "Rock Bottom"
	icon_state = "rock-bottom"
	desc = "When it feels like you're stuck in a pit, might as well have a drink."
	neon_color = "#aa2811"

/datum/barsign/orangejuice
	name = "Oranges' Juicery"
	icon_state = "orangejuice"
	desc = "For those who wish to be optimally tactful to the non-alcoholic population."
	neon_color = COLOR_ORANGE

/datum/barsign/tearoom
	name = "Little Treats Tea Room"
	icon_state = "little_treats"
	desc = "A delightfully relaxing tearoom for all the fancy lads in the cosmos."
	neon_color = COLOR_LIGHT_ORANGE

/datum/barsign/assembly_line
	name = "The Assembly Line"
	icon_state = "the-assembly-line"
	desc = "Where every drink is masterfully crafted with industrial efficiency!"
	neon_color = "#ffffff"

/datum/barsign/bargonia
	name = "Bargonia"
	icon_state = "bargonia"
	desc = "The warehouse yearns for a higher calling... so Supply has declared BARGONIA!"
	neon_color = COLOR_WHITE

/datum/barsign/cult_cove
	name = "Cult Cove"
	icon_state = "cult-cove"
	desc = "Nar'Sie's favourite retreat"
	neon_color = COLOR_RED

/datum/barsign/neon_flamingo
	name = "Neon Flamingo"
	icon_state = "neon-flamingo"
	desc = "A bus for all but the flamboyantly challenged."
	neon_color = COLOR_PINK

/datum/barsign/slowdive
	name = "Slowdive"
	icon_state = "slowdive"
	desc = "First stop out of hell, last stop before heaven."
	neon_color = COLOR_RED

/datum/barsign/the_red_mons
	name = "The Red Mons"
	icon_state = "the-red-mons"
	desc = "Drinks from the Red Planet."
	neon_color = COLOR_RED

/datum/barsign/the_rune
	name = "The Rune"
	icon_state = "therune"
	desc = "Reality Shifting drinks."
	neon_color = COLOR_RED

/datum/barsign/the_wizard
	name = "The Wizard"
	icon_state = "the-wizard"
	desc = "Magical mixes."
	neon_color = COLOR_RED

/datum/barsign/months_moths_moths
	name = "Moths Moths Moths"
	icon_state = "moths-moths-moths"
	desc = "LIVE MOTHS!"
	neon_color = COLOR_RED

// Hidden signs list below this point

/datum/barsign/hiddensigns
	hidden = TRUE

/datum/barsign/hiddensigns/empbarsign
	name = "EMP'd"
	icon_state = "empbarsign"
	desc = "Something has gone very wrong."
	rename_area = FALSE

/datum/barsign/hiddensigns/syndibarsign
	name = "Syndi Cat"
	icon_state = "syndibarsign"
	desc = "Syndicate or die."
	neon_color = "#ff0000"

/datum/barsign/hiddensigns/signoff
	name = "Off"
	icon_state = "empty"
	desc = "This sign doesn't seem to be on."
	rename_area = FALSE
	light_mask = FALSE

// For other locations that aren't in the main bar
/obj/machinery/barsign/all_access
	req_access = null
	disassemble_result = /obj/item/wallframe/barsign/all_access

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/barsign/all_access, 32)

/obj/item/wallframe/barsign
	name = "bar sign frame"
	desc = "Used to help draw the rabble into your bar. Some assembly required."
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "barsign"
	result_path = /obj/machinery/barsign
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)
	pixel_shift = 32

/obj/item/wallframe/barsign/Initialize(mapload)
	. = ..()
	desc += " Can be registered with a set of [span_bold("station blueprints")] to associate the sign with the area it occupies."

/obj/item/wallframe/barsign/try_build(turf/on_wall, mob/user)
	. = ..()
	if(!.)
		return .

	if(isopenturf(get_step(on_wall, EAST))) //This takes up 2 tiles so we want to make sure we have two tiles to hang it from.
		balloon_alert(user, "needs more support!")
		return FALSE

/obj/item/wallframe/barsign/all_access
	desc = "Used to help draw the rabble into your bar. Some assembly required. This one doesn't have an access lock."
	result_path = /obj/machinery/barsign/all_access
