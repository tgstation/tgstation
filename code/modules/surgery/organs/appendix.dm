/obj/item/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	base_icon_state = "appendix"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_APPENDIX
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/toxin/bad_food = 5)
	grind_results = list(/datum/reagent/toxin/bad_food = 5)
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	now_failing = "<span class='warning'>An explosion of pain erupts in your lower right abdomen!</span>"
	now_fixed = "<span class='info'>The pain in your abdomen has subsided.</span>"

	var/inflamed

/obj/item/organ/appendix/update_name()
	. = ..()
	name = "[inflamed ? "inflamed " : null][initial(name)]"

/obj/item/organ/appendix/update_icon_state()
	icon_state = "[base_icon_state][inflamed ? "inflamed" : ""]"
	return ..()

/obj/item/organ/appendix/on_life(delta_time, times_fired)
	..()
	if(!(organ_flags & ORGAN_FAILING))
		return
	var/mob/living/carbon/M = owner
	if(M)
		M.adjustToxLoss(2 * delta_time, TRUE, TRUE) //forced to ensure people don't use it to gain tox as slime person

/obj/item/organ/appendix/get_availability(datum/species/S)
	return !(TRAIT_NOHUNGER in S.inherent_traits)

/obj/item/organ/appendix/Remove(mob/living/carbon/M, special = 0)
	for(var/datum/disease/appendicitis/A in M.diseases)
		A.cure()
		inflamed = TRUE
	update_appearance()
	..()

/obj/item/organ/appendix/Insert(mob/living/carbon/M, special = 0)
	..()
	if(inflamed)
		M.ForceContractDisease(new /datum/disease/appendicitis(), FALSE, TRUE)
