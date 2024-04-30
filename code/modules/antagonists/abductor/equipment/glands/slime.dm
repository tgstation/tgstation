/obj/item/organ/internal/heart/gland/slime
	abductor_hint = "gastric animation galvanizer. The abductee occasionally vomits slimes. Slimes will no longer attack the abductee."
	cooldown_low = 1 MINUTES
	cooldown_high = 2 MINUTES
	uses = -1
	icon_state = "slime"
	mind_control_uses = 1
	mind_control_duration = 4 MINUTES

/obj/item/organ/internal/heart/gland/slime/on_insert(mob/living/carbon/gland_owner)
	. = ..()
	//gland_owner.faction |= FACTION_SLIME
	gland_owner.grant_language(/datum/language/slime, TRUE, TRUE, LANGUAGE_GLAND)

/obj/item/organ/internal/heart/gland/slime/on_remove(mob/living/carbon/gland_owner)
	. = ..()
	//gland_owner.faction -= FACTION_SLIME
	gland_owner.remove_language(/datum/language/slime, TRUE, TRUE, LANGUAGE_GLAND)

/obj/item/organ/internal/heart/gland/slime/activate()
	to_chat(owner, span_warning("You feel nauseated!"))
	owner.vomit(20)

	var/mob/living/basic/slime/Slime = new(get_turf(owner))
	SEND_SIGNAL(Slime, COMSIG_FRIENDSHIP_CHANGE, owner, 110)
