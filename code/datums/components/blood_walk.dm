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

/datum/component/blood_walk/Initialize(
	blood_type = /obj/effect/decal/cleanable/blood,
	sound_played,
	sound_volume = 80,
	blood_spawn_chance = 100,
	target_dir_change = FALSE,
	transfer_blood_dna = FALSE,
	max_blood = INFINITY,
)

	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.blood_type = blood_type
	src.sound_played = sound_played
	src.sound_volume = sound_volume
	src.blood_spawn_chance = blood_spawn_chance
	src.target_dir_change = target_dir_change
	src.transfer_blood_dna = transfer_blood_dna

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
/datum/component/blood_walk/proc/spread_blood(datum/source)
	SIGNAL_HANDLER

	var/atom/movable/movable_source = source
	var/turf/current_turf = movable_source.loc
	if(!isturf(current_turf))
		return
	if(!prob(blood_spawn_chance))
		return

	var/obj/effect/decal/blood = new blood_type(current_turf)
	if(QDELETED(blood)) // Our blood was placed on somewhere it shouldn't be and qdeleted in init.
		return

	if(target_dir_change)
		blood.setDir(movable_source.dir)
	if(transfer_blood_dna)
		blood.add_blood_DNA(GET_ATOM_BLOOD_DNA(movable_source))
	if(!isnull(sound_played))
		playsound(movable_source, sound_played, sound_volume, TRUE, 2, TRUE)

	blood_remaining = max(blood_remaining - 1, 0)
	if(blood_remaining <= 0)
		qdel(src)
