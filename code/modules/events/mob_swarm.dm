/datum/event/mob_swarm
    announceWhen = 2
    endWhen = 10
    var/mob_to_spawn = /mob/living/simple_animal/corgi
    var/area/target_area = /area/shuttle/arrival/station
    var/mobs_to_spawn = 10
    var/list/area/possible_locations = list(/area/science/xenobiology,
                                            /area/crew_quarters/bar,
                                            /area/bridge,
                                            /area/supply/storage,
                                            /area/crew_quarters/hop,
                                            /area/chapel/main,
                                            /area/medical/cmo,
                                            /area/crew_quarters/theatre)

/datum/event/mob_swarm/New(var/mob = /mob/living/simple_animal/corgi, var/amount = 10)
    mob_to_spawn = mob
    mobs_to_spawn = round(amount)
    . = ..()

/datum/event/mob_swarm/setup()
    while(possible_locations.len)
        var/area/possible_spawn_area = pick(possible_locations)
        if(possible_spawn_area.x) // If we're on the map
            target_area = possible_spawn_area
            break
        else
            possible_locations.Remove(possible_spawn_area)

/datum/event/mob_swarm/start()
    var/list/turfs = list()
    for(var/turf/T in target_area)
        if(T.density)
            continue
        turfs.Add(T)

    for(var/n = 0, n < mobs_to_spawn, n++)
        var/turf/targetTurf = pick(turfs)
        if(!targetTurf) // If all else goes wrong for SOME REASON
            targetTurf = get_turf(pick(target_area.contents)) // Areas contain more than turfs
        new mob_to_spawn(targetTurf)
        var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
        sparks.set_up(3,0,targetTurf)
        sparks.start()


/datum/event/mob_swarm/announce()
    command_alert("Due to timespace anomalies of unknown origin, the statio is now host to several [mob_to_spawn]\s more than there were a moment ago.")
