#define IS_ORGANIC_LIMB(limb) (limb.bodytype & BODYTYPE_ORGANIC)

/proc/replace_body_part(mob/living/carbon/human/human_holder, zone, obj/item/bodypart/prosthetic)
	var/obj/item/bodypart/old_limb = human_holder.get_bodypart(zone)
	prosthetic.replace_limb(human_holder, special = TRUE)
	qdel(old_limb)
