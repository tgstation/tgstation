/obj/item/organ/heart/gland/spiderman
	true_name = "araneae cloister accelerator"
	cooldown_low = 450
	cooldown_high = 900
	uses = -1
	icon_state = "spider"
	mind_control_uses = 2
	mind_control_duration = 2400

/obj/item/organ/heart/gland/spiderman/Insert(mob/living/carbon/target, special = FALSE)
	. = ..()
	ADD_TRAIT(owner, TRAIT_FACTION_SPIDER, type)

/obj/item/organ/heart/gland/spiderman/Remove(mob/living/carbon/target, special = FALSE)
	REMOVE_TRAIT(owner, TRAIT_FACTION_SPIDER, type)
	return ..()

/obj/item/organ/heart/gland/spiderman/activate()
	to_chat(owner, span_warning("You feel something crawling in your skin."))
	var/obj/structure/spider/spiderling/S = new(owner.drop_location())
	S.directive = "Protect your nest inside [owner.real_name]."
