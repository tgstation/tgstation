/obj/item/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	possible_fuse_time = list("3", "4", "5")
	var/flashbang_range = 7 //how many tiles away the mob will be stunned.

/obj/item/grenade/flashbang/apply_grenade_fantasy_bonuses(quality)
	flashbang_range = modify_fantasy_variable("flashbang_range", flashbang_range, quality)

/obj/item/grenade/flashbang/remove_grenade_fantasy_bonuses(quality)
	flashbang_range = reset_fantasy_variable("flashbang_range", flashbang_range)

/obj/item/grenade/flashbang/detonate(mob/living/lanced_by)
	. = ..()
	if(!.)
		return

	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return
	do_sparks(rand(5, 9), FALSE, src)
	playsound(flashbang_turf, 'sound/items/weapons/flashbang.ogg', 100, TRUE, 8, 0.9)
	new /obj/effect/dummy/lighting_obj (flashbang_turf, flashbang_range + 2, 4, COLOR_WHITE, 2)
	for(var/mob/living/living_mob in get_hearers_in_view(flashbang_range, flashbang_turf))
		bang(get_turf(living_mob), living_mob)
	qdel(src)

/obj/item/grenade/flashbang/proc/bang(turf/turf, mob/living/living_mob)
	if(living_mob.stat == DEAD) //They're dead!
		return
	living_mob.show_message(span_warning("BANG"), MSG_AUDIBLE)
	var/distance = max(0, get_dist(get_turf(src), turf))

//Flash
	if(living_mob.flash_act(affect_silicon = 1))
		living_mob.Paralyze(max(20/max(1, distance), 5))
		living_mob.Knockdown(max(200/max(1, distance), 60))

//Bang
	if(!distance || loc == living_mob || loc == living_mob.loc)
		living_mob.Paralyze(20)
		living_mob.Knockdown(200)
		living_mob.soundbang_act(1, 200, 10, 15)
	else
		if(distance <= 1) // Adds more stun as to not prime n' pull (#45381)
			living_mob.Paralyze(5)
			living_mob.Knockdown(30)
		living_mob.soundbang_act(1, max(200 / max(1, distance), 60), rand(0, 5))

/obj/item/grenade/stingbang
	name = "stingbang"
	icon_state = "timeg_locked"
	base_icon_state = "timeg"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	var/flashbang_range = 1 //how many tiles away the mob will be stunned.
	shrapnel_type = /obj/projectile/bullet/pellet/stingball
	shrapnel_radius = 5
	custom_premium_price = PAYCHECK_COMMAND * 3.5 // mostly gotten through cargo, but throw in one for the sec vendor ;)

/obj/item/grenade/stingbang/mega
	name = "mega stingbang"
	icon_state = "timeg_mega_locked"
	base_icon_state = "timeg_mega"
	shrapnel_type = /obj/projectile/bullet/pellet/stingball/mega
	shrapnel_radius = 12

/obj/item/grenade/stingbang/detonate(mob/living/lanced_by)
	if(dud_flags)
		active = FALSE
		update_appearance()
		return FALSE

	if(iscarbon(loc))
		var/mob/living/carbon/user = loc
		var/obj/item/bodypart/bodypart = user.get_holding_bodypart_of_item(src)
		if(bodypart)
			forceMove(get_turf(user))
			user.visible_message("<b>[span_danger("[src] goes off in [user]'s hand, blowing [user.p_their()] [bodypart.plaintext_zone] to bloody shreds!")]</b>", span_userdanger("[src] goes off in your hand, blowing your [bodypart.plaintext_zone] to bloody shreds!"))
			bodypart.dismember()

	. = ..()
	if(!.)
		return


	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return
	do_sparks(rand(5, 9), FALSE, src)
	playsound(flashbang_turf, 'sound/items/weapons/flashbang.ogg', 50, TRUE, 8, 0.9)
	new /obj/effect/dummy/lighting_obj (flashbang_turf, flashbang_range + 2, 2, COLOR_WHITE, 1)
	for(var/mob/living/living_mob in get_hearers_in_view(flashbang_range, flashbang_turf))
		pop(get_turf(living_mob), living_mob)
	qdel(src)

/obj/item/grenade/stingbang/proc/pop(turf/turf, mob/living/living_mob)
	if(living_mob.stat == DEAD) //They're dead!
		return
	living_mob.show_message(span_warning("POP"), MSG_AUDIBLE)
	var/distance = max(0, get_dist(get_turf(src), turf))
//Flash
	if(living_mob.flash_act(affect_silicon = 1))
		living_mob.Paralyze(max(10/max(1, distance), 5))
		living_mob.Knockdown(max(100/max(1, distance), 60))

//Bang
	if(!distance || loc == living_mob || loc == living_mob.loc)
		living_mob.Paralyze(20)
		living_mob.Knockdown(200)
		living_mob.soundbang_act(1, 200, 10, 15)
		if(living_mob.apply_damages(brute = 10, burn = 10))
			to_chat(living_mob, span_userdanger("The blast from \the [src] bruises and burns you!"))

	// only checking if they're on top of the tile, cause being one tile over will be its own punishment

// Grenade that releases more shrapnel the more times you use it in hand between priming and detonation (sorta like the 9bang from MW3), for admin goofs
/obj/item/grenade/primer
	name = "rotfrag grenade"
	desc = "A grenade that generates more shrapnel the more you rotate it in your hand after pulling the pin. This one releases shrapnel shards."
	icon_state = "timeg_locked"
	base_icon_state = "timeg"
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
	if(!.)
		return

	qdel(src)

/obj/item/grenade/primer/stingbang
	name = "rotsting"
	desc = "A grenade that generates more shrapnel the more you rotate it in your hand after pulling the pin. This one releases stingballs."
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	rots_per_mag = 2
	shrapnel_type = /obj/projectile/bullet/pellet/stingball
