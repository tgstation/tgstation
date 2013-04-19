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
	src.modules += new /obj/item/security/flash(src)


/obj/item/weapon/hive_module/standard/New()
	..()
	src.modules += new /obj/item/weapon/melee/baton(src)
	src.modules += new /obj/item/tool/extinguisher(src)
	//var/obj/item/weapon/gun/mp5/M = new /obj/item/weapon/gun/mp5(src)
	//M.weapon_lock = 0
	//src.modules += M


/obj/item/weapon/hive_module/engineering/New()

	src.modules += new /obj/item/tool/extinguisher(src)
	src.modules += new /obj/item/tool/screwdriver(src)
	src.modules += new /obj/item/tool/welder(src)
	src.modules += new /obj/item/tool/wrench(src)
	src.modules += new /obj/item/device/scanner/atmospheric(src)
	src.modules += new /obj/item/tool/flashlight(src)

	var/obj/item/tool/rcd/R = new /obj/item/tool/rcd(src)
	R.matter = 30
	src.modules += R

	src.modules += new /obj/item/device/scanner/t_ray(src)
	src.modules += new /obj/item/tool/crowbar(src)
	src.modules += new /obj/item/part/wirecutters(src)
	src.modules += new /obj/item/tool/multitool(src)

	var/obj/item/part/stack/sheet/metal/M = new /obj/item/part/stack/sheet/metal(src)
	M.amount = 50
	src.modules += M

	var/obj/item/part/stack/sheet/rglass/G = new /obj/item/part/stack/sheet/rglass(src)
	G.amount = 50
	src.modules += G

	var/obj/item/part/cable_coil/W = new /obj/item/part/cable_coil(src)
	W.amount = 50
	src.modules += W
