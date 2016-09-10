/obj/item/weapon/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	item_state = "flashbang"
	origin_tech = "materials=2;combat=3"

/obj/item/weapon/grenade/flashbang/prime()
	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return
	for(var/mob/living/M in get_hearers_in_view(7, flashbang_turf))
		bang(get_turf(M), M)

	for(var/obj/effect/blob/B in get_hear(8,flashbang_turf))     		//Blob damage here
		var/distance = get_dist(B, get_turf(src))
		var/damage = round(100/(distance*distance)+1)
		B.take_damage(damage, BURN)
	qdel(src)

/obj/item/weapon/grenade/flashbang/proc/bang(turf/T , mob/living/M)
	M.show_message("<span class='warning'>BANG</span>", 2)
	playsound(loc, 'sound/weapons/flashbang.ogg', 100, 1)

	var/distance = max(1,get_dist(src,T))

//Flash
	if(M.weakeyes)
		M.visible_message("<span class='disarm'><b>[M]</b> screams and collapses!</span>")
		M << "<span class='userdanger'><font size=3>AAAAGH!</font></span>"
		M.Weaken(15) //hella stunned
		M.Stun(15)
		M.adjust_eye_damage(8)

	if(M.flash_act(affect_silicon = 1))
		M.Stun(max(10/distance, 3))
		M.Weaken(max(10/distance, 3))

//Bang
	if((loc == M) || loc == M.loc)//Holding on person or being exactly where lies is significantly more dangerous and voids protection
		M.soundbang_act(1, 10, rand(5, 10))
	else
		M.soundbang_act(1, max(10/distance, 3), rand(0, 5))
