/**
 * Scrambles the languages of someone you shoot.
 */
/obj/item/gun/magic/wand/babel
	name = "rod of babel"
	desc = "The incredible power of this wand causes victims to forget all of the languages they know, and learn a new one."
	school = SCHOOL_TRANSMUTATION
	ammo_type = /obj/item/ammo_casing/magic/babel
	icon_state = "babelwand"
	base_icon_state = "babelwand"
	fire_sound = 'sound/effects/magic/staff_change.ogg'
	max_charges = 6

/obj/item/gun/magic/wand/babel/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	charges--
	if (HAS_TRAIT(user, TRAIT_TOWER_OF_BABEL))
		return
	curse_of_babel(user)

/obj/item/gun/magic/wand/babel/do_suicide(mob/living/user)
	. = ..()
	user.say("Someone please kill me!", forced = "failed babel wand suicide")
	return SHAME
