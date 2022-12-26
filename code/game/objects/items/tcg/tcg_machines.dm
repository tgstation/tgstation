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

/obj/machinery/trading_card_holder/attack_hand(mob/user)
    if(current_card)
        user.put_in_hands(current_card)
        to_chat(user, span_notice("You take [current_card] out of [src]."))
        current_card = null
        icon_state = "paper_bin0"
        update_appearance()
        if(current_summon)
            current_summon.Destroy()
    else
        to_chat(user, span_warning("[src] is empty!"))
    add_fingerprint(user)
    return..()

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

    var/obj/effect/overlay/card_summon/hologram
    var/obj/effect/overlay/status_display_text/power_overlay
    var/obj/effect/overlay/status_display_text/resolve_overlay
    var/power_color = "#af2323"
    var/resolve_color = "#231ac0"

    var/team_color = "#77abff"



/obj/structure/trading_card_summon/proc/load_model(obj/item/tcgcard/current_card)

    hologram = new(loc)

    if(template.humanoid == 1)
        var/datum/outfit/summon_outfit = text2path(template.outfit)

        var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy("TGC_PRESET")
    
        if(summon_outfit)
            mannequin.equipOutfit(summon_outfit ,TRUE)
        mannequin.setDir(SOUTH)

        hologram.icon = mannequin.icon
        hologram.icon_state = mannequin.icon_state
        hologram.copy_overlays(mannequin, TRUE)
        unset_busy_human_dummy("TGC_PRESET")
    else
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
	// Draw our object visually "in front" of this display, taking advantage of sidemap
	stats_display.pixel_y = -32
	stats_display.pixel_z = 32
	vis_contents += stats_display
	return stats_display

/obj/structure/trading_card_summon/Destroy()
    hologram.Destroy()
    return ..()

/obj/structure/trading_card_summon/red
    team_color = "#ff7777"
    

#undef STAT_Y
#undef POWER_X
#undef RESOLVE_X

/obj/effect/overlay/card_summon
    mouse_opacity = 0
