/obj/item/gun/ballistic/revolver/hunter_revolver
	name = "\improper Hunter's Revolver"
	desc = "Does minimal damage but slows down the enemy."
	icon_state = "revolver"
	icon = 'monkestation/icons/bloodsuckers/weapons.dmi'
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/bloodsilver
	initial_caliber = CALIBER_BLOODSILVER

/datum/movespeed_modifier/silver_bullet
	movetypes = GROUND
	multiplicative_slowdown = 4
	flags = IGNORE_NOSLOW

/obj/item/ammo_box/magazine/internal/cylinder/bloodsilver
	name = "detective revolver cylinder"
	ammo_type = /obj/item/ammo_casing/silver
	caliber = CALIBER_BLOODSILVER
	max_ammo = 2

/obj/item/ammo_casing/silver
	name = "Bloodsilver casing"
	desc = "A Bloodsilver bullet casing."
	icon_state = "bloodsilver"
	icon = 'monkestation/icons/bloodsuckers/weapons.dmi'
	projectile_type = /obj/projectile/bullet/bloodsilver
	caliber = CALIBER_BLOODSILVER

/obj/projectile/bullet/bloodsilver
	name = "Bloodsilver bullet"
	damage = 3
	ricochets_max = 4

/obj/projectile/bullet/bloodsilver/on_hit(mob/living/carbon/target, blocked = 0, pierce_hit)
	. = ..()
	if(!iscarbon(target) || QDELING(target) || target.has_movespeed_modifier(/datum/movespeed_modifier/silver_bullet) || !is_monster_hunter_prey(target))
		return
	target.add_movespeed_modifier(/datum/movespeed_modifier/silver_bullet)
	if(!(target.has_movespeed_modifier(/datum/movespeed_modifier/silver_bullet)))
		return
	addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/silver_bullet), 8 SECONDS)
