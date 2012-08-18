/obj/item/weapon/hive_module
	name = "hive robot module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT|TABLEPASS | CONDUCT
	var/list/modules = list()

/obj/item/weapon/hive_module/standard
	name = "give standard robot module"

/obj/item/weapon/hive_module/engineering
	name = "HiveBot engineering robot module"

/obj/item/weapon/hive_module/New()//Shit all the mods have
	src.modules += new /obj/item/device/flash(src)


/obj/item/weapon/hive_module/standard/New()
	..()
	src.modules += new /obj/item/weapon/melee/baton(src)
	src.modules += new /obj/item/weapon/extinguisher(src)
	//var/obj/item/weapon/gun/mp5/M = new /obj/item/weapon/gun/mp5(src)
	//M.weapon_lock = 0
	//src.modules += M


/obj/item/weapon/hive_module/engineering/New()

	src.modules += new /obj/item/weapon/extinguisher(src)
	src.modules += new /obj/item/weapon/screwdriver(src)
	src.modules += new /obj/item/weapon/weldingtool(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/device/analyzer(src)
	src.modules += new /obj/item/device/flashlight(src)

	var/obj/item/weapon/rcd/R = new /obj/item/weapon/rcd(src)
	R.matter = 30
	src.modules += R

	src.modules += new /obj/item/device/t_scanner(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/wirecutters(src)
	src.modules += new /obj/item/device/multitool(src)

	var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(src)
	M.amount = 50
	src.modules += M

	var/obj/item/stack/sheet/rglass/G = new /obj/item/stack/sheet/rglass(src)
	G.amount = 50
	src.modules += G

	var/obj/item/weapon/cable_coil/W = new /obj/item/weapon/cable_coil(src)
	W.amount = 50
	src.modules += W
