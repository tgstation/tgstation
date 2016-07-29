/datum/event/mob_swarm
    announceWhen = 2
    endWhen = 10
    var/mob_to_spawn = /mob/living/simple_animal/corgi
    var/mob_name = null
    var/area/target_area = /area/shuttle/arrival/station
    var/spawn_amount = 10
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
    spawn_amount = round(amount)
    . = ..()

/datum/event/mob_swarm/setup()
    while(possible_locations.len)
        var/area/possible_spawn_area = pick(possible_locations)
        var/area/A = locate(possible_spawn_area)
        if(A) // If we're on the map
            target_area = A
            break
        else
            possible_locations.Remove(possible_spawn_area)


/datum/event/mob_swarm/start()
    var/list/turfs = list()
    for(var/turf/T in target_area)
        if(T.density || T.has_dense_content())
            continue
        turfs.Add(T)

    for(var/n = 0, n < spawn_amount, n++)
        var/turf/targetTurf = pick(turfs)
        if(!targetTurf) // If all else goes wrong for SOME REASON
            targetTurf = get_turf(pick(target_area.contents)) // Areas contain more than turfs
        var/mob/M = new mob_to_spawn(targetTurf)
        if(!mob_name)
            mob_name = M.name
        var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
        sparks.set_up(3,0,targetTurf)
        sparks.start()
    message_admins("Mob swarm of [spawn_amount] [mob_to_spawn] at [target_area].")


/datum/event/mob_swarm/announce()
    command_alert("Due to timespace anomalies of unknown origin, [station_name] is now host to several [mob_name]\s more than there were a moment ago.")
