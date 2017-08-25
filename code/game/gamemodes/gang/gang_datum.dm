//gang_datum.dm
//Bare minimum of gang datum - for multiverse.

/datum/gang
	var/name = "ERROR"
	var/color = "white"
	var/color_hex = "#FFFFFF"
	var/list/datum/mind/gangsters = list() //gang B Members
	var/list/datum/mind/bosses = list() //gang A Bosses
	var/list/obj/item/device/gangtool/gangtools = list()
	var/list/tags_by_mind = list()				//Assoc list in format of tags_by_mind[mind_of_gangster] = list(tag1, tag2, tag3) where tags are the actual object decals.
	var/style
	var/fighting_style = "normal"
	var/list/territory = list()
	var/list/territory_new = list()
	var/list/territory_lost = list()
	var/recalls = 1
	var/dom_attempts = 2
	var/inner_outfit
	var/outer_outfit
	var/datum/atom_hud/antag/gang/ganghud
	var/is_deconvertible = TRUE //Can you deconvert normal gangsters from the gang

	var/domination_timer
	var/is_dominating


/datum/gang/New(loc,gangname)
	if(!GLOB.gang_colors_pool.len)
		message_admins("WARNING: Maximum number of gangs have been exceeded!")
		throw EXCEPTION("Maximum number of gangs has been exceeded")
		return
	else
		color = pick(GLOB.gang_colors_pool)
		GLOB.gang_colors_pool -= color
		switch(color)
			if("red")
				color_hex = "#DA0000"
				inner_outfit = pick(/obj/item/clothing/under/color/red, /obj/item/clothing/under/lawyer/red)
			if("orange")
				color_hex = "#FF9300"
				inner_outfit = pick(/obj/item/clothing/under/color/orange, /obj/item/clothing/under/geisha)
			if("yellow")
				color_hex = "#FFF200"
				inner_outfit = pick(/obj/item/clothing/under/color/yellow, /obj/item/clothing/under/burial, /obj/item/clothing/under/suit_jacket/tan)
			if("green")
				color_hex = "#A8E61D"
				inner_outfit = pick(/obj/item/clothing/under/color/green, /obj/item/clothing/under/syndicate/camo, /obj/item/clothing/under/suit_jacket/green)
			if("blue")
				color_hex = "#00B7EF"
				inner_outfit = pick(/obj/item/clothing/under/color/blue, /obj/item/clothing/under/suit_jacket/navy)
			if("purple")
				color_hex = "#DA00FF"
				inner_outfit = pick(/obj/item/clothing/under/color/lightpurple, /obj/item/clothing/under/lawyer/purpsuit)
			if("white")
				color_hex = "#FFFFFF"
				inner_outfit = pick(/obj/item/clothing/under/color/white, /obj/item/clothing/under/suit_jacket/white)

	name = (gangname ? gangname : pick(GLOB.gang_name_pool))
	GLOB.gang_name_pool -= name
	outer_outfit = pick(GLOB.gang_outfit_pool)
	ganghud = new()
	ganghud.color = color_hex
	log_game("The [name] Gang has been created. Their gang color is [color].")

/datum/gang/proc/add_gang_hud(datum/mind/recruit_mind)
	ganghud.join_hud(recruit_mind.current)
	SSticker.mode.set_antag_hud(recruit_mind.current, ((recruit_mind in bosses) ? "gang_boss" : "gangster"))

/datum/gang/proc/remove_gang_hud(datum/mind/defector_mind)
	ganghud.leave_hud(defector_mind.current)
	SSticker.mode.set_antag_hud(defector_mind.current, null)

//////////////////////////////////////////// MESSAGING


/datum/gang/proc/message_gangtools(message,beep=1,warning)
	if(!gangtools.len || !message)
		return
	for(var/obj/item/device/gangtool/tool in gangtools)
		var/mob/living/mob = get(tool.loc, /mob/living)
		if(mob && mob.mind && mob.stat == CONSCIOUS)
			if(mob.mind.gang_datum == src)
				to_chat(mob, "<span class='[warning ? "warning" : "notice"]'>[icon2html(tool, mob)] [message]</span>")
			return

//Multiverse

/datum/gang/multiverse
	dom_attempts = 0
	fighting_style = "multiverse"
	is_deconvertible = FALSE

/datum/gang/multiverse/New(loc, multiverse_override)
	name = multiverse_override
	ganghud = new()

/datum/gang/multiverse/income()
	return