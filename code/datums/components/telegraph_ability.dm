/**
 * Component given to creatures to telegraph their abilities!
 */
/datum/component/basic_mob_ability_telegraph
	/// how long before we use our attack
	var/telegraph_time
	/// sound to play, if any
	var/sound_path
	/// are we currently telegraphing
	var/currently_telegraphing = FALSE

/datum/component/basic_mob_ability_telegraph/Initialize(telegraph_time = 1 SECONDS, sound_path)

	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.telegraph_time = telegraph_time
	src.sound_path = sound_path

/datum/component/basic_mob_ability_telegraph/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_ABILITY_STARTED, PROC_REF(on_ability_activate))

/datum/component/basic_mob_ability_telegraph/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_ABILITY_STARTED)

///delay the ability
/datum/component/basic_mob_ability_telegraph/proc/on_ability_activate(mob/living/source, datum/action/cooldown/activated, atom/target)
	SIGNAL_HANDLER

	if(currently_telegraphing)
		return COMPONENT_BLOCK_ABILITY_START

	if(!activated.IsAvailable())
		return

	currently_telegraphing = TRUE
	generate_tell_signs(source)
	addtimer(CALLBACK(src, PROC_REF(use_ability), source, activated, target), telegraph_time)
	return COMPONENT_BLOCK_ABILITY_START

///generates the telegraph signs to inform the player we're about to launch an attack
/datum/component/basic_mob_ability_telegraph/proc/generate_tell_signs(mob/living/source)
	if(sound_path)
		playsound(source, sound_path, 50, FALSE)
	source.Shake(duration = telegraph_time)

///use the ability
/datum/component/basic_mob_ability_telegraph/proc/use_ability(mob/living/source, datum/action/cooldown/activated, atom/target)
	if(!QDELETED(target) && source.stat != DEAD) //target is gone or we died
		activated.Activate(target)
	currently_telegraphing = FALSE
