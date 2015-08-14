/obj/item/weapon/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	item_state = "flashbang"
	origin_tech = "materials=2;combat=1"

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

/obj/item/weapon/grenade/flashbang/proc/bang(turf/T , mob/living/M)
	M.show_message("<span class='warning'>BANG</span>", 2)
	playsound(loc, 'sound/effects/bang.ogg', 25, 1)

//Checking for protection
	var/ear_safety = M.check_ear_prot()
	var/distance = max(1,get_dist(src,T))

//Flash
	if(M.weakeyes)
		M.visible_message("<span class='disarm'><b>[M]</b> screams and collapses!</span>")
		M << "<span class='userdanger'><font size=3>AAAAGH!</font></span>"
		M.Weaken(15) //hella stunned
		M.Stun(15)
		M.eye_stat += 8

	if(M.flash_eyes())
		M.eye_stat += rand(1, 3)
		M.Stun(max(10/distance, 3))
		M.Weaken(max(10/distance, 3))


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
			if(prob(M.ear_damage - 10 + 5))
				M << "<span class='warning'>You can't hear anything!</span>"
				M.disabilities |= DEAF
		else
			if (M.ear_damage >= 5)
				M << "<span class='warning'>Your ears start to ring!</span>"
