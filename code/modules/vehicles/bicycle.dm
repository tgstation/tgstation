/obj/vehicle/bicycle
	name = "bicycle"
	desc = "Keep away from electricity."
	icon_state = "bicycle"

var/list/bike_music = list('sound/misc/bike1.mid',
							'sound/misc/bike2.mid',
							'sound/misc/bike3.mid')
/obj/vehicle/bicycle/New()
	..()
	riding_datum = new/datum/riding/bicycle
/obj/vehicle/bicycle/buckle_mob(mob/living/M, force = 0, check_loc = 1)
	..()
	var/YY = text2num(time2text(world.timeofday, "YY"))
	var/MM = text2num(time2text(world.timeofday, "MM"))
	var/DD = text2num(time2text(world.timeofday, "DD"))
	var/datum/holiday/april_fools/AF = new
	if(prob(1) || AF.shouldCelebrate(DD, MM, YY))
		M << sound(pick(bike_music), repeat = 0, wait = 0, volume = 50, channel = 1)

/obj/vehicle/bicycle/unbuckle_mob(mob/living/buckled_mob,force = 0)
	..()
	buckled_mob.stopLobbySound() // :^)

/obj/vehicle/bicycle/tesla_act() // :::^^^)))
	name = "fried bicycle"
	desc = "Well spent."
	riding_datum = null
	color = rgb(63, 23, 4)