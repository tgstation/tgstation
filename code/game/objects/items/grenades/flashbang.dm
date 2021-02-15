/obj/item/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	var/flashbang_range = 7 //how many tiles away the mob will be stunned.

/obj/item/grenade/flashbang/detonate(mob/living/lanced_by)
	. = ..()
	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return
	do_sparks(rand(5, 9), FALSE, src)
	playsound(flashbang_turf, 'sound/weapons/flashbang.ogg', 100, TRUE, 8, 0.9)
	new /obj/effect/dummy/lighting_obj (flashbang_turf, flashbang_range + 2, 4, COLOR_WHITE, 2)
	for(var/mob/living/M in get_hearers_in_view(flashbang_range, flashbang_turf))
		bang(get_turf(M), M)
	qdel(src)

/obj/item/grenade/flashbang/proc/bang(turf/T , mob/living/M)
	if(M.stat == DEAD) //They're dead!
		return
	M.show_message("<span class='warning'>BANG</span>", MSG_AUDIBLE)
	var/distance = max(0,get_dist(get_turf(src),T))

//Flash
	if(M.flash_act(affect_silicon = 1))
		M.Paralyze(max(20/max(1,distance), 5))
		M.Knockdown(max(200/max(1,distance), 60))

//Bang
	if(!distance || loc == M || loc == M.loc) //Stop allahu akbarring rooms with this.
		M.Paralyze(20)
		M.Knockdown(200)
		M.soundbang_act(1, 200, 10, 15)
	else
		if(distance <= 1) // Adds more stun as to not prime n' pull (#45381)
			M.Paralyze(5)
			M.Knockdown(30)
		M.soundbang_act(1, max(200/max(1,distance), 60), rand(0, 5))

/obj/item/grenade/stingbang
	name = "stingbang"
	icon_state = "timeg"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	var/flashbang_range = 1 //how many tiles away the mob will be stunned.
	shrapnel_type = /obj/projectile/bullet/pellet/stingball
	shrapnel_radius = 5
	custom_premium_price = PAYCHECK_HARD * 3.5 // mostly gotten through cargo, but throw in one for the sec vendor ;)

/obj/item/grenade/stingbang/mega
	name = "mega stingbang"
	shrapnel_type = /obj/projectile/bullet/pellet/stingball/mega
	shrapnel_radius = 12

/obj/item/grenade/stingbang/detonate(mob/living/lanced_by)
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		var/obj/item/bodypart/B = C.get_holding_bodypart_of_item(src)
		if(B)
			forceMove(get_turf(C))
			C.visible_message("<b><span class='danger'>[src] goes off in [C]'s hand, blowing [C.p_their()] [B.name] to bloody shreds!</span></b>", "<span class='userdanger'>[src] goes off in your hand, blowing your [B.name] to bloody shreds!</span>")
			B.dismember()

	. = ..()

	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return
	do_sparks(rand(5, 9), FALSE, src)
	playsound(flashbang_turf, 'sound/weapons/flashbang.ogg', 50, TRUE, 8, 0.9)
	new /obj/effect/dummy/lighting_obj (flashbang_turf, flashbang_range + 2, 2, COLOR_WHITE, 1)
	for(var/mob/living/M in get_hearers_in_view(flashbang_range, flashbang_turf))
		pop(get_turf(M), M)
	qdel(src)

/obj/item/grenade/stingbang/proc/pop(turf/T , mob/living/M)
	if(M.stat == DEAD) //They're dead!
		return
	M.show_message("<span class='warning'>POP</span>", MSG_AUDIBLE)
	var/distance = max(0,get_dist(get_turf(src),T))
//Flash
	if(M.flash_act(affect_silicon = 1))
		M.Paralyze(max(10/max(1,distance), 5))
		M.Knockdown(max(100/max(1,distance), 60))

//Bang
	if(!distance || loc == M || loc == M.loc)
		M.Paralyze(20)
		M.Knockdown(200)
		M.soundbang_act(1, 200, 10, 15)
		if(M.apply_damages(10, 10))
			to_chat(M, "<span class='userdanger'>The blast from \the [src] bruises and burns you!</span>")

	// only checking if they're on top of the tile, cause being one tile over will be its own punishment

// Grenade that releases more shrapnel the more times you use it in hand between priming and detonation (sorta like the 9bang from MW3), for admin goofs
/obj/item/grenade/primer
	name = "rotfrag grenade"
	desc = "A grenade that generates more shrapnel the more you rotate it in your hand after pulling the pin. This one releases shrapnel shards."
	icon_state = "timeg"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	var/rots_per_mag = 3 /// how many times we need to "rotate" the charge in hand per extra tile of magnitude
	shrapnel_type = /obj/projectile/bullet/shrapnel
	var/rots = 1 /// how many times we've "rotated" the charge

/obj/item/grenade/primer/attack_self(mob/user)
	. = ..()
	if(active)
		user.playsound_local(user, 'sound/misc/box_deploy.ogg', 50, TRUE)
		rots++
		user.changeNext_move(CLICK_CD_RAPID)

/obj/item/grenade/primer/detonate(mob/living/lanced_by)
	shrapnel_radius = round(rots / rots_per_mag)
	. = ..()
	qdel(src)

/obj/item/grenade/primer/stingbang
	name = "rotsting"
	desc = "A grenade that generates more shrapnel the more you rotate it in your hand after pulling the pin. This one releases stingballs."
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	rots_per_mag = 2
	shrapnel_type = /obj/projectile/bullet/pellet/stingball
