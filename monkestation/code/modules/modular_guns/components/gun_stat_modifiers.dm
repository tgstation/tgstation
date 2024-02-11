/* this proc handles storage and modification of stats on guns
for instance a stock decreases accuracy its modification is stored here
gun is damaged, we can reduce its fire rate here, feels cleaner than calling procs
on the parent of other components.
*/

/datum/component/gun_stat_holder
	var/obj/item/gun/ballistic/owner_weapon
	/// our guns stability, affects recoil and spread
	var/stability
	/// our guns loudness, affects gun sounds
	var/loudness
	/// our firing speed
	var/firing_speed
	/// our guns total wear and tear
	var/usage_damage
	/// our guns handlability
	var/ease_of_use

/datum/component/gun_stat_holder/Initialize(stability, loudness, firing_speed, usage_damage, jamming_potential, ease_of_use)
	. = ..()
	owner_weapon = parent
	src.stability = stability
	src.loudness = loudness
	src.usage_damage = usage_damage
	src.firing_speed = firing_speed
	src.ease_of_use = ease_of_use

/datum/component/gun_stat_holder/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATTACHMENT_ATTACHED, PROC_REF(handle_stat_gain))
	RegisterSignal(parent, COMSIG_ATTACHMENT_DETACHED, PROC_REF(handle_stat_loss))

/datum/component/gun_stat_holder/proc/handle_stat_gain(atom/source, obj/item/attachment/attached)
	stability *= attached.stability
	firing_speed *= attached.fire_multipler
	loudness *= attached.noise_multiplier
	ease_of_use *= attached.ease_of_use
	redistribute_stats()

/datum/component/gun_stat_holder/proc/handle_stat_loss(atom/source, obj/item/attachment/attached)
	stability /= attached.stability
	firing_speed /= attached.fire_multipler
	loudness /= attached.noise_multiplier
	ease_of_use /= attached.ease_of_use
	attached.unique_attachment_effects_removal(parent)
	redistribute_stats()

///this is a shitcode handler until i convert all guns to the stat_holder_system
/datum/component/gun_stat_holder/proc/redistribute_stats()
	reset_stats_to_base(parent)
	var/obj/item/gun/gun = parent

	gun.spread = max(gun.spread - stability, 0)
	gun.recoil +=(max(100 - stability, 0) * 0.01)

	gun.suppressed_volume *= (loudness * 0.01)
	gun.fire_sound_volume *= (loudness * 0.01)

	gun.fire_delay *= (firing_speed * 0.01)

	///we do this at the end and addon using unique shit
	SEND_SIGNAL(gun, COMSIG_ATTACHMENT_STAT_RESET)


/datum/component/gun_stat_holder/proc/reset_stats_to_base(obj/item/gun/gun)
	gun.spread = initial(gun.spread)
	gun.suppressed_volume = initial(gun.suppressed_volume)
	gun.recoil = initial(gun.recoil)
	gun.fire_sound_volume = initial(gun.fire_sound_volume)
	gun.fire_delay = initial(gun.fire_delay)
