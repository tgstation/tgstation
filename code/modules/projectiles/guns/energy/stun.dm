/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "A low-capacity, energy-based stun gun used by security teams to subdue targets at range."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/electrode)
	ammo_x_offset = 3

/obj/item/weapon/gun/energy/shock_revolver
	name = "tesla gun"
	desc = "An experimental gun based on an experimental engine, it's about as likely to kill it's operator as it is the target."
	icon_state = "tesla"
	item_state = "tesla"
	ammo_type = list(/obj/item/ammo_casing/energy/shock_revolver)
	can_flashlight = 0
	pin = null
	shaded_charge = 1

/obj/item/weapon/gun/energy/gun/advtaser
	name = "hybrid taser"
	desc = "A dual-mode taser designed to fire both short-range high-power electrodes and long-range disabler beams."
	icon_state = "advtaser"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler)
	origin_tech = null
	ammo_x_offset = 2

/obj/item/weapon/gun/energy/gun/advtaser/cyborg
	name = "cyborg taser"
	desc = "An integrated hybrid taser that draws directly from a cyborg's power cell. The weapon contains a limiter to prevent the cyborg's power cell from overheating."
	can_flashlight = 0
	can_charge = 0

/obj/item/weapon/gun/energy/gun/advtaser/cyborg/newshot()
	..()
	robocharge()

/obj/item/weapon/gun/energy/disabler
	name = "disabler"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse."
	icon_state = "disabler"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 3

/obj/item/weapon/gun/energy/disabler/cyborg
	name = "cyborg disabler"
	desc = "An integrated disabler that draws from a cyborg's power cell. This weapon contains a limiter to prevent the cyborg's power cell from overheating."
	can_charge = 0

/obj/item/weapon/gun/energy/disabler/cyborg/newshot()
	..()
	robocharge()

//A realistic, cartridge-based taser that must use disposable cartridges.
/obj/item/weapon/gun/energy/realtaser
	name = "taser"
	desc = "A single shot stun weapon that runs on disposable cartridges."
	icon_state = "realtaser"
	item_state = "gun"
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/shotgun)
	can_charge = 0
	can_flashlight = 0
	cell_type = /obj/item/weapon/stock_parts/cell/stuncartridge

/obj/item/weapon/gun/energy/realtaser/update_icon()
	overlays.Cut()
	if(power_supply)
		if(power_supply.charge == power_supply.maxcharge)
			overlays += "[icon_state]-loaded"
		else
			overlays += "[icon_state]-loaded-e"

/obj/item/weapon/gun/energy/realtaser/attack_self(var/mob/living/carbon/user)
	. = ..()
	if(.)
		return
	if(power_supply)
		remove_cartridge(user, 0)
		update_icon()

/obj/item/weapon/gun/energy/realtaser/attackby(obj/item/C, mob/user, params)
	. = ..()
	if(.)
		return
	if(istype(C, /obj/item/weapon/stock_parts/cell/stuncartridge))
		add_cartridge(user, C)
		update_icon()

/obj/item/weapon/gun/energy/realtaser/proc/add_cartridge(var/mob/living/carbon/user, obj/item/C)
	if(power_supply)
		if(power_supply.charge == power_supply.maxcharge)
			user << "<span class='notice'>The [src.name] already has a cartridge loaded.</span>"
		else
			user << "<span class='warning'>You begin replacing the cartridge...</span>"
			if(do_after(usr, 50, target = src))
				if(!user.drop_item())
					return
				remove_cartridge(user, 1)
				power_supply = C
				C.loc = src
				update_icon()
	else
		user << "<span class='warning'>You begin loading the taser...</span>"
		if(do_after(usr, 50, target = src))
			if(!user.drop_item())
				return
			power_supply = C
			C.loc = src
			update_icon()

/obj/item/weapon/gun/energy/realtaser/proc/remove_cartridge(var/mob/living/carbon/user, var/replace)
	if(power_supply)
		power_supply.update_icon()
		power_supply.loc = get_turf(src.loc)
		if(replace) //drop the cartridge on the ground
			user << "<span class='notice'>You replace the cartridge on [src].</span>"
		else //put the cartridge in the user's hands or the ground
			user << "<span class='notice'>The cartridge pops off [src].</span>"
			user.put_in_hands(power_supply)
		power_supply = null
		update_icon()