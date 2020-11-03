/**
  * This element is used to indicate that a movable atom can be mounted by mobs in order to ride it. The movable is considered mounted when a mob is buckled to it,
  * at which point a [riding component][/datum/component/riding] is created on the movable, and that component handles the actual riding behavior.
  *
  * Besides the target, the ridable element has one argument: the component subtype. This is not really ideal since there's ~20-30 component subtypes rather than
  * having the behavior defined on the ridable atoms themselves or some such, but because the old riding behavior was so horrifyingly spread out and redundant,
  * just having the variables, behavior, and procs be standardized is still a big improvement.
  */
/datum/element/ridable
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	var/riding_component_type = /datum/component/riding

/datum/element/ridable/Attach(atom/movable/target, component_type = /datum/component/riding)
	. = ..()
	if(!ismovable(target))
		return COMPONENT_INCOMPATIBLE

	riding_component_type = component_type

	RegisterSignal(target, COMSIG_MOVABLE_TRY_MOUNTING, .proc/check_mounting)

/// Someone is buckling to this movable, which is literally the only thing we care about.
/datum/element/ridable/proc/check_mounting(atom/movable/target_movable, mob/living/potential_rider, force = FALSE, riding_flags = NONE)
	SIGNAL_HANDLER

	if((riding_flags & RIDER_HOLDING_ON) && !equip_buckle_inhands(potential_rider, 2, target_movable)) // hardcode 2 hands for now
		potential_rider.visible_message("<span class='warning'>[potential_rider] can't get a grip on [target_movable] because [potential_rider.p_their()] hands are full!</span>",
			"<span class='warning'>You can't get a grip on [target_movable] because your hands are full!</span>")
		return MOUNTING_HALT_BUCKLE


	var/mob/living/target_living = target_movable

	// need to see if !equip_buckle_inhands() checks are enough to skip any needed incapac/restrain checks
	// ridden_holding_rider shouldn't apply if the ridden isn't even a living mob
	if((riding_flags & RIDDEN_HOLDING_RIDER) && !equip_buckle_inhands(target_living, 1, target_living, potential_rider)) // hardcode 1 hand for now
		target_living.visible_message("<span class='warning'>[target_living] can't get a grip on [potential_rider] because [target_living.p_their()] hands are full!</span>",
			"<span class='warning'>You can't get a grip on [potential_rider] because your hands are full!</span>")
		return MOUNTING_HALT_BUCKLE

	target_living.AddComponent(riding_component_type, potential_rider, force, riding_flags)

/// Try putting the appropriate number of [riding offhand items][/obj/item/riding_offhand] into the target's hands, return FALSE if we can't
/datum/element/ridable/proc/equip_buckle_inhands(mob/living/carbon/human/user, amount_required = 1, atom/movable/target_movable, riding_target_override = null)
	var/atom/movable/AM = target_movable
	var/amount_equipped = 0
	for(var/amount_needed = amount_required, amount_needed > 0, amount_needed--)
		var/obj/item/riding_offhand/inhand = new /obj/item/riding_offhand(user)
		if(!riding_target_override)
			inhand.rider = user
		else
			inhand.rider = riding_target_override
		inhand.parent = AM
		for(var/obj/item/I in user.held_items) // delete any hand items like slappers that could still totally be used to grab on
			if((I.obj_flags & HAND_ITEM))
				qdel(I)

		// this would be put_in_hands() if it didn't have the chance to sleep
		var/inserted_successfully = FALSE
		if(user.put_in_active_hand(inhand, TRUE))
			inserted_successfully = TRUE
		else
			var/hand = user.get_empty_held_index_for_side(LEFT_HANDS) || user.get_empty_held_index_for_side(RIGHT_HANDS)
			if(hand && user.put_in_hand(inhand, hand, TRUE))
				inserted_successfully = TRUE

		if(inserted_successfully)
			amount_equipped++
		else
			qdel(inhand)
			break

	if(amount_equipped >= amount_required)
		return TRUE
	else
		unequip_buckle_inhands(user, target_movable)
		return FALSE

/// Remove all of the relevant [riding offhand items][/obj/item/riding_offhand] from the target
/datum/element/ridable/proc/unequip_buckle_inhands(mob/living/carbon/user, atom/movable/target_movable)
	var/atom/movable/AM = target_movable
	for(var/obj/item/riding_offhand/O in user.contents)
		if(O.parent != AM)
			CRASH("RIDING OFFHAND ON WRONG MOB")
		if(O.selfdeleting)
			continue
		else
			qdel(O)
	return TRUE




/obj/item/riding_offhand
	name = "offhand"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT | DROPDEL | NOBLUDGEON
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/mob/living/carbon/rider
	var/mob/living/parent
	var/selfdeleting = FALSE

/obj/item/riding_offhand/dropped()
	selfdeleting = TRUE
	. = ..()

/obj/item/riding_offhand/equipped()
	if(loc != rider && loc != parent)
		selfdeleting = TRUE
		qdel(src)
	. = ..()

/obj/item/riding_offhand/Destroy()
	var/atom/movable/AM = parent
	if(selfdeleting)
		if(rider in AM.buckled_mobs)
			AM.unbuckle_mob(rider)
	. = ..()

/obj/item/riding_offhand/on_thrown(mob/living/carbon/user, atom/target)
	if(rider == user)
		return //Piggyback user.
	user.unbuckle_mob(rider)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='notice'>You gently let go of [rider].</span>")
		return
	return rider
