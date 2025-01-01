/datum/component/glasses_stats_thief

/datum/component/glasses_stats_thief/Initialize()
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(try_consume))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))

/datum/component/glasses_stats_thief/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("You can use this on another pair of glasses to copy the hud, flash protection, night vision, etc. from them.")

/// Checks if the atom interacted with has the requirements to be consumed or not
/datum/component/glasses_stats_thief/proc/try_consume(datum/source, mob/living/user, obj/item/thing)
	SIGNAL_HANDLER

	var/obj/item/clothing/glasses/attacking_glasses = thing
	if(!istype(attacking_glasses))
		return
	// Do the glasses attacking us have any of the things we care about?
	if(!attacking_glasses.color_cutoffs && (!attacking_glasses.flash_protect != FLASH_PROTECTION_NONE) && (!length(attacking_glasses.clothing_traits)) && !attacking_glasses.vision_flags)
		return
	INVOKE_ASYNC(src, PROC_REF(consume), user, thing)

/// Attempts to consume the glasses we are passed and add their stats to the parent
/datum/component/glasses_stats_thief/proc/consume(mob/living/carbon/human/user, obj/item/clothing/glasses/slick_shades)
	if(!slick_shades)
		return
	if(!do_after(user, 5 SECONDS, slick_shades))
		return

	var/obj/item/clothing/glasses/thief = parent

	thief.color_cutoffs = slick_shades.color_cutoffs
	thief.forced_glass_color = slick_shades.forced_glass_color
	thief.change_glass_color(slick_shades.glass_colour_type)
	thief.clothing_traits = slick_shades.clothing_traits
	thief.flash_protect = slick_shades.flash_protect
	thief.vision_flags = slick_shades.vision_flags
	thief.tint = slick_shades.tint
	playsound(slick_shades, 'sound/effects/industrial_scan/industrial_scan1.ogg', 50, TRUE)
	do_sparks(3, FALSE, slick_shades)
	qdel(slick_shades)
