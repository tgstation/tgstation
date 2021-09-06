/obj/item/organ/heart/gland/slime
	true_name = "gastric animation galvanizer"
	cooldown_low = 600
	cooldown_high = 1200
	uses = -1
	icon_state = "slime"
	mind_control_uses = 1
	mind_control_duration = 2400

/obj/item/organ/heart/gland/slime/Insert(mob/living/carbon/target, special = 0)
	. = ..()
	ADD_TRAIT(owner, TRAIT_FACTION_SLIME, type)
	owner.grant_language(/datum/language/slime, TRUE, TRUE, LANGUAGE_GLAND)

/obj/item/organ/heart/gland/slime/Remove(mob/living/carbon/target, special = 0)
	REMOVE_TRAIT(owner, TRAIT_FACTION_SLIME, type)
	owner.remove_language(/datum/language/slime, TRUE, TRUE, LANGUAGE_GLAND)
	return ..()

/obj/item/organ/heart/gland/slime/activate()
	to_chat(owner, span_warning("You feel nauseated!"))
	owner.vomit(20)

	var/mob/living/simple_animal/slime/Slime = new(get_turf(owner), "grey")
	Slime.set_friends(list(owner))
	Slime.set_leader(owner)
