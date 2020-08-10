/// RIGsuits, trade-off between armor and utility
/obj/item/rig
	name = "Base RIG"
	desc = "You should not see this, yell at a coder!"
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig_shell"
	worn_icon = 'icons/mob/rig.dmi'

/obj/item/rig/control
	name = "RIG control module"
	desc = "A special powered suit that protects against various environments. Wear it on your back, deploy it and activate it."
	icon_state = "engi-module"
	worn_icon_state = "engi-module"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	slowdown = 2
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 30, "acid" = 100)
	actions_types = list(/datum/action/item_action/rig/deploy, /datum/action/item_action/rig/activate)
	resistance_flags = ACID_PROOF
	permeability_coefficient = 0.01
	/// How the RIG and things connected to it look
	var/theme = "engi"
	/// If the suit is deployed and turned on
	var/active = FALSE
	/// If the suit wire/module hatch is open
	var/open = FALSE
	/// If the suit is ID locked
	var/locked = TRUE
	/// If the suit is malfunctioning
	var/malfunctioning = FALSE
	/// If the suit has EMP protection
	var/emp_protection = FALSE
	/// If the suit is currently activating/deactivating
	var/activating = FALSE
	/// How long the RIG is electrified for
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	/// If the suit interface is broken
	var/interface_break = FALSE
	/// Can the RIG swap out modules/parts
	var/no_customization = FALSE
	/// How much modules can this RIG carry without malfunctioning
	var/complexity_max = DEFAULT_MAX_COMPLEXITY
	/// How much modules this RIG is carrying
	var/complexity = 0
	/// How much battery power the RIG uses per tick
	var/cell_usage = 0
	/// RIG cell
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell/high
	/// RIG helmet
	var/obj/item/clothing/head/helmet/space/rig/helmet = /obj/item/clothing/head/helmet/space/rig
	/// RIG chestplate
	var/obj/item/clothing/suit/armor/rig/chestplate = /obj/item/clothing/suit/armor/rig
	/// RIG gauntlets
	var/obj/item/clothing/gloves/rig/gauntlets = /obj/item/clothing/gloves/rig
	/// RIG boots
	var/obj/item/clothing/shoes/rig/boots = /obj/item/clothing/shoes/rig
	/// List of parts
	var/list/rig_parts
	/// Modules the RIG should spawn with
	var/list/initial_modules = list()
	/// Modules the RIG currently possesses
	var/list/modules
	/// Person wearing the RIGsuit
	var/mob/living/carbon/human/wearer

/obj/item/rig/control/Initialize()
	..()
	START_PROCESSING(SSobj,src)
	icon_state = "[theme]-module"
	worn_icon_state = "[theme]-module"
	wires = new /datum/wires/rig(src)
	if((!req_access || !req_access.len) && (!req_one_access || !req_one_access.len))
		locked = FALSE
	if(ispath(cell))
		cell = new cell(src)
	if(ispath(helmet))
		helmet = new helmet(src)
		helmet.rig = src
		helmet.armor = armor
		helmet.resistance_flags = resistance_flags
		helmet.icon_state = "[theme]-helmet"
		helmet.worn_icon_state = "[theme]-helmet"
		LAZYADD(rig_parts, helmet)
	if(ispath(chestplate))
		chestplate = new chestplate(src)
		chestplate.rig = src
		chestplate.armor = armor
		chestplate.resistance_flags = resistance_flags
		chestplate.icon_state = "[theme]-chestplate"
		chestplate.worn_icon_state = "[theme]-chestplate"
		LAZYADD(rig_parts, chestplate)
	if(ispath(gauntlets))
		gauntlets = new gauntlets(src)
		gauntlets.rig = src
		gauntlets.armor = armor
		gauntlets.resistance_flags = resistance_flags
		gauntlets.icon_state = "[theme]-gauntlets"
		gauntlets.worn_icon_state = "[theme]-gauntlets"
		LAZYADD(rig_parts, gauntlets)
	if(ispath(boots))
		boots = new boots(src)
		boots.rig = src
		boots.armor = armor
		boots.resistance_flags = resistance_flags
		boots.icon_state = "[theme]-boots"
		boots.worn_icon_state = "[theme]-boots"
		LAZYADD(rig_parts, boots)
	if(initial_modules)
		for(var/path in initial_modules)
			var/obj/item/rig/module/module = path
			install(module)

/obj/item/rig/control/Destroy()
	..()
	QDEL_NULL(wires)
	if(helmet)
		helmet.rig = null
		QDEL_NULL(helmet)
	if(chestplate)
		chestplate.rig = null
		QDEL_NULL(chestplate)
	if(gauntlets)
		gauntlets.rig = null
		QDEL_NULL(gauntlets)
	if(boots)
		boots.rig = null
		QDEL_NULL(boots)

/obj/item/rig/control/process()
	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--
	if(cell.charge > 0 && active)
		if((cell.charge -= cell_usage) < 0)
			cell.charge = 0
		else
			cell.charge -= cell_usage

/obj/item/rig/control/equipped(mob/user, slot)
	..()
	if(slot == ITEM_SLOT_BACK)
		wearer = user

/obj/item/rig/control/dropped(mob/user)
	..()
	wearer = null

/obj/item/rig/control/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_BACK)
		return TRUE

/obj/item/rig/control/attack_hand(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/guy = user
		if(src == guy.back)
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
			return
	return ..()

/obj/item/rig/control/MouseDrop(atom/over_object)
	. = ..()
	if(src == wearer.back)
		for(var/h in rig_parts)
			var/obj/item/part = h
			if(part.loc != src)
				to_chat(wearer, "<span class='warning'>At least one of the parts are still on your body, please retract them and try again.</span>")
				playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE)
				return
		if(!wearer.incapacitated() && istype(over_object, /obj/screen/inventory/hand))
			var/obj/screen/inventory/hand/H = over_object
			if(wearer.putItemFromInventoryInHandIfPossible(src, H.held_index))
				add_fingerprint(usr)

/obj/item/rig/control/proc/shock(mob/living/user)
	if(!istype(wearer) || cell.charge < 1)
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	if(electrocute_mob(wearer, get_area(src), src, 0.7, check_range))
		return TRUE
	else
		return FALSE

/obj/item/rig/control/proc/install(module)
	var/obj/item/rig/module/thingy = module
	var/complexity_with_thingy = complexity
	complexity_with_thingy += thingy.complexity
	if(complexity_with_thingy > complexity_max)
		to_chat(wearer, "<span class='warning'>This would make the RIG too complex!</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
		return
	thingy.forceMove(src)
	LAZYADD(modules, thingy)
	complexity += thingy.complexity
	thingy.rig = src

/obj/item/clothing/head/helmet/space/rig
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig-helmet"
	worn_icon = 'icons/mob/rig.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 30, "acid" = 100)
	flash_protect = FLASH_PROTECTION_NONE
	clothing_flags = THICKMATERIAL | SNUG_FIT
	resistance_flags = ACID_PROOF
	permeability_coefficient = 0.01
	var/obj/item/rig/control/rig

/obj/item/clothing/head/helmet/space/rig/Destroy()
	..()
	if(rig)
		rig.helmet = null
		QDEL_NULL(rig)

/obj/item/clothing/suit/armor/rig
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig-chestplate"
	worn_icon = 'icons/mob/rig.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 30, "acid" = 100)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS
	cold_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	clothing_flags = THICKMATERIAL
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	resistance_flags = ACID_PROOF
	permeability_coefficient = 0.01
	var/obj/item/rig/control/rig

/obj/item/clothing/suit/armor/rig/Destroy()
	..()
	if(rig)
		rig.chestplate = null
		QDEL_NULL(rig)

/obj/item/clothing/gloves/rig
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig-gauntlets"
	worn_icon = 'icons/mob/rig.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 30, "acid" = 100)
	resistance_flags = ACID_PROOF
	permeability_coefficient = 0.01
	var/obj/item/rig/control/rig

/obj/item/clothing/gloves/rig/Destroy()
	..()
	if(rig)
		rig.gauntlets = null
		QDEL_NULL(rig)

/obj/item/clothing/shoes/rig
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig-boots"
	worn_icon = 'icons/mob/rig.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 30, "acid" = 100)
	resistance_flags = ACID_PROOF
	permeability_coefficient = 0.01
	var/obj/item/rig/control/rig

/obj/item/clothing/shoes/rig/Destroy()
	..()
	if(rig)
		rig.boots = null
		QDEL_NULL(rig)
