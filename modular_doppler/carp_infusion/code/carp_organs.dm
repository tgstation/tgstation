#define INFUSED_CARP_TOX_HEALING 0.5 // equivalent to omnizine (slower than you'd expect)
#define INFUSED_CARP_MAX_TOXIN_AMT 50 // how many units of carpotoxin do we want to produce before we stop making more?
#define INFUSED_CARP_TOXIN_RATE 0.6 // how many units of carpotoxin do we create per tick?

// Changes lung behavior to be vulnerable to >21kPa oxygen environments, not care about miasma, and require carpotoxin to not suffocate
/obj/item/organ/lungs/carp
	safe_oxygen_min = 0
	safe_oxygen_max = 22 // normal air is just about tolerable, pure o2 is BAD
	suffers_miasma = FALSE // you are from a species that eats things for a living
	crit_stabilizing_reagent = /datum/reagent/toxin/carpotoxin // you need to be immersed in space to not suffocate (see carp heart, you secrete this in space)

/obj/item/organ/brain/carp
	cooldown_time = 60 MINUTES // to allow for scenes w/o moodlet grief

// only try to bite people if we're not wearing a mask
/obj/item/organ/brain/carp/get_attacking_limb(mob/living/carbon/human/target)
	. = ..()
	if (!owner.wear_mask)
		return owner.get_bodypart(BODY_ZONE_HEAD)
	else
		return .

// see organ_sets/carp_organs.dm for removal of the carp tooth coughing thing
// carp teeth shenanigans are an action instead of a passive thing

/obj/item/organ/tongue/carp
	actions_types = list(/datum/action/cooldown/carp/tooth_fairy)

// stops carp infusion from setting the no-mask status
/obj/item/organ/tongue/carp/on_mob_insert(mob/living/carbon/tongue_owner, special, movement_flags)
	. = ..()
	var/mob/living/carbon/human/human_receiver = tongue_owner
	var/datum/species/rec_species = human_receiver.dna.species
	rec_species.update_no_equip_flags(tongue_owner, initial(rec_species.no_equip_flags)) // reset the mask removing thing

/datum/action/cooldown/carp/tooth_fairy
	name = "Space Dentistry"
	desc = "Your hyperactive jaws are constantly producing new teeth, allowing you to wiggle one loose to use as a makeshift knife, or whatever other nefarious purpose you have in mind."
	cooldown_time = 5 MINUTES
	button_icon_state = null

/datum/action/cooldown/carp/tooth_fairy/New(Target)
	. = ..()

	if (target)
		AddComponent(/datum/component/action_item_overlay, target)

/datum/action/cooldown/carp/tooth_fairy/Activate(atom/target)
	if (!owner)
		return

	var/mob/living/carbon/human/jaw_owner = owner
	if (jaw_owner)
		jaw_owner.balloon_alert_to_viewers("pulling out tooth...")
		if (do_after(jaw_owner, 5 SECONDS, target = jaw_owner))
			jaw_owner.visible_message(span_notice("[jaw_owner] reaches into [jaw_owner.p_their()] mouth and wiggles a fearsomely-sharp tooth loose with a disconcerting pop!"), span_notice("You reach into your mouth and wiggle a fearsomely-sharp tooth loose with a disconcerting pop!"))
			jaw_owner.put_in_hands(new /obj/item/knife/carp(), del_on_fail = FALSE)
			playsound(jaw_owner, 'sound/items/champagne_pop.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			StartCooldown()
			return

// carp hearts cause the user to secrete carpotoxin when in hard vacuum & in space, carpotoxin also heals equivalent to omnizine
/obj/item/organ/heart/carp
	organ_traits = list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE, TRAIT_CARP_GOODTOX)

// makes carpotoxin heal carp infused individuals (and is also not toxic to them)
/datum/reagent/toxin/carpotoxin/on_mob_metabolize(mob/living/affected_mob)
	if (toxpwr && HAS_TRAIT(affected_mob, TRAIT_CARP_GOODTOX))
		toxpwr = 0

	. = ..()

/datum/reagent/toxin/carpotoxin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	if (HAS_TRAIT(affected_mob, TRAIT_CARP_GOODTOX))
		var/need_mob_update
		need_mob_update += affected_mob.adjustToxLoss(-INFUSED_CARP_TOX_HEALING * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustOxyLoss(-(INFUSED_CARP_TOX_HEALING * 4) * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type) // give oxyloss a bump here because it's our equivalent to epinephrine for oxyloss, see lungs
		need_mob_update += affected_mob.adjustBruteLoss(-INFUSED_CARP_TOX_HEALING * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustFireLoss(-INFUSED_CARP_TOX_HEALING * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		if (need_mob_update)
			if (prob(1))
				affected_mob.visible_message(span_info("[affected_mob]'s wounds steadily close over and knit together."), span_info("Your wounds continue to steadily close over and knit together."))
			return UPDATE_MOB_HEALTH

	. = ..()

/obj/item/organ/heart/carp/on_life(seconds_per_tick, times_fired)
	. = ..()
	if (HAS_TRAIT(owner, TRAIT_CARP_GOODTOX) && owner.isinspace())
		if (!owner.reagents.has_reagent(/datum/reagent/toxin/carpotoxin, INFUSED_CARP_MAX_TOXIN_AMT))
			owner.reagents.add_reagent(/datum/reagent/toxin/carpotoxin, INFUSED_CARP_TOXIN_RATE * seconds_per_tick, no_react = TRUE) // no making rezodone inside of people for free

#undef INFUSED_CARP_TOX_HEALING
#undef INFUSED_CARP_MAX_TOXIN_AMT
#undef INFUSED_CARP_TOXIN_RATE
