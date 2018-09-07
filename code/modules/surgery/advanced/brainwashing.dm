/obj/item/disk/surgery/brainwashing
	name = "Brainwashing Surgery Disk"
	desc = "The disk provides instructions on how to impress an order on a brain, making it the primary objective of the patient."
	surgeries = list(/datum/surgery/advanced/brainwashing)

/datum/surgery/advanced/brainwashing
	name = "Brainwashing"
	desc = "A surgical procedure which directly implants a directive into the patient's brain, making it their absolute priority. It can be cleared using a mindshield implant."
	steps = list(
	/datum/surgery_step/incise,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/saw,
	/datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/brainwash,
	/datum/surgery_step/close)

	species = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_HEAD)

/datum/surgery/advanced/brainwashing/can_start(mob/user, mob/living/carbon/target)
	if(!..())
		return FALSE
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B)
		return FALSE
	return TRUE

/datum/surgery_step/brainwash
	name = "brainwash"
	implements = list(/obj/item/hemostat = 85, TOOL_WIRECUTTER = 50, /obj/item/stack/packageWrap = 35, /obj/item/stack/cable_coil = 15)
	time = 200
	var/objective

/datum/surgery_step/brainwash/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	objective = stripped_input(user, "Choose the objective to imprint on your victim's brain.", "Brainwashing", null, MAX_MESSAGE_LEN)
	if(!objective)
		return -1
	user.visible_message("[user] begins to tinker with [target]'s brain.", "<span class='notice'>You begin to brainwash [target]...</span>")

/datum/surgery_step/brainwash/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!target.mind)
		user.visible_message("[target] doesn't respond to the brainwashing, as if [target.p_they()] lacked a mind...")
		return FALSE
	if(target.has_trait(TRAIT_MINDSHIELD))
		user.visible_message("You hear a faint buzzing from a device inside [target]'s brain, and the brainwashing is erased.")
		return FALSE
	user.visible_message("[user] successfully brainwashes [target]!", "<span class='notice'>You succeed in brainwashing [target].</span>")
	to_chat(target, "<span class='userdanger'>A new compulsion fills your mind... you feel forced to obey it!</span>")
	brainwash(target, objective)
	message_admins("[ADMIN_LOOKUPFLW(user)] surgically brainwashed [ADMIN_LOOKUPFLW(target)] with the objective '[objective]'.")
	log_game("[key_name(user)] surgically brainwashed [key_name(target)] with the objective '[objective]'.")
	return TRUE

/datum/surgery_step/brainwash/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		user.visible_message("<span class='warning'>[user] damages some brain tissue!</span>", "<span class='warning'>You bruise some brain tissue!</span>")
		target.adjustBrainLoss(40)
	else
		user.visible_message("<span class='warning'>[user] suddenly notices that the brain [user.p_they()] [user.p_were()] working on is not there anymore.", "<span class='warning'>You suddenly notice that the brain you were working on is not there anymore.</span>")
	return FALSE