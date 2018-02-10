/obj/item/disk/surgery/viral_bonding
	desc = "The disk provides instructions on how to force symbiosis between a virus and its host."
	surgeries = list(/datum/surgery/advanced/viral_bonding)

/datum/surgery/advanced/viral_bonding
	name = "viral bonding"
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/viral_bond,
				/datum/surgery_step/close)

	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list("chest")

/datum/surgery/advanced/viral_bonding/can_start(mob/user, mob/living/carbon/target)
	if(!..())
		return FALSE
	if(!LAZYLEN(target.viruses))
		return FALSE
	return TRUE

/datum/surgery_step/viral_bond
	name = "viral bond"
	implements = list(/obj/item/cautery = 100, /obj/item/weldingtool = 50,
		/obj/item/lighter = 35, /obj/item/match = 30)
	time = 100

/datum/surgery_step/viral_bond/tool_check(mob/user, obj/item/tool)
	if(istype(tool, /obj/item/cautery))
		return TRUE

	if(istype(tool, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = tool
		if(WT.isOn())
			return TRUE

	else if(istype(tool, /obj/item/lighter))
		var/obj/item/lighter/L = tool
		if(L.lit)
			return TRUE

	else if(istype(tool, /obj/item/match))
		var/obj/item/match/M = tool
		if(M.lit)
			return TRUE
	return FALSE

/datum/surgery_step/viral_bond/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] starts heating [target]'s bone marrow with [tool]...", "<span class='notice'>You start heating [target]'s bone marrow with [tool]...</span>")

/datum/surgery_step/viral_bond/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!target.reagents.has_reagent("spaceacillin", 5) || !target.reagents.has_reagent("plasmavirusfood", 5) || !target.reagents.has_reagent("formaldehyde", 5))
		user.visible_message("[target]'s seems unaffected.", "<span class='notice'>[target]'s body must be dosed with spaceacillin, virus plasma and formaldehyde to complete the surgery!</span>")
		return FALSE
	user.visible_message("[target]'s bone marrow begins pulsing slowly.", "<span class='notice'>[target]'s bone marrow begins pulsing slowly. The viral bonding is complete.</span>")
	for(var/X in target.viruses)
		var/datum/disease/D = X
		D.carrier = TRUE
	return TRUE