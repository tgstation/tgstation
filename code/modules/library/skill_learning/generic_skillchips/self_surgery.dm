/obj/item/skillchip/self_surgery
	name = "4U70-P3R4710N skillchip"
	desc = "A skillchip containing old Nanotrasen medical training protocols, which one could use to perform surgical operations on themselves. \
		This one doesn't look like it's in the best condition - bit rot has probably rendered it somewhat risky to use."
	auto_traits = list(TRAIT_SELF_SURGERY)
	skill_name = "Self Surgery"
	skill_description = "Allows you to perform surgery on yourself."
	skill_icon = FA_ICON_USER_DOCTOR
	activate_message = span_notice("You realize there's nothing stopping you from performing surgery on yourself.")
	deactivate_message = span_notice("You suddenly feel like you should never perform surgery on yourself.")

/obj/item/skillchip/self_surgery/Initialize(mapload, is_removable)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/skillchip/self_surgery/on_activate(mob/living/carbon/user, silent)
	. = ..()
	RegisterSignal(user, COMSIG_LIVING_INITIATE_SURGERY_STEP, PROC_REF(apply_surgery_penalty))

/obj/item/skillchip/self_surgery/on_deactivate(mob/living/carbon/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_LIVING_INITIATE_SURGERY_STEP)

/obj/item/skillchip/self_surgery/proc/apply_surgery_penalty(mob/living/carbon/_source, mob/living/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, datum/surgery_step/step, list/modifiers)
	SIGNAL_HANDLER
	if(user != target)
		return
	modifiers[FAIL_PROB_INDEX] += 33
	modifiers[SPEED_MOD_INDEX] *= 1.5
