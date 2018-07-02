/obj/item/disk/surgery/nerve_grounding
	name = "Nerve Grounding Surgery Disk"
	desc = "The disk provides instructions on how to reroute the nervous system to ground electric shocks."
	surgeries = list(/datum/surgery/advanced/bioware/nerve_grounding)

/datum/surgery/advanced/bioware/nerve_grounding
	name = "nerve grounding"
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/ground_nerves,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_NERVES

/datum/surgery_step/ground_nerves
	name = "ground nerves"
	accept_hand = TRUE
	time = 155

/datum/surgery_step/ground_nerves/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] starts splicing together [target]'s nerves.", "<span class='notice'>You start splicing together [target]'s nerves.</span>")

/datum/surgery_step/ground_nerves/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] successfully splices [target]'s nervous system!", "<span class='notice'>You successfully splice [target]'s nervous system!</span>")
	new /datum/bioware/grounded_nerves(target)
	return TRUE

/datum/bioware/grounded_nerves
	name = "Grounded Nerves"
	desc = "Nerves form a safe path for electricity to traverse, protecting the body from electric shocks."
	mod_type = BIOWARE_NERVES
	var/prev_coeff

/datum/bioware/grounded_nerves/on_gain()
	..()
	prev_coeff = owner.physiology.siemens_coeff
	owner.physiology.siemens_coeff = 0

/datum/bioware/grounded_nerves/on_lose()
	..()
	owner.physiology.siemens_coeff = prev_coeff