/obj/item/weapon/storage/toolbox
	name = "toolbox"
	desc = "Danger. Very robust."
	icon = 'icons/obj/storage.dmi'
	icon_state = "red"
	item_state = "toolbox_red"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 7
	w_class = 4.0
	origin_tech = "combat=1"
	attack_verb = list("robusted")

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is [pick("stoving","robusting")] \his head in with the [src.name]! It looks like \he's  trying to commit suicide!</b>"
		return (BRUTELOSS)


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
		var/lighting = pick( //emergency lighting yay
			20;/obj/item/device/flashlight,
			30;/obj/item/weapon/storage/fancy/flares,
			50;/obj/item/device/flashlight/flare)
		new lighting(src)
		new /obj/item/device/radio(src)

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
	force = 7.0

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
