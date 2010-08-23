/obj/item/weapon/robot_module
	name = "robot module"
	icon = 'module.dmi'
	icon_state = "std_module"
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT|TABLEPASS | CONDUCT
	var/list/modules = list()

/obj/item/weapon/robot_module/standard
	name = "standard robot module"
/*
/obj/item/weapon/robot_module/medical
	name = "medical robot module"
*/
/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"

/obj/item/weapon/robot_module/security
	name = "security robot module"

/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"

/obj/item/weapon/robot_module/brobot
	name = "brobot robot module"

/obj/item/weapon/robot_module/New()//Shit all the mods have
	src.modules += new /obj/item/device/flash(src)


/obj/item/weapon/robot_module/standard/New()
	..()
	src.modules += new /obj/item/weapon/baton(src)
	src.modules += new /obj/item/weapon/extinguisher(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/device/healthanalyzer(src)

/obj/item/weapon/robot_module/engineering/New()
	..()
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

	var/obj/item/weapon/sheet/metal/M = new /obj/item/weapon/sheet/metal(src)
	M.amount = 50
	src.modules += M

	var/obj/item/weapon/sheet/rglass/G = new /obj/item/weapon/sheet/rglass(src)
	G.amount = 50
	src.modules += G

	var/obj/item/weapon/cable_coil/W = new /obj/item/weapon/cable_coil(src)
	W.amount = 50
	src.modules += W

/*
/obj/item/weapon/robot_module/medical/New()
	..()
	src.modules += new /obj/item/device/healthanalyzer(src)
	src.modules += new /obj/item/weapon/medical/ointment/medbot(src)
	src.modules += new /obj/item/weapon/medical/bruise_pack/medbot(src)
	src.modules += new /obj/item/weapon/reagent_containers/syringe/robot(src)
	src.modules += new /obj/item/weapon/scalpel(src)
	src.modules += new /obj/item/weapon/circular_saw(src)
*/

/obj/item/weapon/robot_module/security/New()
	..()
	src.modules += new /obj/item/weapon/baton(src)
	src.modules += new /obj/item/weapon/handcuffs(src)
	src.modules += new /obj/item/weapon/gun/energy/taser_gun(src)
	src.modules += new /obj/item/device/flash(src)

/obj/item/weapon/robot_module/janitor/New()
	..()
	src.modules += new /obj/item/weapon/cleaner(src)
	src.modules += new /obj/item/weapon/mop(src)
	src.modules += new /obj/item/weapon/reagent_containers/glass/bucket

/obj/item/weapon/robot_module/brobot/New()
	..()
	src.modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	src.modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	src.modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	src.modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	src.modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	src.modules += new /obj/item/weapon/spacecash(src)
