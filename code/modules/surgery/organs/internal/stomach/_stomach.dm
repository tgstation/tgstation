//The contant in the rate of reagent transfer on life ticks
#define STOMACH_METABOLISM_CONSTANT 0.25

/obj/item/organ/internal/stomach
	name = "stomach"
	desc = "Onaka ga suite imasu."
	icon_state = "stomach"
	visual = FALSE
	w_class = WEIGHT_CLASS_SMALL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_STOMACH
	attack_verb_continuous = list("gores", "squishes", "slaps", "digests")
	attack_verb_simple = list("gore", "squish", "slap", "digest")

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY * 1.15 // ~13 minutes, the stomach is one of the first organs to die

	low_threshold_passed = "<span class='info'>Your stomach flashes with pain before subsiding. Food doesn't seem like a good idea right now.</span>"
	high_threshold_passed = "<span class='warning'>Your stomach flares up with constant pain- you can hardly stomach the idea of food right now!</span>"
	high_threshold_cleared = "<span class='info'>The pain in your stomach dies down for now, but food still seems unappealing.</span>"
	low_threshold_cleared = "<span class='info'>The last bouts of pain in your stomach have died out.</span>"

	food_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue = 5)
	//This is a reagent user and needs more then the 10u from edible component
	reagent_vol = 1000

	/// The rate that disgust decays at
	var/disgust_metabolism = 1

	/// The rate that the stomach will transfer reagents to the body
	var/metabolism_efficiency = 0.05 // the lowest we should go is 0.025

	/// Multiplier for hunger rate
	var/hunger_modifier = 1

	var/operated = FALSE //whether the stomach's been repaired with surgery and can be fixed again or not

/obj/item/organ/internal/stomach/Initialize(mapload)
	. = ..()
	//Non-edible organs do not get a reagent holder by default
	if(!reagents)
		create_reagents(reagent_vol, REAGENT_HOLDER_ALIVE)
	else
		reagents.flags |= REAGENT_HOLDER_ALIVE

/obj/item/organ/internal/stomach/on_life(seconds_per_tick, times_fired)
	. = ..()

	var/mob/living/carbon/human/human_owner = (ishuman(owner) ? owner : null)

	// manage hunger
	if(human_owner)
		handle_hunger(human_owner, seconds_per_tick, times_fired)

	// "digest" food, send all reagents that can metabolize to the body -  if we aren't failing that is
	handle_digestion(seconds_per_tick, times_fired)

	// If the stomach is not damaged exit out
	if(damage < low_threshold)
		return

	// We are checking if we have reagents in a damaged stomach.
	var/reagent_volume = 0
	for(var/datum/reagent/yummy as anything in reagents.reagent_list)
		var/actual_volume = yummy.volume
		if(organ_flags & ORGAN_EDIBLE)
			actual_volume -= food_reagents[yummy.type]
		if(actual_volume > 0)
			reagent_volume += actual_volume

	// Didn't find any yummies that weren't from the edible component
	if(reagent_volume <= 0)
		return

	// High damage = high chance of vomit
	if((damage >= high_threshold) && SPT_PROB(0.05 * damage * reagent_volume * reagent_volume, seconds_per_tick))
		owner.vomit(damage)
		reagents.remove_any(damage * 0.25) //the reagents got vomited out!
		to_chat(owner, span_warning("Your [src] reels in pain as you're incapable of holding down all that food!"))
	// Low damage = low chance of vomit
	else if(SPT_PROB(0.0125 * damage * reagent_volume * reagent_volume, seconds_per_tick))
		owner.vomit(damage)
		reagents.remove_any(damage * 0.25) //the reagents got vomited out!
		to_chat(owner, span_warning("Your [src] reels in pain as you're incapable of holding down all that food!"))

/// Handles digesting reagents and sending them to the body
/obj/item/organ/internal/stomach/proc/handle_digestion(seconds_per_tick, times_fired)
	if(organ_flags & ORGAN_FAILING)
		return
	for(var/datum/reagent/bit as anything in reagents.reagent_list)

		// If the reagent does not metabolize then it will sit in the stomach
		// This has an effect on items like plastic causing them to take up space in the stomach
		if(bit.metabolization_rate <= 0)
			continue

		//Ensure that the the minimum is equal to the metabolization_rate of the reagent if it is higher then the STOMACH_METABOLISM_CONSTANT
		var/rate_min = max(bit.metabolization_rate, STOMACH_METABOLISM_CONSTANT)
		//Do not transfer over more then we have
		var/amount_max = bit.volume

		//If the reagent is part of the food reagents for the organ
		//prevent all the reagents form being used leaving the food reagents
		var/amount_food = food_reagents[bit.type]
		if(amount_food)
			amount_max = max(amount_max - amount_food, 0)

		// Transfer the amount of reagents based on volume with a min amount of 1u
		var/amount = min((round(metabolism_efficiency * amount_max, 0.05) + rate_min) * seconds_per_tick, amount_max)

		if(amount <= 0)
			continue

		// transfer the reagents over to the body at the rate of the stomach metabolim
		// this way the body is where all reagents that are processed and react
		// the stomach manages how fast they are feed in a drip style
		reagents.trans_id_to(owner, bit.type, amount = amount)

/// Handles nutrition and hunger of the owner
/obj/item/organ/internal/stomach/proc/handle_hunger(mob/living/carbon/human/human, seconds_per_tick, times_fired)
	if(HAS_TRAIT(human, TRAIT_NOHUNGER))
		return //hunger is for BABIES

	// nutrition decrease and satiety
	if (human.nutrition > 0 && human.stat < DEAD)
		// THEY HUNGER
		var/hunger_rate = HUNGER_FACTOR
		if(human.mob_mood && human.mob_mood.sanity > SANITY_DISTURBED)
			hunger_rate *= max(1 - 0.002 * human.mob_mood.sanity, 0.5) //0.85 to 0.75
		// Whether we cap off our satiety or move it towards 0
		if(human.satiety > MAX_SATIETY)
			human.satiety = MAX_SATIETY
		else if(human.satiety > 0)
			human.satiety--
		else if(human.satiety < -MAX_SATIETY)
			human.satiety = -MAX_SATIETY
		else if(human.satiety < 0)
			human.satiety++
			if(SPT_PROB(round(-human.satiety/77), seconds_per_tick))
				human.set_jitter_if_lower(10 SECONDS)
			hunger_rate *= 3
		hunger_rate *= hunger_modifier
		hunger_rate *= human.physiology.hunger_mod
		human.adjust_nutrition(-hunger_rate * seconds_per_tick)

	//The fucking TRAIT_FAT mutation is the dumbest shit ever. It makes the code so difficult to work with
	if(human.nutrition > NUTRITION_LEVEL_FULL && !HAS_TRAIT(human, TRAIT_NOFAT))
		if(human.overeatduration < 20 MINUTES) //capped so people don't take forever to unfat
			human.overeatduration = min(human.overeatduration + (1 SECONDS * seconds_per_tick), 20 MINUTES)
	else
		if(human.overeatduration > 0)
			human.overeatduration = max(human.overeatduration - (2 SECONDS * seconds_per_tick), 0) //doubled the unfat rate

	if(HAS_TRAIT_FROM(human, TRAIT_FAT, OBESITY))//I share your pain, past coder.
		if(human.overeatduration < 200 SECONDS)
			to_chat(human, span_notice("You feel fit again!"))
			REMOVE_TRAIT(human, TRAIT_FAT, OBESITY)
			human.remove_movespeed_modifier(/datum/movespeed_modifier/obesity)
	else
		if(human.overeatduration >= 200 SECONDS)
			to_chat(human, span_danger("You suddenly feel blubbery!"))
			ADD_TRAIT(human, TRAIT_FAT, OBESITY)
			human.add_movespeed_modifier(/datum/movespeed_modifier/obesity)

	//metabolism change
	if(!(organ_flags & ORGAN_FAILING))
		if(human.nutrition > NUTRITION_LEVEL_FAT)
			human.metabolism_efficiency = 1
		else if(human.nutrition > NUTRITION_LEVEL_FED && human.satiety > 80)
			if(human.metabolism_efficiency != 1.25)
				to_chat(human, span_notice("You feel vigorous."))
				human.metabolism_efficiency = 1.25
		else if(human.nutrition < NUTRITION_LEVEL_SLUGGISH)
			if(human.metabolism_efficiency != 0.8)
				to_chat(human, span_notice("You feel sluggish."))
			human.metabolism_efficiency = 0.8
		else
			if(human.metabolism_efficiency == 1.25)
				to_chat(human, span_notice("You no longer feel vigorous."))
			else if(human.metabolism_efficiency == 0.8)
				to_chat(human, span_notice("You no longer feel sluggish."))
			human.metabolism_efficiency = 1
	else
		//always sluggish if failing
		if(human.metabolism_efficiency != 0.8)
			to_chat(human, span_notice("You feel sluggish."))
		human.metabolism_efficiency = 0.8

	//Hunger slowdown for if mood isn't enabled
	if(CONFIG_GET(flag/disable_human_mood))
		handle_hunger_slowdown(human)

	switch(human.nutrition)
		if(0 to NUTRITION_LEVEL_STARVING)
			human.throw_alert(ALERT_NUTRITION, /atom/movable/screen/alert/starving)
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			human.throw_alert(ALERT_NUTRITION, /atom/movable/screen/alert/hungry)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FULL)
			human.clear_alert(ALERT_NUTRITION)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			human.throw_alert(ALERT_NUTRITION, /atom/movable/screen/alert/fat)

///for when mood is disabled and hunger should handle slowdowns
/obj/item/organ/internal/stomach/proc/handle_hunger_slowdown(mob/living/carbon/human/human)
	var/hungry = (500 - human.nutrition) / 5 //So overeat would be 100 and default level would be 80
	if(hungry >= 70)
		human.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/hunger, multiplicative_slowdown = (hungry / 50))
	else
		human.remove_movespeed_modifier(/datum/movespeed_modifier/hunger)

/obj/item/organ/internal/stomach/get_availability(datum/species/owner_species, mob/living/owner_mob)
	return owner_species.mutantstomach

///This gets called after the owner takes a bite of food
/obj/item/organ/internal/stomach/proc/after_eat(atom/edible)
	return

/obj/item/organ/internal/stomach/Remove(mob/living/carbon/organ_owner, special = FALSE)
	. = ..()
	if(ishuman(organ_owner))
		var/mob/living/carbon/human/human_owner = organ_owner
		human_owner.clear_mood_event("disgust")
		human_owner.clear_alert(ALERT_DISGUST)
		human_owner.clear_alert(ALERT_NUTRITION)

/obj/item/organ/internal/stomach/bone
	name = "mass of bones"
	desc = "You have no idea what this strange ball of bones does."
	icon_state = "stomach-bone"
	metabolism_efficiency = 0.025 //as low as possible
	organ_traits = list(TRAIT_NOHUNGER)

/obj/item/organ/internal/stomach/bone/plasmaman
	name = "digestive crystal"
	desc = "A strange crystal that is responsible for metabolizing the unseen energy force that feeds plasmamen."
	icon_state = "stomach-p"
	metabolism_efficiency = 0.06
	organ_traits = null

/obj/item/organ/internal/stomach/cybernetic
	name = "basic cybernetic stomach"
	desc = "A basic device designed to mimic the functions of a human stomach"
	icon_state = "stomach-c"
	organ_flags = ORGAN_ROBOTIC
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.5
	metabolism_efficiency = 0.035 // not as good at digestion
	var/emp_vulnerability = 80 //Chance of permanent effects if emp-ed.

/obj/item/organ/internal/stomach/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		owner.vomit(stun = FALSE)
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)
	if(prob(emp_vulnerability/severity)) //Chance of permanent effects
		organ_flags |= ORGAN_EMP //Starts organ faliure - gonna need replacing soon.

/obj/item/organ/internal/stomach/cybernetic/tier2
	name = "cybernetic stomach"
	desc = "An electronic device designed to mimic the functions of a human stomach. Handles disgusting food a bit better."
	icon_state = "stomach-c-u"
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD
	disgust_metabolism = 2
	emp_vulnerability = 40
	metabolism_efficiency = 0.07

/obj/item/organ/internal/stomach/cybernetic/tier3
	name = "upgraded cybernetic stomach"
	desc = "An upgraded version of the cybernetic stomach, designed to improve further upon organic stomachs. Handles disgusting food very well."
	icon_state = "stomach-c-u2"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	disgust_metabolism = 3
	emp_vulnerability = 20
	metabolism_efficiency = 0.1

/obj/item/organ/internal/stomach/cybernetic/surplus
	name = "surplus prosthetic stomach"
	desc = "A mechanical plastic oval that utilizes sulfuric acid instead of stomach acid. \
		Very fragile, with painfully slow metabolism.\
		Offers no protection against EMPs."
	icon_state = "stomach-c-s"
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.35
	emp_vulnerability = 100
	metabolism_efficiency = 0.025 //as low as possible

//surplus organs are so awful that they explode when removed, unless failing
/obj/item/organ/internal/stomach/cybernetic/surplus/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dangerous_surgical_removal)

#undef STOMACH_METABOLISM_CONSTANT
