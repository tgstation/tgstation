/* In this file:
 *
 * Plating
 * Airless
 * Airless plating
 * Engine floor
 */
// note that plating and engine floor do not call their parent attackby, unlike other flooring
// this is done in order to avoid inheriting the crowbar attackby

/turf/open/floor/plating
	name = "plating"
	icon_state = "plating"
	intact = 0
	broken_states = list("platingdmg1", "platingdmg2", "platingdmg3")
	burnt_states = list("panelscorched")

/turf/open/floor/plating/New()
	..()
	icon_plating = icon_state

/turf/open/floor/plating/update_icon()
	if(!..())
		return
	if(!broken && !burnt)
		icon_state = icon_plating //Because asteroids are 'platings' too.

/turf/open/floor/plating/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/stack/rods))
		if(broken || burnt)
			user << "<span class='warning'>Repair the plating first!</span>"
			return
		var/obj/item/stack/rods/R = C
		if (R.get_amount() < 2)
			user << "<span class='warning'>You need two rods to make a reinforced floor!</span>"
			return
		else
			user << "<span class='notice'>You begin reinforcing the floor...</span>"
			if(do_after(user, 30, target = src))
				if (R.get_amount() >= 2 && !istype(src, /turf/open/floor/engine))
					ChangeTurf(/turf/open/floor/engine)
					playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
					R.use(2)
					user << "<span class='notice'>You reinforce the floor.</span>"
				return
	else if(istype(C, /obj/item/stack/tile))
		if(!broken && !burnt)
			var/obj/item/stack/tile/W = C
			if(!W.use(1))
				return
			var/turf/open/floor/T = ChangeTurf(W.turf_type)
			if(istype(W,/obj/item/stack/tile/light)) //TODO: get rid of this ugly check somehow
				var/obj/item/stack/tile/light/L = W
				var/turf/open/floor/light/F = T
				F.state = L.state
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
		else
			user << "<span class='warning'>This section is too damaged to support a tile! Use a welder to fix the damage.</span>"
	else if(istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/welder = C
		if( welder.isOn() && (broken || burnt) )
			if(welder.remove_fuel(0,user))
				user << "<span class='danger'>You fix some dents on the broken plating.</span>"
				playsound(src, 'sound/items/Welder.ogg', 80, 1)
				icon_state = icon_plating
				burnt = 0
				broken = 0

/turf/open/floor/plating/airless
	icon_state = "plating"
	initial_gas_mix = "TEMP=2.7"

// ONE DAY WE WILL HAVE SUBTYPES
/turf/open/floor/plasteel/airless/shuttle
	icon_state = "shuttlefloor"
/turf/open/floor/plasteel/airless/shuttle/red
	name = "Brig floor"
	icon_state = "shuttlefloor4"
/turf/open/floor/plasteel/airless/shuttle/yellow
	icon_state = "shuttlefloor2"
/turf/open/floor/plasteel/airless/shuttle/white
	icon_state = "shuttlefloor3"
/turf/open/floor/plasteel/airless/shuttle/purple
	icon_state = "shuttlefloor5"

/turf/open/floor/plating/abductor
	name = "alien floor"
	icon_state = "alienpod1"

/turf/open/floor/plating/abductor/New()
	..()
	icon_state = "alienpod[rand(1,9)]"
