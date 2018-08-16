//
// Size Gun
//
/*
/obj/item/gun/energy/sizegun
	name = "shrink ray"
	desc = "A highly advanced ray gun with two settings: Shrink and Grow. Warning: Do not insert into mouth."
	icon = 'icons/obj/gun_vr.dmi'
	icon_state = "sizegun-shrink100" // Someone can probably do better. -Ace
	item_state = null	//so the human update icon uses the icon_state instead
	fire_sound = 'sound/weapons/wave.ogg'
	charge_cost = 100
	projectile_type = /obj/item/projectile/beam/shrinklaser
	modifystate = "sizegun-shrink"
	selfcharge = 1
	firemodes = list(
		list(mode_name		= "grow",
			projectile_type	= /obj/item/projectile/beam/growlaser,
			modifystate		= "sizegun-grow",
			fire_sound		= 'sound/weapons/pulse3.ogg'
		),
		list(mode_name		= "shrink",
			projectile_type	= /obj/item/projectile/beam/shrinklaser,
			modifystate		= "sizegun-shrink",
			fire_sound		= 'sound/weapons/wave.ogg'
		))

//
// Beams for size gun
//
// tracers TBD

/obj/item/projectile/beam/shrinklaser
	name = "shrink beam"
	icon_state = "xray"
	nodamage = 1
	damage = 0
	check_armour = "laser"

	muzzle_type = /obj/effect/projectile/xray/muzzle
	tracer_type = /obj/effect/projectile/xray/tracer
	impact_type = /obj/effect/projectile/xray/impact

/obj/item/projectile/beam/shrinklaser/on_hit(var/atom/target, var/blocked = 0)
	if(istype(target, /mob/living))
		var/mob/living/M = target
		switch(M.size_multiplier)
			if(SIZESCALE_HUGE to INFINITY)
				M.sizescale(SIZESCALE_BIG)
			if(SIZESCALE_BIG to SIZESCALE_HUGE)
				M.sizescale(SIZESCALE_NORMAL)
			if(SIZESCALE_NORMAL to SIZESCALE_BIG)
				M.sizescale(SIZESCALE_SMALL)
			if((0 - INFINITY) to SIZESCALE_NORMAL)
				M.sizescale(SIZESCALE_TINY)
		M.update_transform()
	return 1

/obj/item/projectile/beam/growlaser
	name = "growth beam"
	icon_state = "bluelaser"
	nodamage = 1
	damage = 0
	check_armour = "laser"

	muzzle_type = /obj/effect/projectile/laser_blue/muzzle
	tracer_type = /obj/effect/projectile/laser_blue/tracer
	impact_type = /obj/effect/projectile/laser_blue/impact

/obj/item/projectile/beam/growlaser/on_hit(var/atom/target, var/blocked = 0)
	if(istype(target, /mob/living))
		var/mob/living/M = target
		switch(M.size_multiplier)
			if(SIZESCALE_BIG to SIZESCALE_HUGE)
				M.sizescale(SIZESCALE_HUGE)
			if(SIZESCALE_NORMAL to SIZESCALE_BIG)
				M.sizescale(SIZESCALE_BIG)
			if(SIZESCALE_SMALL to SIZESCALE_NORMAL)
				M.sizescale(SIZESCALE_NORMAL)
			if((0 - INFINITY) to SIZESCALE_TINY)
				M.sizescale(SIZESCALE_SMALL)
		M.update_transform()
	return 1
*/

datum/design/sizeray
	name = "Size Ray"
	desc = "Abuse bluespace tech to alter living matter scale."
	id = "sizeray"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000, MAT_DIAMOND = 2500, MAT_URANIUM = 2500, MAT_TITANIUM = 1000)
	build_path = /obj/item/gun/energy/laser/sizeray
	category = list("Weapons")

/obj/item/projectile/sizeray
	name = "sizeray beam"
	icon_state = "omnilaser"
	hitsound = null
	damage = 0
	damage_type = STAMINA
	flag = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

/obj/item/projectile/sizeray/shrinkray
	icon_state="bluelaser"

/obj/item/projectile/sizeray/growthray
	icon_state="laser"

/obj/item/projectile/sizeray/shrinkray/on_hit(var/atom/target, var/blocked = 0)
	if(istype(target, /mob/living))
		var/mob/living/M = target
		switch(M.size_multiplier)
			if(SIZESCALE_HUGE to INFINITY)
				M.sizescale(SIZESCALE_BIG)
			if(SIZESCALE_BIG to SIZESCALE_HUGE)
				M.sizescale(SIZESCALE_NORMAL)
			if(SIZESCALE_NORMAL to SIZESCALE_BIG)
				M.sizescale(SIZESCALE_SMALL)
			if((0 - INFINITY) to SIZESCALE_NORMAL)
				M.sizescale(SIZESCALE_TINY)
		M.update_transform()
	return 1

/obj/item/projectile/sizeray/growthray/on_hit(var/atom/target, var/blocked = 0)
	if(istype(target, /mob/living))
		var/mob/living/M = target
		switch(M.size_multiplier)
			if(SIZESCALE_BIG to SIZESCALE_HUGE)
				M.sizescale(SIZESCALE_HUGE)
			if(SIZESCALE_NORMAL to SIZESCALE_BIG)
				M.sizescale(SIZESCALE_BIG)
			if(SIZESCALE_SMALL to SIZESCALE_NORMAL)
				M.sizescale(SIZESCALE_NORMAL)
			if((0 - INFINITY) to SIZESCALE_TINY)
				M.sizescale(SIZESCALE_SMALL)
		M.update_transform()
	return 1

/obj/item/ammo_casing/energy/laser/growthray
	projectile_type = /obj/item/projectile/sizeray/growthray
	select_name = "Growth"

/obj/item/ammo_casing/energy/laser/shrinkray
	projectile_type = /obj/item/projectile/sizeray/shrinkray
	select_name = "Shrink"


//Gun here
/obj/item/gun/energy/laser/sizeray
	name = "size ray"
	icon_state = "bluetag"
	desc = "Size manipulator using bluespace breakthroughs."
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/laser/shrinkray, /obj/item/ammo_casing/energy/laser/growthray)
	selfcharge = 1
	charge_delay = 5
	ammo_x_offset = 2
	clumsy_check = 1

	attackby(obj/item/W, mob/user)
		if(W==src)
			if(icon_state=="bluetag")
				icon_state="redtag"
				ammo_type = list(/obj/item/ammo_casing/energy/laser/growthray)
			else
				icon_state="bluetag"
				ammo_type = list(/obj/item/ammo_casing/energy/laser/shrinkray)
		return ..()