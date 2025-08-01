///Blood walk, a component that causes you to make blood wherever you walk.
/datum/component/blood_walk
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	///How many blood pools can we create?
	///If we reach 0, we will stop leaving blood and self delete
	var/blood_remaining = 0
	///Typepath of what blood decal we create on walk
	var/blood_type
	///The sound that plays when we spread blood.
	var/sound_played
	///How loud will the sound be, if there is one.
	var/sound_volume
	///The chance of spawning blood whenever walking
	var/blood_spawn_chance
	///Should the decal face the direction of the parent
	var/target_dir_change
	///Should we transfer the parent's blood DNA to created blood decal
	var/transfer_blood_dna
	///List of additional blood DNA we're adding to the decal
	var/list/blood_dna_info

/datum/component/blood_walk/Initialize(
	blood_type = /obj/effect/decal/cleanable/blood,
	sound_played,
	sound_volume = 80,
	blood_spawn_chance = 100,
	target_dir_change = FALSE,
	transfer_blood_dna = FALSE,
	max_blood = INFINITY,
	list/blood_dna_info = list("meaty DNA" = get_blood_type(BLOOD_TYPE_MEAT))
)

	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.blood_type = blood_type
	src.sound_played = sound_played
	src.sound_volume = sound_volume
	src.blood_spawn_chance = blood_spawn_chance
	src.target_dir_change = target_dir_change
	src.transfer_blood_dna = transfer_blood_dna
	src.blood_dna_info = blood_dna_info.Copy()

	blood_remaining = max_blood

/datum/component/blood_walk/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(spread_blood))

/datum/component/blood_walk/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

/datum/component/blood_walk/InheritComponent(
	datum/component/pricetag/new_comp,
	i_am_original,
	blood_type = /obj/effect/decal/cleanable/blood,
	sound_played,
	sound_volume = 80,
	blood_spawn_chance = 100,
	target_dir_change = FALSE,
	transfer_blood_dna = FALSE,
	max_blood = INFINITY,
)

	if(!i_am_original)
		return

	if(max_blood >= INFINITY || blood_remaining >= INFINITY)
		return

	// Applying a new version of the blood walk component will add the new version's step count to our's.
	// We will completely disregard any other arguments passed, because we already have arguments set.
	blood_remaining += max_blood

///Spawns blood (if possible) under the source, and plays a sound effect (if any)
/datum/component/blood_walk/proc/spread_blood(atom/movable/source)
	SIGNAL_HANDLER

	var/turf/current_turf = source.loc
	if(!isturf(current_turf) || isclosedturf(current_turf) || isgroundlessturf(current_turf))
		return

	if(!prob(blood_spawn_chance))
		return

	var/list/blood_DNA = blood_dna_info.Copy()
	if(transfer_blood_dna && GET_ATOM_BLOOD_DNA_LENGTH(source))
		blood_DNA = GET_ATOM_BLOOD_DNA(source) | blood_DNA

	if(!has_blood_flag(blood_DNA, BLOOD_COVER_TURFS))
		if (has_blood_flag(blood_DNA, BLOOD_ADD_DNA))
			current_turf.add_blood_DNA(blood_DNA)
		return

	var/obj/effect/decal/cleanable/blood/blood = new blood_type(current_turf, null, blood_DNA)

	if(QDELETED(blood)) // Our blood was placed on somewhere it shouldn't be and qdeleted in init.
		return

	if(target_dir_change)
		blood.setDir(source.dir)
	if(!isnull(sound_played))
		playsound(source, sound_played, sound_volume, TRUE, 2, TRUE)

	blood_remaining = max(blood_remaining - 1, 0)
	if(blood_remaining <= 0)
		qdel(src)
