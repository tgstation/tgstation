/obj/item/weapon/storage/toolbox
	name = "toolbox"
	desc = "Danger. Very robust."
	icon = 'icons/obj/storage.dmi'
	icon_state = "red"
	item_state = "toolbox_red"
	flags = FPRINT
	siemens_coefficient = 1
	force = 12.0
	hitsound = 'sound/weapons/toolbox.ogg'
	throwforce = 10.0
	throw_speed = 1
	throw_range = 7
	starting_materials = list(MAT_IRON = 5000)
	w_type = RECYK_METAL
	w_class = 4.0
	melt_temperature = MELTPOINT_STEEL
	origin_tech = "combat=1"
	attack_verb = list("robusted", "battered", "staved in")


/obj/item/weapon/storage/toolbox/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is [pick("staving","robusting")] \his head in with the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (BRUTELOSS)


/obj/item/weapon/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "red"
	item_state = "toolbox_red"

/obj/item/weapon/storage/toolbox/emergency/New()
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

/obj/item/weapon/storage/toolbox/mechanical/New()
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

/obj/item/weapon/storage/toolbox/electrical/New()
	..()
	var/color = pick("red","yellow","green","blue","pink","orange","cyan","white")
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/t_scanner(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/stack/cable_coil(src,30,color)
	new /obj/item/stack/cable_coil(src,30,color)
	if(prob(5))
		new /obj/item/clothing/gloves/yellow(src)
	else
		new /obj/item/stack/cable_coil(src,30,color)

/obj/item/weapon/storage/toolbox/syndicate
	name = "suspicious looking toolbox"
	icon_state = "syndicate"
	item_state = "toolbox_syndi"
	origin_tech = "combat=1;syndicate=1"
	force = 15.0

/obj/item/weapon/storage/toolbox/syndicate/New()
	..()
	var/color = pick("red","yellow","green","blue","pink","orange","cyan","white")
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/stack/cable_coil(src,30,color)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/multitool(src)
