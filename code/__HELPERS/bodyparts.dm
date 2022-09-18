#define IS_ORGANIC_LIMB(limb) (limb.bodytype & BODYTYPE_ORGANIC)

/mob/living/carbon/proc/del_and_replace_bodypart(obj/item/bodypart/new_limb, special)
	var/obj/item/bodypart/old_limb = get_bodypart(new_limb.body_zone)
	if(old_limb)
		qdel(old_limb)
	new_limb.attach_limb(src, special = special)
