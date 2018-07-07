/datum/component/squeak
	var/static/list/default_squeak_sounds = list('sound/items/toysqueak1.ogg'=1, 'sound/items/toysqueak2.ogg'=1, 'sound/items/toysqueak3.ogg'=1)
	var/list/override_squeak_sounds
	var/squeak_chance = 100
	var/volume = 30

	// This is so shoes don't squeak every step
	var/steps = 0
	var/step_delay = 1

	// This is to stop squeak spam from inhand usage
	var/last_use = 0
	var/use_delay = 20

/datum/component/squeak/Initialize(custom_sounds, volume_override, chance_override, step_delay_override, use_delay_override)
	if(custom_sounds)
		override_squeak_sounds = custom_sounds
	if(chance_override)
		squeak_chance = chance_override
	if(volume_override)
		volume = volume_override
	if(step_delay_override)
		step_delay = step_delay_override
	if(use_delay_override)
		use_delay = use_delay_override

	RegisterSignal(parent, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_BLOB_ACT, COMSIG_ATOM_HULK_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_MOVABLE_COLLIDE, COMSIG_MOVABLE_IMPACT, COMSIG_ITEM_ATTACK, COMSIG_ITEM_ATTACK_OBJ), .proc/play_squeak)
	RegisterSignal(parent, COMSIG_MOVABLE_CROSSED, .proc/play_squeak_turf)
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/use_squeak)
	RegisterSignal(parent, COMSIG_SHOES_STEP_ACTION, .proc/step_squeak)

/datum/component/squeak/proc/play_squeak()
	if(prob(squeak_chance))
		if(!override_squeak_sounds)
			playsound(parent, pickweight(default_squeak_sounds), volume, 1, -1)
		else
			playsound(parent, pickweight(override_squeak_sounds), volume, 1, -1)

/datum/component/squeak/proc/step_squeak()
	if(steps > step_delay)
		play_squeak()
		steps = 0
	else
		steps++

/datum/component/squeak/proc/play_squeak_turf()
	var/atom/current_parent = parent
	if(isturf(current_parent.loc))
		play_squeak()

/datum/component/squeak/proc/use_squeak()
	if(last_use + use_delay < world.time)
		last_use = world.time
		play_squeak()