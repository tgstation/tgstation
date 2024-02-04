// A 10% chance that out of a group of 25 people, one person will get appendicitis in 1 hour.
#define APPENDICITIS_PROB 100 * (0.1 * (1 / 25) / 3600)
#define INFLAMATION_ADVANCEMENT_PROB 2

#define NORMAL_APPENDICITIS "Appendicitis"
#define EXPLOSIVE_APPENDICITIS "Explosive Appendicitis"

#define NORMAL_MAX_STAGE 3
#define EXPLOSIVE_MAX_STAGE 8
#define EXPLOSIVE_TERMINAL_STAGE 3

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
	var/appendicitis_type = NORMAL_APPENDICITIS
	var/disease_trait = TRAIT_DISEASELIKE_SEVERITY_MEDIUM

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

	if(appendicitis_type)
		var/stable_medicine_efficiency = 100
		if(appendicitis_type == EXPLOSIVE_APPENDICITIS)
			stable_medicine_efficiency = 66
			if(SPT_PROB(5, seconds_per_tick) && get_stabilized_status())
				to_chat(owner, span_notice("You feel stabilized."))
				return

		if(HAS_TRAIT(owner, TRAIT_STABLE_APPENDIX) && prob(stable_medicine_efficiency))
			return

	if(organ_flags & ORGAN_FAILING)
		// forced to ensure people don't use it to gain tox as slime person
		owner.adjustToxLoss(2 * seconds_per_tick, forced = TRUE)
	else if(inflamation_stage && (appendicitis_type == NORMAL_APPENDICITIS))
		inflamation(seconds_per_tick)
	else if(inflamation_stage && (appendicitis_type == EXPLOSIVE_APPENDICITIS))
		bursting(seconds_per_tick)
	else if(SPT_PROB(APPENDICITIS_PROB, seconds_per_tick))
		var/disease_type = NORMAL_APPENDICITIS
		var/severity_type = TRAIT_DISEASELIKE_SEVERITY_MEDIUM
		var/notification_type = "spontaneous"
		if(prob(50))
			disease_type = EXPLOSIVE_APPENDICITIS
			severity_type = TRAIT_DISEASELIKE_SEVERITY_HIGH
			notification_type = "explosive"
		become_inflamed(disease_type, severity_type, notification_type)

/mob/living/carbon/human/proc/become_inflamed_test()
	var/obj/item/organ/internal/appendix/gignus = locate() in src.organs
	gignus.become_inflamed(EXPLOSIVE_APPENDICITIS, TRAIT_DISEASELIKE_SEVERITY_HIGH, "explosive")

/obj/item/organ/internal/appendix/proc/become_inflamed(disease_type, severity_type, notification_type)
	appendicitis_type = disease_type
	disease_trait = severity_type
	inflamation_stage = 1
	update_appearance()
	if(owner)
		ADD_TRAIT(owner, disease_trait, type)
		owner.med_hud_set_status()
		notify_ghosts(
			"[owner] has developed [notification_type] appendicitis!",
			source = owner,
			header = "Whoa, Sick!",
		)

/obj/item/organ/internal/appendix/proc/inflamation(seconds_per_tick)
	var/mob/living/carbon/organ_owner = owner
	if(inflamation_stage < NORMAL_MAX_STAGE && SPT_PROB(INFLAMATION_ADVANCEMENT_PROB, seconds_per_tick))
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

/obj/item/organ/internal/appendix/proc/get_stabilized_status()
	var/list/holder_list = owner?.reagents.reagent_list
	return locate(/datum/reagent/stabilizing_agent) in holder_list

/obj/item/organ/internal/appendix/proc/bursting(seconds_per_tick)
	var/mob/living/carbon/organ_owner = owner
	if(inflamation_stage < EXPLOSIVE_MAX_STAGE && SPT_PROB(INFLAMATION_ADVANCEMENT_PROB * 0.5, seconds_per_tick))
		inflamation_stage += 1

	if(get_stabilized_status() && inflamation_stage < EXPLOSIVE_TERMINAL_STAGE)
		inflamation_stage = 0
		appendicitis_type = null
		to_chat(organ_owner, span_notice("Your chest feels like it's completely stabilized. It doesn't hurt at all!"))
		return

	switch(inflamation_stage)
		if(1 to 2)
			if(SPT_PROB(0.5, seconds_per_tick))
				to_chat(organ_owner, span_warning("Your chest hurts miserably, as if something was pressing on it very heavily."))
				INVOKE_ASYNC(organ_owner, TYPE_PROC_REF(/mob, emote), "grimace")
		if(EXPLOSIVE_TERMINAL_STAGE) // point of no return
			AddElement(/datum/element/dangerous_surgical_removal, fuse_time = 4 SECONDS, explosion_strength = 2, flag_blockers = ORGAN_FROZEN)
			inflamation_stage = EXPLOSIVE_TERMINAL_STAGE + 1
		if(4 to 5)
			if(SPT_PROB(1.5, seconds_per_tick))
				to_chat(organ_owner, span_warning("Your chest feels like it's barely able to keep something inside at bay, you feel extremely nauseous..."))
				INVOKE_ASYNC(organ_owner, TYPE_PROC_REF(/mob, emote), "sway")
				organ_owner.adjustOrganLoss(ORGAN_SLOT_APPENDIX, 5)
				organ_owner.Stun(rand(40, 60))
				organ_owner.adjustToxLoss(1, forced = TRUE)
		if(6)
			if(SPT_PROB(0.5, seconds_per_tick))
				organ_owner.visible_message(span_userdanger("[organ_owner] clutches at their lower abdomen!"), span_userdanger("You clutch at your lower abdomen in blinding pain! It feels like something is about to burst from your body!"))
			else if(SPT_PROB(1.5, seconds_per_tick))
				INVOKE_ASYNC(organ_owner, TYPE_PROC_REF(/mob, emote), "grimace")
				to_chat(organ_owner, span_warning("It's hard to think about anything but the crippling pain in your abdomen."))
				organ_owner.damageoverlaytemp = 60
				organ_owner.update_damage_hud()
			else if(SPT_PROB(2.5, seconds_per_tick))
				INVOKE_ASYNC(organ_owner, TYPE_PROC_REF(/mob, emote), "sway")
				to_chat(organ_owner, span_warning("You're becoming delirious from the explosive pain in your chest."))
				organ_owner.set_eye_blur_if_lower(6 SECONDS * seconds_per_tick)
		if(7)
			INVOKE_ASYNC(src, PROC_REF(kaboom))
			inflamation_stage = EXPLOSIVE_MAX_STAGE // nothing happens in 8

/obj/item/organ/internal/appendix/proc/kaboom()
	stoplag(60 SECONDS)
	if(get_stabilized_status())
		inflamation_stage = EXPLOSIVE_MAX_STAGE - 1
		return to_chat(owner, span_notice("Your chest feels slightly stabilized. It still hurts like hell though.."))
	playsound(get_turf(src), 'sound/effects/fuse.ogg', 80)
	owner.visible_message(span_userdanger("A strange sizzling sound emanates from [owner]..."))
	stoplag(5 SECONDS)
	explosion(owner, devastation_range = 0, heavy_impact_range = 1, light_impact_range = 2, flame_range = 3, flash_range = 4, explosion_cause = src)

/obj/item/organ/internal/appendix/get_availability(datum/species/owner_species, mob/living/owner_mob)
	return owner_species.mutantappendix

/obj/item/organ/internal/appendix/on_mob_remove(mob/living/carbon/organ_owner)
	. = ..()
	REMOVE_TRAIT(organ_owner, disease_trait, type)
	organ_owner.med_hud_set_status()

/obj/item/organ/internal/appendix/on_mob_insert(mob/living/carbon/organ_owner)
	. = ..()
	if(inflamation_stage)
		ADD_TRAIT(organ_owner, disease_trait, type)
		organ_owner.med_hud_set_status()

/obj/item/organ/internal/appendix/get_status_text()
	if((!(organ_flags & ORGAN_FAILING)) && inflamation_stage)
		return "<font color='#ff9933'>Inflamed</font>"
	else
		return ..()

#undef APPENDICITIS_PROB
#undef INFLAMATION_ADVANCEMENT_PROB
