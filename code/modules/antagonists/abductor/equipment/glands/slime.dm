/obj/item/organ/internal/heart/gland/slime
	abductor_hint = "gastric animation galvanizer. The abductee occasionally vomits slimes. Slimes will no longer attack the abductee."
	cooldown_low = 600
	cooldown_high = 1200
	uses = -1
	icon_state = "slime"
	mind_control_uses = 1
	mind_control_duration = 2400

/obj/item/organ/internal/heart/gland/slime/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	..()
	owner.faction |= FACTION_SLIME
	owner.grant_language(/datum/language/slime, TRUE, TRUE, LANGUAGE_GLAND)

/obj/item/organ/internal/heart/gland/slime/Remove(mob/living/carbon/M, special = FALSE)
	owner.faction -= FACTION_SLIME
	owner.remove_language(/datum/language/slime, TRUE, TRUE, LANGUAGE_GLAND)
	..()

/obj/item/organ/internal/heart/gland/slime/activate()
	to_chat(owner, span_warning("You feel nauseated!"))
	owner.vomit(20)

	var/mob/living/simple_animal/slime/Slime = new(get_turf(owner), "grey")
	Slime.set_friends(list(owner))
	Slime.set_leader(owner)
