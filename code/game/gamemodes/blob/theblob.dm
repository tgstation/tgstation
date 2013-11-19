//I will need to recode parts of this but I am way too tired atm
/obj/effect/blob
	name = "blob"
	icon = 'icons/mob/blob.dmi'
	luminosity = 3
	desc = "Some blob creature thingy"
	density = 0
	opacity = 0
	anchored = 1
	var/health = 30
	var/health_timestamp = 0
	var/brute_resist = 4
	var/fire_resist = 1


/obj/effect/blob/New(loc)
	blobs += src
	src.dir = pick(1, 2, 4, 8)
	src.update_icon()
	..(loc)
	for(var/atom/A in loc)
		A.blob_act()
	return


/obj/effect/blob/Del()
	blobs -= src
	..()
	return


/obj/effect/blob/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0))	return 1
	if(istype(mover) && mover.checkpass(PASSBLOB))	return 1
	return 0


/obj/effect/blob/process()
	Life()
	return

/obj/effect/blob/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	var/damage = Clamp(0.01 * exposed_temperature / fire_resist, 0, 4 - fire_resist)
	if(damage)
		health -= damage
		update_icon()

/obj/effect/blob/proc/Life()
	return

/obj/effect/blob/proc/PulseAnimation()
	flick("[icon_state]_glow", src)
	return

/obj/effect/blob/proc/RegenHealth()
	// All blobs heal over time when pulsed, but it has a cool down
	if(health_timestamp > world.time)
		return 0
	if(health < initial(health))
		health++
		update_icon()
		health_timestamp = world.time + 10 // 1 seconds


/obj/effect/blob/proc/Pulse(var/pulse = 0, var/origin_dir = 0)//Todo: Fix spaceblob expand

	set background = 1

	PulseAnimation()

	RegenHealth()

	if(run_action())//If we can do something here then we dont need to pulse more
		return

	if(pulse > 30)
		return//Inf loop check

	//Looking for another blob to pulse
	var/list/dirs = list(1,2,4,8)
	dirs.Remove(origin_dir)//Dont pulse the guy who pulsed us
	for(var/i = 1 to 4)
		if(!dirs.len)	break
		var/dirn = pick(dirs)
		dirs.Remove(dirn)
		var/turf/T = get_step(src, dirn)
		var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)
		if(!B)
			expand(T)//No blob here so try and expand
			return
		B.Pulse((pulse+1),get_dir(src.loc,T))
		return
	return


/obj/effect/blob/proc/run_action()
	return 0


/obj/effect/blob/proc/expand(var/turf/T = null, var/prob = 1)
	if(prob && !prob(health))	return
	if(istype(T, /turf/space) && prob(75)) 	return
	if(!T)
		var/list/dirs = list(1,2,4,8)
		for(var/i = 1 to 4)
			var/dirn = pick(dirs)
			dirs.Remove(dirn)
			T = get_step(src, dirn)
			if(!(locate(/obj/effect/blob) in T))	break
			else	T = null

	if(!T)	return 0
	var/obj/effect/blob/normal/B = new /obj/effect/blob/normal(src.loc, min(src.health, 30))
	B.density = 1
	if(T.Enter(B,src))//Attempt to move into the tile
		B.density = initial(B.density)
		B.loc = T
	else
		T.blob_act()//If we cant move in hit the turf
		B.Delete()

	for(var/atom/A in T)//Hit everything in the turf
		A.blob_act()
	return 1

/obj/effect/blob/ex_act(severity)
	var/damage = 150
	health -= ((damage/brute_resist) - (severity * 5))
	update_icon()
	return


/obj/effect/blob/bullet_act(var/obj/item/projectile/Proj)
	..()
	switch(Proj.damage_type)
	 if(BRUTE)
		 health -= (Proj.damage/brute_resist)
	 if(BURN)
		 health -= (Proj.damage/fire_resist)

	update_icon()
	return 0

/obj/effect/blob/Crossed(var/mob/living/L)
	..()
	L.blob_act()


/obj/effect/blob/attackby(var/obj/item/weapon/W, var/mob/user)
	playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
	src.visible_message("\red <B>The [src.name] has been attacked with \the [W][(user ? " by [user]." : ".")]")
	var/damage = 0
	switch(W.damtype)
		if("fire")
			damage = (W.force / max(src.fire_resist,1))
			if(istype(W, /obj/item/weapon/weldingtool))
				playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
		if("brute")
			damage = (W.force / max(src.brute_resist,1))

	health -= damage
	update_icon()
	return

/obj/effect/blob/attack_animal(mob/living/simple_animal/M as mob)
	playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
	src.visible_message("\red <B>The [src.name] has been attacked by \the [M].")
	var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
	if(!damage) // Avoid divide by zero errors
		return
	damage /= max(src.brute_resist, 1)
	health -= damage
	update_icon()
	return

/obj/effect/blob/proc/change_to(var/type)
	if(!ispath(type))
		error("[type] is an invalid type for the blob.")
	new type(src.loc)
	Delete()
	return

/obj/effect/blob/proc/Delete()
	del(src)

/obj/effect/blob/normal
	icon_state = "blob"
	luminosity = 0
	health = 21

/obj/effect/blob/normal/Delete()
	src.loc = null
	blobs -= src

/obj/effect/blob/normal/update_icon()
	if(health <= 0)
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
		Delete()
	else if(health <= 15)
		icon_state = "blob_damaged"
	else
		icon_state = "blob"

/* // Used to create the glow sprites. Remember to set the animate loop to 1, instead of infinite!

var/datum/blob_colour/B = new()

/datum/blob_colour/New()
	..()
	var/icon/I = 'icons/mob/blob.dmi'
	I += rgb(35, 35, 0)
	if(isfile("icons/mob/blob_result.dmi"))
		fdel("icons/mob/blob_result.dmi")
	fcopy(I, "icons/mob/blob_result.dmi")

*/