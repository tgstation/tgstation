// A 10% chance that out of a group of 25 people, one person will get appendicitis in 1 hour.
#define APPENDICITIS_PROB 100 * (0.1 * (1 / 25) / 3600)
#define INFLAMATION_ADVANCEMENT_PROB 2

/obj/item/organ/internal/appendix
	name = "appendix"
	icon_state = "appendix"
	base_icon_state = "appendix"
	visual = FALSE
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_APPENDIX
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/toxin/bad_food = 5)
	grind_results = list(/datum/reagent/toxin/bad_food = 5)
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	now_failing = "<span class='warning'>An explosion of pain erupts in your lower right abdomen!</span>"
	now_fixed = "<span class='info'>The pain in your abdomen has subsided.</span>"

	var/inflamation_stage = 0

/obj/item/organ/internal/appendix/update_name()
	. = ..()
	name = "[inflamation_stage ? "inflamed " : null][initial(name)]"

/obj/item/organ/internal/appendix/update_icon_state()
	icon_state = "[base_icon_state][inflamation_stage ? "inflamed" : ""]"
	return ..()

/obj/item/organ/internal/appendix/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(!owner)
		return

	if(organ_flags & ORGAN_FAILING)
		// forced to ensure people don't use it to gain tox as slime person
		owner.adjustToxLoss(2 * seconds_per_tick, forced = TRUE)
	else if(inflamation_stage)
		inflamation(seconds_per_tick)
	else if(SPT_PROB(APPENDICITIS_PROB, seconds_per_tick))
		become_inflamed()

/obj/item/organ/internal/appendix/proc/become_inflamed()
	inflamation_stage = 1
	update_appearance()
	if(owner)
		ADD_TRAIT(owner, TRAIT_DISEASELIKE_SEVERITY_MEDIUM, type)
		owner.med_hud_set_status()
		notify_ghosts(
			"[owner] has developed spontaneous appendicitis!",
			source = owner,
			header = "Whoa, Sick!",
		)

/obj/item/organ/internal/appendix/proc/inflamation(seconds_per_tick)
	var/mob/living/carbon/organ_owner = owner
	if(inflamation_stage < 3 && SPT_PROB(INFLAMATION_ADVANCEMENT_PROB, seconds_per_tick))
		inflamation_stage += 1

	switch(inflamation_stage)
		if(1)
			if(SPT_PROB(2.5, seconds_per_tick))
				organ_owner.emote("cough")
		if(2)
			if(SPT_PROB(1.5, seconds_per_tick))
				to_chat(organ_owner, span_warning("You feel a stabbing pain in your abdomen!"))
				organ_owner.adjustOrganLoss(ORGAN_SLOT_APPENDIX, 5)
				organ_owner.Stun(rand(40, 60))
				organ_owner.adjustToxLoss(1, forced = TRUE)
		if(3)
			if(SPT_PROB(0.5, seconds_per_tick))
				organ_owner.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = 95)
				organ_owner.adjustOrganLoss(ORGAN_SLOT_APPENDIX, 15)


/obj/item/organ/internal/appendix/get_availability(datum/species/owner_species, mob/living/owner_mob)
	return owner_species.mutantappendix

/obj/item/organ/internal/appendix/on_mob_remove(mob/living/carbon/organ_owner)
	. = ..()
	REMOVE_TRAIT(organ_owner, TRAIT_DISEASELIKE_SEVERITY_MEDIUM, type)
	organ_owner.med_hud_set_status()

/obj/item/organ/internal/appendix/on_mob_insert(mob/living/carbon/organ_owner)
	. = ..()
	if(inflamation_stage)
		ADD_TRAIT(organ_owner, TRAIT_DISEASELIKE_SEVERITY_MEDIUM, type)
		organ_owner.med_hud_set_status()

/obj/item/organ/internal/appendix/get_status_text(advanced)
	if((!(organ_flags & ORGAN_FAILING)) && inflamation_stage)
		return "<font color='#ff9933'>Inflamed</font>"
	else
		return ..()

#undef APPENDICITIS_PROB
#undef INFLAMATION_ADVANCEMENT_PROB
