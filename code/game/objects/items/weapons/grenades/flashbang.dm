/obj/item/weapon/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	item_state = "flashbang"
	origin_tech = "materials=2;combat=1"
	var/banglet = 0

/obj/item/weapon/grenade/flashbang/prime()
	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return
	for(var/mob/living/M in get_hearers_in_view(7, flashbang_turf))
		bang(get_turf(M), M)

	for(var/obj/effect/blob/B in get_hear(8,flashbang_turf))     		//Blob damage here
		var/damage = round(30/(get_dist(B,get_turf(src))+1))
		B.health -= damage
		B.update_icon()
	qdel(src)

/obj/item/weapon/grenade/flashbang/proc/bang(var/turf/T , var/mob/living/M)
	M.show_message("<span class='warning'>BANG</span>", 2)
	playsound(loc, 'sound/effects/bang.ogg', 25, 1)

//Checking for protections
	var/eye_safety = 0
	var/ear_safety = 0
	var/distance = max(1,get_dist(src,T))
	var/takes_eye_damage = 0
	if(iscarbon(M))
		takes_eye_damage++
		var/mob/living/carbon/C = M
		eye_safety = C.eyecheck()
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if((H.ears && (H.ears.flags & EARBANGPROTECT)) || (H.head && (H.head.flags & HEADBANGPROTECT)))
				ear_safety++

//Flash
	if(!eye_safety)
		flick("e_flash", M.flash)
		M.eye_stat += rand(1, 3)
		M.Stun(max(10/distance, 3))
		M.Weaken(max(10/distance, 3))
		if (M.eye_stat >= 20 && takes_eye_damage)
			M << "<span class='warning'>Your eyes start to burn badly!</span>"
			M.disabilities |= NEARSIGHT
			if(!banglet)
				if (prob(M.eye_stat - 20 + 1))
					M << "<span class='warning'>You can't see anything!</span>"
					M.disabilities |= BLIND

//Bang
	if((loc == M) || loc == M.loc)//Holding on person or being exactly where lies is significantly more dangerous and voids protection
		M.Stun(10)
		M.Weaken(10)
	if(!ear_safety)
		M.Stun(max(10/distance, 3))
		M.Weaken(max(10/distance, 3))
		M.setEarDamage(M.ear_damage + rand(0, 5), max(M.ear_deaf,15))
		if (M.ear_damage >= 15)
			M << "<span class='warning'>Your ears start to ring badly!</span>"
			if(!banglet)
				if(prob(M.ear_damage - 10 + 5))
					M << "<span class='warning'>You can't hear anything!</span>"
					M.disabilities |= DEAF
		else
			if (M.ear_damage >= 5)
				M << "<span class='warning'>Your ears start to ring!</span>"
