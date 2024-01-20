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
	ease_of_use *= attached.burden
	redistribute_stats()

/datum/component/gun_stat_holder/proc/handle_stat_loss(atom/source, obj/item/attachment/attached)
	stability /= attached.stability
	firing_speed /= attached.fire_multipler
	loudness /= attached.noise_multiplier
	ease_of_use /= attached.burden
	redistribute_stats()

///this is a shitcode handler until i convert all guns to the stat_holder_system
/datum/component/gun_stat_holder/proc/redistribute_stats()
