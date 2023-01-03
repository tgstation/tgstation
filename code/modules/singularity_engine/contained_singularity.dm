// MBTODO: Play the NarSie tearing effect when it's about to release (lol)
// MBTODO: Insta-red alert for the sake of the prototype...
/obj/contained_singularity
	name = "contained singularity"
	desc = "A gravitational singularity. Through a battle-tested, though heavily confidential, technique, it is contained in the folds of space, making it reasonably safe to extract energy from. Looking at it gives you a headache."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "boh_tear"
	anchored = TRUE
	density = TRUE
	move_resist = INFINITY
	plane = ABOVE_LIGHTING_PLANE // idk
	light_range = 6
	flags_1 = SUPERMATTER_IGNORES_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	appearance_flags = KEEP_TOGETHER
	pixel_x = -28
	pixel_y = -28

/obj/contained_singularity/Initialize(mapload)
	. = ..()

	AddComponent( \
		/datum/component/singularity, \
		roaming = FALSE, \
		singularity_size = STAGE_THREE, \
		consume_range = 1, \
	)

	update_appearance(UPDATE_ICON)

/obj/contained_singularity/update_overlays()
	. = ..()

	var/mutable_appearance/mask = mutable_appearance('icons/effects/96x96.dmi', "singularity_s3")
	mask.blend_mode = BLEND_INSET_OVERLAY
	. += mask

	return .

/obj/contained_singularity/singularity_act()
	return
