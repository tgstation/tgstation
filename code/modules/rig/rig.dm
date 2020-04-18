//epic rig
/obj/item/rig
	name = "Base RIG"
	desc = "You should not see this, yell at a coder!"
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig_shell"

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
	///Can the RIG swap out modules/parts
	var/no_customization = FALSE
	///How much battery power the RIG uses per tick
	var/cell_usage = 0
	///RIG cell
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell/high
	///RIG helmet
	var/obj/item/clothing/head/helmet/space/rig/helmet = /obj/item/clothing/head/helmet/space/rig
	///RIG chestplate
	var/obj/item/clothing/suit/space/rig/chestplate = /obj/item/clothing/suit/space/rig
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
	if(cell)
		new cell(src)
	if(helmet)
		helmet.icon_state = "[theme]-helmet-unsealed"
		new helmet(src)
	if(chestplate)
		chestplate.icon_state = "[theme]-chestplate-unsealed"
		new chestplate(src)
	if(gauntlets)
		gauntlets.icon_state = "[theme]-gauntlets-unsealed"
		new gauntlets(src)
	if(boots)
		boots.icon_state = "[theme]-boots-unsealed"
		new boots(src)
	if(initial_modules)
		for(var/path in initial_modules)
			var/obj/item/rig/module/module = new path(src)
			install(module)

/obj/item/rig/control/Destroy()
	..()
	QDEL_NULL(wires)

/obj/item/rig/control/process()
	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--
	if(cell.charge > 0)
		cell.charge -= cell_usage

/obj/item/rig/control/equipped(mob/user)
	wearer = user

/obj/item/rig/control/proc/shock(mob/living/user)
	if(!istype(wearer) || cell.charge < 1)
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	if(electrocute_mob(wearer, get_area(src), src, 0.7, check_range))
		return TRUE
	else
		return FALSE

/obj/item/rig/control/proc/install()
	return

/obj/item/rig/control/proc/deploy()
	if(!wearer)
		return
	if(wearer.wear_suit != src)
		to_chat(wearer, "<span class='warning'>You must be wearing [src] to engage the helmet!</span>")
		return
	if(wearer.head)
		to_chat(wearer, "<span class='warning'>You're already wearing something on your head!</span>")
		return
	else if(wearer.equip_to_slot_if_possible(helmet,ITEM_SLOT_HEAD,0,0,1))
		to_chat(wearer, "<span class='notice'>You engage the helmet on the hardsuit.</span>")
		wearer.update_inv_wear_suit()
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)
	if(wearer.wear_suit)
		to_chat(wearer, "<span class='warning'>You're already wearing something on your body!</span>")
		return
	else if(wearer.equip_to_slot_if_possible(chestplate,ITEM_SLOT_OCLOTHING,0,0,1))
		to_chat(wearer, "<span class='notice'>You engage the chestplate on the hardsuit.</span>")
		wearer.update_inv_wear_suit()
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)
	if(wearer.gloves)
		to_chat(wearer, "<span class='warning'>You're already wearing something on your arms!</span>")
		return
	else if(wearer.equip_to_slot_if_possible(gauntlets,ITEM_SLOT_HANDS,0,0,1))
		to_chat(wearer, "<span class='notice'>You engage the gauntlets on the hardsuit.</span>")
		wearer.update_inv_wear_suit()
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)
	if(wearer.shoes)
		to_chat(wearer, "<span class='warning'>You're already wearing something on your legs!</span>")
		return
	else if(wearer.equip_to_slot_if_possible(boots,ITEM_SLOT_FEET,0,0,1))
		to_chat(wearer, "<span class='notice'>You engage the boots on the hardsuit.</span>")
		wearer.update_inv_wear_suit()
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)

/obj/item/clothing/head/helmet/space/rig
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig-helmet"
	mob_overlay_icon = 'icons/mob/rig.dmi'

/obj/item/clothing/suit/space/rig
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig-chestplate"
	mob_overlay_icon = 'icons/mob/rig.dmi'

/obj/item/clothing/gloves/rig
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig-gauntlets"
	mob_overlay_icon = 'icons/mob/rig.dmi'

/obj/item/clothing/shoes/rig
	icon = 'icons/obj/rig.dmi'
	icon_state = "rig-boots"
	mob_overlay_icon = 'icons/mob/rig.dmi'
