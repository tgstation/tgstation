/obj/item/weapon/gun_attachment
	name = "attach"
	icon = 'icons/obj/guncrafting/main.dmi'
	var/gun_type = BOTHTYPES
	var/image/my_overlay
	var/uses_overlay = TRUE

/obj/item/weapon/gun_attachment/proc/can_attach(var/obj/item/weapon/gun/owning_gun) // Sorry but if I don't put a var in front of these it gives me duplicate definition errors pointing to here
	return (owning_gun.customizable_type == gun_type || gun_type == BOTHTYPES)

/obj/item/weapon/gun_attachment/proc/on_attach(var/obj/item/weapon/gun/owning_gun)
	if(uses_overlay)
		my_overlay = image('icons/obj/guncrafting/main.dmi',icon_state)
		my_overlay.color = color
		owning_gun.overlays += my_overlay

/obj/item/weapon/gun_attachment/proc/on_remove(var/obj/item/weapon/gun/owning_gun)
	if(uses_overlay)
		owning_gun.overlays -= my_overlay

/obj/item/weapon/gun_attachment/proc/on_fire(var/obj/item/weapon/gun/owning_gun, var/obj/item/projectile/temp_bullet)
	return

/obj/item/weapon/gun_attachment/proc/on_tick(var/obj/item/weapon/gun/owning_gun)
	return