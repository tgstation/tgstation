/obj/item/organ/internal/heart/gland/slime
	abductor_hint = "gastric animation galvanizer. The abductee occasionally vomits slimes. Slimes will no longer attack the abductee."
	cooldown_low = 600
	cooldown_high = 1200
	uses = -1
	icon_state = "slime"
	mind_control_uses = 1
	mind_control_duration = 2400

/obj/item/organ/internal/heart/gland/slime/on_mob_insert(mob/living/carbon/gland_owner)
	. = ..()
	gland_owner.faction |= FACTION_SLIME
	gland_owner.grant_language(/datum/language/slime, source = LANGUAGE_GLAND)

/obj/item/organ/internal/heart/gland/slime/on_mob_remove(mob/living/carbon/gland_owner)
	. = ..()
	gland_owner.faction -= FACTION_SLIME
	gland_owner.remove_language(/datum/language/slime, source = LANGUAGE_GLAND)

/obj/item/organ/internal/heart/gland/slime/activate()
	to_chat(owner, span_warning("You feel nauseated!"))
	owner.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = 20)

	var/mob/living/basic/slime/new_baby_slime = new(get_turf(owner), /datum/slime_type/grey)
	new_baby_slime.befriend(owner)
