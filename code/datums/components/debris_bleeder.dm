/// Drop debris when taking damage
/datum/component/debris_bleeder
	/// The type of debrees to spawn at a certain damage threshold. First threshold to hit in the list wins, so usually you'd want to construct from descending damage
	/// list(/obj/item/toolbox = 30, /obj/item/wire = 20, etc)
	var/list/debris_to_damage
	/// Which type of damage to respond to
	var/damage_type
	/// The sound to play on hit
	var/sound
	/// Minimal damage at which we can play the sound
	var/sound_threshold

/datum/component/debris_bleeder/Initialize(list/debris_to_damage, damage_type = BRUTE, sound = null, sound_threshold = 0)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.debris_to_damage = debris_to_damage
	src.damage_type = damage_type
	src.sound = sound
	src.sound_threshold = sound_threshold

	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_apply_damage))

/datum/component/debris_bleeder/proc/on_apply_damage(mob/living/liver, amount, damage_type)
	SIGNAL_HANDLER

	if(src.damage_type != damage_type)
		return

	for(var/key in debris_to_damage)
		var/value = debris_to_damage[key]

		if(value < amount)
			new key ((get_turf(liver)))
			if(sound && sound_threshold < amount)
				playsound(liver, sound, 60)
