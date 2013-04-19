//make incision
/datum/surgery_step/incise
	implements = list(/obj/item/medical/scalpel = 100, /obj/item/kitchen/knife = 65, /obj/item/trash/shard = 45)
	time = 24

/datum/surgery_step/incise/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to make an incision in [target]'s [target_zone].</span>")


//clamp bleeders
/datum/surgery_step/clamp_bleeders
	implements = list(/obj/item/medical/hemostat = 100, /obj/item/part/wirecutters = 60, /obj/item/part/cable_coil = 15)
	time = 48

/datum/surgery_step/clamp_bleeders/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to clamp bleeders in [target]'s [target_zone].</span>")


//retract skin
/datum/surgery_step/retract_skin
	implements = list(/obj/item/medical/retractor = 100, /obj/item/tool/screwdriver = 45, /obj/item/part/wirecutters = 35)
	time = 32

/datum/surgery_step/retract_skin/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to retract the skin in [target]'s [target_zone].</span>")


//close incision
/datum/surgery_step/close
	implements = list(/obj/item/medical/cautery = 100, /obj/item/tool/welder = 70, /obj/item/tool/lighter = 45, /obj/item/tool/match = 20)
	time = 32

/datum/surgery_step/close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to mend the incision in [target]'s [target_zone].</span>")

/datum/surgery_step/close/tool_check(mob/user, obj/item/tool)
	if(istype(tool, /obj/item/medical/cautery))
		return 1

	if(istype(tool, /obj/item/tool/welder))
		var/obj/item/tool/welder/WT = tool
		if(WT.isOn())	return 1

	else if(istype(tool, /obj/item/tool/lighter))
		var/obj/item/tool/lighter/L = tool
		if(L.lit)	return 1

	else if(istype(tool, /obj/item/tool/match))
		var/obj/item/tool/match/M = tool
		if(M.lit)	return 1

	return 0


//saw bone
/datum/surgery_step/saw
	implements = list(/obj/item/medical/saw = 100, /obj/item/botany/hatchet = 35, /obj/item/kitchen/butch = 25)
	time = 64

/datum/surgery_step/saw/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to saw through the bone in [target]'s [target_zone].</span>")