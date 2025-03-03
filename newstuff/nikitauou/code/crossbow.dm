/obj/item/ammo_casing/rebar/flame
	name = "Зажигательный болт"
	desc = "🔥"
	caliber = CALIBER_REBAR
	icon_state = "rod_flame"
	base_icon_state = "rod_flame"
	projectile_type = /obj/projectile/bullet/rebar/flame
	newtonian_force = 1.5

/obj/projectile/bullet/rebar/flame
	name = "Зажигательный болт"
	var/fire_stacks = 5
	damage = 15
	dismemberment = 0
	armour_penetration = 5

/obj/projectile/bullet/rebar/flame/impact(atom/target)
	.=..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(fire_stacks)
		M.ignite_mob()

/obj/item/ammo_casing/rebar/explosive
	name = "Разрывной болт"
	desc = "Действительно разрывной"
	caliber = CALIBER_REBAR
	icon_state = "rod_sharp"
	base_icon_state = "rod_sharp"
	projectile_type = /obj/projectile/bullet/rebar/explosive
	newtonian_force = 1.5

/obj/projectile/bullet/rebar/explosive
	name = "Разрывной болт"
	damage = 15
	dismemberment = 0
	armour_penetration = 5

/obj/projectile/bullet/rebar/explosive/impact(atom/target)
	.=..()
	explosion(target.loc, explosion_cause = src, flame_range = 1, flash_range = 1, light_impact_range = 1)
	qdel(src)
