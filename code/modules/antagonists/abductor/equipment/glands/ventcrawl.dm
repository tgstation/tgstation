/obj/item/organ/heart/gland/ventcrawling
	true_name = "pliant cartilage enabler. Allows the abductee to crawl through vents without trouble."
	cooldown_low = 1800
	cooldown_high = 2400
	uses = 1
	icon_state = "vent"
	mind_control_uses = 4
	mind_control_duration = 1800

/obj/item/organ/heart/gland/ventcrawling/activate()
	to_chat(owner, span_notice("You feel very stretchy."))
	ADD_TRAIT(owner, TRAIT_VENTCRAWLER_ALWAYS, type)
