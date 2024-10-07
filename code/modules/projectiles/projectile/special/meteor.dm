/obj/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"
	damage = 90
	paralyze = 100
	dismemberment = 90
	armour_penetration = 100
	damage_type = BRUTE
	armor_flag = BULLET

/obj/projectile/meteor/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(. == BULLET_ACT_HIT && isliving(target))
		explosion(target, devastation_range = -1, light_impact_range = 2, flame_range = 0, flash_range = 1, adminlog = FALSE)
		create_sound(target.loc, 'sound/effects/meteorimpact.ogg').volume(40).vary(TRUE).play()

/obj/projectile/meteor/Bump(atom/hit_target)
	if(hit_target == firer)
		forceMove(hit_target.loc)
		return
	if(isobj(hit_target))
		SSexplosions.med_mov_atom += hit_target
	if(isturf(hit_target))
		SSexplosions.medturf += hit_target
	create_sound(src.loc, 'sound/effects/meteorimpact.ogg').volume(40).vary(TRUE).play()
	for(var/mob/onlookers_in_range in urange(10, src))
		if(!onlookers_in_range.stat)
			shake_camera(onlookers_in_range, 3, 1)
	qdel(src)
