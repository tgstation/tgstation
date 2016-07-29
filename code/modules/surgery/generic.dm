//Procedures in this file: Gneric surgery steps
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/generic/
	can_infect = 1
	var/painful=1
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (isslime(target))
			return 0
		if (target_zone == "eyes")	//there are specific steps for eye surgery
			return 0
		if (!hasorgans(target))
			return 0
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected == null)
			return 0
		if (affected.status & ORGAN_DESTROYED)
			return 0
		if (affected.status & ORGAN_ROBOT)
			return 0
		if (affected.status & ORGAN_PEG)
			return 0
		// N3X:  Patient must be sleeping, dead, or unconscious.
		if(!check_anesthesia(target) && painful)
			return -1
		return 1



//////CUT WITH LASER(cut+clamp)//////////
/datum/surgery_step/generic/cut_with_laser
	allowed_tools = list(
		/obj/item/weapon/scalpel/laser/tier2 = 100,
		/obj/item/weapon/scalpel/laser/tier1 = 100,
		/obj/item/weapon/melee/energy/sword = 5 //haha, oh god what
		)

	priority = 0.1 //so the tool checks for this step before /generic/cut_open

	min_duration = 90
	max_duration = 110

/datum/surgery_step/generic/cut_with_laser/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		if(target.species && (target.species.flags & NO_SKIN))
			to_chat(user, "<span class='info'>[target] has no skin!</span>")
			return 0
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open == 0 && target_zone != "mouth"

/datum/surgery_step/generic/cut_with_laser/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts the bloodless incision on [target]'s [affected.display_name] with \the [tool].", \
	"You start the bloodless incision on [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("You feel a horrible, searing pain in your [affected.display_name]!",1)
	..()

/datum/surgery_step/generic/cut_with_laser/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has made a bloodless incision on [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You have made a bloodless incision on [target]'s [affected.display_name] with \the [tool].</span>",)
	//Could be cleaner ...
	affected.open = 1
	affected.status |= ORGAN_BLEEDING
	affected.createwound(CUT, 1)
	affected.clamp()
	//spread_germs_to_organ(affected, user) //a laser scalpel shouldn't spread germs.

/datum/surgery_step/generic/cut_with_laser/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips as the blade sputters, searing a long gash in [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips as the blade sputters, searing a long gash in [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 7.5)
	affected.createwound(BURN, 12.5)
	if(istype(tool,/obj/item/weapon/scalpel))
		var/obj/item/weapon/scalpel/S = tool
		S.icon_state = "[initial(S.icon_state)]_off"



//////INCISION MANAGER(cut+clamp+retract)//////////
/datum/surgery_step/generic/incision_manager
	allowed_tools = list(
		/obj/item/weapon/retractor/manager = 100
		)

	priority = 0.1 //so the tool checks for this step before /generic/cut_open

	min_duration = 80
	max_duration = 120

/datum/surgery_step/generic/incision_manager/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		if(target.species && (target.species.flags & NO_SKIN))
			to_chat(user, "<span class='info'>[target] has no skin!</span>")
			return 0

		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open == 0 && target_zone != "mouth"

/datum/surgery_step/generic/incision_manager/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to construct a prepared incision on and within [target]'s [affected.display_name] with \the [tool].", \
	"You start to construct a prepared incision on and within [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("You feel a horrible, searing pain in your [affected.display_name] as it is pushed apart!",1)
	tool.icon_state = "[initial(tool.icon_state)]_on"
	spawn(max_duration)//in case the player doesn't go all the way through the step (if he moves away, puts the tool away,...)
		tool.icon_state = "[initial(tool.icon_state)]_off"
	..()

/datum/surgery_step/generic/incision_manager/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has constructed a prepared incision on and within [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You have constructed a prepared incision on and within [target]'s [affected.display_name] with \the [tool].</span>",)
	affected.open = 1
	affected.status |= ORGAN_BLEEDING
	affected.createwound(CUT, 1)
	affected.clamp()
	affected.open = 2
	tool.icon_state = "[initial(tool.icon_state)]_off"

/datum/surgery_step/generic/incision_manager/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand jolts as the system sparks, ripping a gruesome hole in [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand jolts as the system sparks, ripping a gruesome hole in [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 20)
	affected.createwound(BURN, 15)
	tool.icon_state = "[initial(tool.icon_state)]_off"



////////CUT OPEN/////////
/datum/surgery_step/generic/cut_open/tool_quality(obj/item/tool)
	. = ..()
	if(!tool.is_sharp())
		return 0

/datum/surgery_step/generic/cut_open
	allowed_tools = list(
		/obj/item/weapon/scalpel = 100,
		/obj/item/weapon/kitchen/utensil/knife/large = 75,
		/obj/item/weapon/shard = 50,
		)

	priority = 0

	min_duration = 90
	max_duration = 110

/datum/surgery_step/generic/cut_open/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	if(target.species && (target.species.flags & NO_SKIN))
		to_chat(user, "<span class='info'>[target] has no skin!</span>")
		return 0

	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(. && !affected.open && target_zone != "mouth")
		return .
	return 0

/datum/surgery_step/generic/cut_open/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts the incision on [target]'s [affected.display_name] with \the [tool].", \
	"You start the incision on [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("You feel a horrible pain as if from a sharp knife in your [affected.display_name]!",1)
	..()

/datum/surgery_step/generic/cut_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has made an incision on [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You have made an incision on [target]'s [affected.display_name] with \the [tool].</span>",)
	affected.open = 1
	affected.status |= ORGAN_BLEEDING
	affected.createwound(CUT, 1)

/datum/surgery_step/generic/cut_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing open [target]'s [affected.display_name] in the wrong place with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, slicing open [target]'s [affected.display_name] in the wrong place with \the [tool]!</span>")
	affected.createwound(CUT, 10)



///////CLAMP BLEEDERS/////
/datum/surgery_step/generic/clamp_bleeders
	allowed_tools = list(
		/obj/item/weapon/hemostat = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/device/assembly/mousetrap = 20,
		)

	min_duration = 40
	max_duration = 60

/datum/surgery_step/generic/clamp_bleeders/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		if(target.species && (target.species.flags & NO_BLOOD))
			to_chat(user, "<span class='info'>[target] has no vessels to clamp!</span>")
			return 0

		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open && (affected.status & ORGAN_BLEEDING)

/datum/surgery_step/generic/clamp_bleeders/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts clamping bleeders in [target]'s [affected.display_name] with \the [tool].", \
	"You start clamping bleeders in [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("The pain in your [affected.display_name] is maddening!",1)
	..()

/datum/surgery_step/generic/clamp_bleeders/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] clamps bleeders in [target]'s [affected.display_name] with \the [tool].</span>",	\
	"<span class='notice'>You clamp bleeders in [target]'s [affected.display_name] with \the [tool].</span>")
	affected.clamp()
	spread_germs_to_organ(affected, user)

/datum/surgery_step/generic/clamp_bleeders/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing blood vessals and causing massive bleeding in [target]'s [affected.display_name] with \the [tool]!</span>",	\
	"<span class='warning'>Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.display_name] with \the [tool]!</span>",)
	affected.createwound(CUT, 10)



////////RETRACT SKIN//////
/datum/surgery_step/generic/retract_skin
	allowed_tools = list(
		/obj/item/weapon/retractor = 100,
		/obj/item/weapon/crowbar = 75,
		/obj/item/weapon/kitchen/utensil/fork = 50
		)

	min_duration = 30
	max_duration = 40

/datum/surgery_step/generic/retract_skin/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		if(target.species && (target.species.flags & NO_SKIN))
			to_chat(user, "<span class='info'>[target] has no skin!</span>")
			return 0

		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open == 1 //&& !(affected.status & ORGAN_BLEEDING)

/datum/surgery_step/generic/retract_skin/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	var/msg = "[user] starts to pry open the incision on [target]'s [affected.display_name] with \the [tool]."
	var/self_msg = "You start to pry open the incision on [target]'s [affected.display_name] with \the [tool]."
	if (target_zone == LIMB_CHEST)
		msg = "[user] starts to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
		self_msg = "You start to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
	if (target_zone == LIMB_GROIN)
		msg = "[user] starts to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
		self_msg = "You start to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("It feels like the skin on your [affected.display_name] is on fire!",1)
	..()

/datum/surgery_step/generic/retract_skin/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	var/msg = "<span class='notice'>[user] keeps the incision open on [target]'s [affected.display_name] with \the [tool].</span>"
	var/self_msg = "<span class='notice'>You keep the incision open on [target]'s [affected.display_name] with \the [tool].</span>"
	if (target_zone == LIMB_CHEST)
		msg = "<span class='notice'>[user] keeps the ribcage open on [target]'s torso with \the [tool].</span>"
		self_msg = "<span class='notice'>You keep the ribcage open on [target]'s torso with \the [tool].</span>"
	if (target_zone == LIMB_GROIN)
		msg = "<span class='notice'>[user] keeps the incision open on [target]'s lower abdomen with \the [tool].</span>"
		self_msg = "<span class='notice'>You keep the incision open on [target]'s lower abdomen with \the [tool].</span>"
	user.visible_message(msg, self_msg)
	affected.open = 2

/datum/surgery_step/generic/retract_skin/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	var/msg = "<span class='warning'>[user]'s hand slips, tearing the edges of the incision on [target]'s [affected.display_name] with \the [tool]!</span>"
	var/self_msg = "<span class='warning'>Your hand slips, tearing the edges of the incision on [target]'s [affected.display_name] with \the [tool]!</span>"
	if (target_zone == LIMB_CHEST)
		msg = "<span class='warning'>[user]'s hand slips, damaging several organs in [target]'s torso with \the [tool]!</span>"
		self_msg = "<span class='warning'>Your hand slips, damaging several organs in [target]'s torso with \the [tool]!</span>"
	if (target_zone == LIMB_GROIN)
		msg = "<span class='warning'>[user]'s hand slips, damaging several organs in [target]'s lower abdomen with \the [tool]</span>"
		self_msg = "<span class='warning'>Your hand slips, damaging several organs in [target]'s lower abdomen with \the [tool]!</span>"
	user.visible_message(msg, self_msg)
	target.apply_damage(12, BRUTE, affected, sharp=1)



/////////CAUTERIZE///////
/datum/surgery_step/generic/cauterize/tool_quality(obj/item/tool)
	if(tool.is_hot())
		for (var/T in allowed_tools)
			if (istype(tool,T))
				return allowed_tools[T]
	return 0
/datum/surgery_step/generic/cauterize
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,
	/obj/item/weapon/scalpel/laser = 100,
	/obj/item/clothing/mask/cigarette = 75,
	/obj/item/weapon/lighter = 50,
	/obj/item/weapon/weldingtool = 25,
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/generic/cauterize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		if(target.species && (target.species.flags & NO_SKIN))
			to_chat(user, "<span class='info'>[target] has no skin!</span>")
			return 0

		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open && target_zone != "mouth"

/datum/surgery_step/generic/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] is beginning to cauterize the incision on [target]'s [affected.display_name] with \the [tool]." , \
	"You are beginning to cauterize the incision on [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("Your [affected.display_name] is being burned!",1)
	..()

/datum/surgery_step/generic/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] cauterizes the incision on [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You cauterize the incision on [target]'s [affected.display_name] with \the [tool].</span>")
	affected.open = 0
	affected.germ_level = 0
	affected.status &= ~ORGAN_BLEEDING

/datum/surgery_step/generic/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, leaving a small burn on [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, leaving a small burn on [target]'s [affected.display_name] with \the [tool]!</span>")
	target.apply_damage(3, BURN, affected)

/*
////////FIX LIMB CANCER////////

/datum/surgery_step/generic/fix_limb_cancer
	allowed_tools = list(
		/obj/item/weapon/FixOVein = 100,
		/obj/item/stack/cable_coil = 75,
		)

	priority = 4 //Maximum priority, even higher than fixing brain hematomas
	min_duration = 90
	max_duration = 110
	blood_level = 1

/datum/surgery_step/internal/fix_organ_cancer/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if(..())
		var/datum/organ/external/affected = target.get_organ(target_zone)

		var/cancer_found = 0
		if(affected.cancer_stage >= 1)
			cancer_found = 1
		return affected.open == 1 && cancer_found

/datum/surgery_step/internal/fix_organ_cancer/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if(!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	if(affected && affected.cancer_stage >= 1)
		user.visible_message("[user] starts carefully removing the cancerous growths in [target]'s [affected.name] with \the [tool].", \
		"You start carefully removing the cancerous growths in [target]'s [affected.name] with \the [tool]." )

	target.custom_pain("The pain in your [affected.display_name] is living hell!", 1)
	..()

/datum/surgery_step/internal/fix_organ_cancer/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if(!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	if(affected && affected.cancer_stage >= 1)
		user.visible_message("[user] carefully removes and mends the area around the cancerous growths in [target]'s [affected.name] with \the [tool].", \
		"You carefully remove and mends the area around the cancerous growths in [target]'s [affected.name] with \the [tool]." )
		affected.cancer_stage = 0

/datum/surgery_step/internal/fix_organ_cancer/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if(!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, getting mess in and tearing the inside of [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, getting mess in and tearing the inside of [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 10)
*/

////////CUT LIMB/////////
/datum/surgery_step/generic/cut_limb
	allowed_tools = list(
		/obj/item/weapon/circular_saw = 100,
		/obj/item/weapon/kitchen/utensil/knife/large/butch = 75,
		/obj/item/weapon/hatchet = 75,
		)

	min_duration = 110
	max_duration = 160

/datum/surgery_step/generic/cut_limb/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (target_zone == "eyes")	//there are specific steps for eye surgery
		return 0
	if (!hasorgans(target))
		return 0
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (affected == null)
		return 0
	if (affected.status & ORGAN_DESTROYED)
		return 0
	return target_zone != LIMB_CHEST && target_zone != LIMB_GROIN && target_zone != LIMB_HEAD

/datum/surgery_step/generic/cut_limb/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] is beginning to cut off [target]'s [affected.display_name] with \the [tool]." , \
	"You are beginning to cut off [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("Your [affected.display_name] is being ripped apart!",1)
	..()

/datum/surgery_step/generic/cut_limb/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] cuts off [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You cut off [target]'s [affected.display_name] with \the [tool].</span>")
	affected.droplimb(1,0)

/datum/surgery_step/generic/cut_limb/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, sawing through the bone in [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, sawing through the bone in [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 30)
	affected.fracture()
