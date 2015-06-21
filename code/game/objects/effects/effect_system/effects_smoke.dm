/////////////////////////////////////////////
//// SMOKE SYSTEMS
// direct can be optionally added when set_up, to make the smoke always travel in one direction
// in case you wanted a vent to always smoke north for example
/////////////////////////////////////////////

/obj/effect/effect/smoke
	name = "smoke"
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32
	icon_state = "smoke"
	opacity = 1
	anchored = 0
	mouse_opacity = 0
	var/steps = 0
	var/lifetime = 10
	var/direction
	var/fading = 0


/obj/effect/effect/smoke/proc/fade_out(var/frames = 16)
	if(alpha == 0) //Handle already transparent case
		return
	if(frames == 0)
		frames = 1 //We will just assume that by 0 frames, the coder meant "during one frame".
	var/step = alpha / frames
	for(var/i = 0, i < frames, i++)
		alpha -= step
		sleep(world.tick_lag)

/obj/effect/effect/smoke/New()
	..()
	create_reagents(500)
	SSobj.processing.Add(src)
	lifetime = lifetime + rand(1,3)

/obj/effect/effect/smoke/Destroy()
	SSobj.processing.Remove(src)
	..()

/obj/effect/effect/smoke/proc/kill_smoke()
	SSobj.processing.Remove(src)
	qdel(src)

/obj/effect/effect/smoke/process()
	world << "Process"
	lifetime--
	if(lifetime < 3 && !fading)
		fading = 1
		spawn(0)
			fade_out(100)
	if(lifetime < 1)
		kill_smoke()
		return 0
	if(steps >= 1)
		step(src,direction)
		steps--
	return 1

/obj/effect/effect/smoke/Crossed(mob/living/M as mob)
	if(!istype(M))
		return
	smoke_mob(M)

/obj/effect/effect/smoke/proc/smoke_mob(mob/living/carbon/M as mob)
	if(!istype(M))
		return 0
	if(lifetime<1)
		return 0
	if(M.internal != null || (M.wear_mask && (M.wear_mask.flags & BLOCK_GAS_SMOKE_EFFECT)))
		return 0
	if(M.smoke_delay)
		return 0
	M.smoke_delay++
	spawn(10)
		if(M)
			M.smoke_delay = 0
	return 1



/datum/effect/effect/system/smoke_spread
	var/direction
	var/smoke_type = /obj/effect/effect/smoke

/datum/effect/effect/system/smoke_spread/set_up(n = 5, c = 0, loca, direct)
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

/datum/effect/effect/system/smoke_spread/start()
	for(var/i=0, i<src.number, i++)
		if(holder)
			src.location = get_turf(holder)
		var/obj/effect/effect/smoke/S = PoolOrNew(smoke_type, location)
		SSobj.processing.Add(S)
		if(!direction)
			if(src.cardinals)
				S.direction = pick(cardinal)
			else
				S.direction = pick(alldirs)
		else
			S.direction = direction
		S.steps = pick(0,1,1,1,2,2,2,3)
		S.process()



/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/obj/effect/effect/smoke/bad/process()
	if(..())
		for(var/mob/living/carbon/M in range(1,src))
			smoke_mob(M)

/obj/effect/effect/smoke/bad/smoke_mob(mob/living/carbon/M as mob)
	if(..())
		M.drop_item()
		M.adjustOxyLoss(1)
		M.emote("cough")

/obj/effect/effect/smoke/bad/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0) return 1
	if(istype(mover, /obj/item/projectile/beam))
		var/obj/item/projectile/beam/B = mover
		B.damage = (B.damage/2)
	return 1



/datum/effect/effect/system/smoke_spread/bad
	smoke_type = /obj/effect/effect/smoke/bad


/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////

/obj/effect/effect/smoke/chem
	icon = 'icons/effects/chemsmoke.dmi'
	icon_state = ""
	var/max_lifetime = 10

/obj/effect/effect/smoke/chem/process()
	if(..())
		var/fraction = 1/max_lifetime
		for(var/obj/O in range(1,src))
			if(O.type == src.type)
				continue
			reagents.reaction(O, TOUCH, fraction)

		for(var/turf/T in range(1,src))
			reagents.reaction(T, TOUCH, fraction)

		for(var/mob/living/L in range(1,src))
			smoke_mob(L)

/obj/effect/effect/smoke/chem/smoke_mob((mob/living/carbon/M as mob))
	if(lifetime<1)
		return
	if(!istype(M))
		return
	var/fraction = 1/max_lifetime
	reagents.reaction(M, TOUCH, fraction)
	lifetime--



/datum/effect/effect/system/smoke_spread/chem
	var/obj/chemholder
	smoke_type = /obj/effect/effect/smoke/chem

/datum/effect/effect/system/smoke_spread/chem/New()
	..()
	chemholder = PoolOrNew(/obj)
	var/datum/reagents/R = new/datum/reagents(500)
	chemholder.reagents = R
	R.my_atom = chemholder

/datum/effect/effect/system/smoke_spread/chem/Destroy()
	chemholder = null
	..()
	return QDEL_HINT_PUTINPOOL

/datum/effect/effect/system/smoke_spread/chem/set_up(var/datum/reagents/carry = null, n = 5, c = 0, loca, direct, silent = 0)
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
	carry.copy_to(chemholder, carry.total_volume)

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


/datum/effect/effect/system/smoke_spread/chem/start()

	var/color = mix_color_from_reagents(chemholder.reagents.reagent_list)

	for(var/i=0, i<src.number, i++)
		if(holder)
			src.location = get_turf(holder)
		var/obj/effect/effect/smoke/chem/S = PoolOrNew(smoke_type, location)
		if(!direction)
			if(src.cardinals)
				S.direction = pick(cardinal)
			else
				S.direction = pick(alldirs)
		else
			S.direction = direction
		if(number<=5)
			S.steps = pick(0,1,1)
		else if(number<=10)
			S.steps = pick(0,1,1,1,2)
		else
			S.steps = pick(0,1,1,1,2,2,2,3)
		S.max_lifetime = Clamp(round(sqrt(chemholder.reagents.total_volume/2), 1), 4, 10) //the more chemicals, the longer the smoke duration.
		S.lifetime = S.max_lifetime

		if(chemholder.reagents.total_volume > 1) // can't split 1 very well
			chemholder.reagents.copy_to(S, chemholder.reagents.total_volume / number) // copy reagents to each smoke, divide evenly

		if(color)
			S.color = color // give the smoke color, if it has any to begin with
		else
			// if no color, just use the old smoke icon
			S.icon = 'icons/effects/96x96.dmi'
			S.icon_state = "smoke"

		S.process() //calling process right now so the smoke immediately attacks mobs.

/////////////////////////////////////////////
// Sleep smoke
/////////////////////////////////////////////

/obj/effect/effect/smoke/sleeping
	color = "#9C3636"

/obj/effect/effect/smoke/sleeping/process()
	for(var/mob/living/carbon/M in range(1,src))
		smoke_mob(M)

/obj/effect/effect/smoke/sleeping/smoke_mob(mob/living/carbon/M as mob)
	if(..())
		if(M.internal != null || (M.wear_mask && (M.wear_mask.flags & BLOCK_GAS_SMOKE_EFFECT)))
			return
		else
			M.drop_item()
			M.sleeping = max(M.sleeping,10)
			M.emote("cough")


/datum/effect/effect/system/smoke_spread/sleeping
	smoke_type = /obj/effect/effect/smoke/sleeping
	var/obj/chemholder
