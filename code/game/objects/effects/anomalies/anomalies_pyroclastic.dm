
/obj/effect/anomaly/pyro
	name = "pyroclastic anomaly"
	icon_state = "pyroclastic"
	var/ticks = 0
	/// How many seconds between each gas release
	var/releasedelay = 10
	aSignal = /obj/item/assembly/signaler/anomaly/pyro

/obj/effect/anomaly/pyro/anomalyEffect(delta_time)
	..()
	ticks += delta_time
	if(ticks < releasedelay)
		return
	else
		ticks -= releasedelay
	var/turf/open/tile = get_turf(src)
	if(istype(tile))
		tile.atmos_spawn_air("o2=5;plasma=5;TEMP=1000")

/obj/effect/anomaly/pyro/detonate()
	INVOKE_ASYNC(src, PROC_REF(makepyroslime))

/obj/effect/anomaly/pyro/proc/makepyroslime()
	var/turf/open/tile = get_turf(src)
	if(istype(tile))
		tile.atmos_spawn_air("o2=500;plasma=500;TEMP=1000") //Make it hot and burny for the new slime

	var/new_colour = pick("red", "orange")
	var/mob/living/simple_animal/slime/pyro = new(tile, new_colour)
	pyro.rabid = TRUE
	pyro.amount_grown = SLIME_EVOLUTION_THRESHOLD
	pyro.Evolve()
	var/datum/action/innate/slime/reproduce/repro_action = new
	repro_action.Grant(pyro)

	var/list/mob/dead/observer/candidates = poll_candidates_for_mob("Do you want to play as a pyroclastic anomaly slime?", ROLE_SENTIENCE, null, 10 SECONDS, pyro, POLL_IGNORE_PYROSLIME)
	if(!LAZYLEN(candidates))
		return

	var/mob/dead/observer/chosen = pick(candidates)
	pyro.key = chosen.key
	pyro.mind.special_role = ROLE_PYROCLASTIC_SLIME
	pyro.mind.add_antag_datum(/datum/antagonist/pyro_slime)
	pyro.log_message("was made into a slime by pyroclastic anomaly", LOG_GAME)
