///This element allows something to be when crossed, for example for cockroaches.
/datum/element/squashable
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2
	///Chance on crossed to be squashed
	var/squash_chance = 50
	///How much brute is applied when mob is squashed
	var/squash_damage = 1
	///Squash flags, for extra checks etcetera.
	var/squash_flags = NONE
	///Special callback to call on squash instead, for things like hauberoach
	var/datum/callback/on_squash_callback


/datum/element/squashable/Attach(mob/living/target, squash_chance, squash_damage, squash_flags, squash_callback)
	. = ..()
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE
	if(squash_chance)
		src.squash_chance = squash_chance
	if(squash_damage)
		src.squash_damage = squash_damage
	if(squash_flags)
		src.squash_flags = squash_flags
	if(!src.on_squash_callback && squash_callback)
		on_squash_callback = CALLBACK(target, squash_callback)

	RegisterSignal(target, COMSIG_MOVABLE_CROSSED, .proc/OnCrossed)

/datum/element/squashable/Detach(mob/living/target)
	UnregisterSignal(target, COMSIG_MOVABLE_CROSSED)

///Handles the squashing of the mob
/datum/element/squashable/proc/OnCrossed(mob/living/target, atom/movable/crossing_movable)
	SIGNAL_HANDLER


	if(squash_flags & SQUASHED_SHOULD_BE_DOWN && target.body_position != LYING_DOWN)
		return

	var/should_squash = prob(squash_chance)

	if(should_squash && on_squash_callback)
		if(on_squash_callback.Invoke(target, crossing_movable))
			return //Everything worked, we're done!
	if(isliving(crossing_movable))
		var/mob/living/crossing_mob = crossing_movable
		if(crossing_mob.mob_size > MOB_SIZE_SMALL && !(crossing_mob.movement_type & FLYING))
			if(HAS_TRAIT(crossing_mob, TRAIT_PACIFISM))
				crossing_mob.visible_message("<span class='notice'>[crossing_mob] carefully steps over [target].</span>", "<span class='notice'>You carefully step over [target] to avoid hurting it.</span>")
				return
			if(should_squash)
				crossing_mob.visible_message("<span class='notice'>[crossing_mob] squashed [target].</span>", "<span class='notice'>You squashed [target].</span>")
				Squish(target)
			else
				target.visible_message("<span class='notice'>[target] avoids getting crushed.</span>")
	else if(isstructure(crossing_movable))
		if(should_squash)
			crossing_movable.visible_message("<span class='notice'>[target] is crushed under [crossing_movable].</span>")
			Squish(target)
		else
			target.visible_message("<span class='notice'>[target] avoids getting crushed.</span>")

/datum/element/squashable/proc/Squish(mob/living/target)
	if(squash_flags & SQUASHED_SHOULD_BE_GIBBED)
		target.gib()
	else
		target.adjustBruteLoss(squash_damage)
