/datum/effect_system/smoke_spread/transparent/extrashort
	effect_type = /obj/effect/particle_effect/fluid/smoke/transparent/extrashort

/obj/effect/particle_effect/fluid/smoke/transparent/extrashort
	lifetime = 0.2 SECONDS

/datum/action/cooldown/spell/summon_dancefloor
	name = "Summon Dancefloor"
	desc = "When you really need some funk."

	spell_requirements = NONE
	school = SCHOOL_EVOCATION
	cooldown_time = 3 SECONDS
	/// turfs we dance floored
	var/list/dance_floors = list()

/datum/action/cooldown/spell/summon_dancefloor/cast(atom/target)
	. = ..()
	var/datum/effect_system/smoke = new /datum/effect_system/smoke_spread/transparent/extrashort()
	smoke.set_up(1, get_turf(owner))
	smoke.start()

	if(dance_floors.len)
		for(var/turf/turf as anything in dance_floors)
			dance_floors -= turf
			if(!istype(turf, /turf/open/floor/light/colour_cycle))
				continue
			turf.ScrapeAway(amount = 1, flags = CHANGETURF_INHERIT_AIR)
		return

	var/list/affected = RANGE_TURFS(1, owner)

	for(var/turf/affecting as anything in affected)
		if(!affecting.density)
			continue
		owner.balloon_alert(owner, "not enough space!")
		return

	dance_floors = affected
	var/alternate = FALSE
	for(var/turf/turf in dance_floors)
		turf.place_on_top(alternate ? /turf/open/floor/light/colour_cycle/dancefloor_a : /turf/open/floor/light/colour_cycle/dancefloor_b, flags = CHANGETURF_INHERIT_AIR)
		alternate = !alternate
