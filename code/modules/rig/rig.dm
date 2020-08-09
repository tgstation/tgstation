//epic rig
/obj/item/rig
	name = "Base RIG"
	desc = "You should not see this, yell at a coder!"
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig_shell"
	worn_icon = 'icons/mob/rig.dmi'

/obj/item/rig/control
	name = "RIG control module"
	desc = "A special powered suit that protects against various environments. Wear it on your back, deploy it and turn it on to use its' power. This one has pink socks! Yell at a coder if you see this."
	icon_state = "engi-module"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	slowdown = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 0, "acid" = 0)
	actions_types = list(/datum/action/item_action/rig/deploy)
	///How the RIG and things connected to it look
	var/theme = "coder"
	///If the suit is deployed and turned on
	var/active = FALSE
	///If the suit wire/module hatch is open
	var/open = FALSE
	///If the suit is ID locked
	var/locked = TRUE
	///If the suit is malfunctioning
	var/malfunctioning = FALSE
	///If the suit has EMP protection
	var/emp_protection = FALSE
	///How long the RIG is electrified for
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	///If the suit interface is broken
	var/interface_break = FALSE
	///How much modules can this RIG carry without malfunctioning
	var/complexity_max = 15
	///How much modules this RIG is carrying
	var/complexity = 0
	///Can the RIG swap out modules/parts
	var/no_customization = FALSE
	///How much battery power the RIG uses per tick
	var/cell_usage = 0
	///RIG cell
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell/high
	///RIG helmet
	var/obj/item/clothing/head/helmet/space/rig/helmet = /obj/item/clothing/head/helmet/space/rig
	///RIG chestplate
	var/obj/item/clothing/suit/armor/rig/chestplate = /obj/item/clothing/suit/armor/rig
	///RIG gauntlets
	var/obj/item/clothing/gloves/rig/gauntlets = /obj/item/clothing/gloves/rig
	///RIG boots
	var/obj/item/clothing/shoes/rig/boots = /obj/item/clothing/shoes/rig
	///Modules the RIG should spawn with
	var/list/initial_modules = list()
	///Person wearing the RIGsuit
	var/mob/living/carbon/human/wearer

/obj/item/rig/control/Initialize()
	..()
	START_PROCESSING(SSobj,src)
	icon_state = "[theme]-module"
	wires = new /datum/wires/rig(src)
	if((!req_access || !req_access.len) && (!req_one_access || !req_one_access.len))
		locked = FALSE
	if(ispath(cell))
		cell = new cell(src)
	if(ispath(helmet))
		helmet = new helmet(src)
		helmet.rig = src
		helmet.icon_state = "[theme]-helmet-unsealed"
		helmet.worn_icon_state = "[theme]-helmet-unsealed"
	if(ispath(chestplate))
		chestplate = new chestplate(src)
		chestplate.rig = src
		chestplate.icon_state = "[theme]-chestplate-unsealed"
		chestplate.worn_icon_state = "[theme]-chestplate-unsealed"
	if(ispath(gauntlets))
		gauntlets = new gauntlets(src)
		gauntlets.rig = src
		gauntlets.icon_state = "[theme]-gauntlets-unsealed"
		gauntlets.worn_icon_state = "[theme]-gauntlets-unsealed"
	if(ispath(boots))
		boots = new boots(src)
		boots.rig = src
		boots.icon_state = "[theme]-boots-unsealed"
		boots.worn_icon_state = "[theme]-boots-unsealed"
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
		return
	var/obj/item/rig/module/thingy_unleashed = new thingy(src)
	complexity += thingy_unleashed.complexity
	thingy_unleashed.rig = src

/obj/item/rig/control/proc/deploy(part)
	var/obj/item/piece = part
	if(wearer.equip_to_slot_if_possible(piece,piece.slot_flags,0,0,1))
		to_chat(wearer, "<span class='notice'>[piece] deploy[piece.p_s()] with a mechanical hiss.</span>")
		playsound(loc, 'sound/mecha/mechmove03.ogg', 25, TRUE)
		wearer.update_inv_wear_suit()
		ADD_TRAIT(piece, TRAIT_NODROP, RIG_TRAIT)
	else if(piece.loc != src)
		to_chat(wearer, "<span class='warning'>[piece] [piece.p_are()] already deployed!</span>")
	else
		to_chat(wearer, "<span class='warning'>You are already wearing something where [piece] would go!</span>")

/obj/item/rig/control/proc/conceal(part)
	var/obj/item/piece = part
	REMOVE_TRAIT(piece, TRAIT_NODROP, RIG_TRAIT)
	wearer.transferItemToLoc(piece, src, TRUE)
	to_chat(wearer, "<span class='notice'>[piece] retract[piece.p_s()] back into [src] with a mechanical hiss.</span>")
	playsound(loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)

/obj/item/clothing/head/helmet/space/rig
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig-helmet"
	worn_icon = 'icons/mob/rig.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 100)
	var/obj/item/rig/control/rig

/obj/item/clothing/suit/armor/rig
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig-chestplate"
	worn_icon = 'icons/mob/rig.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 100)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS
	cold_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	var/obj/item/rig/control/rig

/obj/item/clothing/gloves/rig
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig-gauntlets"
	worn_icon = 'icons/mob/rig.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 100)
	var/obj/item/rig/control/rig

/obj/item/clothing/shoes/rig
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig-boots"
	worn_icon = 'icons/mob/rig.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 100)
	var/obj/item/rig/control/rig
