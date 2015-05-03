/////////////////////////////////////////////
//// SMOKE SYSTEMS
// direct can be optionally added when set_up, to make the smoke always travel in one direction
// in case you wanted a vent to always smoke north for example
/////////////////////////////////////////////

/obj/effect/effect/smoke
	name = "smoke"
	icon = 'icons/effects/water.dmi'
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 8.0

/obj/effect/effect/harmless_smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effect/effect/harmless_smoke/New()
	..()
	spawn (100)
		qdel(src)

/datum/effect/effect/system/harmless_smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

/datum/effect/effect/system/harmless_smoke_spread/set_up(n = 5, c = 0, loca, direct)
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


/datum/effect/effect/system/harmless_smoke_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/harmless_smoke/smoke = PoolOrNew(/obj/effect/effect/harmless_smoke, location)
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
				if(smoke)
					fadeOut(smoke)
					qdel(smoke)
				src.total_smoke--


/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/obj/effect/effect/bad_smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effect/effect/bad_smoke/New()
	..()
	spawn (200+rand(10,30))
		qdel(src)

/obj/effect/effect/bad_smoke/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
		else
			M.drop_item()
			M.adjustOxyLoss(1)
			if (M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn(20)
					if(M && M.loc)
						M.coughedtime = 0
	return


/obj/effect/effect/bad_smoke/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0) return 1
	if(istype(mover, /obj/item/projectile/beam))
		var/obj/item/projectile/beam/B = mover
		B.damage = (B.damage/2)
	return 1


/obj/effect/effect/bad_smoke/Crossed(mob/living/carbon/M as mob )
	..()
	if(istype(M, /mob/living/carbon))
		if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
			return
		else
			M.drop_item()
			M.adjustOxyLoss(1)
			if (M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn(20)
					if(M && M.loc)
						M.coughedtime = 0
	return

/datum/effect/effect/system/bad_smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

/datum/effect/effect/system/bad_smoke_spread/set_up(n = 5, c = 0, loca, direct)
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

/datum/effect/effect/system/bad_smoke_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/bad_smoke/smoke = PoolOrNew(/obj/effect/effect/bad_smoke, location)
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
				if(smoke)
					fadeOut(smoke)
					qdel(smoke)
				src.total_smoke--


/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////


/obj/effect/effect/chem_smoke
	name = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	icon = 'icons/effects/chemsmoke.dmi'
	pixel_x = -32
	pixel_y = -32


/obj/effect/effect/chem_smoke/New()
	..()
	create_reagents(500)
	spawn(200+rand(10,30))
		qdel(src)


/obj/effect/effect/chem_smoke/Move()
	..()
	for(var/mob/living/A in view(1, src))
		if(reagents.total_volume >= 1)
			reagents.reaction(A, TOUCH)
			reagents.trans_to(A.reagents, 10)
	return


/obj/effect/effect/chem_smoke/Crossed(mob/living/carbon/M as mob )
	..()
	if(reagents.total_volume >= 1)
		reagents.reaction(M, TOUCH)
		reagents.trans_to(M.reagents, 10)

/datum/effect/effect/system/chem_smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction
	var/obj/chemholder


/datum/effect/effect/system/chem_smoke_spread/New()
	..()
	chemholder = PoolOrNew(/obj)
	var/datum/reagents/R = new/datum/reagents(500)
	chemholder.reagents = R
	R.my_atom = chemholder

/datum/effect/effect/system/chem_smoke_spread/Destroy()
	chemholder = null
	..()
	return QDEL_HINT_PUTINPOOL

/datum/effect/effect/system/chem_smoke_spread/set_up(var/datum/reagents/carry = null, n = 5, c = 0, loca, direct, silent = 0)
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

	if(!silent)
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


/datum/effect/effect/system/chem_smoke_spread/start()
	var/i = 0

	var/color = mix_color_from_reagents(chemholder.reagents.reagent_list)

	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/chem_smoke/smoke = PoolOrNew(/obj/effect/effect/chem_smoke, location)
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
				smoke.color = color // give the smoke color, if it has any to begin with
			else
				// if no color, just use the old smoke icon
				smoke.icon = 'icons/effects/96x96.dmi'
				smoke.icon_state = "smoke"

			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(smoke,direction)
			spawn(150+rand(10,30))
				if(smoke)
					fadeOut(smoke)
					qdel(smoke)
				src.total_smoke--



/////////////////////////////////////////////
// Sleep smoke
/////////////////////////////////////////////

/obj/effect/effect/sleep_smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32
	color = "#9C3636"

/obj/effect/effect/sleep_smoke/New()
	..()
	spawn (200+rand(10,30))
		qdel(src)

/obj/effect/effect/sleep_smoke/Move()
	..()
	for(var/mob/living/carbon/M in get_turf(src))
		if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
//		if (M.wear_suit, /obj/item/clothing/suit/wizrobe && (M.hat, /obj/item/clothing/head/wizard) && (M.shoes, /obj/item/clothing/shoes/sandal))  // I'll work on it later
		else
			M.drop_item()
			M:sleeping += 5
			if (M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn(20)
					if(M && M.loc)
						M.coughedtime = 0
	return

/obj/effect/effect/sleep_smoke/Crossed(mob/living/carbon/M as mob )
	..()
	if(istype(M, /mob/living/carbon))
		if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
//		if (M.wear_suit, /obj/item/clothing/suit/wizrobe && (M.hat, /obj/item/clothing/head/wizard) && (M.shoes, /obj/item/clothing/shoes/sandal)) // Work on it later
			return
		else
			M.drop_item()
			M:sleeping += 5
			if (M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn(20)
					if(M && M.loc)
						M.coughedtime = 0
	return

/datum/effect/effect/system/sleep_smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

/datum/effect/effect/system/sleep_smoke_spread/set_up(n = 5, c = 0, loca, direct)
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


/datum/effect/effect/system/sleep_smoke_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/sleep_smoke/smoke = PoolOrNew(/obj/effect/effect/sleep_smoke, location)
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
				if(smoke)
					fadeOut(smoke)
					qdel(smoke)
				src.total_smoke--