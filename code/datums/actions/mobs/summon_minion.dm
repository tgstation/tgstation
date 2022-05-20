/datum/action/cooldown/mob_cooldown/summon_minion
	name = "Summon spider"
	icon_icon = 'icons/mob/actions/actions_ccult.dmi'
	button_icon_state = "clockwork_spider"
	background_icon_state = "bg_clock"
	desc = "Create a clockwork spider created from scrap brass."
	cooldown_time = 10 SECONDS
	/// The type of minion that will be summoned
	var/minion_type = /mob/living/simple_animal/hostile/asteroid/clockwork_spider
	/// The sound summoning the minion makes
	var/summon_sound = 'sound/creatures/clockwork_golem_spider.ogg'
	/// Delay of summoning the minion
	var/summon_delay = 10

/datum/action/cooldown/mob_cooldown/summon_minion/Activate(atom/target_atom)
	playsound(owner, summon_sound, 100)
	StartCooldown(10 SECONDS)
	create_minion(target_atom)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/summon_minion/proc/create_minion(atom/target)
	SLEEP_CHECK_DEATH(summon_delay, src)
	var/turf/summon_location = null
	summon_location = get_turf(owner)
	new minion_type(summon_location)
