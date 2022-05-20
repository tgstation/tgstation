/datum/action/cooldown/mob_cooldown/release_smoke
	name = "Release smoke"
	icon_icon = 'icons/mob/actions/actions_ccult.dmi'
	button_icon_state = "clockwork_smoke"
	background_icon_state = "bg_clock"
	desc = "Release smoke stored in the steam engine."
	cooldown_time = 10 SECONDS
	/// The sound releasing the smoke makes
	var/smoke_sound = 'sound/creatures/clockwork_golem_steam.ogg'
	/// Delay of the smoke release
	var/smoke_delay = 10
	/// Smoke amount
	var/smoke_amount = 2

/datum/action/cooldown/mob_cooldown/release_smoke/Activate(atom/target_atom)
	playsound(owner, smoke_sound, 100)
	StartCooldown(10 SECONDS)
	create_smoke(target_atom)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/release_smoke/proc/create_smoke(atom/target)
	SLEEP_CHECK_DEATH(smoke_delay, src)
	var/turf/smoke_location = null
	smoke_location = get_turf(owner)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(smoke_amount, location = smoke_location)
	smoke.start()
