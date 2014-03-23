
//make incision
/datum/surgery_step/incise
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/kitchenknife = 65, /obj/item/weapon/shard = 45)
	time = 24

/datum/surgery_step/incise/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to make an incision in [target]'s [parse_zone(target_zone)].</span>")



//clamp bleeders
/datum/surgery_step/clamp_bleeders
	implements = list(/obj/item/weapon/hemostat = 100, /obj/item/weapon/wirecutters = 60, /obj/item/stack/cable_coil = 15)
	time = 48

/datum/surgery_step/clamp_bleeders/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to clamp bleeders in [target]'s [parse_zone(target_zone)].</span>")


//retract skin
/datum/surgery_step/retract_skin
	implements = list(/obj/item/weapon/retractor = 100, /obj/item/weapon/screwdriver = 45, /obj/item/weapon/wirecutters = 35)
	time = 32

/datum/surgery_step/retract_skin/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to retract the skin in [target]'s [parse_zone(target_zone)].</span>")



//close incision
/datum/surgery_step/close
	implements = list(/obj/item/weapon/cautery = 100, /obj/item/weapon/weldingtool = 70, /obj/item/weapon/lighter = 45, /obj/item/weapon/match = 20)
	time = 32

/datum/surgery_step/close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to mend the incision in [target]'s [parse_zone(target_zone)].</span>")


/datum/surgery_step/close/tool_check(mob/user, obj/item/tool)
	if(istype(tool, /obj/item/weapon/cautery))
		return 1

	if(istype(tool, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = tool
		if(WT.isOn())	return 1

	else if(istype(tool, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = tool
		if(L.lit)	return 1

	else if(istype(tool, /obj/item/weapon/match))
		var/obj/item/weapon/match/M = tool
		if(M.lit)	return 1

	return 0


//saw bone
/datum/surgery_step/saw
	implements = list(/obj/item/weapon/circular_saw = 100, /obj/item/weapon/melee/arm_blade = 75, /obj/item/weapon/hatchet = 35, /obj/item/weapon/butch = 25)
	time = 64

/datum/surgery_step/saw/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to saw through the bone in [target]'s [parse_zone(target_zone)].</span>")



