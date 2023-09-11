//Quirks that have little gameplay impacts

/datum/quirk/item_quirk/allergic
	name = "Extreme Medicine Allergy"
	desc = "Ever since you were a kid, you've been allergic to certain chemicals..."
	icon = FA_ICON_PRESCRIPTION_BOTTLE
	gain_text = span_danger("You feel your immune system shift.")
	lose_text = span_notice("You feel your immune system phase back into perfect shape.")
	medical_record_text = "Patient's immune system responds violently to certain chemicals."
	hardcore_value = 3
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/item/reagent_containers/hypospray/medipen) // epinephrine medipen stops allergic reactions
	var/list/allergies = list()
	var/list/blacklist = list(
		/datum/reagent/medicine/c2,
		/datum/reagent/medicine/epinephrine,
		/datum/reagent/medicine/adminordrazine,
		/datum/reagent/medicine/omnizine/godblood,
		/datum/reagent/medicine/cordiolis_hepatico,
		/datum/reagent/medicine/synaphydramine,
		/datum/reagent/medicine/diphenhydramine,
		/datum/reagent/medicine/sansufentanyl
		)
	var/allergy_string

/datum/quirk/item_quirk/allergic/add_unique(client/client_source)
	var/list/chem_list = subtypesof(/datum/reagent/medicine) - blacklist
	var/list/allergy_chem_names = list()
	for(var/i in 0 to 5)
		var/datum/reagent/medicine/chem_type = pick_n_take(chem_list)
		allergies += chem_type
		allergy_chem_names += initial(chem_type.name)

	allergy_string = allergy_chem_names.Join(", ")
	name = "Extreme [allergy_string] Allergies"
	medical_record_text = "Patient's immune system responds violently to [allergy_string]"

	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/clothing/accessory/dogtag/allergy/dogtag = new(get_turf(human_holder), allergy_string)

	give_item_to_holder(dogtag, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS), flavour_text = "Make sure medical staff can see this...")

/datum/quirk/item_quirk/allergic/post_add()
	quirk_holder.add_mob_memory(/datum/memory/key/quirk_allergy, allergy_string = allergy_string)
	to_chat(quirk_holder, span_boldnotice("You are allergic to [allergy_string], make sure not to consume any of these!"))

/datum/quirk/item_quirk/allergic/process(seconds_per_tick)
	if(!iscarbon(quirk_holder))
		return

	if(IS_IN_STASIS(quirk_holder))
		return

	if(quirk_holder.stat == DEAD)
		return

	var/mob/living/carbon/carbon_quirk_holder = quirk_holder
	for(var/allergy in allergies)
		var/datum/reagent/instantiated_med = carbon_quirk_holder.reagents.has_reagent(allergy)
		if(!instantiated_med)
			continue
		//Just halts the progression, I'd suggest you run to medbay asap to get it fixed
		if(carbon_quirk_holder.reagents.has_reagent(/datum/reagent/medicine/epinephrine))
			instantiated_med.reagent_removal_skip_list |= ALLERGIC_REMOVAL_SKIP
			return //intentionally stops the entire proc so we avoid the organ damage after the loop
		instantiated_med.reagent_removal_skip_list -= ALLERGIC_REMOVAL_SKIP
		carbon_quirk_holder.adjustToxLoss(3 * seconds_per_tick)
		carbon_quirk_holder.reagents.add_reagent(/datum/reagent/toxin/histamine, 3 * seconds_per_tick)
		if(SPT_PROB(10, seconds_per_tick))
			carbon_quirk_holder.vomit()
			carbon_quirk_holder.adjustOrganLoss(pick(ORGAN_SLOT_BRAIN,ORGAN_SLOT_APPENDIX,ORGAN_SLOT_LUNGS,ORGAN_SLOT_HEART,ORGAN_SLOT_LIVER,ORGAN_SLOT_STOMACH),10)

/datum/quirk/body_purist
	name = "Body Purist"
	desc = "You believe your body is a temple and its natural form is an embodiment of perfection. Accordingly, you despise the idea of ever augmenting it with unnatural parts, cybernetic, prosthetic, or anything like it."
	icon = FA_ICON_PERSON_RAYS
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	gain_text = span_danger("You now begin to hate the idea of having cybernetic implants.")
	lose_text = span_notice("Maybe cybernetics aren't so bad. You now feel okay with augmentations and prosthetics.")
	medical_record_text = "This patient has disclosed an extreme hatred for unnatural bodyparts and augmentations."
	hardcore_value = 3
	mail_goodies = list(/obj/item/paper/pamphlet/cybernetics)
	var/cybernetics_level = 0

/datum/quirk/body_purist/add(client/client_source)
	check_cybernetics()
	RegisterSignal(quirk_holder, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_organ_gain))
	RegisterSignal(quirk_holder, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_organ_lose))
	RegisterSignal(quirk_holder, COMSIG_CARBON_ATTACH_LIMB, PROC_REF(on_limb_gain))
	RegisterSignal(quirk_holder, COMSIG_CARBON_REMOVE_LIMB, PROC_REF(on_limb_lose))

/datum/quirk/body_purist/remove()
	UnregisterSignal(quirk_holder, list(
		COMSIG_CARBON_GAIN_ORGAN,
		COMSIG_CARBON_LOSE_ORGAN,
		COMSIG_CARBON_ATTACH_LIMB,
		COMSIG_CARBON_REMOVE_LIMB,
	))
	quirk_holder.clear_mood_event("body_purist")

/datum/quirk/body_purist/proc/check_cybernetics()
	var/mob/living/carbon/owner = quirk_holder
	if(!istype(owner))
		return
	for(var/obj/item/bodypart/limb as anything in owner.bodyparts)
		if(IS_ROBOTIC_LIMB(limb))
			cybernetics_level++
	for(var/obj/item/organ/organ as anything in owner.organs)
		if(IS_ROBOTIC_ORGAN(organ) && !(organ.organ_flags & ORGAN_HIDDEN))
			cybernetics_level++
	update_mood()

/datum/quirk/body_purist/proc/update_mood()
	quirk_holder.clear_mood_event("body_purist")
	if(cybernetics_level)
		quirk_holder.add_mood_event("body_purist", /datum/mood_event/body_purist, -cybernetics_level * 10)

/datum/quirk/body_purist/proc/on_organ_gain(datum/source, obj/item/organ/new_organ, special)
	SIGNAL_HANDLER
	if(IS_ROBOTIC_ORGAN(new_organ) && !(new_organ.organ_flags & ORGAN_HIDDEN)) //why the fuck are there 2 of them
		cybernetics_level++
		update_mood()

/datum/quirk/body_purist/proc/on_organ_lose(datum/source, obj/item/organ/old_organ, special)
	SIGNAL_HANDLER
	if(IS_ROBOTIC_ORGAN(old_organ) && !(old_organ.organ_flags & ORGAN_HIDDEN))
		cybernetics_level--
		update_mood()

/datum/quirk/body_purist/proc/on_limb_gain(datum/source, obj/item/bodypart/new_limb, special)
	SIGNAL_HANDLER
	if(IS_ROBOTIC_LIMB(new_limb))
		cybernetics_level++
		update_mood()

/datum/quirk/body_purist/proc/on_limb_lose(datum/source, obj/item/bodypart/old_limb, special)
	SIGNAL_HANDLER
	if(IS_ROBOTIC_LIMB(old_limb))
		cybernetics_level--
		update_mood()

/datum/quirk/claustrophobia
	name = "Claustrophobia"
	desc = "You are terrified of small spaces and certain jolly figures. If you are placed inside any container, locker, or machinery, a panic attack sets in and you struggle to breathe."
	icon = FA_ICON_BOX_OPEN
	medical_record_text = "Patient demonstrates a fear of tight spaces."
	hardcore_value = 5
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/item/reagent_containers/syringe/convermol) // to help breathing

/datum/quirk/claustrophobia/remove()
	quirk_holder.clear_mood_event("claustrophobia")

/datum/quirk/claustrophobia/process(seconds_per_tick)
	if(quirk_holder.stat != CONSCIOUS || quirk_holder.IsSleeping() || quirk_holder.IsUnconscious())
		return

	if(HAS_TRAIT(quirk_holder, TRAIT_FEARLESS))
		return

	var/nick_spotted = FALSE

	for(var/mob/living/carbon/human/possible_claus in view(5, quirk_holder))
		if(evaluate_jolly_levels(possible_claus))
			nick_spotted = TRUE
			break

	if(!nick_spotted && isturf(quirk_holder.loc))
		quirk_holder.clear_mood_event("claustrophobia")
		return

	quirk_holder.add_mood_event("claustrophobia", /datum/mood_event/claustrophobia)
	quirk_holder.losebreath += 0.25 // miss a breath one in four times
	if(SPT_PROB(25, seconds_per_tick))
		if(nick_spotted)
			to_chat(quirk_holder, span_warning("Santa Claus is here! I gotta get out of here!"))
		else
			to_chat(quirk_holder, span_warning("You feel trapped!  Must escape... can't breathe..."))

///investigates whether possible_saint_nick possesses a high level of christmas cheer
/datum/quirk/claustrophobia/proc/evaluate_jolly_levels(mob/living/carbon/human/possible_saint_nick)
	if(!istype(possible_saint_nick))
		return FALSE

	if(istype(possible_saint_nick.back, /obj/item/storage/backpack/santabag))
		return TRUE

	if(istype(possible_saint_nick.head, /obj/item/clothing/head/costume/santa) || istype(possible_saint_nick.head,  /obj/item/clothing/head/helmet/space/santahat))
		return TRUE

	if(istype(possible_saint_nick.wear_suit, /obj/item/clothing/suit/space/santa))
		return TRUE

	return FALSE

/datum/quirk/depression
	name = "Depression"
	desc = "You sometimes just hate life."
	icon = FA_ICON_FROWN
	mob_trait = TRAIT_DEPRESSION
	gain_text = span_danger("You start feeling depressed.")
	lose_text = span_notice("You no longer feel depressed.") //if only it were that easy!
	medical_record_text = "Patient has a mild mood disorder causing them to experience acute episodes of depression."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	hardcore_value = 2
	mail_goodies = list(/obj/item/storage/pill_bottle/happinesspsych)

/datum/quirk/deviant_tastes
	name = "Deviant Tastes"
	desc = "You dislike food that most people enjoy, and find delicious what they don't."
	icon = FA_ICON_GRIN_TONGUE_SQUINT
	gain_text = span_notice("You start craving something that tastes strange.")
	lose_text = span_notice("You feel like eating normal food again.")
	medical_record_text = "Patient demonstrates irregular nutrition preferences."
	mail_goodies = list(/obj/item/food/urinalcake, /obj/item/food/badrecipe) // Mhhhmmm yummy

/datum/quirk/deviant_tastes/add(client/client_source)
	var/obj/item/organ/internal/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		return
	var/liked_foodtypes = tongue.liked_foodtypes
	tongue.liked_foodtypes = tongue.disliked_foodtypes
	tongue.disliked_foodtypes = liked_foodtypes

/datum/quirk/deviant_tastes/remove()
	var/obj/item/organ/internal/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		return
	tongue.liked_foodtypes = initial(tongue.liked_foodtypes)
	tongue.disliked_foodtypes = initial(tongue.disliked_foodtypes)

/datum/quirk/drunkhealing
	name = "Drunken Resilience"
	desc = "Nothing like a good drink to make you feel on top of the world. Whenever you're drunk, you slowly recover from injuries."
	icon = FA_ICON_WINE_BOTTLE
	gain_text = span_notice("You feel like a drink would do you good.")
	lose_text = span_danger("You no longer feel like drinking would ease your pain.")
	medical_record_text = "Patient has unusually efficient liver metabolism and can slowly regenerate wounds by drinking alcoholic beverages."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/effect/spawner/random/food_or_drink/booze)

/datum/quirk/drunkhealing/process(seconds_per_tick)
	switch(quirk_holder.get_drunk_amount())
		if (6 to 40)
			quirk_holder.adjustBruteLoss(-0.1 * seconds_per_tick, FALSE, required_bodytype = BODYTYPE_ORGANIC)
			quirk_holder.adjustFireLoss(-0.05 * seconds_per_tick, required_bodytype = BODYTYPE_ORGANIC)
		if (41 to 60)
			quirk_holder.adjustBruteLoss(-0.4 * seconds_per_tick, FALSE, required_bodytype = BODYTYPE_ORGANIC)
			quirk_holder.adjustFireLoss(-0.2 * seconds_per_tick, required_bodytype = BODYTYPE_ORGANIC)
		if (61 to INFINITY)
			quirk_holder.adjustBruteLoss(-0.8 * seconds_per_tick, FALSE, required_bodytype = BODYTYPE_ORGANIC)
			quirk_holder.adjustFireLoss(-0.4 * seconds_per_tick, required_bodytype = BODYTYPE_ORGANIC)

/datum/quirk/item_quirk/family_heirloom
	name = "Family Heirloom"
	desc = "You are the current owner of an heirloom, passed down for generations. You have to keep it safe!"
	icon = FA_ICON_TOOLBOX
	medical_record_text = "Patient demonstrates an unnatural attachment to a family heirloom."
	hardcore_value = 1
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES|QUIRK_MOODLET_BASED
	/// A weak reference to our heirloom.
	var/datum/weakref/heirloom
	mail_goodies = list(/obj/item/storage/secure/briefcase)

/datum/quirk/item_quirk/family_heirloom/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/heirloom_type

	// The quirk holder's species - we have a 50% chance, if we have a species with a set heirloom, to choose a species heirloom.
	var/datum/species/holder_species = human_holder.dna?.species
	if(holder_species && LAZYLEN(holder_species.family_heirlooms) && prob(50))
		heirloom_type = pick(holder_species.family_heirlooms)
	else
		// Our quirk holder's job
		var/datum/job/holder_job = human_holder.last_mind?.assigned_role
		if(holder_job && LAZYLEN(holder_job.family_heirlooms))
			heirloom_type = pick(holder_job.family_heirlooms)

	// If we didn't find an heirloom somehow, throw them a generic one
	if(!heirloom_type)
		heirloom_type = pick(/obj/item/toy/cards/deck, /obj/item/lighter, /obj/item/dice/d20)

	var/obj/new_heirloom = new heirloom_type(get_turf(human_holder))
	heirloom = WEAKREF(new_heirloom)

	give_item_to_holder(
		new_heirloom,
		list(
			LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
			LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
			LOCATION_HANDS = ITEM_SLOT_HANDS,
		),
		flavour_text = "This is a precious family heirloom, passed down from generation to generation. Keep it safe!",
	)

/datum/quirk/item_quirk/family_heirloom/post_add()
	var/list/names = splittext(quirk_holder.real_name, " ")
	var/family_name = names[names.len]

	var/obj/family_heirloom = heirloom?.resolve()
	if(!family_heirloom)
		to_chat(quirk_holder, span_boldnotice("A wave of existential dread runs over you as you realize your precious family heirloom is missing. Perhaps the Gods will show mercy on your cursed soul?"))
		return
	family_heirloom.AddComponent(/datum/component/heirloom, quirk_holder.mind, family_name)

	return ..()

/datum/quirk/item_quirk/family_heirloom/process()
	if(quirk_holder.stat == DEAD)
		return

	var/obj/family_heirloom = heirloom?.resolve()

	if(family_heirloom && (family_heirloom in quirk_holder.get_all_contents()))
		quirk_holder.clear_mood_event("family_heirloom_missing")
		quirk_holder.add_mood_event("family_heirloom", /datum/mood_event/family_heirloom)
	else
		quirk_holder.clear_mood_event("family_heirloom")
		quirk_holder.add_mood_event("family_heirloom_missing", /datum/mood_event/family_heirloom_missing)

/datum/quirk/item_quirk/family_heirloom/remove()
	quirk_holder.clear_mood_event("family_heirloom_missing")
	quirk_holder.clear_mood_event("family_heirloom")

/datum/quirk/frail
	name = "Frail"
	desc = "You have skin of paper and bones of glass! You suffer wounds much more easily than most."
	icon = FA_ICON_SKULL
	mob_trait = TRAIT_EASILY_WOUNDED
	gain_text = span_danger("You feel frail.")
	lose_text = span_notice("You feel sturdy again.")
	medical_record_text = "Patient is absurdly easy to injure. Please take all due diligence to avoid possible malpractice suits."
	hardcore_value = 4
	mail_goodies = list(/obj/effect/spawner/random/medical/minor_healing)

/datum/quirk/freerunning
	name = "Freerunning"
	desc = "You're great at quick moves! You can climb tables more quickly and take no damage from short falls."
	icon = FA_ICON_RUNNING
	mob_trait = TRAIT_FREERUNNING
	gain_text = span_notice("You feel lithe on your feet!")
	lose_text = span_danger("You feel clumsy again.")
	medical_record_text = "Patient scored highly on cardio tests."
	mail_goodies = list(/obj/item/melee/skateboard, /obj/item/clothing/shoes/wheelys/rollerskates)

#define GAMING_WITHDRAWAL_TIME (15 MINUTES)
/datum/quirk/gamer
	name = "Gamer"
	desc = "You are a hardcore gamer, and you have a need to game. You love winning and hate losing. You only like gamer food."
	icon = FA_ICON_GAMEPAD
	gain_text = span_notice("You feel the sudden urge to game.")
	lose_text = span_notice("You've lost all interest in gaming.")
	medical_record_text = "Patient has a severe video game addiction."
	mob_trait = TRAIT_GAMER
	mail_goodies = list(/obj/item/toy/intento, /obj/item/clothing/head/fedora)
	/// Timer for gaming withdrawal to kick in
	var/gaming_withdrawal_timer = TIMER_ID_NULL

/datum/quirk/gamer/add(client/client_source)
	var/obj/item/organ/internal/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(tongue)
		// Gamer diet
		tongue.liked_foodtypes = JUNKFOOD
	RegisterSignal(quirk_holder, COMSIG_MOB_WON_VIDEOGAME, PROC_REF(won_game))
	RegisterSignal(quirk_holder, COMSIG_MOB_LOST_VIDEOGAME, PROC_REF(lost_game))
	RegisterSignal(quirk_holder, COMSIG_MOB_PLAYED_VIDEOGAME, PROC_REF(gamed))

/datum/quirk/gamer/add_unique(client/client_source)
	// The gamer starts off quelled
	gaming_withdrawal_timer = addtimer(CALLBACK(src, PROC_REF(enter_withdrawal)), GAMING_WITHDRAWAL_TIME, TIMER_STOPPABLE)

/datum/quirk/gamer/remove()
	var/obj/item/organ/internal/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(tongue)
		tongue.liked_foodtypes = initial(tongue.liked_foodtypes)
	UnregisterSignal(quirk_holder, COMSIG_MOB_WON_VIDEOGAME)
	UnregisterSignal(quirk_holder, COMSIG_MOB_LOST_VIDEOGAME)
	UnregisterSignal(quirk_holder, COMSIG_MOB_PLAYED_VIDEOGAME)

/**
 * Gamer won a game
 *
 * Executed on the COMSIG_MOB_WON_VIDEOGAME signal
 * This signal should be called whenever a player has won a video game.
 * (E.g. Orion Trail)
 */
/datum/quirk/gamer/proc/won_game()
	SIGNAL_HANDLER
	// Epic gamer victory
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.add_mood_event("gamer_won", /datum/mood_event/gamer_won)

/**
 * Gamer lost a game
 *
 * Executed on the COMSIG_MOB_LOST_VIDEOGAME signal
 * This signal should be called whenever a player has lost a video game.
 * (E.g. Orion Trail)
 */
/datum/quirk/gamer/proc/lost_game()
	SIGNAL_HANDLER
	// Executed when a gamer has lost
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.add_mood_event("gamer_lost", /datum/mood_event/gamer_lost)
	// Executed asynchronously due to say()
	INVOKE_ASYNC(src, PROC_REF(gamer_moment))
/**
 * Gamer is playing a game
 *
 * Executed on the COMSIG_MOB_PLAYED_VIDEOGAME signal
 * This signal should be called whenever a player interacts with a video game.
 */
/datum/quirk/gamer/proc/gamed()
	SIGNAL_HANDLER

	var/mob/living/carbon/human/human_holder = quirk_holder
	// Remove withdrawal malus
	human_holder.clear_mood_event("gamer_withdrawal")
	// Reset withdrawal timer
	if (gaming_withdrawal_timer)
		deltimer(gaming_withdrawal_timer)
	gaming_withdrawal_timer = addtimer(CALLBACK(src, PROC_REF(enter_withdrawal)), GAMING_WITHDRAWAL_TIME, TIMER_STOPPABLE)


/datum/quirk/gamer/proc/gamer_moment()
	// It was a heated gamer moment...
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.say(";[pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER")]!!", forced = name)

/datum/quirk/gamer/proc/enter_withdrawal()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.add_mood_event("gamer_withdrawal", /datum/mood_event/gamer_withdrawal)

#undef GAMING_WITHDRAWAL_TIME

/datum/quirk/glass_jaw
	name = "Glass Jaw"
	desc = "You have a very fragile jaw. Any sufficiently hard blow to your head might knock you out."
	icon = FA_ICON_HAND_FIST
	gain_text = span_danger("Your jaw feels loose.")
	lose_text = span_notice("Your jaw feels fitting again.")
	medical_record_text = "Patient is absurdly easy to knock out. Do not allow them near a boxing ring."
	hardcore_value = 4
	mail_goodies = list(
		/obj/item/clothing/gloves/boxing,
		/obj/item/clothing/mask/luchador/rudos,
	)

/datum/quirk/glass_jaw/New()
	. = ..()
	//randomly picks between blue or red equipment for goodies
	if(prob(50))
		mail_goodies = list(
			/obj/item/clothing/gloves/boxing,
			/obj/item/clothing/mask/luchador/rudos,
		)
	else
		mail_goodies = list(
			/obj/item/clothing/gloves/boxing/blue,
			/obj/item/clothing/mask/luchador/tecnicos,
		)

/datum/quirk/glass_jaw/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(punch_out))

/datum/quirk/glass_jaw/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_APPLY_DAMAGE)

/datum/quirk/glass_jaw/proc/punch_out(mob/living/carbon/source, damage, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER
	if((damagetype != BRUTE) || (def_zone != BODY_ZONE_HEAD))
		return
	var/actual_damage = damage - (damage * blocked/100)
	//only roll for knockouts at 5 damage or more
	if(actual_damage < 5)
		return
	//blunt items are more likely to knock out, but sharp ones are still capable of doing it
	if(prob(CEILING(actual_damage * (sharpness & (SHARP_EDGED|SHARP_POINTY) ? 0.65 : 1), 1)))
		//don't display the message if little mac is already KO'd
		if(!source.IsUnconscious())
			source.visible_message(
				span_warning("[source] gets knocked out!"),
				span_userdanger("You get knocked out!"),
				vision_distance = COMBAT_MESSAGE_RANGE,
		)
		source.Unconscious(3 SECONDS)

/datum/quirk/heavy_sleeper
	name = "Heavy Sleeper"
	desc = "You sleep like a rock! Whenever you're put to sleep or knocked unconscious, you take a little bit longer to wake up."
	icon = FA_ICON_BED
	mob_trait = TRAIT_HEAVY_SLEEPER
	gain_text = span_danger("You feel sleepy.")
	lose_text = span_notice("You feel awake again.")
	medical_record_text = "Patient has abnormal sleep study results and is difficult to wake up."
	hardcore_value = 2
	mail_goodies = list(
		/obj/item/clothing/glasses/blindfold,
		/obj/item/bedsheet/random,
		/obj/item/clothing/under/misc/pj/red,
		/obj/item/clothing/head/costume/nightcap/red,
		/obj/item/clothing/under/misc/pj/blue,
		/obj/item/clothing/head/costume/nightcap/blue,
		/obj/item/pillow/random,
	)

/datum/quirk/hypersensitive
	name = "Hypersensitive"
	desc = "For better or worse, everything seems to affect your mood more than it should."
	icon = FA_ICON_FLUSHED
	gain_text = span_danger("You seem to make a big deal out of everything.")
	lose_text = span_notice("You don't seem to make a big deal out of everything anymore.")
	medical_record_text = "Patient demonstrates a high level of emotional volatility."
	hardcore_value = 3
	mail_goodies = list(/obj/effect/spawner/random/entertainment/plushie_delux)

/datum/quirk/hypersensitive/add(client/client_source)
	if (quirk_holder.mob_mood)
		quirk_holder.mob_mood.mood_modifier += 0.5

/datum/quirk/hypersensitive/remove()
	if (quirk_holder.mob_mood)
		quirk_holder.mob_mood.mood_modifier -= 0.5

/datum/quirk/indebted
	name = "Indebted"
	desc = "Bad life decisions, medical bills, student loans, whatever it may be, you've incurred quite the debt. A portion of all you receive will go towards extinguishing it."
	icon = FA_ICON_DOLLAR
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_HIDE_FROM_SCAN
	medical_record_text = "Alas, the patient struggled to scrape together enough money to pay the checkup bill."
	hardcore_value = 2

/datum/quirk/indebted/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(!human_holder.account_id)
		return
	var/datum/bank_account/account = SSeconomy.bank_accounts_by_id["[human_holder.account_id]"]
	var/debt = PAYCHECK_CREW * rand(275, 325)
	account.account_debt += debt
	RegisterSignal(account, COMSIG_BANK_ACCOUNT_DEBT_PAID, PROC_REF(on_debt_paid))
	to_chat(client_source.mob, span_warning("You remember, you've a hefty, [debt] credits debt to pay..."))

///Once the debt is extinguished, award an achievement and a pin for actually taking care of it.
/datum/quirk/indebted/proc/on_debt_paid(datum/bank_account/source)
	SIGNAL_HANDLER
	if(source.account_debt)
		return
	UnregisterSignal(source, COMSIG_BANK_ACCOUNT_DEBT_PAID)
	///The debt was extinguished while the quirk holder was logged out, so let's kindly award it once they come back.
	if(!quirk_holder.client)
		RegisterSignal(quirk_holder, COMSIG_MOB_LOGIN, PROC_REF(award_on_login))
	else
		quirk_holder.client.give_award(/datum/award/achievement/misc/debt_extinguished, quirk_holder)
	podspawn(list(
		"target" = get_turf(quirk_holder),
		"style" = STYLE_BLUESPACE,
		"spawn" = /obj/item/clothing/accessory/debt_payer_pin,
	))

/datum/quirk/indebted/proc/award_on_login(mob/source)
	SIGNAL_HANDLER
	quirk_holder.client.give_award(/datum/award/achievement/misc/debt_extinguished, quirk_holder)
	UnregisterSignal(source, COMSIG_MOB_LOGIN)

/datum/quirk/item_quirk/nearsighted
	name = "Nearsighted"
	desc = "You are nearsighted without prescription glasses, but spawn with a pair."
	icon = FA_ICON_GLASSES
	gain_text = span_danger("Things far away from you start looking blurry.")
	lose_text = span_notice("You start seeing faraway things normally again.")
	medical_record_text = "Patient requires prescription glasses in order to counteract nearsightedness."
	hardcore_value = 5
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/clothing/glasses/regular) // extra pair if orginal one gets broken by somebody mean

/datum/quirk/item_quirk/nearsighted/add_unique(client/client_source)
	var/glasses_name = client_source?.prefs.read_preference(/datum/preference/choiced/glasses) || "Regular"
	var/obj/item/clothing/glasses/glasses_type

	glasses_name = glasses_name == "Random" ? pick(GLOB.nearsighted_glasses) : glasses_name
	glasses_type = GLOB.nearsighted_glasses[glasses_name]

	give_item_to_holder(glasses_type, list(
		LOCATION_EYES = ITEM_SLOT_EYES,
		LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
		LOCATION_HANDS = ITEM_SLOT_HANDS,
	))

/datum/quirk/item_quirk/nearsighted/add(client/client_source)
	quirk_holder.become_nearsighted(QUIRK_TRAIT)

/datum/quirk/item_quirk/nearsighted/remove()
	quirk_holder.cure_nearsighted(QUIRK_TRAIT)

/datum/quirk/insanity
	name = "Reality Dissociation Syndrome"
	desc = "You suffer from a severe disorder that causes very vivid hallucinations. \
		Mindbreaker toxin can suppress its effects, and you are immune to mindbreaker's hallucinogenic properties. \
		THIS IS NOT A LICENSE TO GRIEF."
	icon = FA_ICON_GRIN_TONGUE_WINK
	gain_text = span_userdanger("...")
	lose_text = span_notice("You feel in tune with the world again.")
	medical_record_text = "Patient suffers from acute Reality Dissociation Syndrome and experiences vivid hallucinations."
	hardcore_value = 6
	mail_goodies = list(/obj/item/storage/pill_bottle/lsdpsych)
	/// Weakref to the trauma we give out
	var/datum/weakref/added_trama_ref

/datum/quirk/insanity/add(client/client_source)
	if(!iscarbon(quirk_holder))
		return
	var/mob/living/carbon/carbon_quirk_holder = quirk_holder

	// Setup our special RDS mild hallucination.
	// Not a unique subtype so not to plague subtypesof,
	// also as we inherit the names and values from our quirk.
	var/datum/brain_trauma/mild/hallucinations/added_trauma = new()
	added_trauma.resilience = TRAUMA_RESILIENCE_ABSOLUTE
	added_trauma.name = name
	added_trauma.desc = medical_record_text
	added_trauma.scan_desc = lowertext(name)
	added_trauma.gain_text = null
	added_trauma.lose_text = null

	carbon_quirk_holder.gain_trauma(added_trauma)
	added_trama_ref = WEAKREF(added_trauma)

/datum/quirk/insanity/post_add()
	var/rds_policy = get_policy("[type]") || "Please note that your [lowertext(name)] does NOT give you any additional right to attack people or cause chaos."
	// I don't /think/ we'll need this, but for newbies who think "roleplay as insane" = "license to kill", it's probably a good thing to have.
	to_chat(quirk_holder, span_big(span_info(rds_policy)))

/datum/quirk/insanity/remove()
	QDEL_NULL(added_trama_ref)

/datum/quirk/item_quirk/junkie
	name = "Junkie"
	desc = "You can't get enough of hard drugs."
	icon = FA_ICON_PILLS
	gain_text = span_danger("You suddenly feel the craving for drugs.")
	medical_record_text = "Patient has a history of hard drugs."
	hardcore_value = 4
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/effect/spawner/random/contraband/narcotics)
	var/drug_list = list(/datum/reagent/drug/blastoff, /datum/reagent/drug/krokodil, /datum/reagent/medicine/morphine, /datum/reagent/drug/happiness, /datum/reagent/drug/methamphetamine) //List of possible IDs
	var/datum/reagent/reagent_type //!If this is defined, reagent_id will be unused and the defined reagent type will be instead.
	var/datum/reagent/reagent_instance //! actual instanced version of the reagent
	var/where_drug //! Where the drug spawned
	var/obj/item/drug_container_type //! If this is defined before pill generation, pill generation will be skipped. This is the type of the pill bottle.
	var/where_accessory //! where the accessory spawned
	var/obj/item/accessory_type //! If this is null, an accessory won't be spawned.
	var/process_interval = 30 SECONDS //! how frequently the quirk processes
	var/next_process = 0 //! ticker for processing
	var/drug_flavour_text = "Better hope you don't run out..."

/datum/quirk/item_quirk/junkie/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder

	if(!reagent_type)
		reagent_type = pick(drug_list)

	reagent_instance = new reagent_type()

	for(var/addiction in reagent_instance.addiction_types)
		human_holder.last_mind?.add_addiction_points(addiction, 1000)

	var/current_turf = get_turf(quirk_holder)

	if(!drug_container_type)
		drug_container_type = /obj/item/storage/pill_bottle

	var/obj/item/drug_instance = new drug_container_type(current_turf)
	if(istype(drug_instance, /obj/item/storage/pill_bottle))
		var/pill_state = "pill[rand(1,20)]"
		for(var/i in 1 to 7)
			var/obj/item/reagent_containers/pill/pill = new(drug_instance)
			pill.icon_state = pill_state
			pill.reagents.add_reagent(reagent_type, 3)

	give_item_to_holder(
		drug_instance,
		list(
			LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
			LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
			LOCATION_HANDS = ITEM_SLOT_HANDS,
		),
		flavour_text = drug_flavour_text,
	)

	if(accessory_type)
		give_item_to_holder(
		accessory_type,
		list(
			LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
			LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
			LOCATION_HANDS = ITEM_SLOT_HANDS,
		)
	)

/datum/quirk/item_quirk/junkie/remove()
	if(quirk_holder && reagent_instance)
		for(var/addiction_type in subtypesof(/datum/addiction))
			quirk_holder.mind.remove_addiction_points(addiction_type, MAX_ADDICTION_POINTS)

/datum/quirk/item_quirk/junkie/process(seconds_per_tick)
	if(HAS_TRAIT(quirk_holder, TRAIT_LIVERLESS_METABOLISM))
		return
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(world.time > next_process)
		next_process = world.time + process_interval
		var/deleted = QDELETED(reagent_instance)
		var/missing_addiction = FALSE
		for(var/addiction_type in reagent_instance.addiction_types)
			if(!LAZYACCESS(human_holder.last_mind?.active_addictions, addiction_type))
				missing_addiction = TRUE
		if(deleted || missing_addiction)
			if(deleted)
				reagent_instance = new reagent_type()
			to_chat(quirk_holder, span_danger("You thought you kicked it, but you feel like you're falling back onto bad habits.."))
			for(var/addiction in reagent_instance.addiction_types)
				human_holder.last_mind?.add_addiction_points(addiction, 1000) ///Max that shit out

/datum/quirk/item_quirk/junkie/smoker
	name = "Smoker"
	desc = "Sometimes you just really want a smoke. Probably not great for your lungs."
	icon = FA_ICON_SMOKING
	gain_text = span_danger("You could really go for a smoke right about now.")
	lose_text = span_notice("You don't feel nearly as hooked to nicotine anymore.")
	medical_record_text = "Patient is a current smoker."
	reagent_type = /datum/reagent/drug/nicotine
	accessory_type = /obj/item/lighter/greyscale
	mob_trait = TRAIT_SMOKER
	hardcore_value = 1
	drug_flavour_text = "Make sure you get your favorite brand when you run out."
	mail_goodies = list(
		/obj/effect/spawner/random/entertainment/cigarette_pack,
		/obj/effect/spawner/random/entertainment/cigar,
		/obj/effect/spawner/random/entertainment/lighter,
		/obj/item/clothing/mask/cigarette/pipe,
	)

/datum/quirk/item_quirk/junkie/smoker/New()
	drug_container_type = pick(/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/fancy/cigarettes/cigpack_midori,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift,
		/obj/item/storage/fancy/cigarettes/cigpack_robust,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold,
		/obj/item/storage/fancy/cigarettes/cigpack_carp)

	return ..()

/datum/quirk/item_quirk/junkie/smoker/post_add()
	. = ..()
	quirk_holder.add_mob_memory(/datum/memory/key/quirk_smoker, protagonist = quirk_holder, preferred_brand = initial(drug_container_type.name))
	// smoker lungs have 25% less health and healing
	var/mob/living/carbon/carbon_holder = quirk_holder
	var/obj/item/organ/internal/lungs/smoker_lungs = null
	var/obj/item/organ/internal/lungs/old_lungs = carbon_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(old_lungs && IS_ORGANIC_ORGAN(old_lungs))
		if(isplasmaman(carbon_holder))
			smoker_lungs = /obj/item/organ/internal/lungs/plasmaman/plasmaman_smoker
		else if(isethereal(carbon_holder))
			smoker_lungs = /obj/item/organ/internal/lungs/ethereal/ethereal_smoker
		else
			smoker_lungs = /obj/item/organ/internal/lungs/smoker_lungs
	if(!isnull(smoker_lungs))
		smoker_lungs = new smoker_lungs
		smoker_lungs.Insert(carbon_holder, special = TRUE, drop_if_replaced = FALSE)

/datum/quirk/item_quirk/junkie/smoker/process(seconds_per_tick)
	. = ..()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/mask_item = human_holder.get_item_by_slot(ITEM_SLOT_MASK)
	if(istype(mask_item, /obj/item/clothing/mask/cigarette))
		var/obj/item/storage/fancy/cigarettes/cigarettes = drug_container_type
		if(istype(mask_item, initial(cigarettes.spawn_type)))
			quirk_holder.clear_mood_event("wrong_cigs")
		else
			quirk_holder.add_mood_event("wrong_cigs", /datum/mood_event/wrong_brand)

/datum/quirk/item_quirk/junkie/alcoholic
	name = "Alcoholic"
	desc = "You just can't live without alcohol. Your liver is a machine that turns ethanol into acetaldehyde."
	icon = FA_ICON_WINE_GLASS
	gain_text = span_danger("You really need a drink.")
	lose_text = span_notice("Alcohol doesn't seem nearly as enticing anymore.")
	medical_record_text = "Patient is an alcoholic."
	reagent_type = /datum/reagent/consumable/ethanol
	drug_container_type = /obj/item/reagent_containers/cup/glass/bottle/whiskey
	mob_trait = TRAIT_HEAVY_DRINKER
	hardcore_value = 1
	drug_flavour_text = "Make sure you get your favorite type of drink when you run out."
	mail_goodies = list(
		/obj/effect/spawner/random/food_or_drink/booze,
		/obj/item/book/bible/booze,
	)
	/// Cached typepath of the owner's favorite alcohol reagent
	var/datum/reagent/consumable/ethanol/favorite_alcohol

/datum/quirk/item_quirk/junkie/alcoholic/New()
	drug_container_type = pick(
		/obj/item/reagent_containers/cup/glass/bottle/whiskey,
		/obj/item/reagent_containers/cup/glass/bottle/vodka,
		/obj/item/reagent_containers/cup/glass/bottle/ale,
		/obj/item/reagent_containers/cup/glass/bottle/beer,
		/obj/item/reagent_containers/cup/glass/bottle/hcider,
		/obj/item/reagent_containers/cup/glass/bottle/wine,
		/obj/item/reagent_containers/cup/glass/bottle/sake,
	)

	return ..()

/datum/quirk/item_quirk/junkie/alcoholic/post_add()
	. = ..()
	RegisterSignal(quirk_holder, COMSIG_MOB_REAGENT_CHECK, PROC_REF(check_brandy))

	var/obj/item/reagent_containers/brandy_container = GLOB.alcohol_containers[drug_container_type]
	if(isnull(brandy_container))
		stack_trace("Alcoholic quirk added while the GLOB.alcohol_containers is (somehow) not initialized!")
		brandy_container = new drug_container_type
		favorite_alcohol = brandy_container.list_reagents[1]
		qdel(brandy_container)
	else
		favorite_alcohol = brandy_container.list_reagents[1]

	quirk_holder.add_mob_memory(/datum/memory/key/quirk_alcoholic, protagonist = quirk_holder, preferred_brandy = initial(favorite_alcohol.name))
	// alcoholic livers have 25% less health and healing
	var/obj/item/organ/internal/liver/alcohol_liver = quirk_holder.get_organ_slot(ORGAN_SLOT_LIVER)
	if(alcohol_liver && IS_ORGANIC_ORGAN(alcohol_liver)) // robotic livers aren't affected
		alcohol_liver.maxHealth = alcohol_liver.maxHealth * 0.75
		alcohol_liver.healing_factor = alcohol_liver.healing_factor * 0.75

/datum/quirk/item_quirk/junkie/alcoholic/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_REAGENT_CHECK)

/datum/quirk/item_quirk/junkie/alcoholic/proc/check_brandy(mob/source, datum/reagent/booze)
	SIGNAL_HANDLER

	//we don't care if it is not alcohol
	if(!istype(booze, /datum/reagent/consumable/ethanol))
		return

	if(istype(booze, favorite_alcohol))
		quirk_holder.clear_mood_event("wrong_alcohol")
	else
		quirk_holder.add_mood_event("wrong_alcohol", /datum/mood_event/wrong_brandy)

/datum/quirk/phobia
	name = "Phobia"
	desc = "You are irrationally afraid of something."
	icon = FA_ICON_SPIDER
	medical_record_text = "Patient has an irrational fear of something."
	mail_goodies = list(/obj/item/clothing/glasses/blindfold, /obj/item/storage/pill_bottle/psicodine)

/datum/quirk/light_step
	name = "Light Step"
	desc = "You walk with a gentle step; footsteps and stepping on sharp objects is quieter and less painful. Also, your hands and clothes will not get messed in case of stepping in blood."
	icon = FA_ICON_SHOE_PRINTS
	mob_trait = TRAIT_LIGHT_STEP
	gain_text = span_notice("You walk with a little more litheness.")
	lose_text = span_danger("You start tromping around like a barbarian.")
	medical_record_text = "Patient's dexterity belies a strong capacity for stealth."
	mail_goodies = list(/obj/item/clothing/shoes/sandal)

// Phobia will follow you between transfers
/datum/quirk/phobia/add(client/client_source)
	var/phobia = client_source?.prefs.read_preference(/datum/preference/choiced/phobia)
	if(!phobia)
		return

	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.gain_trauma(new /datum/brain_trauma/mild/phobia(phobia), TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/phobia/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.cure_trauma_type(/datum/brain_trauma/mild/phobia, TRAUMA_RESILIENCE_ABSOLUTE)


/datum/quirk/poor_aim
	name = "Stormtrooper Aim"
	desc = "You've never hit anything you were aiming for in your life."
	icon = FA_ICON_BULLSEYE
	medical_record_text = "Patient possesses a strong tremor in both hands."
	hardcore_value = 3
	mail_goodies = list(/obj/item/cardboard_cutout) // for target practice

/datum/quirk/poor_aim/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_MOB_FIRED_GUN, PROC_REF(on_mob_fired_gun))

/datum/quirk/poor_aim/remove(client/client_source)
	UnregisterSignal(quirk_holder, COMSIG_MOB_FIRED_GUN)

/datum/quirk/poor_aim/proc/on_mob_fired_gun(mob/user, obj/item/gun/gun_fired, target, params, zone_override, list/bonus_spread_values)
	SIGNAL_HANDLER
	bonus_spread_values[MIN_BONUS_SPREAD_INDEX] += 10
	bonus_spread_values[MAX_BONUS_SPREAD_INDEX] += 35

/datum/quirk/prosthetic_limb
	name = "Prosthetic Limb"
	desc = "An accident caused you to lose one of your limbs. Because of this, you now have a surplus prosthetic!"
	icon = "tg-prosthetic-leg"
	medical_record_text = "During physical examination, patient was found to have a low-budget prosthetic limb."
	hardcore_value = 3
	quirk_flags = QUIRK_HUMAN_ONLY // while this technically changes appearance, we don't want it to be shown on the dummy because it's randomized at roundstart
	mail_goodies = list(/obj/item/weldingtool/mini, /obj/item/stack/cable_coil/five)
	/// The slot to replace, in string form
	var/slot_string = "limb"
	/// the original limb from before the prosthetic was applied
	var/obj/item/bodypart/old_limb

/datum/quirk/prosthetic_limb/add_unique(client/client_source)
	var/limb_slot = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/bodypart/prosthetic
	switch(limb_slot)
		if(BODY_ZONE_L_ARM)
			prosthetic = new /obj/item/bodypart/arm/left/robot/surplus
			slot_string = "left arm"
		if(BODY_ZONE_R_ARM)
			prosthetic = new /obj/item/bodypart/arm/right/robot/surplus
			slot_string = "right arm"
		if(BODY_ZONE_L_LEG)
			prosthetic = new /obj/item/bodypart/leg/left/robot/surplus
			slot_string = "left leg"
		if(BODY_ZONE_R_LEG)
			prosthetic = new /obj/item/bodypart/leg/right/robot/surplus
			slot_string = "right leg"
	medical_record_text = "During physical examination, patient was found to have a low-budget prosthetic [slot_string]."
	old_limb = human_holder.return_and_replace_bodypart(prosthetic, special = TRUE)

/datum/quirk/prosthetic_limb/post_add()
	to_chat(quirk_holder, span_boldannounce("Your [slot_string] has been replaced with a surplus prosthetic. It is fragile and will easily come apart under duress. Additionally, \
	you need to use a welding tool and cables to repair it, instead of bruise packs and ointment."))

/datum/quirk/prosthetic_limb/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.del_and_replace_bodypart(old_limb, special = TRUE)
	old_limb = null

/datum/quirk/prosthetic_organ
	name = "Prosthetic Organ"
	desc = "An accident caused you to lose one of your organs. Because of this, you now have a surplus prosthetic!"
	icon = FA_ICON_LUNGS
	medical_record_text = "During physical examination, patient was found to have a low-budget prosthetic organ. \
		<b>Removal of these organs is known to be dangerous to the patient as well as the practitioner.</b>"
	hardcore_value = 3
	mail_goodies = list(/obj/item/storage/organbox)
	/// The slot to replace, in string form
	var/slot_string = "organ"
	/// The original organ from before the prosthetic was applied
	var/obj/item/organ/old_organ

/datum/quirk/prosthetic_organ/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/static/list/organ_slots = list(
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
	)
	var/list/possible_organ_slots = organ_slots.Copy()
	if(HAS_TRAIT(human_holder, TRAIT_NOBLOOD))
		possible_organ_slots -= ORGAN_SLOT_HEART
	if(HAS_TRAIT(human_holder, TRAIT_NOBREATH))
		possible_organ_slots -= ORGAN_SLOT_LUNGS
	if(HAS_TRAIT(human_holder, TRAIT_LIVERLESS_METABOLISM))
		possible_organ_slots -= ORGAN_SLOT_LIVER
	if(HAS_TRAIT(human_holder, TRAIT_NOHUNGER))
		possible_organ_slots -= ORGAN_SLOT_STOMACH
	if(!length(organ_slots)) //what the hell
		return
	var/organ_slot = pick(possible_organ_slots)
	var/obj/item/organ/prosthetic
	switch(organ_slot)
		if(ORGAN_SLOT_HEART)
			prosthetic = new /obj/item/organ/internal/heart/cybernetic/surplus
			slot_string = "heart"
		if(ORGAN_SLOT_LUNGS)
			prosthetic = new /obj/item/organ/internal/lungs/cybernetic/surplus
			slot_string = "lungs"
		if(ORGAN_SLOT_LIVER)
			prosthetic = new /obj/item/organ/internal/liver/cybernetic/surplus
			slot_string = "liver"
		if(ORGAN_SLOT_STOMACH)
			prosthetic = new /obj/item/organ/internal/stomach/cybernetic/surplus
			slot_string = "stomach"
	medical_record_text = "During physical examination, patient was found to have a low-budget prosthetic [slot_string]. \
	<b>Removal of these organs is known to be dangerous to the patient as well as the practitioner.</b>"
	old_organ = human_holder.get_organ_slot(organ_slot)
	if(prosthetic.Insert(human_holder, special = TRUE, drop_if_replaced = TRUE))
		old_organ.moveToNullspace()
		STOP_PROCESSING(SSobj, old_organ)

/datum/quirk/prosthetic_organ/post_add()
	to_chat(quirk_holder, span_boldannounce("Your [slot_string] has been replaced with a surplus organ. It is fragile and will easily come apart under duress. \
	Additionally, any EMP will make it stop working entirely."))

/datum/quirk/prosthetic_organ/remove()
	if(old_organ)
		old_organ.Insert(quirk_holder, special = TRUE)
	old_organ = null

/datum/quirk/pushover
	name = "Pushover"
	desc = "Your first instinct is always to let people push you around. Resisting out of grabs will take conscious effort."
	icon = FA_ICON_HANDSHAKE
	mob_trait = TRAIT_GRABWEAKNESS
	gain_text = span_danger("You feel like a pushover.")
	lose_text = span_notice("You feel like standing up for yourself.")
	medical_record_text = "Patient presents a notably unassertive personality and is easy to manipulate."
	hardcore_value = 4
	mail_goodies = list(/obj/item/clothing/gloves/cargo_gauntlet)

/datum/quirk/item_quirk/signer
	name = "Signer"
	desc = "You possess excellent communication skills in sign language."
	icon = FA_ICON_HANDS
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/clothing/gloves/radio)

/datum/quirk/item_quirk/signer/add_unique(client/client_source)
	quirk_holder.AddComponent(/datum/component/sign_language)
	var/obj/item/clothing/gloves/gloves_type = /obj/item/clothing/gloves/radio
	if(isplasmaman(quirk_holder))
		gloves_type = /obj/item/clothing/gloves/color/plasmaman/radio
	give_item_to_holder(gloves_type, list(LOCATION_GLOVES = ITEM_SLOT_GLOVES, LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/item_quirk/signer/remove()
	qdel(quirk_holder.GetComponent(/datum/component/sign_language))

/datum/quirk/skittish
	name = "Skittish"
	desc = "You're easy to startle, and hide frequently. Run into a closed locker to jump into it, as long as you have access. You can walk to avoid this."
	icon = FA_ICON_TRASH
	mob_trait = TRAIT_SKITTISH
	medical_record_text = "Patient demonstrates a high aversion to danger and has described hiding in containers out of fear."
	mail_goodies = list(/obj/structure/closet/cardboard)

/datum/quirk/throwingarm
	name = "Throwing Arm"
	desc = "Your arms have a lot of heft to them! Objects that you throw just always seem to fly further than everyone elses, and you never miss a toss."
	icon = FA_ICON_BASEBALL
	mob_trait = TRAIT_THROWINGARM
	gain_text = span_notice("Your arms are full of energy!")
	lose_text = span_danger("Your arms ache a bit.")
	medical_record_text = "Patient displays mastery over throwing balls."
	mail_goodies = list(/obj/item/toy/beach_ball/baseball, /obj/item/toy/basketball, /obj/item/toy/dodgeball)
