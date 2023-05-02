/datum/component/unbreakable
	COOLDOWN_DECLARE(surge_cooldown)

/datum/component/unbreakable/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	ADD_TRAIT(parent, TRAIT_UNBREAKABLE, INNATE_TRAIT)

/datum/component/unbreakable/Destroy(force, silent)
	REMOVE_TRAIT(parent, TRAIT_UNBREAKABLE, INNATE_TRAIT)
	return ..()

/datum/component/unbreakable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_STATCHANGE, PROC_REF(surge))

/datum/component/unbreakable/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_STATCHANGE)

/datum/component/unbreakable/proc/surge(mob/living/carbon/human/surged, new_stat)
	SIGNAL_HANDLER
	if(new_stat < SOFT_CRIT || new_stat >= DEAD)
		return
	if(!COOLDOWN_FINISHED(src, surge_cooldown))
		return
	COOLDOWN_START(src, surge_cooldown, 1 MINUTES)
	surged.balloon_alert(surged, "you refuse to give up!")//breaks balloon alert conventions by using a "!" for a fail message but that's okay because it's a pretty awesome moment
	surged.heal_overall_damage(brute = 15, burn = 15, required_bodytype = BODYTYPE_ORGANIC)
	if(surged.reagents.get_reagent_amount(/datum/reagent/medicine/ephedrine) < 20)
		surged.reagents.add_reagent(/datum/reagent/medicine/ephedrine, 10)
	if(surged.reagents.get_reagent_amount(/datum/reagent/medicine/epinephrine) < 20)
		surged.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 10)
