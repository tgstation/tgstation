/* This is an attempt to make some easily reusable "particle" type effect, to stop the code
constantly having to be rewritten. An item like the jetpack that uses the ion_trail_follow system, just has one
defined, then set up when it is created with New(). Then this same system can just be reused each time
it needs to create more trails.A beaker could have a steam_trail_follow system set up, then the steam
would spawn and follow the beaker, even if it is carried or thrown.
*/


/obj/effect/effect
	name = "effect"
	icon = 'icons/effects/effects.dmi'
	mouse_opacity = 0
	unacidable = 1 // so effect are not targeted by alien acid.
	flags = TABLEPASS
	w_type=NOT_RECYCLABLE

/obj/effect/effect/water
	name = "water"
	icon_state = "extinguish"
	var/life = 15.0

/obj/effect/effect/water/New()
	. = ..()
	//var/turf/T = src.loc
	//if (istype(T, /turf))
	//	T.firelevel = 0 //TODO: FIX

	spawn(70)
		qdel(src)

/obj/effect/effect/water/Destroy()
	//var/turf/T = src.loc
	//if (istype(T, /turf))
	//	T.firelevel = 0 //TODO: FIX

	..()

/obj/effect/effect/water/Move(NewLoc,Dir=0,step_x=0,step_y=0)
	//var/turf/T = src.loc
	//if (istype(T, /turf))
	//	T.firelevel = 0 //TODO: FIX

	if (--life < 1)
		//SN src = null
		qdel(src)
		return 0

	.=..()

/obj/effect/effect/water/Bump(atom/A)
	if(reagents)
		reagents.reaction(A)
	return ..()

/datum/effect/effect/system
	var/number = 3
	var/cardinals = 0
	var/turf/location
	var/atom/holder
	var/setup = 0

	proc/set_up(n = 3, c = 0, turf/loc)
		if(n > 10)
			n = 10
		number = n
		cardinals = c
		location = loc
		setup = 1

	proc/attach(atom/atom)
		holder = atom

	proc/start()

/////////////////////////////////////////////
// GENERIC STEAM SPREAD SYSTEM

//Usage: set_up(number of bits of steam, use North/South/East/West only, spawn location)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like a smoking beaker, so then you can just call start() and the steam
// will always spawn at the items location, even if it's moved.

/* Example:
var/datum/effect/system/steam_spread/steam = new /datum/effect/system/steam_spread() -- creates new system
steam.set_up(5, 0, mob.loc) -- sets up variables
OPTIONAL: steam.attach(mob)
steam.start() -- spawns the effect
*/
/////////////////////////////////////////////
/obj/effect/effect/steam
	name = "steam"
	icon_state = "extinguish"
	density = 0

/datum/effect/effect/system/steam_spread

	set_up(n = 3, c = 0, turf/loc)
		if(n > 10)
			n = 10
		number = n
		cardinals = c
		location = loc

	start()
		var/i = 0
		for(i=0, i<src.number, i++)
			spawn(0)
				if(holder)
					src.location = get_turf(holder)
				var/obj/effect/effect/steam/steam = new /obj/effect/effect/steam(src.location)
				var/direction
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
				for(i=0, i<pick(1,2,3), i++)
					sleep(5)
					step(steam,direction)
				spawn(20)
					if(steam)
						qdel(steam)

/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/obj/effect/effect/sparks
	name = "sparks"
	desc = "it's a spark what do you need to know?"
	icon_state = "sparks"
	anchored = 1

	var/inertia_dir = 0
	var/energy = 0

/obj/effect/effect/sparks/New(var/travel_dir)
	..()

/obj/effect/effect/sparks/proc/start(var/travel_dir, var/max_energy=3)
	inertia_dir=travel_dir
	energy=rand(1,max_energy)
	processing_objects.Add(src)
	var/turf/T = loc
	if (istype(T, /turf))
		T.hotspot_expose(1000, 100)

/obj/effect/effect/sparks/Destroy()
	processing_objects.Remove(src)
	var/turf/T = src.loc

	if (istype(T, /turf))
		T.hotspot_expose(1000, 100)

	..()

/obj/effect/effect/sparks/Move()
	..()
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(1000,100)
	return

/obj/effect/effect/sparks/process()
	if(energy==0)
		processing_objects.Remove(src)
		returnToPool(src)
		return
	else
		step(src,inertia_dir)
	energy--

/datum/effect/effect/system/spark_spread/set_up(var/n = 3, var/use_cardinals = 0, loca)
	number = min(10,n)
	cardinals = use_cardinals

	if (istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)

/datum/effect/effect/system/spark_spread/start()
	if (holder)
		location = get_turf(holder)

	var/list/directions
	if (cardinals)
		directions = cardinal.Copy()
	else
		directions = alldirs.Copy()

	playsound(location, "sparks", 100, 1)
	for (var/i = 1 to number)
		var/nextdir=pick_n_take(directions)
		if(nextdir)
			var/obj/effect/effect/sparks/sparks = getFromPool(/obj/effect/effect/sparks, location)
			sparks.start(nextdir)

/////////////////////////////////////////////
//// SMOKE SYSTEMS
// direct can be optinally added when set_up, to make the smoke always travel in one direction
// in case you wanted a vent to always smoke north for example
/////////////////////////////////////////////


/obj/effect/effect/smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0
	var/amount = 6.0
	var/time_to_live = 100

	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effect/effect/smoke/New()
	. = ..()
	spawn(time_to_live)
		qdel(src)

/obj/effect/effect/smoke/Crossed(mob/living/carbon/M as mob )
	..()
	if(istype(M))
		affect(M)

/obj/effect/effect/smoke/proc/affect(var/mob/living/carbon/M)
	if (istype(M))
		return 0
	if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
		return 0
	return 1

/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/obj/effect/effect/smoke/bad
	time_to_live = 200

/obj/effect/effect/smoke/bad/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		affect(M)

/obj/effect/effect/smoke/bad/affect(var/mob/living/carbon/M)
	if (!..())
		return 0
	M.drop_item()
	M.adjustOxyLoss(1)
	if (M.coughedtime != 1)
		M.coughedtime = 1
		M.emote("cough")
		spawn ( 20 )
			M.coughedtime = 0

/obj/effect/effect/smoke/bad/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0)) return 1
	if(istype(mover, /obj/item/projectile/beam))
		var/obj/item/projectile/beam/B = mover
		B.damage = (B.damage/2)
	return 1
/////////////////////////////////////////////
// Sleep smoke
/////////////////////////////////////////////

/obj/effect/effect/smoke/sleepy

/obj/effect/effect/smoke/sleepy/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		affect(M)

/obj/effect/effect/smoke/sleepy/affect(mob/living/carbon/M as mob )
	if (!..())
		return 0

	M.drop_item()
	M:sleeping += 1
	if (M.coughedtime != 1)
		M.coughedtime = 1
		M.emote("cough")
		spawn ( 20 )
			M.coughedtime = 0
/////////////////////////////////////////////
// Mustard Gas
/////////////////////////////////////////////


/obj/effect/effect/smoke/mustard
	name = "mustard gas"
	icon_state = "mustard"

/obj/effect/effect/smoke/mustard/Move()
	..()
	for(var/mob/living/carbon/human/R in get_turf(src))
		affect(R)

/obj/effect/effect/smoke/mustard/affect(var/mob/living/carbon/human/R)
	if (!..())
		return 0
	if (R.wear_suit != null)
		return 0

	R.burn_skin(0.75)
	if (R.coughedtime != 1)
		R.coughedtime = 1
		R.emote("gasp")
		spawn (20)
			R.coughedtime = 0
	R.updatehealth()
	return

/////////////////////////////////////////////
// Smoke spread
/////////////////////////////////////////////

/datum/effect/effect/system/smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction
	var/smoke_type = /obj/effect/effect/smoke

/datum/effect/effect/system/smoke_spread/set_up(n = 5, c = 0, loca, direct)
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

/datum/effect/effect/system/smoke_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/smoke/smoke = new smoke_type(src.location)
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
			spawn(smoke.time_to_live*0.75+rand(10,30))
				if (smoke) qdel(smoke)
				src.total_smoke--


/datum/effect/effect/system/smoke_spread/bad
	smoke_type = /obj/effect/effect/smoke/bad

/datum/effect/effect/system/smoke_spread/sleepy
	smoke_type = /obj/effect/effect/smoke/sleepy


/datum/effect/effect/system/smoke_spread/mustard
	smoke_type = /obj/effect/effect/smoke/mustard
/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////
/obj/effect/effect/smoke/chem
	icon = 'icons/effects/chemsmoke.dmi'

/obj/effect/effect/smoke/chem/New()
	. = ..()
	create_reagents(500)

/obj/effect/effect/smoke/chem/Move()
	..()
	for(var/atom/A in view(2, src))
		if(reagents.has_reagent("radium")||reagents.has_reagent("uranium")||reagents.has_reagent("carbon")||reagents.has_reagent("thermite"))//Prevents unholy radium spam by reducing the number of 'greenglows' down to something reasonable -Sieve
			if(prob(5))
				reagents.reaction(A)
		else
			reagents.reaction(A)

	return

/obj/effect/effect/smoke/chem/affect(mob/living/carbon/M as mob )
	reagents.reaction(M)

/datum/effect/effect/system/smoke_spread/chem
	smoke_type = /obj/effect/effect/smoke/chem
	var/obj/chemholder

	New()
		..()
		chemholder = new/obj()
		var/datum/reagents/R = new/datum/reagents(500)
		chemholder.reagents = R
		R.my_atom = chemholder

	set_up(var/datum/reagents/carry = null, n = 5, c = 0, loca, direct)
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

		var/contained = ""
		for(var/reagent in carry.reagent_list)
			contained += " [reagent] "
		if(contained)
			contained = "\[[contained]\]"
		var/area/A = get_area(location)

		var/where = "[A.name] | [location.x], [location.y]"
		var/whereLink = "<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>[where]</a>"

		if(carry.my_atom.fingerprintslast)
			var/mob/M = get_mob_by_key(carry.my_atom.fingerprintslast)
			var/more = ""
			if(M)
				more = "(<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</a>)"
			message_admins("A chemical smoke reaction has taken place in ([whereLink])[contained]. Last associated key is [carry.my_atom.fingerprintslast][more].", 0, 1)
			log_game("A chemical smoke reaction has taken place in ([where])[contained]. Last associated key is [carry.my_atom.fingerprintslast].")
		else
			message_admins("A chemical smoke reaction has taken place in ([whereLink]). No associated key.", 0, 1)
			log_game("A chemical smoke reaction has taken place in ([where])[contained]. No associated key.")

	start()
		var/i = 0

		var/color = mix_color_from_reagents(chemholder.reagents.reagent_list)

		for(i=0, i<src.number, i++)
			if(src.total_smoke > 20)
				return
			spawn(0)
				if(holder)
					src.location = get_turf(holder)
				var/obj/effect/effect/smoke/chem/smoke = new /obj/effect/effect/smoke/chem(src.location)
				src.total_smoke++
				var/direction = src.direction
				if(!direction)
					if(src.cardinals)
						direction = pick(cardinal)
					else
						direction = pick(alldirs)

				if(chemholder.reagents.total_volume != 1) // can't split 1 very well
					chemholder.reagents.copy_to(smoke, chemholder.reagents.total_volume / number) // copy reagents to each smoke, divide evenly

				if(color)
					smoke.icon += color // give the smoke color, if it has any to begin with
				else
					// if no color, just use the old smoke icon
					smoke.icon = 'icons/effects/96x96.dmi'
					smoke.icon_state = "smoke"

				for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
					sleep(10)
					step(smoke,direction)
				spawn(150+rand(10,30))
					if(smoke) qdel(smoke)
					src.total_smoke--

// Goon compat.
/datum/effect/effect/system/smoke_spread/chem/fart
	set_up(var/mob/M, n = 5, c = 0, loca, direct)
		if(n > 20)
			n = 20
		number = n
		cardinals = c

		chemholder.reagents.add_reagent("space_drugs", rand(1,10))

		if(istype(loca, /turf/))
			location = loca
		else
			location = get_turf(loca)
		if(direct)
			direction = direct

		var/contained = "\[[chemholder.reagents.get_reagent_ids()]\]"
		var/area/A = get_area(location)

		var/where = "[A.name] | [location.x], [location.y]"
		var/whereLink=formatJumpTo(location,where)

		var/more = "(<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</a>)"
		message_admins("[M][more] produced a toxic fart in ([whereLink])[contained].", 0, 1)
		log_game("[M][more] produced a toxic fart in ([where])[contained].")


/////////////////////////////////////////////
//////// Attach an Ion trail to any object, that spawns when it moves (like for the jetpack)
/// just pass in the object to attach it to in set_up
/// Then do start() to start it and stop() to stop it, obviously
/// and don't call start() in a loop that will be repeated otherwise it'll get spammed!
/////////////////////////////////////////////

/obj/effect/effect/ion_trails
	name = "ion trails"
	icon_state = "ion_trails"
	anchored = 1

/datum/effect/effect/system/ion_trail_follow
	var/turf/oldposition
	var/processing = 1
	var/on = 1

	set_up(atom/atom)
		attach(atom)
		oldposition = get_turf(atom)

	start()
		if(!src.on)
			src.on = 1
			src.processing = 1
		if(src.processing)
			src.processing = 0
			spawn(0)
				var/turf/T = get_turf(src.holder)
				if(T != src.oldposition)
					if(istype(T, /turf/space))
						var/obj/effect/effect/ion_trails/I = new /obj/effect/effect/ion_trails(src.oldposition)
						src.oldposition = T
						I.dir = src.holder.dir
						flick("ion_fade", I)
						I.icon_state = "blank"
						spawn( 20 )
							if(I) qdel(I)
					spawn(2)
						if(src.on)
							src.processing = 1
							src.start()
				else
					spawn(2)
						if(src.on)
							src.processing = 1
							src.start()

	proc/stop()
		src.processing = 0
		src.on = 0

/datum/effect/effect/system/ion_trail_follow/space_trail
	var/turf/oldloc // secondary ion trail loc
	var/turf/currloc
/datum/effect/effect/system/ion_trail_follow/space_trail/start()
	if(!src.on)
		src.on = 1
		src.processing = 1
	if(src.processing)
		src.processing = 0
		spawn(0)
			var/turf/T = get_turf(src.holder)
			if(currloc != T)
				switch(holder.dir)
					if(NORTH)
						src.oldposition = T
						src.oldposition = get_step(oldposition, SOUTH)
						src.oldloc = get_step(oldposition,EAST)
						//src.oldloc = get_step(oldloc, SOUTH)
					if(SOUTH) // More difficult, offset to the north!
						src.oldposition = get_step(holder,NORTH)
						src.oldposition = get_step(oldposition,NORTH)
						src.oldloc = get_step(oldposition,EAST)
						//src.oldloc = get_step(oldloc,NORTH)
					if(EAST) // Just one to the north should suffice
						src.oldposition = T
						src.oldposition = get_step(oldposition, WEST)
						src.oldloc = get_step(oldposition,NORTH)
						//src.oldloc = get_step(oldloc,WEST)
					if(WEST) // One to the east and north from there
						src.oldposition = get_step(holder,EAST)
						src.oldposition = get_step(oldposition,EAST)
						src.oldloc = get_step(oldposition,NORTH)
						//src.oldloc = get_step(oldloc,EAST)
				if(istype(T, /turf/space))
					var/obj/effect/effect/ion_trails/I = new /obj/effect/effect/ion_trails(src.oldposition)
					var/obj/effect/effect/ion_trails/II = new /obj/effect/effect/ion_trails(src.oldloc)
					//src.oldposition = T
					I.dir = src.holder.dir
					II.dir = src.holder.dir
					flick("ion_fade", I)
					flick("ion_fade", II)
					I.icon_state = "blank"
					II.icon_state = "blank"
					spawn( 20 )
						if(I) qdel(I)
						if(II) qdel(II)
				spawn(2)
					if(src.on)
						src.processing = 1
						src.start()
			else
				spawn(2)
					if(src.on)
						src.processing = 1
						src.start()
			currloc = T


/////////////////////////////////////////////
//////// Attach a steam trail to an object (eg. a reacting beaker) that will follow it
// even if it's carried of thrown.
/////////////////////////////////////////////

/datum/effect/effect/system/steam_trail_follow
	var/turf/oldposition
	var/processing = 1
	var/on = 1

	set_up(atom/atom)
		attach(atom)
		oldposition = get_turf(atom)

	start()
		if(!src.on)
			src.on = 1
			src.processing = 1
		if(src.processing)
			src.processing = 0
			spawn(0)
				if(src.number < 3)
					var/obj/effect/effect/steam/I = new /obj/effect/effect/steam(src.oldposition)
					src.number++
					src.oldposition = get_turf(holder)
					I.dir = src.holder.dir
					spawn(10)
						if(I) qdel(I)
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

	proc/stop()
		src.processing = 0
		src.on = 0



// Foam
// Similar to smoke, but spreads out more
// metal foams leave behind a foamed metal wall

/obj/effect/effect/foam
	name = "foam"
	icon_state = "foam"
	opacity = 0
	anchored = 1
	density = 0
	layer = OBJ_LAYER + 0.9
	var/amount = 3
	var/expand = 1
	animate_movement = 0
	var/metal = 0

/obj/effect/effect/foam/fire
	name = "fire supression foam"
	icon_state = "mfoam"

/obj/effect/effect/foam/New(loc, var/ismetal=0)
	. = ..(loc)
	icon_state = "[ismetal ? "m":""]foam"
	metal = ismetal
	playsound(src, 'sound/effects/bubbles2.ogg', 80, 1, -3)
	spawn(3 + metal*3)
		process()
	spawn(120)
		processing_objects.Remove(src)
		sleep(30)

		if(metal)
			var/obj/structure/foamedmetal/M = new(src.loc)
			M.metal = metal
			M.updateicon()

		flick("[icon_state]-disolve", src)
		sleep(5)
		qdel(src)

/obj/effect/effect/foam/fire/New(loc, datum/reagents/R)
	reagents = R
	reagents.my_atom = src
	var/ccolor = mix_color_from_reagents(reagents.reagent_list)
	if(ccolor)
		icon += ccolor
	//playsound(src, 'sound/effects/bubbles2.ogg', 80, 1, -3)
	if(reagents.has_reagent("water"))
		var/turf/simulated/T = get_turf(src)
		if(istype(T))
			var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
			lowertemp.temperature = max( min(lowertemp.temperature-500,lowertemp.temperature / 2) ,0)
			lowertemp.react()
			T.assume_air(lowertemp)
	spawn(3)
		process()
	spawn(120)
		processing_objects.Remove(src)
		sleep(30)
		flick("[icon_state]-disolve", src)
		sleep(5)
		qdel(src)

/obj/effect/effect/foam/fire/process()
	if(--amount < 0)
		return

// on delete, transfer any reagents to the floor
/obj/effect/effect/foam/Destroy()
	if(!metal && reagents && !istype(src, /obj/effect/effect/foam/fire))
		for(var/atom/A in oview(0,src))
			if(A == src)
				continue
			reagents.reaction(A, 1, 1)
	..()


/obj/effect/effect/foam/process()
	if(--amount < 0)
		return


	for(var/direction in cardinal)


		var/turf/T = get_step(src,direction)
		if(!T)
			continue

		if(!T.Enter(src))
			continue

		var/obj/effect/effect/foam/F = locate() in T
		if(F)
			continue

		F = new(T, metal)
		F.amount = amount
		if(!metal)
			F.create_reagents(10)
			if (reagents)
				for(var/datum/reagent/R in reagents.reagent_list)
					F.reagents.add_reagent(R.id,1)

// foam disolves when heated
// except metal foams
/obj/effect/effect/foam/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!metal && prob(max(0, exposed_temperature - 475)))
		flick("[icon_state]-disolve", src)

		spawn(5)
			qdel(src)


/obj/effect/effect/foam/Crossed(var/atom/movable/AM)
	if(metal)
		return
	if(istype(src, /obj/effect/effect/foam/fire))
		if(isliving(AM))
			var/mob/living/M = AM
			reagents.reaction(M)
		return

	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if (istype(M, /mob/living/carbon/human) && (istype(M:shoes, /obj/item/clothing/shoes) && M:shoes.flags&NOSLIP))
			return

		M.stop_pulling()
		M << "\blue You slipped on the foam!"
		playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
		M.Stun(5)
		M.Weaken(2)


/datum/effect/effect/system/foam_spread
	var/amount = 5				// the size of the foam spread.
	var/list/carried_reagents	// the IDs of reagents present when the foam was mixed
	var/metal = 0				// 0=foam, 1=metalfoam, 2=ironfoam




	set_up(amt=5, loca, var/datum/reagents/carry = null, var/metalfoam = 0)
		amount = round(sqrt(amt / 3), 1)
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

	start()
		spawn(0)
			var/obj/effect/effect/foam/F = locate() in location
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

/obj/structure/foamedmetal
	icon = 'icons/effects/effects.dmi'
	icon_state = "metalfoam"
	density = 1
	opacity = 1 	// changed in New()
	anchored = 1
	name = "foamed metal"
	desc = "A lightweight foamed metal wall."
	var/metal = 1		// 1=aluminum, 2=iron

	proc/updateicon()
		if(metal == 1)
			icon_state = "metalfoam"
		else
			icon_state = "ironfoam"


	ex_act(severity)
		qdel(src)

	blob_act()
		del(src)

	bullet_act()
		if(metal==1 || prob(50))
			del(src)

	attack_paw(var/mob/user)
		attack_hand(user)
		return

	attack_hand(var/mob/user)
		if ((M_HULK in user.mutations) || (prob(75 - metal*25)))
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

	CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
		if(air_group) return 0
		return !density


	proc/update_nearby_tiles()
		if (isnull(air_master))
			return 0

		var/T = loc

		if (isturf(T))
			air_master.mark_for_update(T)

		return 1

/obj/structure/foamedmetal/New()
	. = ..()
	update_nearby_tiles()

/obj/structure/foamedmetal/Destroy()
	update_nearby_tiles()
	..()

/datum/effect/effect/system/reagents_explosion
	var/amount 						// TNT equivalent
	var/flashing = 0			// does explosion creates flash effect?
	var/flashing_factor = 0		// factor of how powerful the flash effect relatively to the explosion

	set_up (amt, loc, flash = 0, flash_fact = 0)
		amount = amt
		if(istype(loc, /turf/))
			location = loc
		else
			location = get_turf(loc)

		flashing = flash
		flashing_factor = flash_fact

		return

	start()
		if (amount <= 2)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(2, 1, location)
			s.start()

			for(var/mob/M in viewers(5, location))
				M << "\red The solution violently explodes."
			for(var/mob/M in viewers(1, location))
				if (prob (50 * amount))
					M << "\red The explosion knocks you down."
					M.Weaken(rand(1,5))
			return
		else
			var/devastation = -1
			var/heavy = -1
			var/light = -1
			var/flash = -1
			var/range = 0
			// Clamp all values to MAX_EXPLOSION_RANGE
			range = min (MAX_EXPLOSION_RANGE, light + round(amount/3))
			devastation = round(min(1, range * 0.25)) // clamps to 1 devestation for grenades
			heavy = round(min(3, range * 0.5)) // clamps to 3 heavy range for grenades
			light = min(6, range) // clamps to 6 light range for grenades
			flash = range * 1.5
			/*
			if (round(amount/12) > 0)
				devastation = min (MAX_EXPLOSION_RANGE, devastation + round(amount/12))

			if (round(amount/6) > 0)
				heavy = min (MAX_EXPLOSION_RANGE, heavy + round(amount/6))

			if (round(amount/3) > 0)
				light = min (MAX_EXPLOSION_RANGE, light + round(amount/3))

			if (flash && flashing_factor)
				flash += (round(amount/4) * flashing_factor)
			*/

			for(var/mob/M in viewers(8, location))
				M << "\red The solution violently explodes."

			explosion(location, devastation, heavy, light, flash)

	proc/holder_damage(var/atom/holder)
		if(holder)
			var/dmglevel = 4

			if (round(amount/8) > 0)
				dmglevel = 1
			else if (round(amount/4) > 0)
				dmglevel = 2
			else if (round(amount/2) > 0)
				dmglevel = 3

			if(dmglevel<4) holder.ex_act(dmglevel)
