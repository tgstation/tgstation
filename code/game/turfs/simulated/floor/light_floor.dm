/* In this file:
 *
 * Light floor
 */

/turf/simulated/floor/light
	name = "Light floor"
	luminosity = 5
	icon_state = "light_on"
	floor_tile = /obj/item/stack/tile/light
	broken_states = list("light-broken")
	var/on = 1
	var/state //0 = fine, 1 = flickering, 2 = breaking, 3 = broken

/turf/simulated/floor/light/New()
	..()
	spawn(4)
		if(src)
			update_icon()
			name = initial(name)

/turf/simulated/floor/light/update_icon()
	if(on)
		switch(state)
			if(0)
				icon_state = "light_on"
				SetLuminosity(1)
			if(1)
				var/num = pick("1","2","3","4")
				icon_state = "light_on_flicker[num]"
				SetLuminosity(1)
			if(2)
				icon_state = "light_on_broken"
				SetLuminosity(1)
			if(3)
				icon_state = "light_off"
				SetLuminosity(0)
	else
		SetLuminosity(0)
		icon_state = "light_off"

/turf/simulated/floor/light/attack_hand(mob/user as mob)
	on = !on
	update_icon()
	..()

/turf/simulated/floor/light/attackby(obj/item/C as obj, mob/user as mob)
	if(!..())
		return
	if(istype(C,/obj/item/weapon/light/bulb)) //only for light tiles
		if(state)
			user.drop_item()
			qdel(C)
			state = 0 //fixing it by bashing it with a light bulb, fun eh?
			update_icon()
			user << "<span class='notice'>You replace the light bulb.</span>"
		else
			user << "<span class='notice'>The lightbulb seems fine, no need to replace it.</span>"
		return
