/obj/item/weapon/storage/toolbox
	name = "toolbox"
	desc = "Danger. Very robust."
	icon = 'icons/obj/storage.dmi'
	icon_state = "red"
	item_state = "toolbox_red"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 10.0
	throwforce = 15.0
	throw_speed = 1
	throw_range = 7
	w_class = 4.0
	origin_tech = "combat=1"
	attack_verb = list("robusted")

	New()
		..()
		if (src.type == /obj/item/weapon/storage/toolbox)
			world << "BAD: [src] ([src.type]) spawned at [src.x] [src.y] [src.z]"
			del(src)

/obj/item/weapon/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "red"
	item_state = "toolbox_red"

	New()
		..()
		new /obj/item/weapon/crowbar/red(src)
		new /obj/item/weapon/extinguisher/mini(src)
		if(prob(50))
			new /obj/item/device/flashlight(src)
		else
			new /obj/item/device/flashlight/flare(src)
		new /obj/item/device/radio/off(src)

/obj/item/weapon/storage/toolbox/mechanical
	name = "mechanical toolbox"
	icon_state = "blue"
	item_state = "toolbox_blue"

	New()
		..()
		new /obj/item/weapon/screwdriver(src)
		new /obj/item/weapon/wrench(src)
		new /obj/item/weapon/weldingtool(src)
		new /obj/item/weapon/crowbar(src)
		new /obj/item/device/analyzer(src)
		new /obj/item/weapon/wirecutters(src)

/obj/item/weapon/storage/toolbox/electrical
	name = "electrical toolbox"
	icon_state = "yellow"
	item_state = "toolbox_yellow"

	New()
		..()
		var/color = pick("red","yellow","green","blue","pink","orange","cyan","white")
		new /obj/item/weapon/screwdriver(src)
		new /obj/item/weapon/wirecutters(src)
		new /obj/item/device/t_scanner(src)
		new /obj/item/weapon/crowbar(src)
		new /obj/item/weapon/cable_coil(src,30,color)
		new /obj/item/weapon/cable_coil(src,30,color)
		if(prob(5))
			new /obj/item/clothing/gloves/yellow(src)
		else
			new /obj/item/weapon/cable_coil(src,30,color)

/obj/item/weapon/storage/toolbox/syndicate
	name = "suspicious looking toolbox"
	icon_state = "syndicate"
	item_state = "toolbox_syndi"
	origin_tech = "combat=1;syndicate=1"
	force = 15.0
	throwforce = 18.0

	New()
		..()
		var/color = pick("red","yellow","green","blue","pink","orange","cyan","white")
		new /obj/item/weapon/screwdriver(src)
		new /obj/item/weapon/wrench(src)
		new /obj/item/weapon/weldingtool(src)
		new /obj/item/weapon/crowbar(src)
		new /obj/item/weapon/cable_coil(src,30,color)
		new /obj/item/weapon/wirecutters(src)
		new /obj/item/device/multitool(src)
