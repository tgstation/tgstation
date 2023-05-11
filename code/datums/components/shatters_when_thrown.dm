/// Anything with this component will shatter when throw_impact happens, like a ceramic plate.
/datum/component/shatters_when_thrown
	/// What type should be spawned as 'shards' when the parent is broken
	var/obj/item/shard_type
	/// How many shards total are made when the parent shatters
	var/number_of_shards
	/// What sound plays when the parent shatters
	var/shattering_sound

/datum/component/shatters_when_thrown/Initialize(shard_type = /obj/item/plate_shard, number_of_shards = 5, shattering_sound = 'sound/items/ceramic_break.ogg')
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	src.shard_type = shard_type
	src.number_of_shards = number_of_shards
	src.shattering_sound = shattering_sound

/datum/component/shatters_when_thrown/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
	RegisterSignal(parent, COMSIG_ATOM_ON_Z_IMPACT, PROC_REF(on_z_impact))

/datum/component/shatters_when_thrown/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_IMPACT, COMSIG_ATOM_ON_Z_IMPACT))

/// Tells the parent to shatter if we impact a lower zlevel
/datum/component/shatters_when_thrown/proc/on_z_impact(datum/source, turf/impacted_turf, levels)
	SIGNAL_HANDLER

	shatter(impacted_turf)

/// Tells the parent to shatter if we are thrown and impact something
/datum/component/shatters_when_thrown/proc/on_throw_impact(datum/source, atom/hit_atom)
	SIGNAL_HANDLER

	shatter(hit_atom)

/// Handles the actual shattering part, throwing shards of whatever is defined on the component everywhere
/datum/component/shatters_when_thrown/proc/shatter(atom/hit_atom)
	var/generator/scatter_gen = generator(GEN_CIRCLE, 0, 48, NORMAL_RAND)
	var/scatter_turf = get_turf(hit_atom)

	var/is_a_plate
	var/obj/item/plate/obj_parent_plate_edition // We gotta be special with plates because I'm fairly sure the universe falls apart if we don't do this

	if(istype(parent, /obj/item/plate))
		obj_parent_plate_edition = parent
		is_a_plate = TRUE

	var/obj/obj_parent = parent

	for(var/obj/item/scattered_item as anything in obj_parent.contents)
		if(is_a_plate)
			obj_parent_plate_edition.ItemRemovedFromPlate(scattered_item)
		scattered_item.forceMove(scatter_turf)
		var/list/scatter_vector = scatter_gen.Rand()
		scattered_item.pixel_x = scatter_vector[1]
		scattered_item.pixel_y = scatter_vector[2]

	for(var/iteration in 1 to number_of_shards)
		var/obj/item/shard = new shard_type(scatter_turf)
		shard.pixel_x = rand(-6, 6)
		shard.pixel_y = rand(-6, 6)
	playsound(scatter_turf, shattering_sound, 60, TRUE)
	obj_parent.deconstruct(disassembled = FALSE)
