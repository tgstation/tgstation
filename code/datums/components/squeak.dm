/datum/component/squeak
	var/static/list/default_squeak_sounds = list('sound/items/toysqueak1.ogg'=1, 'sound/items/toysqueak2.ogg'=1, 'sound/items/toysqueak3.ogg'=1)
	var/list/override_squeak_sounds
	var/mob/holder

	var/squeak_chance = 100
	var/volume = 30

	// This is so shoes don't squeak every step
	var/steps = 0
	var/step_delay = 1

	// This is to stop squeak spam from inhand usage
	var/last_use = 0
	var/use_delay = 20

	///extra-range for this component's sound
	var/sound_extra_range = -1
	///when sounds start falling off for the squeak
	var/sound_falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE
	///sound exponent for squeak. Defaults to 10 as squeaking is loud and annoying enough.
	var/sound_falloff_exponent = 10

	///what we set connect_loc to if parent is an item
	var/static/list/item_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(play_squeak_crossed),
	)


/datum/component/squeak/Initialize(custom_sounds, volume_override, chance_override, step_delay_override, use_delay_override, extrarange, falloff_exponent, fallof_distance)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignals(parent, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_BLOB_ACT, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACKBY), PROC_REF(play_squeak))
	if(ismovable(parent))
		RegisterSignals(parent, list(COMSIG_MOVABLE_BUMP, COMSIG_MOVABLE_IMPACT, COMSIG_PROJECTILE_BEFORE_FIRE), PROC_REF(play_squeak))

		AddComponent(/datum/component/connect_loc_behalf, parent, item_connections)
		RegisterSignal(parent, COMSIG_MOVABLE_DISPOSING, PROC_REF(disposing_react))
		if(isitem(parent))
			RegisterSignals(parent, list(COMSIG_ITEM_ATTACK, COMSIG_ITEM_ATTACK_ATOM, COMSIG_ITEM_HIT_REACT), PROC_REF(play_squeak))
			RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(use_squeak))
			RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
			RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
			if(istype(parent, /obj/item/clothing/shoes))
				RegisterSignal(parent, COMSIG_SHOES_STEP_ACTION, PROC_REF(step_squeak))
		else if(isstructure(parent))
			RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(use_squeak))

	if(istype(parent, /obj/item/organ/internal/liver))
		// Liver squeaking is depending on them functioning like a clown's liver
		RegisterSignal(parent, SIGNAL_REMOVETRAIT(TRAIT_COMEDY_METABOLISM), PROC_REF(on_comedy_metabolism_removal))

	override_squeak_sounds = custom_sounds
	if(chance_override)
		squeak_chance = chance_override
	if(volume_override)
		volume = volume_override
	if(isnum(step_delay_override))
		step_delay = step_delay_override
	if(isnum(use_delay_override))
		use_delay = use_delay_override
	if(isnum(extrarange))
		sound_extra_range = extrarange
	if(isnum(falloff_exponent))
		sound_falloff_exponent = falloff_exponent
	if(isnum(fallof_distance))
		sound_falloff_distance = fallof_distance

/datum/component/squeak/UnregisterFromParent()
	. = ..()
	qdel(GetComponent(/datum/component/connect_loc_behalf))

/datum/component/squeak/proc/play_squeak()
	SIGNAL_HANDLER

	if(prob(squeak_chance))
		if(!override_squeak_sounds)
			playsound(parent, pick_weight(default_squeak_sounds), volume, TRUE, sound_extra_range, sound_falloff_exponent, falloff_distance = sound_falloff_distance)
		else
			playsound(parent, pick_weight(override_squeak_sounds), volume, TRUE, sound_extra_range, sound_falloff_exponent, falloff_distance = sound_falloff_distance)

/datum/component/squeak/proc/step_squeak(obj/item/clothing/shoes/source)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/owner = source.loc
	if(CHECK_MOVE_LOOP_FLAGS(owner, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return
	if(steps > step_delay)
		play_squeak()
		steps = 0
	else
		steps++

/datum/component/squeak/proc/play_squeak_crossed(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(isitem(arrived))
		var/obj/item/I = arrived
		if(I.item_flags & ABSTRACT)
			return
	if((arrived.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) || !arrived.has_gravity())
		return
	if(ismob(arrived) && !arrived.density) // Prevents 10 overlapping mice from making an unholy sound while moving
		return
	var/atom/current_parent = parent
	if(isturf(current_parent?.loc))
		play_squeak()

/datum/component/squeak/proc/use_squeak()
	SIGNAL_HANDLER

	if(last_use + use_delay < world.time)
		last_use = world.time
		play_squeak()

/datum/component/squeak/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	holder = equipper
	RegisterSignal(holder, COMSIG_MOVABLE_DISPOSING, PROC_REF(disposing_react), override=TRUE)
	RegisterSignal(holder, COMSIG_QDELETING, PROC_REF(holder_deleted), override=TRUE)
	//override for the preqdeleted is necessary because putting parent in hands sends the signal that this proc is registered towards,
	//so putting an object in hands and then equipping the item on a clothing slot (without dropping it first)
	//will always runtime without override = TRUE

/datum/component/squeak/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_MOVABLE_DISPOSING)
	UnregisterSignal(user, COMSIG_QDELETING)
	holder = null

///just gets rid of the reference to holder in the case that they're qdeleted
/datum/component/squeak/proc/holder_deleted(datum/source, datum/possible_holder)
	SIGNAL_HANDLER
	if(possible_holder == holder)
		holder = null

// Disposal pipes related shits
/datum/component/squeak/proc/disposing_react(datum/source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_source)
	SIGNAL_HANDLER

	//We don't need to worry about unregistering this signal as it will happen for us automatically when the holder is qdeleted
	RegisterSignal(disposal_holder, COMSIG_ATOM_DIR_CHANGE, PROC_REF(holder_dir_change))

/datum/component/squeak/proc/holder_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER

	//If the dir changes it means we're going through a bend in the pipes, let's pretend we bumped the wall
	if(old_dir != new_dir)
		play_squeak()

/datum/component/squeak/proc/on_comedy_metabolism_removal(datum/source, trait)
	SIGNAL_HANDLER

	qdel(src)
