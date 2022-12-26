/obj/machinery/trading_card_holder
	name = "card slot"
	desc = "a slot for placing Tactical Game Cards"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin0"
	use_power = NO_POWER_USE

	var/obj/item/tcgcard/current_card
	var/obj/structure/trading_card_summon/current_summon

	var/spawn_direction = 1
	var/summon_type = /obj/structure/trading_card_summon

/obj/machinery/trading_card_holder/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/tcgcard) && current_card == null)
		current_card = I
		var/datum/card/card_template = current_card.extract_datum()
		if(!user.transferItemToLoc(current_card, src))
			return
		to_chat(user, span_notice("You put [current_card] in [src]."))
		icon_state = "paper_bin1"
		update_appearance()
		if(card_template.cardtype == "Creature")
			current_summon = new summon_type(get_step(src.loc, spawn_direction))
			current_summon.template = card_template
			current_summon.load_model(current_card)
	else
		return..()

GLOBAL_LIST_EMPTY(tcgcard_machine_radial_choices)

/obj/machinery/trading_card_holder/attack_hand(mob/user)
	if(current_card)
		var/list/choices = GLOB.tcgcard_machine_radial_choices
		if(!length(choices))
			choices = GLOB.tcgcard_machine_radial_choices = list(
			"Eject" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_eject"),
			"Tap" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_tap"),
			"Modify" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_flip"),
			)
		var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
		if(!check_menu(user))
			return
		switch(choice)
			if("Tap")
				current_summon.update_tapped(current_card)
			if("Eject")
				user.put_in_hands(current_card)
				to_chat(user, span_notice("You take [current_card] out of [src]."))
				current_card = null
				icon_state = "paper_bin0"
				update_appearance()
				if(current_summon)
					current_summon.Destroy()
			if("Modify")
				//Do nothing yet
			if(null)
				return
	else
		to_chat(user, span_warning("[src] is empty!"))
	add_fingerprint(user)
	return..()

/obj/machinery/trading_card_holder/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/machinery/trading_card_holder/red
	spawn_direction = 2
	summon_type = /obj/structure/trading_card_summon/red

#define STAT_Y -23
#define POWER_X -12
#define RESOLVE_X 12

/obj/structure/trading_card_summon
	name = "coder"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "holopad1"
	anchored = TRUE

	var/datum/card/template

	var/summon_power
	var/summon_resolve
	var/tapped

	var/obj/effect/overlay/card_summon/hologram
	var/obj/effect/overlay/status_display_text/power_overlay
	var/obj/effect/overlay/status_display_text/resolve_overlay
	var/power_color = "#af2323"
	var/resolve_color = "#231ac0"

	var/team_color = "#77abff"

/obj/structure/trading_card_summon/proc/load_model(obj/item/tcgcard/current_card)

	hologram = new(loc)

	hologram.icon = file(template.summon_icon_file)
	hologram.icon_state = template.summon_icon_state
	hologram.name = name
	hologram.alpha = 170
	hologram.add_atom_colour(team_color, FIXED_COLOUR_PRIORITY)
	name = template.name
	desc = template.desc
	summon_power = template.power
	summon_resolve = template.resolve
	update_overlays()


/obj/structure/trading_card_summon/get_name_chaser(mob/user, list/name_chaser = list())

	name_chaser += "Faction: [template.faction]"
	name_chaser += "Cost: [template.summoncost]"
	name_chaser += "Type: [template.cardtype] - [template.cardsubtype]"
	name_chaser += "Power/Resolve: [summon_power]/[summon_resolve]"
	if(template.rules) //This can sometimes be empty
		name_chaser += "Ruleset: [template.rules]"
	return name_chaser

/obj/structure/trading_card_summon/update_overlays()
	. = ..()

	var/overlay = update_stats(power_overlay, STAT_Y, summon_power, power_color, x_offset = POWER_X)

	if(overlay)
		power_overlay = overlay
	overlay = update_stats(resolve_overlay, STAT_Y, summon_resolve, resolve_color, x_offset = RESOLVE_X)
	if(overlay)
		resolve_overlay = overlay

/obj/structure/trading_card_summon/proc/update_stats(obj/effect/overlay/status_display_text/overlay, pos_y, stats, text_color, x_offset)
	if(overlay && stats == overlay.message)
		return null

	if(overlay)
		qdel(overlay)

	var/obj/effect/overlay/status_display_text/stats_display = new(src, pos_y, stats, text_color, text_color, x_offset)

	stats_display.pixel_y = -32
	stats_display.pixel_z = 32
	vis_contents += stats_display
	return stats_display

/obj/structure/trading_card_summon/proc/update_tapped(obj/item/tcgcard/current_card)
	if(tapped)
		hologram.transform = turn(hologram.transform, 90)
	else
		hologram.transform = turn(hologram.transform, -90)
	tapped = !tapped

/obj/structure/trading_card_summon/Destroy()
	if(hologram)
		hologram.Destroy()
	return ..()

/obj/structure/trading_card_summon/red
	team_color = "#ff7777"

#undef STAT_Y
#undef POWER_X
#undef RESOLVE_X

/obj/effect/overlay/card_summon
	mouse_opacity = 0
