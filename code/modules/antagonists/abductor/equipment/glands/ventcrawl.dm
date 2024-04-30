/obj/item/organ/internal/heart/gland/ventcrawling
	abductor_hint = "pliant cartilage enabler. The abductee can crawl through vents without trouble."
	cooldown_low = 3 MINUTES
	cooldown_high = 4 MINUTES
	uses = 1
	icon_state = "vent"
	mind_control_uses = 4
	mind_control_duration = 3 MINUTES

/obj/item/organ/internal/heart/gland/ventcrawling/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	RegisterSignal(organ_owner, SIGNAL_ADDTRAIT(TRAIT_MOVE_VENTCRAWLING), PROC_REF(give_pipe_resistance))
	RegisterSignal(organ_owner, SIGNAL_REMOVETRAIT(TRAIT_MOVE_VENTCRAWLING), PROC_REF(take_pipe_resistance))

/obj/item/organ/internal/heart/gland/ventcrawling/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	UnregisterSignal(organ_owner, list(SIGNAL_ADDTRAIT(TRAIT_MOVE_VENTCRAWLING), SIGNAL_REMOVETRAIT(TRAIT_MOVE_VENTCRAWLING)))
	REMOVE_TRAITS_IN(organ_owner, ABDUCTOR_GLAND_VENTCRAWLING_TRAIT)

/obj/item/organ/internal/heart/gland/ventcrawling/activate()
	to_chat(owner, span_notice("You feel very stretchy."))
	ADD_TRAIT(owner, TRAIT_VENTCRAWLER_ALWAYS, ABDUCTOR_GLAND_TRAIT)

/obj/item/organ/internal/heart/gland/ventcrawling/proc/give_pipe_resistance()
	SIGNAL_HANDLER
	owner.add_traits(list(TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHEAT, TRAIT_RESISTCOLD, TRAIT_NOBREATH), ABDUCTOR_GLAND_VENTCRAWLING_TRAIT)

/obj/item/organ/internal/heart/gland/ventcrawling/proc/take_pipe_resistance()
	SIGNAL_HANDLER
	REMOVE_TRAITS_IN(owner, ABDUCTOR_GLAND_VENTCRAWLING_TRAIT)
