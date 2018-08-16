/obj/item/robot_module/loader
	name = "loader robot module"
/obj/item/robot_module/loader/New()
	..()
	emag = new /obj/item/borg/stun(src)
	modules += new /obj/item/extinguisher(src)
	modules += new /obj/item/weldingtool/largetank/cyborg(src)
	modules += new /obj/item/screwdriver(src)
	modules += new /obj/item/wrench(src)
	modules += new /obj/item/crowbar(src)
	modules += new /obj/item/wirecutters(src)
	modules += new /obj/item/multitool(src)
	modules += new /obj/item/t_scanner(src)
	modules += new /obj/item/analyzer(src)
	modules += new /obj/item/assembly/signaler
	modules += new /obj/item/soap/nanotrasen(src)

	fix_modules()

/obj/item/robot_module/k9
	name = "Security K-9 Unit module"
/obj/item/robot_module/k9/New()
	..()
	modules += new /obj/item/restraints/handcuffs/cable/zipties/cyborg/dog(src)
	modules += new /obj/item/dogborg/jaws/big(src)
	modules += new /obj/item/dogborg/pounce(src)
	modules += new /obj/item/clothing/mask/gas/sechailer/cyborg(src)
	modules += new /obj/item/soap/tongue(src)
	modules += new /obj/item/analyzer/nose(src)
	modules += new /obj/item/storage/bag/borgdelivery(src)
	//modules += new /obj/item/assembly/signaler(src)
	//modules += new /obj/item/detective_scanner(src)
	modules += new /obj/item/gun/energy/disabler/cyborg(src)
	emag = new /obj/item/gun/energy/laser/cyborg(src)
	fix_modules()

/obj/item/robot_module/security/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	..()
	var/obj/item/gun/energy/gun/advtaser/cyborg/T = locate(/obj/item/gun/energy/gun/advtaser/cyborg) in get_usable_modules()
	if(T)
		if(T.power_supply.charge < T.power_supply.maxcharge)
			var/obj/item/ammo_casing/energy/S = T.ammo_type[T.select]
			T.power_supply.give(S.e_cost * coeff)
			T.update_icon()
		else
			T.charge_tick = 0
	fix_modules()

/obj/item/robot_module/borgi
	name = "Borgi module"

/obj/item/robot_module/borgi/New()
	..()
	modules += new /obj/item/dogborg/jaws/small(src)
	modules += new /obj/item/storage/bag/borgdelivery(src)
	modules += new /obj/item/soap/tongue(src)
	modules += new /obj/item/healthanalyzer(src)
	modules += new /obj/item/analyzer/nose(src)
	emag = new /obj/item/dogborg/pounce(src)
	fix_modules()

/obj/item/robot_module/medihound
	name = "MediHound module"

/obj/item/robot_module/medihound/New()
	..()
	modules += new /obj/item/dogborg/jaws/small(src)
	modules += new /obj/item/storage/bag/borgdelivery(src)
	modules += new /obj/item/analyzer/nose(src)
	modules += new /obj/item/soap/tongue(src)
	modules += new /obj/item/healthanalyzer(src)
	modules += new /obj/item/dogborg/sleeper(src)
	modules += new /obj/item/twohanded/shockpaddles/hound(src)
	modules += new /obj/item/sensor_device(src)
	emag = new /obj/item/dogborg/pounce(src)
	fix_modules()