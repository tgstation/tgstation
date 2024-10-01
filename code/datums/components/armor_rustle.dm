/datum/component/armor_rustle
	var/static/list/default_rustle_sounds = SFX_SUIT_STEP

	var/list/rustle_sounds
	var/mob/holder

	///what move are we on.
	var/move_counter = 0
	///how many moves to take before playing the sound, defaults to 4.
	var/move_delay = 4

	///volume at which the sound plays, defaults to 50.
	var/volume = 50
	///does the sound vary? defaults to true.
	var/sound_vary = TRUE
	///extra-range for this component's sound, defaults to -1.
	var/sound_extra_range = -1
	///sound exponent for the rustle. Defaults to 5.
	var/sound_falloff_exponent = 5
	///when sounds start falling off for the rustle rustle, defaults to SOUND_DEFAULT_FALLOFF_DISTANCE.
	var/sound_falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE

/datum/component/armor_rustle/Initialize(custom_sounds, move_delay_override, volume_override, extrarange, falloff_exponent, falloff_distance)
	SIGNAL_HANDLER
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_unequip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

	if(custom_sounds)
		rustle_sounds = custom_sounds
	else
		rustle_sounds = default_rustle_sounds
	if(volume_override)
		volume = volume_override
	if(isnum(move_delay_override))
		move_delay = move_delay_override
	if(isnum(extrarange))
		sound_extra_range = extrarange
	if(isnum(falloff_exponent))
		sound_falloff_exponent = falloff_exponent
	if(isnum(fallof_distance))
		sound_falloff_distance = falloff_distance

/datum/component/armor_rustle/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	holder = equipper
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(step), override = TRUE)
	RegisterSignal(holder, COMSIG_QDELETING, PROC_REF(holder_deleted), override = TRUE)
	//override for the preqdeleted is necessary because putting parent in hands sends the signal that this proc is registered towards,
	//so putting an object in hands and then equipping the item on a clothing slot (without dropping it first)
	//will always runtime without override = TRUE

/datum/component/armor_rustle/proc/on_unequip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)

/datum/component/armor_rustle/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(user, COMSIG_QDELETING)
	holder = null

///just gets rid of the reference to holder in the case that they're qdeleted.
/datum/component/armor_rustle/proc/holder_deleted(datum/source, datum/possible_holder)
	SIGNAL_HANDLER
	if(possible_holder == holder)
		holder = null

/datum/component/armor_rustle/proc/step(obj/item/clothing)

	var/mob/living/carbon/human/owner = source.loc
	if(CHECK_MOVE_LOOP_FLAGS(owner, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return
	move_counter++
	if(move_counter >= 4)
		play_rustle_sound()

/datum/component/armor_rustle/proc/play_rustle_sound()
	playsound(parent, pick_weight(rustle_sounds), volume, sound_vary, sound_extra_range, sound_falloff_exponent, falloff_distance = sound_falloff_distance)
