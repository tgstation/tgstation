//Organ reconstruction, limited to the chest region as most organs in the head have their own repair method (eyes/brain). We require synthflesh for these
//steps since fixing internal organs aren't as simple as mending exterior flesh, though in the future it would be neat to add more chems to the viable list.
//TBD: Add heart damage, have heart reconstruction seperate from organ reconstruction, and find a better name for this. I can imagine people getting it confused with manipulation.

/datum/surgery/organ_reconstruction
	name = "Organ reconstruction"
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
	/datum/surgery_step/incise,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/saw,
	/datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/repair_lungs,
	/datum/surgery_step/incise,
	/datum/surgery_step/repair_liver,
	/datum/surgery_step/close
	)

//repair lungs step
/datum/surgery_step/repair_lungs
	name = "fix lungs"
	implements = list(/obj/item/hemostat = 100, TOOL_SCREWDRIVER = 35, /obj/item/pen = 15)
	repeatable = TRUE
	time = 25
	chems_needed = list(/datum/reagent/medicine/synthflesh)


//repair liver step
/datum/surgery_step/repair_liver
	name = "fix liver"
	implements = list(/obj/item/hemostat = 100, TOOL_SCREWDRIVER = 35, /obj/item/pen = 15)
	repeatable = TRUE
	time = 25
	chems_needed = list(/datum/reagent/medicine/synthflesh)

//Repair lungs
/datum/surgery_step/repair_lungs/preop(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to repair damaged portions of [target]'s lungs.</span>")

/datum/surgery_step/repair_lungs/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/lungs/lungs = target.getorganslot(ORGAN_SLOT_LUNGS)
	if((!lungs)||(lungs.failing))
		to_chat(user, "[target] has no lungs capable of repair!")
	else
		user.visible_message("[user] successfully repairs part of [target]'s lungs.", "<span class='notice'>You succeed in repairing parts of [target]'s lungs.</span>")
		if(lungs.damage < 10)
			target.applyLungDamage(-(lungs.damage))
		else
			target.applyLungDamage(-10)

/datum/surgery_step/repair_lungs/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/lungs/lungs = target.getorganslot(ORGAN_SLOT_LUNGS)
	if((lungs)&&(!lungs.failing))
		user.visible_message("<span class='warning'>[user] accidentally damages part of [target]'s lungs!</span>", "<span class='warning'>You damage [target]'s lungs! Apply more synthflesh if it's run out.</span>")
		target.applyLungDamage(10)
	else
		to_chat(user, "[target] has no lungs capable of repair!")
	return FALSE


//Repair liver
/datum/surgery_step/repair_liver/preop(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to repair damaged portions of [target]'s liver.</span>")

/datum/surgery_step/repair_liver/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/liver/liver = target.getorganslot(ORGAN_SLOT_LIVER)
	if((!liver)||(liver.failing))
		to_chat(user, "[target] has no liver capable of repair!")
	else
		user.visible_message("[user] successfully repairs part of [target]'s liver.", "<span class='notice'>You succeed in repairing parts of [target]'s liver.</span>")
		if(liver.damage < 10)
			target.applyLiverDamage(-(liver.damage))
		else
			target.applyLiverDamage(-10)

/datum/surgery_step/repair_liver/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/liver/liver = target.getorganslot(ORGAN_SLOT_LIVER)
	if((liver)&&(!liver.failing))
		user.visible_message("<span class='warning'>[user] accidentally damages part of [target]'s liver!</span>", "<span class='warning'>You damage [target]'s liver! Apply more synthflesh if it's run out.</span>")
		target.applyLiverDamage(10)
	else
		to_chat(user, "[target] has no liver capable of repair!")
	return FALSE
