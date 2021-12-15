
/mob/living/carbon/human/species/alien/attack_larva(mob/living/carbon/human/species/alien/larva/L)
	return attack_alien(L)

/mob/living/carbon/human/species/alien/attack_paw(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(!.)
		return
	if(stat != DEAD)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(user.zone_selected))
		apply_damage(rand(1, 3), BRUTE, affecting)
