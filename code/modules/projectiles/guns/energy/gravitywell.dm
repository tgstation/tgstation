/obj/item/weapon/gun/gravitywell	//-by Deity Link
	name = "\improper Gravity Well Gun"
	desc = "Whoever created that gun had a taste for organized chaos..."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "gravitywell"
	item_state = "gravitywell"
	slot_flags = SLOT_BELT
	origin_tech = "materials=7;bluespace=5;magnets=5"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 0
	flags = FPRINT
	w_class = 3.0
	fire_delay = 0
	fire_sound = 'sound/weapons/wave.ogg'
	var/charge = 100
	var/maxcharge = 100//admins can varedit this var to 0 to allow the gun to fire non-stop. I decline all responsibilities for lag-induced server crashes caused by gravity wells spam.

/obj/item/weapon/gun/gravitywell/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>Charge = [charge]%</span>")

/obj/item/weapon/gun/gravitywell/Destroy()
	if(charge < maxcharge)
		processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/gravitywell/process_chambered()
	if(in_chamber) return 1
	if(charge >= maxcharge)
		charge = 0
		update_icon()
		in_chamber = new/obj/item/projectile/gravitywell()
		processing_objects.Add(src)
		return 1
	return 0

/obj/item/weapon/gun/gravitywell/process()//it takes 100 seconds to recharge and be able to fire again
	charge = min(maxcharge,charge+1)
	if(charge >= maxcharge)
		update_icon()
		if(istype(loc,/mob))
			var/mob/M = loc
			M.regenerate_icons()
		processing_objects.Remove(src)
	return 1

/obj/item/weapon/gun/gravitywell/update_icon()
	if(charge == maxcharge)
		icon_state = "gravitywell"
		item_state = "gravitywell"
	else
		icon_state = "gravitywell0"
		item_state = "gravitywell0"
