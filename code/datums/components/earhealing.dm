// An item worn in the ear slot with this component will heal your ears each
// Life() tick, even if normally your ears would be too damaged to heal.

/datum/component/wearertargeting/earhealing
	valid_slots = list(SLOT_EARS)
	signals = list(COMSIG_LIVING_LIFE)
	mobtype = /mob/living/carbon

/datum/component/wearertargeting/earhealing/Initialize()
	callback = CALLBACK(src, .proc/onMobLife) // We can't refer to src in type definition
	return ..()

/datum/component/wearertargeting/earhealing/proc/onMobLife(mob/living/carbon/user)
	if(!user.has_trait(TRAIT_DEAF))
		var/obj/item/organ/ears/ears = user.getorganslot(ORGAN_SLOT_EARS)
		if (ears)
			ears.deaf = max(ears.deaf - 1, (ears.ear_damage < UNHEALING_EAR_DAMAGE ? 0 : 1)) // Do not clear deafness while above the unhealing ear damage threshold
			ears.ear_damage = max(ears.ear_damage - 0.1, 0)
