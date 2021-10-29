/mob/living/silicon/robot/model/roleplay
	lawupdate = FALSE
	scrambledcodes = TRUE // Roleplay borgs aren't real
	set_model = /obj/item/robot_model/roleplay

/mob/living/silicon/robot/model/roleplay/Initialize()
	. = ..()
	cell = new /obj/item/stock_parts/cell/infinite(src, 30000)
	laws = new /datum/ai_laws/roleplay()
	//This part is because the camera stays in the list, so we'll just do a check
	if(!QDELETED(builtInCamera))
		QDEL_NULL(builtInCamera)

/mob/living/silicon/robot/model/roleplay/binarycheck()
	return FALSE //Roleplay borgs aren't truly borgs

/datum/ai_laws/roleplay
	name = "Roleplay"
	id = "roleplay"
	zeroth = "Roleplay as you'd like!"
	inherent = list()

/obj/item/robot_model/roleplay
	name = "Roleplay"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/iron,
		/obj/item/stack/cable_coil,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/rsf/cyborg,
		/obj/item/reagent_containers/food/drinks/drinkingglass,
		/obj/item/soap/nanotrasen,
		/obj/item/borg/cyborghug,
		/obj/item/dogborg_nose,
		/obj/item/dogborg_tongue,
		/obj/item/borg_shapeshifter/stable)
	hat_offset = -3

/obj/item/borg_shapeshifter/stable
	signalCache = list()
	activationCost = 0
	activationUpkeep = 0
