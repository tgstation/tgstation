/obj/item/weapon/gun_attachment
	name = "attach"
	icon = 'icons/obj/guncrafting/main.dmi'
	var/gun_type = BOTHTYPES
	var/image/my_overlay
	var/uses_overlay = TRUE

/obj/item/weapon/gun_attachment/proc/can_attach(var/obj/item/weapon/gun/owner)
	return (owner.customizable_type == gun_type || gun_type == BOTHTYPES)

/obj/item/weapon/gun_attachment/proc/on_attach(var/obj/item/weapon/gun/owner)
	if(uses_overlay)
		my_overlay = image('icons/obj/guncrafting/main.dmi',icon_state)
		my_overlay.color = color
		owner.overlays += my_overlay
	return

/obj/item/weapon/gun_attachment/proc/on_remove(var/obj/item/weapon/gun/owner)
	if(uses_overlay)
		owner.overlays -= my_overlay
	return

/obj/item/weapon/gun_attachment/proc/on_fire(var/obj/item/weapon/gun/owner, var/obj/item/projectile/bullet)
	return

/obj/item/weapon/gun_attachment/proc/on_tick(var/obj/item/weapon/gun/owner)
	return