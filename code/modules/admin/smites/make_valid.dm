/// Marks the target as "Valid"
/datum/smite/make_valid
	name = "Make Valid"

/datum/smite/make_valid/effect(client/user, mob/living/target)
	. = ..()
	target.remove_alt_appearance("validify_adminsmite")
	target.remove_alt_appearance("validify_adminsmite_observers")
	var/image/image = image('icons/mob/effects/debuff_overlays.dmi', target, "valid")
	image.layer = ABOVE_MOB_LAYER
	image.plane = FLOAT_PLANE
	image.transform = matrix(0, 18, MATRIX_TRANSLATE)
	target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone_plus_observers, "validify_adminsmite", image)

/// Marks the target as "Valid", but only to themselves
/datum/smite/make_valid_fake
	name = "Make Valid (fake)"

/datum/smite/make_valid_fake/effect(client/user, mob/living/target)
	. = ..()
	target.remove_alt_appearance("validify_adminsmite")
	var/image/image = image('icons/mob/effects/debuff_overlays.dmi', target, "valid")
	image.layer = ABOVE_MOB_LAYER
	image.plane = FLOAT_PLANE
	image.transform = matrix(0, 18, MATRIX_TRANSLATE)
	target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "validify_adminsmite", image, null, target)

	// Ghost-visible version, mostly so that the admin can see that the smite succeeded
	target.remove_alt_appearance("validify_adminsmite_observers")
	var/image/image_observers = image('icons/mob/effects/debuff_overlays.dmi', target, "fakevalid")
	image_observers.layer = ABOVE_MOB_LAYER
	image_observers.plane = FLOAT_PLANE
	image_observers.transform = matrix(0, 18, MATRIX_TRANSLATE)
	target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/observers, "validify_adminsmite_observers", image_observers)
