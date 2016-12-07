/obj/machinery/gunfab_machine
	name = "Part Fabricator"
	desc = "our daddy taught us not to be ashamed of our guns"
	var/path_to_use = /obj/item/weapon/gun_attachment
	icon = 'goon/icons/obj/machinery.dmi'
	icon_state = "gunfab_machine"
	density = 1


/obj/machinery/gunfab_machine/attack_hand(mob/user)
	var/picked_part
	picked_part = input("Select part to print.", "Part Fabricator (BETA)", picked_part) in subtypesof(path_to_use)
	if(!picked_part)
		return
	else
		user << "you print [picked_part]"
		new picked_part(get_turf(src))
	return


/obj/machinery/gunfab_machine/frames
	name = "Part Fabricator (Frames)"
	desc = "I see you don't have a lifeguard at this gun crafting station."
	path_to_use = /obj/item/weapon/gun_attachment/frame

/obj/machinery/gunfab_machine/bases
	name = "Part Fabricator (Bases)"
	desc = "our daddy taught us not to be ashamed of our guns"
	path_to_use = /obj/item/weapon/gun_attachment/base

/obj/machinery/gunfab_machine/underbarrels
	name = "Part Fabricator (Underbarrels)"
	desc = "FREE TONTO"
	path_to_use = /obj/item/weapon/gun_attachment/underbarrel

/obj/machinery/gunfab_machine/barrels
	name = "Part Fabricator (Barrels)"
	desc = "FREE 2BEARD"
	path_to_use = /obj/item/weapon/gun_attachment/barrel

/obj/machinery/gunfab_machine/scopes
	name = "Part Fabricator (Scopes)"
	desc = "BAN CYFAUSE"
	path_to_use = /obj/item/weapon/gun_attachment/scope

/obj/machinery/gunfab_machine/handles
	name = "Part Fabricator (Handles)"
	desc = "What the fuck is carbon dioxide?"
	path_to_use = /obj/item/weapon/gun_attachment/handle

/obj/machinery/gunfab_machine/bullets
	name = "Part Fabricator (Bullets)"
	desc = "CHIPPO MAN"
	path_to_use = /obj/item/weapon/gun_attachment/bullet

/obj/machinery/gunfab_machine/energy_bullets
	name = "Part Fabricator (Energy Bullets)"
	desc = "TALES FROM 4CHAN"
	path_to_use = /obj/item/weapon/gun_attachment/energy_bullet


/obj/machinery/ammo_machine
	name = "Ammo Fabricator"
	desc = "our daddy taught us not to be ashamed of our guns"
	icon = 'goon/icons/obj/machinery.dmi'
	icon_state = "gunfab_machine"
	var/list/ammos = list(/obj/item/ammo_box/magazine/pistolm9mm)
	density = 1

/obj/machinery/ammo_machine/attack_hand(mob/user)
	var/picked_part
	picked_part = input("Select ammo to print.", "Ammo Fabricator (BETA)", picked_part) in ammos
	if(!picked_part)
		return
	else
		user << "you print [picked_part]"
		new picked_part(get_turf(src))
	return

