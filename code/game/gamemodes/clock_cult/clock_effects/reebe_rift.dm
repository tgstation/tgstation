//A two-way portal that leads to and from the City of Cogs. These spawn across the station and lead to one location.
//This file also contains the City of Cogs beckoner.
/obj/effect/clockwork/reebe_rift
	name = "spatial rift"
	desc = "A shimmering portal to another area. You can see shimmers of brassy colors on the other side."
	clockwork_desc = "A two-way rift that leads between the station and the Celestial Derelict."
	icon_state = "spatial_gateway"
	density = 1
	light_range = 2
	light_power = 3
	light_color = "#6A4D2F"

/obj/effect/clockwork/reebe_rift/Initialize()
	..()
	if(!GLOB.city_of_cogs_beckoner)
		qdel(src)

/obj/effect/clockwork/reebe_rift/attack_hand(mob/living/user)
	user.visible_message("<span class='warning'>[user] touches [src] and is pulled through!</span>", "<span class='boldwarning'>You reach out to touch [src] and are yanked through it!</span>")
	one_way_ticket(user)

/obj/effect/clockwork/reebe_rift/attackby(obj/item/I, mob/living/user, params)
	user.visible_message("<span class='warning'>[user] swings [I] at [src] and is pulled through!</span>", "<span class='boldwarning'>You swing [I] at [src] and are yanked through it!</span>")
	one_way_ticket(user)

/obj/effect/clockwork/reebe_rift/Bumped(atom/A)
	A.visible_message("<span class='warning'>[A] passes into [src]!</span>", "<span class='boldwarning'>You pass through [src] and appear somewhere else!</span>")
	one_way_ticket(A)

/obj/effect/clockwork/reebe_rift/proc/one_way_ticket(atom/movable/A)
	var/obj/effect/clockwork/city_of_cogs_beckoner/B = GLOB.city_of_cogs_beckoner // :b:eckoner
	playsound(src, 'sound/effects/EMPulse.ogg', 50, 1)
	playsound(B, 'sound/effects/EMPulse.ogg', 50, 1)
	B.visible_message("<span class='warning'>[B]'s eye flashes, and [A] appears in front of it!</span>")
	A.forceMove(get_turf(B))

//The destination for rifts to Reebe, and a semi-dangerous way to get to the station.
/obj/effect/clockwork/city_of_cogs_beckoner
	name = "\improper City of Cogs beckoner"
	desc = "A clockwork mechanism set into the wall with a bright, glowing red eye."
	clockwork_desc = "All rifts to Reebe lead here. You can also interact with it to go to the station, assuming you don't mind where you end up."
	icon_state = "city_of_cogs_beckoner"
	pixel_y = -64

/obj/effect/clockwork/city_of_cogs_beckoner/Initialize()
	..()
	GLOB.city_of_cogs_beckoner = src

/obj/effect/clockwork/city_of_cogs_beckoner/attack_hand(mob/living/user)
	if(!is_servant_of_ratvar(user))
		user.visible_message("<span class='warning'>[user] waves their hand in front of [src] and vanishes in a flash of red light!</span>", \
		"<span class='boldwarning'>You wave your hand in front of [src], and appear somewhere else!</span>")
		var/obj/effect/landmark/L = pick(GLOB.generic_event_spawns)
		var/turf/destination = get_turf(L)
		playsound(src, 'sound/effects/EMPulse.ogg', 50, 1)
		playsound(destination, 'sound/effects/EMPulse.ogg', 50, 1)
		destination.visible_message("<span class='warning'>[user] appears in a flash of red light!</span>")
		user.forceMove(destination)
		user.overlay_fullscreen("flash", /obj/screen/fullscreen/city_of_cogs_beckoner)
		user.clear_fullscreen("flash", 20)
	else
		var/turf/destination
		switch(alert(user, "Teleport to a random beacon or \"random\" location?", "City of Cogs Beckoner", "Location (Safer)", "Beacon (Less Suspicious)", "Cancel"))
			if("Cancel")
				return
			if("Beacon (Less Suspicious)")
				if(GLOB.teleportbeacons.len)
					var/obj/item/I = pick(GLOB.teleportbeacons)
					destination = get_turf(I)
		if(!destination)
			var/obj/effect/landmark/L = pick(GLOB.generic_event_spawns)
			destination = get_turf(L)
		user.visible_message("<span class='warning'>[user] waves their hand in front of [src] and vanishes in a flash of red light!</span>", \
		"<span class='boldwarning'>You wave your hand in front of [src], and appear somewhere else!</span>")
		playsound(src, 'sound/effects/EMPulse.ogg', 50, 1)
		playsound(destination, 'sound/effects/EMPulse.ogg', 50, 1)
		destination.visible_message("<span class='warning'>[user] appears in a flash of red light!</span>")
		user.forceMove(destination)
		user.overlay_fullscreen("flash", /obj/screen/fullscreen/city_of_cogs_beckoner)
		user.clear_fullscreen("flash", 20)
