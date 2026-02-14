
/// Wand of making objects alive
/obj/item/gun/magic/wand/animate
	name = "wand of animation"
	desc = "This wand is attuned to life and will animate effected objects into destructive servants."
	school = SCHOOL_EVOCATION
	ammo_type = /obj/item/ammo_casing/magic/animate
	icon_state = "polywand"
	base_icon_state = "polywand"
	fire_sound = 'sound/effects/magic/staff_animation.ogg'
	max_charges = 10

/obj/item/gun/magic/wand/animate/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	to_chat(user, span_warning("You animate one of your own possessions!"))
	charges--
	var/list/possessions = user.get_equipped_items()
	if (!length(possessions))
		to_chat(user, span_notice("...but you don't have any."))
		return

	var/obj/some_item = pick(possessions)
	user.dropItemToGround(some_item)
	some_item.animate_atom_living(user)

/obj/item/gun/magic/wand/animate/do_suicide(mob/living/user)
	charges--
	if (!iscarbon(user))
		user.visible_message(span_suicide("... but [user] is already animate!"))
		return SHAME
	var/mob/living/carbon/suicider = user
	var/obj/item/animate_part = suicider.get_organ_slot(ORGAN_SLOT_BRAIN)
	if (!animate_part)
		animate_part = suicider.get_bodypart(BODY_ZONE_HEAD)
	if (!animate_part)
		return SHAME

	var/turf/destination = user.drop_location()

	if (isorgan(animate_part))
		var/obj/item/organ/brain = animate_part
		brain.Remove(user, special = FALSE)
	else
		var/obj/item/bodypart/head = animate_part
		head.dismember(BRUTE)

	animate_part.forceMove(destination)
	animate_part.animate_atom_living()
	if (user.stat != DEAD)
		return SHAME
	user.set_suicide(TRUE)
	return MANUAL_SUICIDE
