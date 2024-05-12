/**
 * When attached to something, will make that thing shatter into shards on throw impact or z level falling
 * Or even when used as a weapon if the 'shatters_as_weapon' arg is TRUE
 */
/datum/element/can_shatter
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// What type of item is spawned as a 'shard' once the shattering happens
	var/obj/item/shard_type
	/// How many shards total are made when the thing we're attached to shatters
	var/number_of_shards
	/// What sound plays when the thing we're attached to shatters
	var/shattering_sound

/datum/element/can_shatter/Attach(datum/target,
	shard_type = /obj/item/plate_shard,
	number_of_shards = 5,
	shattering_sound = 'sound/items/ceramic_break.ogg',
	shatters_as_weapon = FALSE,
	)
	. = ..()

	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.shard_type = shard_type
	src.number_of_shards = number_of_shards
	src.shattering_sound = shattering_sound

	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
	RegisterSignal(target, COMSIG_ATOM_ON_Z_IMPACT, PROC_REF(on_z_impact))
	if(shatters_as_weapon)
		RegisterSignal(target, COMSIG_ITEM_POST_ATTACK_ATOM, PROC_REF(on_post_attack_atom))

/datum/element/can_shatter/Detach(datum/target)
	. = ..()

	UnregisterSignal(target, list(COMSIG_MOVABLE_IMPACT, COMSIG_ATOM_ON_Z_IMPACT))

/// Tells the parent to shatter if we impact a lower zlevel
/datum/element/can_shatter/proc/on_z_impact(datum/source, turf/impacted_turf, levels)
	SIGNAL_HANDLER

	shatter(source, impacted_turf)

/// Tells the parent to shatter if we are thrown and impact something
/datum/element/can_shatter/proc/on_throw_impact(datum/source, atom/hit_atom)
	SIGNAL_HANDLER

	shatter(source, hit_atom)

/// Handles the actual shattering part, throwing shards of whatever is defined on the component everywhere
/datum/element/can_shatter/proc/shatter(atom/movable/source, atom/hit_atom)
	var/generator/scatter_gen = generator(GEN_CIRCLE, 0, 48, NORMAL_RAND)
	var/scatter_turf = get_turf(hit_atom)

	for(var/obj/item/scattered_item as anything in source.contents)
		scattered_item.forceMove(scatter_turf)
		var/list/scatter_vector = scatter_gen.Rand()
		scattered_item.pixel_x = scatter_vector[1]
		scattered_item.pixel_y = scatter_vector[2]

	for(var/iteration in 1 to number_of_shards)
		var/obj/item/shard = new shard_type(scatter_turf)
		shard.pixel_x = rand(-6, 6)
		shard.pixel_y = rand(-6, 6)
	playsound(scatter_turf, shattering_sound, 60, TRUE)
	if(isobj(source))
		var/obj/obj_source = source
		obj_source.deconstruct(FALSE)
		return
	else
		qdel(source)

/datum/element/can_shatter/proc/on_post_attack_atom(obj/item/source, atom/attacked_atom, mob/living/user)
	SIGNAL_HANDLER
	shatter(source, attacked_atom)
