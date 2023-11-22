// Applies an affect on view
/datum/proximity_monitor/advanced/eldritch_painting
	var/applied_trauma = /datum/brain_trauma/severe/pacifism
	var/text_to_display = "I should not be seeing this..."

/datum/proximity_monitor/advanced/eldritch_painting/field_turf_crossed(atom/movable/crossed, turf/location)
	if (!isliving(crossed) || !can_see(crossed, host, current_range))
		return
	on_seen(crossed)

/datum/proximity_monitor/advanced/eldritch_painting/proc/on_seen(mob/living/carbon/human/viewer)
	if (!viewer.mind || !viewer.mob_mood || viewer.stat != CONSCIOUS || viewer.is_blind())
		return
	if (viewer.has_trauma_type(applied_trauma))
		return
	if(IS_HERETIC(viewer))
		return
	if(viewer.can_block_magic(MAGIC_RESISTANCE))
		return
	to_chat(viewer, span_notice(text_to_display))
	viewer.gain_trauma(applied_trauma, TRAUMA_RESILIENCE_SURGERY)
	viewer.emote("scream")
	to_chat(viewer, span_warning("As you gaze upon the painting your mind rends to its truth!"))

// Proximity sensor for /obj/structure/sign/painting/eldritch/weeping
/datum/proximity_monitor/advanced/eldritch_painting/weeping
	applied_trauma = /datum/brain_trauma/severe/weeping
	text_to_display = "Oh what arts! She is so fair, and he...HE WEEPS!!!"

// Specific proximity monitor for The First Desire or /obj/item/wallframe/painting/eldritch/desire
/datum/proximity_monitor/advanced/eldritch_painting/desire
	applied_trauma = /datum/brain_trauma/severe/flesh_desire
	text_to_display = "What an artwork, just looking at it makes me hunger...."

// Specific proximity monitor for Lady out of gates or /obj/item/wallframe/painting/eldritch/beauty
/datum/proximity_monitor/advanced/eldritch_painting/beauty
	applied_trauma = /datum/brain_trauma/severe/eldritch_beauty
	text_to_display = "Her flesh glows in the pale light, and mine can too...If it wasnt for these imperfections...."

// Specific proximity monitor for Climb over the rusted mountain or /obj/item/wallframe/painting/eldritch/rust
/datum/proximity_monitor/advanced/eldritch_painting/rust
	applied_trauma = /datum/brain_trauma/severe/rusting
	text_to_display = "It climbs, and I will aid it...The rust calls and I shall answer..."
