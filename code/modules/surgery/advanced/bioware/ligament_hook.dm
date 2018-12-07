/datum/surgery/advanced/bioware/ligament_hook
	name = "Ligament Hook"
	desc = "A surgical procedure which reshapes the connections between torso and limbs, making it so limbs can be attached manually if severed. \
	However this weakens the connection, making them easier to detach as well."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/reshape_ligaments,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_LIGAMENTS

/datum/surgery_step/reshape_ligaments
	name = "reshape ligaments"
	accept_hand = TRUE
	time = 125

/datum/surgery_step/reshape_ligaments/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] starts reshaping [target]'s ligaments into a hook-like shape.", "<span class='notice'>You start reshaping [target]'s ligaments into a hook-like shape.</span>")

/datum/surgery_step/reshape_ligaments/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] reshapes [target]'s ligaments into a connective hook!", "<span class='notice'>You reshape [target]'s ligaments into a connective hook!</span>")
	new /datum/bioware/hooked_ligaments(target)
	return TRUE

/datum/bioware/hooked_ligaments
	name = "Hooked Ligaments"
	desc = "The ligaments and nerve endings that connect the torso to the limbs are formed into a hook-like shape, so limbs can be attached without requiring surgery, but are easier to sever."
	mod_type = BIOWARE_LIGAMENTS

/datum/bioware/hooked_ligaments/on_gain()
	..()
	owner.add_trait(TRAIT_LIMBATTACHMENT, "ligament_hook")
	owner.add_trait(TRAIT_EASYDISMEMBER, "ligament_hook")

/datum/bioware/hooked_ligaments/on_lose()
	..()
	owner.remove_trait(TRAIT_LIMBATTACHMENT, "ligament_hook")
	owner.remove_trait(TRAIT_EASYDISMEMBER, "ligament_hook")