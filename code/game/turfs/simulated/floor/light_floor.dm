/turf/simulated/floor/light
	name = "Light floor"
	luminosity = 5
	icon_state = "light_on"
	floor_tile = /obj/item/stack/tile/light
	broken_states = list("light_broken")
	var/on = 1
	var/state //0 = fine, 1 = flickering, 2 = breaking, 3 = broken
	var/list/coloredlights = list("g", "r", "y", "b", "p", "w", "s","o","g")
	var/currentcolor = 1


/turf/simulated/floor/light/New()
	..()
	spawn(5) //needed because when placing a light floor tile it will take a short while before setting state
		if(istype(builtin_tile, /obj/item/stack/tile/light))
			var/obj/item/stack/tile/light/L = builtin_tile
			L.state = state
	update_icon()

/turf/simulated/floor/light/update_icon()
	..()
	if(on)
		switch(state)
			if(0)
				icon_state = "light_on-[coloredlights[currentcolor]]"
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


/turf/simulated/floor/light/ChangeTurf(turf/T)
	SetLuminosity(0)
	..()

/turf/simulated/floor/light/attack_hand(mob/user)
	if(!on)
		on = 1
		currentcolor = 1
		return
	else
		currentcolor++
	if(currentcolor > coloredlights.len)
		on = 0
	update_icon()
	..()  //I am not sure what the parent procs have for attack_hand, best to check later.

/turf/simulated/floor/light/attack_ai(mob/user)
	attack_hand(user)

/turf/simulated/floor/light/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C,/obj/item/weapon/light/bulb)) //only for light tiles
		if(state && user.drop_item())
			qdel(C)
			state = 0 //fixing it by bashing it with a light bulb, fun eh?
			update_icon()
			user << "<span class='notice'>You replace the light bulb.</span>"
		else
			user << "<span class='notice'>The lightbulb seems fine, no need to replace it.</span>"
