/obj/item/weapon/gun_attachment
	name = "attach"
	icon = 'icons/obj/guncrafting/ausops_new.dmi'
	var/gun_type = BOTHTYPES
	var/image/my_overlay
	var/uses_overlay = TRUE
	var/not_okay = /obj/item/weapon/gun_attachment
	var/no_revolver = 1
	var/list/random_sprite

/obj/item/weapon/gun_attachment/New()
	..()
	if(random_sprite)
		icon_state = "[icon_state][rand(random_sprite[1], random_sprite[2])]"

/obj/item/weapon/gun_attachment/proc/can_attach(var/obj/item/weapon/gun/owning_gun)
	if(gun_type == BOTHTYPES)
		if(owning_gun.customizable_type == CUSTOMIZABLE_REVOLVER && !no_revolver)
			return 1
		if(owning_gun.customizable_type == CUSTOMIZABLE_ENERGY || owning_gun.customizable_type == CUSTOMIZABLE_PROJECTILE)
			return 1
		return 0
	switch(gun_type)
		if(CUSTOMIZABLE_ENERGY)
			if(owning_gun.customizable_type == CUSTOMIZABLE_ENERGY)
				return 1
		if(CUSTOMIZABLE_PROJECTILE)
			if(owning_gun.customizable_type == CUSTOMIZABLE_PROJECTILE || (owning_gun.customizable_type == CUSTOMIZABLE_REVOLVER && !no_revolver))
				return 1
		if(CUSTOMIZABLE_REVOLVER)
			if(owning_gun.customizable_type == CUSTOMIZABLE_REVOLVER)
				return 1
	return 0

/obj/item/weapon/gun_attachment/proc/on_attach(var/obj/item/weapon/gun/owning_gun)
	return

/obj/item/weapon/gun_attachment/proc/on_remove(var/obj/item/weapon/gun/owning_gun)
	return

/obj/item/weapon/gun_attachment/proc/on_fire(var/obj/item/weapon/gun/owning_gun, var/obj/item/projectile/temp_bullet)
	return

/obj/item/weapon/gun_attachment/proc/on_tick(var/obj/item/weapon/gun/owning_gun)
	return

/obj/item/weapon/gun_attachment/proc/on_hit(var/mob/target, var/mob/firer)
	return