/obj/item/weapon/robot_module/mommi
	name = "mobile mmi robot module"


/obj/item/weapon/robot_module/mommi/New(var/mob/living/silicon/robot/R)
	..()
	languages = list(	LANGUAGE_SOL_COMMON = 0, LANGUAGE_TRADEBAND = 0, LANGUAGE_VOX = 0,
						LANGUAGE_ROOTSPEAK = 0, LANGUAGE_GREY = 0, LANGUAGE_CLATTER = 0,
						LANGUAGE_MONKEY = 0, LANGUAGE_UNATHI = 0, LANGUAGE_SIIK_TAJR = 0,
						LANGUAGE_SKRELLIAN = 0, LANGUAGE_GUTTER = 0, LANGUAGE_MONKEY = 0)
	add_languages(R)
	src.emag = new /obj/item/borg/stun(src)
	//src.modules += new /obj/item/weapon/rcd/borg(src)     // Too OP
	//src.modules += new /obj/item/device/flashlight(src)   // Broken
	src.modules += new /obj/item/weapon/weldingtool/largetank(src)
	src.modules += new /obj/item/weapon/screwdriver(src)
	src.modules += new /obj/item/weapon/wrench(src)
	src.modules += new /obj/item/weapon/crowbar(src)
	src.modules += new /obj/item/weapon/wirecutters(src)
	src.modules += new /obj/item/device/multitool(src)
	src.modules += new /obj/item/device/t_scanner(src)
	src.modules += new /obj/item/device/analyzer(src)
	src.modules += new /obj/item/weapon/extinguisher(src) // Aurx sed so
	src.modules += new /obj/item/weapon/extinguisher/foam(src)
	src.modules += new /obj/item/device/rcd/rpd(src)
	src.modules += new /obj/item/device/rcd/tile_painter(src)
	src.modules += new /obj/item/blueprints/mommiprints(src)
	src.modules += new /obj/item/device/material_synth/robot/mommi(src)
	sensor_augs = list("Mesons", "Disable")
	var/obj/item/stack/cable_coil/W = new /obj/item/stack/cable_coil(src)
	W.amount = 50
	W.max_amount = 50 // Override MAXCOIL
	src.modules += W
	return

/obj/item/weapon/robot_module/mommi/respawn_consumable(var/mob/living/silicon/robot/R)
	var/list/what = list (
		// /obj/item/stack/sheet/metal/cyborg,
		// /obj/item/stack/sheet/glass/glass,
		/obj/item/stack/cable_coil,
		// /obj/item/stack/sheet/glass/rglass/cyborg,
	)
	for (var/T in what)
		if (!(locate(T) in src.modules))
			src.modules -= null
			var/O = new T(src)
			if(istype(O,/obj/item/stack/cable_coil))
				O:max_amount = 50
			src.modules += O
			O:amount = 1
	return