
/obj/effect/anomaly/pyro
	name = "pyroclastic anomaly"
	icon_state = "pyroclastic"
	var/ticks = 0
	/// How many seconds between each gas release
	var/releasedelay = 10
	aSignal = /obj/item/assembly/signaler/anomaly/pyro

/obj/effect/anomaly/pyro/anomalyEffect(seconds_per_tick)
	..()
	ticks += seconds_per_tick
	if(ticks < releasedelay)
		return FALSE
	else
		ticks -= releasedelay
	var/turf/open/tile = get_turf(src)
	if(istype(tile))
		tile.atmos_spawn_air("o2=5;plasma=5;TEMP=1000")
	return TRUE

/obj/effect/anomaly/pyro/detonate()
	INVOKE_ASYNC(src, PROC_REF(makepyroslime))

/obj/effect/anomaly/pyro/proc/makepyroslime()
	var/turf/open/tile = get_turf(src)
	if(istype(tile))
		tile.atmos_spawn_air("o2=500;plasma=500;TEMP=1000") //Make it hot and burny for the new slime

	var/new_colour = pick(/datum/slime_color/red, /datum/slime_color/orange)
	var/mob/living/basic/slime/pyro = new(tile, new_colour)
	ADD_TRAIT(pyro, TRAIT_SLIME_RABID, "pyro")
	pyro.maximum_survivable_temperature = INFINITY
	pyro.apply_temperature_requirements()

	var/mob/chosen_one = SSpolling.poll_ghosts_for_target(check_jobban = ROLE_SENTIENCE, poll_time = 10 SECONDS, checked_target = pyro, ignore_category = POLL_IGNORE_PYROSLIME, alert_pic = pyro, role_name_text = "pyroclastic anomaly slime")
	if(isnull(chosen_one))
		return
	pyro.key = chosen_one.key
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
