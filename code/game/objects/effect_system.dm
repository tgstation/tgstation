/* This is an attempt to make some easily reusable "particle" type effects, to stop the code
constantly having to be rewritten. An item like the jetpack that uses the ion_trail_follow system, just has one
defined, then set up when it is created with New(). Then this same system can just be reused each time
it needs to create more trails.A beaker could have a steam_trail_follow system set up, then the steam
would spawn and follow the beaker, even if it is carried or thrown.
*/


/obj/effects
	name = "effects"
	icon = 'effects.dmi'
	mouse_opacity = 0
	unacidable = 1//So effects are not targeted by alien acid.
	flags = TABLEPASS

/obj/effects/water
	name = "water"
	icon = 'effects.dmi'
	icon_state = "extinguish"
	var/life = 15.0
	flags = 2.0
	mouse_opacity = 0

/obj/effects/smoke
	name = "smoke"
	icon = 'water.dmi'
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 8.0


/obj/effects/water/New()
	..()
	//var/turf/T = src.loc
	//if (istype(T, /turf))
	//	T.firelevel = 0 //TODO: FIX
	spawn( 70 )
		del(src)
		return
	return

/obj/effects/water/Del()
	//var/turf/T = src.loc
	//if (istype(T, /turf))
	//	T.firelevel = 0 //TODO: FIX
	..()
	return

/obj/effects/water/Move(turf/newloc)
	//var/turf/T = src.loc
	//if (istype(T, /turf))
	//	T.firelevel = 0 //TODO: FIX
	if (--src.life < 1)
		//SN src = null
		del(src)
	if(newloc.density)
		return 0
	.=..()


/////////////////////////////////////////////
// GENERIC STEAM SPREAD SYSTEM

//Usage: set_up(number of bits of steam, use North/South/East/West only, spawn location)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like a smoking beaker, so then you can just call start() and the steam
// will always spawn at the items location, even if it's moved.

/* Example:
var/datum/effects/system/steam_spread/steam = new /datum/effects/system/steam_spread() -- creates new system
steam.set_up(5, 0, mob.loc) -- sets up variables
OPTIONAL: steam.attach(mob)
steam.start() -- spawns the effect
*/
/////////////////////////////////////////////
/obj/effects/steam
	name = "steam"
	icon = 'effects.dmi'
	icon_state = "extinguish"
	density = 0

/datum/effects/system/steam_spread
	var/number = 3
	var/cardinals = 0
	var/turf/location
	var/atom/holder

/datum/effects/system/steam_spread/proc/set_up(n = 3, c = 0, turf/loc)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	location = loc

/datum/effects/system/steam_spread/proc/attach(atom/atom)
	holder = atom

/datum/effects/system/steam_spread/proc/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effects/steam/steam = new /obj/effects/steam(src.location)
			var/direction
			if(src.cardinals)
				direction = pick(cardinal)
			else
				direction = pick(alldirs)
			for(i=0, i<pick(1,2,3), i++)
				sleep(5)
				step(steam,direction)
			spawn(20)
				del(steam)







/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/obj/effects/sparks
	name = "sparks"
	icon_state = "sparks"
	var/amount = 6.0
	anchored = 1.0
	mouse_opacity = 0

/obj/effects/sparks/New()
	..()
	playsound(src.loc, "sparks", 100, 1)
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(1000,100)
	spawn (100)
		del(src)
	return

/obj/effects/sparks/Del()
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(1000,100)
	..()
	return

/obj/effects/sparks/Move()
	..()
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(1000,100)
	return

/datum/effects/system/spark_spread
	var/number = 3
	var/cardinals = 0
	var/turf/location
	var/atom/holder
	var/total_sparks = 0 // To stop it being spammed and lagging!

/datum/effects/system/spark_spread/proc/set_up(n = 3, c = 0, loca)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)

/datum/effects/system/spark_spread/proc/attach(atom/atom)
	holder = atom

/datum/effects/system/spark_spread/proc/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_sparks > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effects/sparks/sparks = new /obj/effects/sparks(src.location)
			src.total_sparks++
			var/direction
			if(src.cardinals)
				direction = pick(cardinal)
			else
				direction = pick(alldirs)
			for(i=0, i<pick(1,2,3), i++)
				sleep(5)
				step(sparks,direction)
			spawn(20)
				del(sparks)
				src.total_sparks--








/////////////////////////////////////////////
//// SMOKE SYSTEMS
// direct can be optinally added when set_up, to make the smoke always travel in one direction
// in case you wanted a vent to always smoke north for example
/////////////////////////////////////////////


/obj/effects/harmless_smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	//Remove this bit to use the old smoke
	icon = '96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effects/harmless_smoke/New()
	..()
	spawn (100)
		del(src)
	return

/obj/effects/harmless_smoke/Move()
	..()
	return

/datum/effects/system/harmless_smoke_spread
	var/number = 3
	var/cardinals = 0
	var/turf/location
	var/atom/holder
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

/datum/effects/system/harmless_smoke_spread/proc/set_up(n = 5, c = 0, loca, direct)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct


/datum/effects/system/harmless_smoke_spread/proc/attach(atom/atom)
	holder = atom

/datum/effects/system/harmless_smoke_spread/proc/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effects/harmless_smoke/smoke = new /obj/effects/harmless_smoke(src.location)
			src.total_smoke++
			var/direction = src.direction
			if(!direction)
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(smoke,direction)
			spawn(75+rand(10,30))
				del(smoke)
				src.total_smoke--







/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/obj/effects/bad_smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	//Remove this bit to use the old smoke
	icon = '96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effects/bad_smoke/New()
	..()
	spawn (200+rand(10,30))
		del(src)
	return

/obj/effects/bad_smoke/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
		else
			M.drop_item()
			M.oxyloss += 1
			if (M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn ( 20 )
					M.coughedtime = 0
	return

/obj/effects/bad_smoke/HasEntered(mob/living/carbon/M as mob )
	..()
	if(istype(M, /mob/living/carbon))
		if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
			return
		else
			M.drop_item()
			M.oxyloss += 1
			if (M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn ( 20 )
					M.coughedtime = 0
	return

/datum/effects/system/bad_smoke_spread
	var/number = 3
	var/cardinals = 0
	var/turf/location
	var/atom/holder
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

/datum/effects/system/bad_smoke_spread/proc/set_up(n = 5, c = 0, loca, direct)
	if(n > 20)
		n = 20
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct


/datum/effects/system/bad_smoke_spread/proc/attach(atom/atom)
	holder = atom

/datum/effects/system/bad_smoke_spread/proc/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effects/bad_smoke/smoke = new /obj/effects/bad_smoke(src.location)
			src.total_smoke++
			var/direction = src.direction
			if(!direction)
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(smoke,direction)
			spawn(150+rand(10,30))
				del(smoke)
				src.total_smoke--


/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////


/obj/effects/chem_smoke
	name = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0

	icon = 'chemsmoke.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effects/chem_smoke/New()
	..()
	var/datum/reagents/R = new/datum/reagents(500)
	reagents = R
	R.my_atom = src

	spawn (200+rand(10,30))
		del(src)
	return

/obj/effects/chem_smoke/Move()
	..()
	for(var/atom/A in view(2, src))
		reagents.reaction(A)

	return

/obj/effects/chem_smoke/HasEntered(mob/living/carbon/M as mob )
	..()
	reagents.reaction(M)

	return

/datum/effects/system/chem_smoke_spread
	var/number = 3
	var/cardinals = 0
	var/turf/location
	var/atom/holder
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction
	var/obj/chemholder
	New()
		..()
		chemholder = new/obj()
		var/datum/reagents/R = new/datum/reagents(500)
		chemholder.reagents = R
		R.my_atom = chemholder

/datum/effects/system/chem_smoke_spread/proc/set_up(var/datum/reagents/carry = null, n = 5, c = 0, loca, direct)
	if(n > 20)
		n = 20
	number = n
	cardinals = c
	carry.copy_to(chemholder, carry.total_volume)

	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct


/datum/effects/system/chem_smoke_spread/proc/attach(atom/atom)
	holder = atom

/datum/effects/system/chem_smoke_spread/proc/start()
	var/i = 0

	// Calculate the smokes' color
	var/list/rgbcolor = list(0,0,0)
	var/finalcolor
	for(var/datum/reagent/re in chemholder.reagents.reagent_list)
		if(!finalcolor)
			rgbcolor = GetColors(re.color)
			finalcolor = re.color
		else
			var/newcolor[3]
			var/prergbcolor[3]
			prergbcolor = rgbcolor
			newcolor = GetColors(re.color)

			rgbcolor[1] = (prergbcolor[1]+newcolor[1])/2
			rgbcolor[2] = (prergbcolor[2]+newcolor[2])/2
			rgbcolor[3] = (prergbcolor[3]+newcolor[3])/2

			finalcolor = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3])

	if(finalcolor)
		finalcolor = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3]) // slightly darker color

	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effects/chem_smoke/smoke = new /obj/effects/chem_smoke(src.location)
			src.total_smoke++
			var/direction = src.direction
			if(!direction)
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)

			chemholder.reagents.copy_to(smoke, chemholder.reagents.total_volume) // copy reagents to each smoke

			if(finalcolor)
				smoke.icon += finalcolor // give the smoke color, if it has any to begin with
			else
				// if no color, just use the old smoke icon
				smoke.icon = '96x96.dmi'
				smoke.icon_state = "smoke"

			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(smoke,direction)
			spawn(150+rand(10,30))
				del(smoke)
				src.total_smoke--



/////////////////////////////////////////////
// Sleep smoke
/////////////////////////////////////////////

/obj/effects/sleep_smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	//Remove this bit to use the old smoke
	icon = '96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effects/sleep_smoke/New()
	..()
	spawn (200+rand(10,30))
		del(src)
	return

/obj/effects/sleep_smoke/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
//		if (M.wear_suit, /obj/item/clothing/suit/wizrobe && (M.hat, /obj/item/clothing/head/wizard) && (M.shoes, /obj/item/clothing/shoes/sandal))  // I'll work on it later
		else
			M.drop_item()
			M:sleeping += 1
			if (M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn ( 20 )
					M.coughedtime = 0
	return

/obj/effects/sleep_smoke/HasEntered(mob/living/carbon/M as mob )
	..()
	if(istype(M, /mob/living/carbon))
		if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
//		if (M.wear_suit, /obj/item/clothing/suit/wizrobe && (M.hat, /obj/item/clothing/head/wizard) && (M.shoes, /obj/item/clothing/shoes/sandal)) // Work on it later
			return
		else
			M.drop_item()
			M:sleeping += 1
			if (M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn ( 20 )
					M.coughedtime = 0
	return

/datum/effects/system/sleep_smoke_spread
	var/number = 3
	var/cardinals = 0
	var/turf/location
	var/atom/holder
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

/datum/effects/system/sleep_smoke_spread/proc/set_up(n = 5, c = 0, loca, direct)
	if(n > 20)
		n = 20
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct


/datum/effects/system/sleep_smoke_spread/proc/attach(atom/atom)
	holder = atom

/datum/effects/system/sleep_smoke_spread/proc/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effects/sleep_smoke/smoke = new /obj/effects/sleep_smoke(src.location)
			src.total_smoke++
			var/direction = src.direction
			if(!direction)
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(smoke,direction)
			spawn(150+rand(10,30))
				del(smoke)
				src.total_smoke--

/////////////////////////////////////////////
// Mustard Gas
/////////////////////////////////////////////


/obj/effects/mustard_gas
	name = "mustard gas"
	icon_state = "mustard"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0

/obj/effects/mustard_gas/New()
	..()
	spawn (100)
		del(src)
	return

/obj/effects/mustard_gas/Move()
	..()
	for(var/mob/living/carbon/human/R in get_turf(src))
		if (R.internal != null && usr.wear_mask && (R.wear_mask.flags & MASKINTERNALS) && R.wear_suit != null && !istype(R.wear_suit, /obj/item/clothing/suit/labcoat) && !istype(R.wear_suit, /obj/item/clothing/suit/straight_jacket) && !istype(R.wear_suit, /obj/item/clothing/suit/straight_jacket && !istype(R.wear_suit, /obj/item/clothing/suit/armor)))
		else
			R.burn_skin(0.75)
			if (R.coughedtime != 1)
				R.coughedtime = 1
				R.emote("gasp")
				spawn (20)
					R.coughedtime = 0
			R.updatehealth()
	return

/obj/effects/mustard_gas/HasEntered(mob/living/carbon/human/R as mob )
	..()
	if (istype(R, /mob/living/carbon/human))
		if (R.internal != null && usr.wear_mask && (R.wear_mask.flags & MASKINTERNALS) && R.wear_suit != null && !istype(R.wear_suit, /obj/item/clothing/suit/labcoat) && !istype(R.wear_suit, /obj/item/clothing/suit/straight_jacket) && !istype(R.wear_suit, /obj/item/clothing/suit/straight_jacket && !istype(R.wear_suit, /obj/item/clothing/suit/armor)))
			return
		R.burn_skin(0.75)
		if (R.coughedtime != 1)
			R.coughedtime = 1
			R.emote("gasp")
			spawn (20)
				R.coughedtime = 0
		R.updatehealth()
	return

/datum/effects/system/mustard_gas_spread
	var/number = 3
	var/cardinals = 0
	var/turf/location
	var/atom/holder
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

/datum/effects/system/mustard_gas_spread/proc/set_up(n = 5, c = 0, loca, direct)
	if(n > 20)
		n = 20
	number = n
	cardinals = c
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct

/datum/effects/system/mustard_gas_spread/proc/attach(atom/atom)
	holder = atom

/datum/effects/system/mustard_gas_spread/proc/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effects/mustard_gas/smoke = new /obj/effects/mustard_gas(src.location)
			src.total_smoke++
			var/direction = src.direction
			if(!direction)
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(smoke,direction)
			spawn(100)
				del(smoke)
				src.total_smoke--





/////////////////////////////////////////////
//////// Attach an Ion trail to any object, that spawns when it moves (like for the jetpack)
/// just pass in the object to attach it to in set_up
/// Then do start() to start it and stop() to stop it, obviously
/// and don't call start() in a loop that will be repeated otherwise it'll get spammed!
/////////////////////////////////////////////

/obj/effects/ion_trails
	name = "ion trails"
	icon_state = "ion_trails"
	anchored = 1.0

/datum/effects/system/ion_trail_follow
	var/atom/holder
	var/turf/oldposition
	var/processing = 1
	var/on = 1

/datum/effects/system/ion_trail_follow/proc/set_up(atom/atom)
	holder = atom
	oldposition = get_turf(atom)

/datum/effects/system/ion_trail_follow/proc/start()
	if(!src.on)
		src.on = 1
		src.processing = 1
	if(src.processing)
		src.processing = 0
		spawn(0)
			var/turf/T = get_turf(src.holder)
			if(T != src.oldposition)
				if(istype(T, /turf/space))
					var/obj/effects/ion_trails/I = new /obj/effects/ion_trails(src.oldposition)
					src.oldposition = T
					I.dir = src.holder.dir
					flick("ion_fade", I)
					I.icon_state = "blank"
					spawn( 20 )
						del(I)
				spawn(2)
					if(src.on)
						src.processing = 1
						src.start()
			else
				spawn(2)
					if(src.on)
						src.processing = 1
						src.start()

/datum/effects/system/ion_trail_follow/proc/stop()
	src.processing = 0
	src.on = 0





/////////////////////////////////////////////
//////// Attach a steam trail to an object (eg. a reacting beaker) that will follow it
// even if it's carried of thrown.
/////////////////////////////////////////////

/datum/effects/system/steam_trail_follow
	var/atom/holder
	var/turf/oldposition
	var/processing = 1
	var/on = 1
	var/number

/datum/effects/system/steam_trail_follow/proc/set_up(atom/atom)
	holder = atom
	oldposition = get_turf(atom)

/datum/effects/system/steam_trail_follow/proc/start()
	if(!src.on)
		src.on = 1
		src.processing = 1
	if(src.processing)
		src.processing = 0
		spawn(0)
			if(src.number < 3)
				var/obj/effects/steam/I = new /obj/effects/steam(src.oldposition)
				src.number++
				src.oldposition = get_turf(holder)
				I.dir = src.holder.dir
				spawn(10)
					del(I)
					src.number--
				spawn(2)
					if(src.on)
						src.processing = 1
						src.start()
			else
				spawn(2)
					if(src.on)
						src.processing = 1
						src.start()

/datum/effects/system/steam_trail_follow/proc/stop()
	src.processing = 0
	src.on = 0



// Foam
// Similar to smoke, but spreads out more
// metal foams leave behind a foamed metal wall

/obj/effects/foam
	name = "foam"
	icon_state = "foam"
	opacity = 0
	anchored = 1
	density = 0
	layer = OBJ_LAYER + 0.9
	mouse_opacity = 0
	var/amount = 3
	var/expand = 1
	animate_movement = 0
	var/metal = 0


/obj/effects/foam/New(loc, var/ismetal=0)
	..(loc)
	icon_state = "[ismetal ? "m":""]foam"
	metal = ismetal
	playsound(src, 'bubbles2.ogg', 80, 1, -3)
	spawn(3 + metal*3)
		process()
	spawn(120)
		expand = 0 // stop expanding
		sleep(30)

		if(metal)
			var/obj/foamedmetal/M = new(src.loc)
			M.metal = metal
			M.updateicon()

		flick("[icon_state]-disolve", src)
		sleep(5)
		del(src)
	return

// on delete, transfer any reagents to the floor
/obj/effects/foam/Del()
	if(!metal && reagents)
		for(var/atom/A in oview(0,src))
			if(A == src)
				continue
			reagents.reaction(A, 1, 1)
	..()

/obj/effects/foam/proc/process()
	if(--amount < 0)
		return


	while(expand)	// keep trying to expand while true

		for(var/direction in cardinal)


			var/turf/T = get_step(src,direction)
			if(!T)
				continue

			if(!T.Enter(src))
				continue

			var/obj/effects/foam/F = locate() in T
			if(F)
				continue

			F = new(T, metal)
			F.amount = amount
			if(!metal)
				F.create_reagents(10)
				if (reagents)
					for(var/datum/reagent/R in reagents.reagent_list)
						F.reagents.add_reagent(R.id,1)
		sleep(15)

// foam disolves when heated
// except metal foams
/obj/effects/foam/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!metal && prob(max(0, exposed_temperature - 475)))
		flick("[icon_state]-disolve", src)

		spawn(5)
			del(src)


/obj/effects/foam/HasEntered(var/atom/movable/AM)
	if(metal)
		return

	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if (istype(M, /mob/living/carbon/human) && (istype(M:shoes, /obj/item/clothing/shoes) && M:shoes.flags&NOSLIP))
			return

		M.pulling = null
		M << "\blue You slipped on the foam!"
		playsound(src.loc, 'slip.ogg', 50, 1, -3)
		M.stunned = 5
		M.weakened = 2


/datum/effects/system/foam_spread
	var/amount = 5				// the size of the foam spread.
	var/turf/location
	var/list/carried_reagents	// the IDs of reagents present when the foam was mixed
	var/metal = 0				// 0=foam, 1=metalfoam, 2=ironfoam




/datum/effects/system/foam_spread/proc/set_up(amt=5, loca, var/datum/reagents/carry = null, var/metalfoam = 0)
	amount = round(amt/5, 1)
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)

	carried_reagents = list()
	metal = metalfoam


	// bit of a hack here. Foam carries along any reagent also present in the glass it is mixed
	// with (defaults to water if none is present). Rather than actually transfer the reagents,
	// this makes a list of the reagent ids and spawns 1 unit of that reagent when the foam disolves.


	if(carry && !metal)
		for(var/datum/reagent/R in carry.reagent_list)
			carried_reagents += R.id

/datum/effects/system/foam_spread/proc/start()
	spawn(0)
		var/obj/effects/foam/F = locate() in location
		if(F)
			F.amount += amount
			return

		F = new(src.location, metal)
		F.amount = amount

		if(!metal)			// don't carry other chemicals if a metal foam
			F.create_reagents(10)

			if(carried_reagents)
				for(var/id in carried_reagents)
					F.reagents.add_reagent(id,1)
			else
				F.reagents.add_reagent("water", 1)

// wall formed by metal foams
// dense and opaque, but easy to break

/obj/foamedmetal
	icon = 'effects.dmi'
	icon_state = "metalfoam"
	density = 1
	opacity = 0 	// changed in New()
	anchored = 1
	name = "foamed metal"
	desc = "A lightweight foamed metal wall."
	var/metal = 1		// 1=aluminum, 2=iron

	New()
		..()
		update_nearby_tiles(1)
		spawn(1)
			sd_NewOpacity(1)

	Del()
		sd_NewOpacity(0)
		density = 0
		update_nearby_tiles(1)
		..()

	proc/updateicon()
		if(metal == 1)
			icon_state = "metalfoam"
		else
			icon_state = "ironfoam"


	ex_act(severity)
		del(src)

	blob_act()
		del(src)

	bullet_act()
		if(metal==1 || prob(50))
			del(src)

	attack_paw(var/mob/user)
		attack_hand(user)
		return

	attack_hand(var/mob/user)
		if (user.mutations & HULK || (prob(75 - metal*25)))
			user << "\blue You smash through the metal foam wall."
			for(var/mob/O in oviewers(user))
				if ((O.client && !( O.blinded )))
					O << "\red [user] smashes through the foamed metal."

			del(src)
		else
			user << "\blue You hit the metal foam but bounce off it."
		return


	attackby(var/obj/item/I, var/mob/user)

		if (istype(I, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = I
			G.affecting.loc = src.loc
			for(var/mob/O in viewers(src))
				if (O.client)
					O << "\red [G.assailant] smashes [G.affecting] through the foamed metal wall."
			del(I)
			del(src)
			return

		if(prob(I.force*20 - metal*25))
			user << "\blue You smash through the foamed metal with \the [I]."
			for(var/mob/O in oviewers(user))
				if ((O.client && !( O.blinded )))
					O << "\red [user] smashes through the foamed metal."
			del(src)
		else
			user << "\blue You hit the metal foam to no effect."

	// only air group geometry can pass
	CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
		return air_group


	// shouldn't this be a general procedure?
	// not sure if this neccessary or overkill
	proc/update_nearby_tiles(need_rebuild)
		if(!air_master) return 0

		var/turf/simulated/source = loc
		var/turf/simulated/north = get_step(source,NORTH)
		var/turf/simulated/south = get_step(source,SOUTH)
		var/turf/simulated/east = get_step(source,EAST)
		var/turf/simulated/west = get_step(source,WEST)

		if(need_rebuild)
			if(istype(source)) //Rebuild/update nearby group geometry
				if(source.parent)
					air_master.groups_to_rebuild += source.parent
				else
					air_master.tiles_to_update += source
			if(istype(north))
				if(north.parent)
					air_master.groups_to_rebuild += north.parent
				else
					air_master.tiles_to_update += north
			if(istype(south))
				if(south.parent)
					air_master.groups_to_rebuild += south.parent
				else
					air_master.tiles_to_update += south
			if(istype(east))
				if(east.parent)
					air_master.groups_to_rebuild += east.parent
				else
					air_master.tiles_to_update += east
			if(istype(west))
				if(west.parent)
					air_master.groups_to_rebuild += west.parent
				else
					air_master.tiles_to_update += west
		else
			if(istype(source)) air_master.tiles_to_update += source
			if(istype(north)) air_master.tiles_to_update += north
			if(istype(south)) air_master.tiles_to_update += south
			if(istype(east)) air_master.tiles_to_update += east
			if(istype(west)) air_master.tiles_to_update += west

		return 1

/datum/effects/system/reagents_explosion
	var/amount					// TNT equivalent
	var/turf/location
	var/flashing = 0			// does explosion creates flash effect?
	var/flashing_factor = 0		// factor of how powerful the flash effect relatively to the explosion

/datum/effects/system/reagents_explosion/proc/set_up (amt, loc, flash = 0, flash_fact = 0)
	amount = amt
	if(istype(loc, /turf/))
		location = loc
	else
		location = get_turf(loc)

	flashing = flash
	flashing_factor = flash_fact

	return

/datum/effects/system/reagents_explosion/proc/start()
	if (amount <= 2)
		var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
		s.set_up(2, 1, location)
		s.start()

		for(var/mob/M in viewers(5, location))
			M << "\red The solution violently explodes."
		for(var/mob/M in viewers(1, location))
			if (prob (50 * amount))
				M << "\red The explosion knocks you down."
				M.weakened += rand (1, 5)
		return
	else
		var/devastation = -1
		var/heavy = -1
		var/light = -1
		var/flash = -1

		// Clamp all values to MAX_EXPLOSION_RANGE
		if (round(amount/12) > 0)
			devastation = min (MAX_EXPLOSION_RANGE, devastation + round(amount/12))

		if (round(amount/6) > 0)
			heavy = min (MAX_EXPLOSION_RANGE, heavy + round(amount/6))

		if (round(amount/3) > 0)
			light = min (MAX_EXPLOSION_RANGE, light + round(amount/3))

		if (flash && flashing_factor)
			flash += (round(amount/4) * flashing_factor)

		for(var/mob/M in viewers(8, location))
			M << "\red The solution violently explodes."

		explosion(location, devastation, heavy, light, flash)