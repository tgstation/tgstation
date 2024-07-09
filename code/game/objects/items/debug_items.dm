/* This file contains standalone items for debug purposes. */

/obj/item/debug/human_spawner
	name = "human spawner"
	desc = "Spawn a human by aiming at a turf and clicking. Use in hand to change type."
	icon = 'icons/obj/weapons/guns/magic.dmi'
	icon_state = "nothingwand"
	inhand_icon_state = "wand"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/datum/species/selected_species
	var/valid_species = list()

/obj/item/debug/human_spawner/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom(interacting_with, user, modifiers)

/obj/item/debug/human_spawner/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(isturf(interacting_with))
		var/mob/living/carbon/human/H = new /mob/living/carbon/human(interacting_with)
		if(selected_species)
			H.set_species(selected_species)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/debug/human_spawner/attack_self(mob/user)
	..()
	var/choice = input("Select a species", "Human Spawner", null) in sortTim(GLOB.species_list, GLOBAL_PROC_REF(cmp_text_asc))
	selected_species = GLOB.species_list[choice]

/obj/item/debug/omnitool
	name = "omnitool"
	desc = "The original hypertool, born before them all. Use it in hand to unleash its true power."
	icon = 'icons/obj/weapons/club.dmi'
	icon_state = "hypertool"
	inhand_icon_state = "hypertool"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	toolspeed = 0.1
	tool_behaviour = null

/obj/item/debug/omnitool/examine()
	. = ..()
	. += " The mode is: [tool_behaviour]"

/obj/item/debug/omnitool/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/debug/omnitool/get_all_tool_behaviours()
	return list(TOOL_ANALYZER,
	TOOL_BLOODFILTER,
	TOOL_BONESET,
	TOOL_CAUTERY,
	TOOL_CROWBAR,
	TOOL_DRILL,
	TOOL_HEMOSTAT,
	TOOL_KNIFE,
	TOOL_MINING,
	TOOL_MULTITOOL,
	TOOL_RETRACTOR,
	TOOL_ROLLINGPIN,
	TOOL_RUSTSCRAPER,
	TOOL_SAW,
	TOOL_SCALPEL,
	TOOL_SCREWDRIVER,
	TOOL_SHOVEL,
	TOOL_WELDER,
	TOOL_WIRECUTTER,
	TOOL_WRENCH,
	)

/obj/item/debug/omnitool/attack_self(mob/user)
	if(!user)
		return
	var/list/tool_list = list(
		"Crowbar" = image(icon = 'icons/obj/tools.dmi', icon_state = "crowbar"),
		"Multitool" = image(icon = 'icons/obj/devices/tool.dmi', icon_state = "multitool"),
		"Screwdriver" = image(icon = 'icons/obj/tools.dmi', icon_state = "screwdriver_map"),
		"Wirecutters" = image(icon = 'icons/obj/tools.dmi', icon_state = "cutters_map"),
		"Wrench" = image(icon = 'icons/obj/tools.dmi', icon_state = "wrench"),
		"Welding Tool" = image(icon = 'icons/obj/tools.dmi', icon_state = "miniwelder"),
		"Analyzer" = image(icon = 'icons/obj/devices/scanner.dmi', icon_state = "analyzer"),
		"Pickaxe" = image(icon = 'icons/obj/mining.dmi', icon_state = "minipick"),
		"Shovel" = image(icon = 'icons/obj/mining.dmi', icon_state = "shovel"),
		"Retractor" = image(icon = 'icons/obj/medical/surgery_tools.dmi', icon_state = "retractor"),
		"Hemostat" = image(icon = 'icons/obj/medical/surgery_tools.dmi', icon_state = "hemostat"),
		"Cautery" = image(icon = 'icons/obj/medical/surgery_tools.dmi', icon_state = "cautery"),
		"Drill" = image(icon = 'icons/obj/medical/surgery_tools.dmi', icon_state = "drill"),
		"Scalpel" = image(icon = 'icons/obj/medical/surgery_tools.dmi', icon_state = "scalpel"),
		"Saw" = image(icon = 'icons/obj/medical/surgery_tools.dmi', icon_state = "saw"),
		"Bonesetter" = image(icon = 'icons/obj/medical/surgery_tools.dmi', icon_state = "bonesetter"),
		"Knife" = image(icon = 'icons/obj/service/kitchen.dmi', icon_state = "knife"),
		"Blood Filter" = image(icon = 'icons/obj/medical/surgery_tools.dmi', icon_state = "bloodfilter"),
		"Rolling Pin" = image(icon = 'icons/obj/service/kitchen.dmi', icon_state = "rolling_pin"),
		"Wire Brush" = image(icon = 'icons/obj/tools.dmi', icon_state = "wirebrush"),
		)
	var/tool_result = show_radial_menu(user, src, tool_list, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(tool_result)
		if("Crowbar")
			tool_behaviour = TOOL_CROWBAR
		if("Multitool")
			tool_behaviour = TOOL_MULTITOOL
		if("Screwdriver")
			tool_behaviour = TOOL_SCREWDRIVER
		if("Wirecutters")
			tool_behaviour = TOOL_WIRECUTTER
		if("Wrench")
			tool_behaviour = TOOL_WRENCH
		if("Welding Tool")
			tool_behaviour = TOOL_WELDER
		if("Analyzer")
			tool_behaviour = TOOL_ANALYZER
		if("Pickaxe")
			tool_behaviour = TOOL_MINING
		if("Shovel")
			tool_behaviour = TOOL_SHOVEL
		if("Retractor")
			tool_behaviour = TOOL_RETRACTOR
		if("Hemostat")
			tool_behaviour = TOOL_HEMOSTAT
		if("Cautery")
			tool_behaviour = TOOL_CAUTERY
		if("Drill")
			tool_behaviour = TOOL_DRILL
		if("Scalpel")
			tool_behaviour = TOOL_SCALPEL
		if("Saw")
			tool_behaviour = TOOL_SAW
		if("Bonesetter")
			tool_behaviour = TOOL_BONESET
		if("Knife")
			tool_behaviour = TOOL_KNIFE
		if("Blood Filter")
			tool_behaviour = TOOL_BLOODFILTER
		if("Rolling Pin")
			tool_behaviour = TOOL_ROLLINGPIN
		if("Wire Brush")
			tool_behaviour = TOOL_RUSTSCRAPER

/obj/item/debug/omnitool/item_spawner
	name = "spawntool"
	color = COLOR_ADMIN_PINK

/obj/item/debug/omnitool/item_spawner/attack_self(mob/user)
	if(!user || !user.client)
		return
	var/path = text2path(tgui_input_text(user, "Insert an item typepath to spawn", "ADMINS ONLY. FUCK AROUND AND FIND OUT."))
	if(!path)
		return
	var/choice = tgui_alert(user, "Subtypes only?",, list("Yes", "No"))
	if(!choice)
		return
	if(!user.client.holder)
		if(!isliving(user))
			return
		var/mob/living/living_user = user
		to_chat(user, span_warning("As you try to use [src], you hear strange tearing sounds, as if the coder gods were attempting to reach out and choke you themselves."))
		playsound(src, 'sound/effects/dimensional_rend.ogg')
		sleep(4 SECONDS)
		var/confirmation = tgui_alert(user, "Are you certain you want to do that?", "Admins Only. Last Chance.", list("Yes", "No"))
		if(!confirmation || confirmation == ("No"))
			return
		if(!user.client.holder) //safety if the admin readmined to save their ass lol.
			to_chat(user, span_reallybig("You shouldn't have done that..."))
			playsound(src, 'sound/voice/borg_deathsound.ogg')
			sleep(3 SECONDS)
			living_user.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
			living_user.gib(DROP_ALL_REMAINS)
			return
	var/turf/loc_turf = get_turf(src)
	for(var/spawn_atom in (choice == "No" ? typesof(path) : subtypesof(path)))
		new spawn_atom(loc_turf)
