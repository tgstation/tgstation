/obj/vehicle/ridden/bicycle
	name = "bicycle"
	desc = "Keep away from electricity."
	icon_state = "bicycle"
	var/easter_egg_chance = 1

	var/static/list/bike_music = list('sound/misc/bike1.mid',
								'sound/misc/bike2.mid',
								'sound/misc/bike3.mid')

/obj/vehicle/ridden/bicycle/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))
	D.vehicle_move_delay = 0

/obj/vehicle/ridden/bicycle/buckle_mob(mob/living/M, force = 0, check_loc = 1)
	if(prob(easter_egg_chance) || (SSevents.holidays && SSevents.holidays[APRIL_FOOLS]))
		SEND_SOUND(M, sound(pick(bike_music), repeat = 1, wait = 0, volume = 80, channel = CHANNEL_BICYCLE))
	. = ..()

/obj/vehicle/ridden/bicycle/unbuckle_mob(mob/living/buckled_mob,force = 0)
	if(buckled_mob)
		buckled_mob.stop_sound_channel(CHANNEL_BICYCLE)
	. =..()

/obj/vehicle/ridden/bicycle/tesla_act() // :::^^^)))
	name = "fried bicycle"
	desc = "Well spent."
	color = rgb(63, 23, 4)
	can_buckle = FALSE
	for(var/m in buckled_mobs)
		unbuckle_mob(m,1)
