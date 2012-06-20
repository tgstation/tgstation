/obj/item/clothing/head/det_hat
	name = "detective's hat"
	desc = "Someone who wears this will look very smart."
	icon_state = "detective"
	allowed = list(/obj/item/weapon/reagent_containers/food/snacks/candy_corn, /obj/item/weapon/pen)
	armor = list(melee = 50, bullet = 5, laser = 25,energy = 10, bomb = 0, bio = 0, rad = 0)


/obj/item/clothing/suit/storage/det_suit
	name = "detective's coat"
	desc = "An 18th-century multi-purpose trenchcoat. Someone who wears this means serious business."
	icon_state = "detective"
	item_state = "det_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/weapon/tank/emergency_oxygen, /obj/item/device/flashlight,/obj/item/weapon/gun/energy,/obj/item/weapon/gun/projectile,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/cigpacket,/obj/item/weapon/lighter,/obj/item/device/detective_scanner,/obj/item/device/taperecorder,/obj/item/taperoll/police)
	armor = list(melee = 50, bullet = 10, laser = 25, energy = 10, bomb = 0, bio = 0, rad = 0)


/obj/item/clothing/suit/det_suit/armor
	name = "detective's armor"
	desc = "An armored vest with a detective's badge on it."
	icon_state = "detective-armor"
	item_state = "armor"
	flags = FPRINT | TABLEPASS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/gun/projectile,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/taperoll/police)
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)

/obj/item/clothing/under/det/verb/holster()
	set name = "Holster"
	set category = "Object"
	set src in usr

	if(!gun)
		if(istype(usr.get_active_hand(),/obj/item/weapon/gun/projectile/detective) || istype(usr.get_active_hand(),/obj/item/weapon/gun/energy/stunrevolver))
			gun = usr.get_active_hand()
			usr.drop_item()
			gun.loc = src
			for(var/mob/M in viewers(usr, null))
				if(M.client)
					M.show_message(text("\blue [usr] holsters his gun."), 2)
		else
			usr << "\blue You need your gun equiped to holster it."
	else
		if(istype(usr.get_active_hand(),/obj) && istype(usr.get_inactive_hand(),/obj))
			usr << "\red If you want your gun from your holster, you need an empty hand!"
		else
			usr.put_in_hand(gun)
			icon_state = "detective"
			gun = null
			if(usr.a_intent == "hurt")
				for(var/mob/M in viewers(usr, null))
					if(M.client)
						M.show_message(text("\red [usr] draws his gun, and readies it for use!"), 2)
			else
				for(var/mob/M in viewers(usr, null))
					if(M.client)
						M.show_message(text("\blue [usr] draws his gun, but keeps it pointed safely at the ground."), 2)
