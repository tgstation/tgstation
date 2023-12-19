
/obj/effect/anomaly/pyro
	name = "pyroclastic anomaly"
	icon_state = "pyroclastic"
	var/ticks = 0
	/// How many seconds between each gas release
	var/releasedelay = 10
	aSignal = /obj/item/assembly/signaler/anomaly/pyro

/obj/effect/anomaly/pyro/Initialize(mapload, new_lifespan, drops_core)
	. = ..()
	apply_wibbly_filters(src)

/obj/effect/anomaly/pyro/anomalyEffect(seconds_per_tick)
	..()
	ticks += seconds_per_tick
	if(ticks < releasedelay)
		return FALSE
	else
		ticks -= releasedelay
	var/turf/open/tile = get_turf(src)
	if(istype(tile))
		tile.atmos_spawn_air("[GAS_O2]=5;[GAS_PLASMA]=5;[TURF_TEMPERATURE(1000)]")
	return TRUE

/obj/effect/anomaly/pyro/detonate()
	INVOKE_ASYNC(src, PROC_REF(makepyroslime))

/obj/effect/anomaly/pyro/proc/makepyroslime()
	var/turf/open/tile = get_turf(src)
	if(istype(tile))
		tile.atmos_spawn_air("[GAS_O2]=500;[GAS_PLASMA]=500;[TURF_TEMPERATURE(1000)]") //Make it hot and burny for the new slime

	var/new_colour = pick(/datum/slime_type/red, /datum/slime_type/orange)
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

///Bigger, meaner, immortal pyro anomaly
/obj/effect/anomaly/pyro/big
	immortal = TRUE
	aSignal = null
	releasedelay = 2
	move_force = MOVE_FORCE_OVERPOWERING

/obj/effect/anomaly/pyro/big/Initialize(mapload, new_lifespan, drops_core)
	. = ..()

	transform *= 3

/obj/effect/anomaly/pyro/big/Bumped(atom/movable/bumpee)
	. = ..()

	if(isliving(bumpee))
		var/mob/living/living = bumpee
		living.dust()

/obj/effect/anomaly/pyro/big/anomalyEffect(seconds_per_tick)
	. = ..()

	if(!.)
		return

	var/turf/turf = get_turf(src)
	if(!isgroundlessturf(turf))
		turf.TerraformTurf(/turf/open/lava/smooth/weak, flags = CHANGETURF_INHERIT_AIR)
