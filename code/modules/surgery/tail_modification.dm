// The detachment and attachment of lizard tails
// Dismemberment lite; can/should be generalized aka augs when we get more mutant parts and/or for actual dismemberment

// TAIL REMOVAL

/datum/surgery/tail_removal
	name = "tail removal"
	steps = list(/datum/surgery_step/sever_tail, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human)
	possible_locs = list("groin")

/datum/surgery/tail_removal/can_start(mob/user, mob/living/carbon/target)
	var/mob/living/carbon/human/L = target
	if(("tail_lizard" in L.dna.species.mutant_bodyparts) || ("waggingtail_lizard" in L.dna.species.mutant_bodyparts))
		return 1
	return 0

/datum/surgery_step/sever_tail
	name = "sever tail"
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/circular_saw = 100,
	/obj/item/weapon/melee/sabre = 100, /obj/item/weapon/melee/transforming/energy/sword/cyborg/saw = 100,
	/obj/item/weapon/melee/arm_blade = 80, /obj/item/weapon/twohanded/required/chainsaw = 80,
	/obj/item/weapon/mounted_chainsaw = 80, /obj/item/weapon/twohanded/fireaxe = 50,
	/obj/item/weapon/hatchet = 40, /obj/item = 30) // 30% success with any sharp item.
	time = 64

/datum/surgery_step/sever_tail/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to sever [target]'s tail!", "<span class='notice'>You begin to sever [target]'s tail...</span>")

/datum/surgery_step/sever_tail/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.is_sharp())
		return FALSE

	return TRUE

/datum/surgery_step/sever_tail/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/L = target
	user.visible_message("[user] severs [L]'s tail!", "<span class='notice'>You sever [L]'s tail.</span>")
	if("tail_lizard" in L.dna.species.mutant_bodyparts)
		L.dna.species.mutant_bodyparts -= "tail_lizard"
	else if("waggingtail_lizard" in L.dna.species.mutant_bodyparts)
		L.dna.species.mutant_bodyparts -= "waggingtail_lizard"
	if("spines" in L.dna.features)
		L.dna.features -= "spines"
	var/obj/item/severedtail/S = new(get_turf(target))
	S.add_atom_colour("#[L.dna.features["mcolor"]]", FIXED_COLOUR_PRIORITY)
	S.markings = "[L.dna.features["tail_lizard"]]"
	L.update_body()
	return 1

// TAIL ATTACHMENT

/datum/surgery/tail_attachment
	name = "tail attachment"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace, /datum/surgery_step/attach_tail, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human)
	possible_locs = list("groin")

/datum/surgery/tail_attachment/can_start(mob/user, mob/living/carbon/target)
	var/mob/living/carbon/human/L = target
	if(!("tail_lizard" in L.dna.species.mutant_bodyparts) && !("waggingtail_lizard" in L.dna.species.mutant_bodyparts))
		return 1
	return 0

/datum/surgery_step/attach_tail
	name = "attach tail"
	implements = list(/obj/item/severedtail = 100)
	time = 64

/datum/surgery_step/attach_tail/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to attach a tail to [target]!", "<span class='notice'>You begin to attach the tail to [target]...</span>")

/datum/surgery_step/attach_tail/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/L = target
	user.visible_message("[user] gives [L] a tail!", "<span class='notice'>You give [L] a tail. It adjusts to [L]'s melanin.</span>") // fluff for color
	if(!(L.dna.features["mcolor"]))
		L.dna.features["mcolor"] = tool.color
	var/obj/item/severedtail/T = tool
	L.dna.features["tail_lizard"] = T.markings
	L.dna.species.mutant_bodyparts += "tail_lizard"
	qdel(tool)
	L.update_mutant_bodyparts()
	return 1