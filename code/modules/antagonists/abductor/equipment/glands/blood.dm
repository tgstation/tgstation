/obj/item/organ/heart/gland/blood
	abductor_hint = "pseudonuclear hemo-destabilizer. Periodically randomizes the abductee's bloodtype into a random reagent."
	cooldown_low = 1200
	cooldown_high = 1800
	uses = -1
	icon_state = "egg"
	lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	mind_control_uses = 3
	mind_control_duration = 1500

/obj/item/organ/heart/gland/blood/activate()
	if(!ishuman(owner) || !owner.dna.species)
		return
	var/mob/living/carbon/human/owner_mob = owner
	to_chat(owner_mob, span_warning("You feel your blood heat up for a moment."))
	owner_mob.set_blood_type(new /datum/blood_type/random_chemical(get_random_reagent_id()))
