#define IFF_HOSTILE 1
#define IFF_NEUTRAL 2
#define IFF_FRIENDLY 3

#define IFF_FACTION_NONE "None"
#define IFF_FACTION_SYNDICATE "Syndicate"
#define IFF_FACTION_CREW "Crew"
#define IFF_FACTION_SEC_COMMAND "Security & Command"
#define IFF_FACTION_CENTCOM "CentCom"
#define IFF_FACTION_EVERYONE "Non-Allies"

/obj/item/organ/eyes/robotic/tacvisor/centcom
	no_glasses = FALSE
	friendly_faction = IFF_FACTION_CENTCOM
	hostile_faction = IFF_FACTION_SYNDICATE

/obj/item/organ/eyes/robotic/tacvisor/centcom/on_mob_insert(mob/living/carbon/receiver, special, movement_flags)
	. = ..()
	receiver.remove_client_colour(REF(src))
	receiver.remove_status_effect(/datum/status_effect/grouped/see_no_names, REF(src))
	UnregisterSignal(receiver, COMSIG_MOB_EXAMINING)
	UnregisterSignal(receiver, COMSIG_MOVABLE_PRE_HEAR)

/obj/item/organ/eyes/robotic/tacvisor/centcom/make_overlay(mob/living/target)
	if (!target)
		return

	if (obj_flags & EMAGGED)
		var/image/overlay_image = image(mutable_appearance('icons/effects/effects.dmi', "nothing"), target)
		overlay_image.override = TRUE
		overlay_image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		SET_PLANE_EXPLICIT(overlay_image, ABOVE_GAME_PLANE, target)
		return overlay_image

	var/mutable_appearance/appearance_copy = new(target.appearance)
	appearance_copy.appearance_flags |= KEEP_APART|KEEP_TOGETHER
	var/outline_color = "#FFD500CC"
	switch (get_iff_signature(target))
		if (IFF_FRIENDLY)
			outline_color = "#0099FFCC"
		if (IFF_HOSTILE)
			outline_color = "#FF0022CC"
	appearance_copy.add_filter("target_lock_outline", 2, outline_filter(1, outline_color))
	appearance_copy.override = TRUE
	appearance_copy.transform = null
	appearance_copy.pixel_x = 0
	appearance_copy.pixel_y = 0
	var/image/overlay_image = image(appearance_copy, target)
	overlay_image.override = TRUE
	SET_PLANE_EXPLICIT(overlay_image, ABOVE_GAME_PLANE, target)
	return overlay_image

#undef IFF_HOSTILE
#undef IFF_NEUTRAL
#undef IFF_FRIENDLY

#undef IFF_FACTION_NONE
#undef IFF_FACTION_SYNDICATE
#undef IFF_FACTION_CREW
#undef IFF_FACTION_SEC_COMMAND
#undef IFF_FACTION_CENTCOM
#undef IFF_FACTION_EVERYONE
