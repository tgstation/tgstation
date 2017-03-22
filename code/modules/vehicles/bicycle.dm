/obj/vehicle/bicycle
	name = "bicycle"
	desc = "Keep away from electricity."
	icon_state = "bicycle"
	var/easter_egg_chance = 1

var/static/list/bike_music = list('sound/misc/bike1.mid',
							'sound/misc/bike2.mid',
							'sound/misc/bike3.mid')
/obj/vehicle/bicycle/New()
	..()
	riding_datum = new/datum/riding/bicycle

/obj/vehicle/bicycle/buckle_mob(mob/living/M, force = 0, check_loc = 1)
	if(prob(easter_egg_chance) || (SSevent.holidays && SSevent.holidays[APRIL_FOOLS]))
		M << sound(pick(bike_music), repeat = 1, wait = 0, volume = 80, channel = 42)
	. = ..()

/obj/vehicle/bicycle/unbuckle_mob(mob/living/buckled_mob,force = 0)
	if(buckled_mob)
		buckled_mob << sound(null, repeat = 0, wait = 0, volume = 80, channel = 42)
	. =..()

/obj/vehicle/bicycle/tesla_act() // :::^^^)))
	name = "fried bicycle"
	desc = "Well spent."
	riding_datum = null
	color = rgb(63, 23, 4)
	for(var/m in buckled_mobs)
		unbuckle_mob(m,1)
