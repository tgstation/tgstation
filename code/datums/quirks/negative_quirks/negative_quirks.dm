//predominantly negative traits
/datum/quirk/badback
	name = "Bad Back"
	desc = "Thanks to your poor posture, backpacks and other bags never sit right on your back. More evenly weighted objects are fine, though."
	icon = FA_ICON_HIKING
	value = -8
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	gain_text = span_danger("Your back REALLY hurts!")
	lose_text = span_notice("Your back feels better.")
	medical_record_text = "Patient scans indicate severe and chronic back pain."
	hardcore_value = 4
	mail_goodies = list(/obj/item/cane)
	var/datum/weakref/backpack

/datum/quirk/badback/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/storage/backpack/equipped_backpack = human_holder.back
	if(istype(equipped_backpack))
		quirk_holder.add_mood_event("back_pain", /datum/mood_event/back_pain)
		RegisterSignal(human_holder.back, COMSIG_ITEM_POST_UNEQUIP, PROC_REF(on_unequipped_backpack))
	else
		RegisterSignal(quirk_holder, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equipped_item))

/datum/quirk/badback/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_EQUIPPED_ITEM)

	var/obj/item/storage/equipped_backpack = backpack?.resolve()
	if(equipped_backpack)
		UnregisterSignal(equipped_backpack, COMSIG_ITEM_POST_UNEQUIP)
		quirk_holder.clear_mood_event("back_pain")

/// Signal handler for when the quirk_holder equips an item. If it's a backpack, adds the back_pain mood event.
/datum/quirk/badback/proc/on_equipped_item(mob/living/source, obj/item/equipped_item, slot)
	SIGNAL_HANDLER

	if(!(slot & ITEM_SLOT_BACK) || !istype(equipped_item, /obj/item/storage/backpack))
		return

	quirk_holder.add_mood_event("back_pain", /datum/mood_event/back_pain)
	RegisterSignal(equipped_item, COMSIG_ITEM_POST_UNEQUIP, PROC_REF(on_unequipped_backpack))
	UnregisterSignal(quirk_holder, COMSIG_MOB_EQUIPPED_ITEM)
	backpack = WEAKREF(equipped_item)

/// Signal handler for when the quirk_holder unequips an equipped backpack. Removes the back_pain mood event.
/datum/quirk/badback/proc/on_unequipped_backpack(obj/item/source, force, atom/newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_ITEM_POST_UNEQUIP)
	quirk_holder.clear_mood_event("back_pain")
	backpack = null
	RegisterSignal(quirk_holder, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equipped_item))

/datum/quirk/blooddeficiency
	name = "Blood Deficiency"
	desc = "Your body can't produce enough blood to sustain itself."
	icon = FA_ICON_TINT
	value = -8
	mob_trait = TRAIT_BLOOD_DEFICIENCY
	gain_text = span_danger("You feel your vigor slowly fading away.")
	lose_text = span_notice("You feel vigorous again.")
	medical_record_text = "Patient requires regular treatment for blood loss due to low production of blood."
	hardcore_value = 8
	mail_goodies = list(/obj/item/reagent_containers/blood/o_minus) // universal blood type that is safe for all
	var/min_blood = BLOOD_VOLUME_SAFE - 25 // just barely survivable without treatment

/datum/quirk/blooddeficiency/post_add()
	if(!ishuman(quirk_holder))
		return

	// for making sure the roundstart species has the right blood pack sent to them
	var/mob/living/carbon/human/carbon_target = quirk_holder
	carbon_target.dna.species.update_quirk_mail_goodies(carbon_target, src)

/**
 * Makes the mob lose blood from having the blood deficiency quirk, if possible
 *
 * Arguments:
 * * seconds_per_tick
 */
/datum/quirk/blooddeficiency/proc/lose_blood(seconds_per_tick)
	if(quirk_holder.stat == DEAD)
		return

	var/mob/living/carbon/human/carbon_target = quirk_holder
	if(HAS_TRAIT(carbon_target, TRAIT_NOBLOOD) && isnull(carbon_target.dna.species.exotic_blood)) //can't lose blood if your species doesn't have any
		return

	if (carbon_target.blood_volume <= min_blood)
		return
	// Ensures that we don't reduce total blood volume below min_blood.
	carbon_target.blood_volume = max(min_blood, carbon_target.blood_volume - carbon_target.dna.species.blood_deficiency_drain_rate * seconds_per_tick)

/datum/quirk/item_quirk/blindness
	name = "Blind"
	desc = "You are completely blind, nothing can counteract this."
	icon = FA_ICON_EYE_SLASH
	value = -16
	gain_text = span_danger("You can't see anything.")
	lose_text = span_notice("You miraculously gain back your vision.")
	medical_record_text = "Patient has permanent blindness."
	hardcore_value = 15
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/clothing/glasses/sunglasses, /obj/item/cane/white)

/datum/quirk/item_quirk/blindness/add_unique(client/client_source)
	give_item_to_holder(/obj/item/clothing/glasses/blindfold/white, list(LOCATION_EYES = ITEM_SLOT_EYES, LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/item_quirk/blindness/add(client/client_source)
	quirk_holder.become_blind(QUIRK_TRAIT)

/datum/quirk/item_quirk/blindness/remove()
	quirk_holder.cure_blind(QUIRK_TRAIT)

	/* A couple of brain tumor stats for anyone curious / looking at this quirk for balancing:
	 * - It takes less 16 minute 40 seconds to die from brain death due to a brain tumor.
	 * - It takes 1 minutes 40 seconds to take 10% (20 organ damage) brain damage.
	 * - 5u mannitol will heal 12.5% (25 organ damage) brain damage
	 */
/datum/quirk/item_quirk/brainproblems
	name = "Brain Tumor"
	desc = "You have a little friend in your brain that is slowly destroying it. Better bring some mannitol!"
	icon = FA_ICON_BRAIN
	value = -12
	gain_text = span_danger("You feel smooth.")
	lose_text = span_notice("You feel wrinkled again.")
	medical_record_text = "Patient has a tumor in their brain that is slowly driving them to brain death."
	hardcore_value = 12
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/item/storage/pill_bottle/mannitol/braintumor)

/datum/quirk/item_quirk/brainproblems/add_unique(client/client_source)
	give_item_to_holder(
		/obj/item/storage/pill_bottle/mannitol/braintumor,
		list(
			LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
			LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
			LOCATION_HANDS = ITEM_SLOT_HANDS,
		),
		flavour_text = "These will keep you alive until you can secure a supply of medication. Don't rely on them too much!",
	)

/datum/quirk/item_quirk/brainproblems/process(seconds_per_tick)
	if(quirk_holder.stat == DEAD)
		return

	if(HAS_TRAIT(quirk_holder, TRAIT_TUMOR_SUPPRESSED))
		return

	quirk_holder.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.2 * seconds_per_tick)

/datum/quirk/item_quirk/deafness
	name = "Deaf"
	desc = "You are incurably deaf."
	icon = FA_ICON_DEAF
	value = -8
	mob_trait = TRAIT_DEAF
	gain_text = span_danger("You can't hear anything.")
	lose_text = span_notice("You're able to hear again!")
	medical_record_text = "Patient's cochlear nerve is incurably damaged."
	hardcore_value = 12
	mail_goodies = list(/obj/item/clothing/mask/whistle)

/datum/quirk/item_quirk/deafness/add_unique(client/client_source)
	give_item_to_holder(/obj/item/clothing/accessory/deaf_pin, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/depression
	name = "Depression"
	desc = "You sometimes just hate life."
	icon = FA_ICON_FROWN
	mob_trait = TRAIT_DEPRESSION
	value = -3
	gain_text = span_danger("You start feeling depressed.")
	lose_text = span_notice("You no longer feel depressed.") //if only it were that easy!
	medical_record_text = "Patient has a mild mood disorder causing them to experience acute episodes of depression."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	hardcore_value = 2
	mail_goodies = list(/obj/item/storage/pill_bottle/happinesspsych)

/datum/quirk/item_quirk/family_heirloom
	name = "Family Heirloom"
	desc = "You are the current owner of an heirloom, passed down for generations. You have to keep it safe!"
	icon = FA_ICON_TOOLBOX
	value = -2
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

/datum/quirk/glass_jaw
	name = "Glass Jaw"
	desc = "You have a very fragile jaw. Any sufficiently hard blow to your head might knock you out."
	icon = FA_ICON_HAND_FIST
	value = -4
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

/datum/quirk/frail
	name = "Frail"
	desc = "You have skin of paper and bones of glass! You suffer wounds much more easily than most."
	icon = FA_ICON_SKULL
	value = -6
	mob_trait = TRAIT_EASILY_WOUNDED
	gain_text = span_danger("You feel frail.")
	lose_text = span_notice("You feel sturdy again.")
	medical_record_text = "Patient is absurdly easy to injure. Please take all due diligence to avoid possible malpractice suits."
	hardcore_value = 4
	mail_goodies = list(/obj/effect/spawner/random/medical/minor_healing)

/datum/quirk/heavy_sleeper
	name = "Heavy Sleeper"
	desc = "You sleep like a rock! Whenever you're put to sleep or knocked unconscious, you take a little bit longer to wake up."
	icon = FA_ICON_BED
	value = -2
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
	value = -2
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

/datum/quirk/light_drinker
	name = "Light Drinker"
	desc = "You just can't handle your drinks and get drunk very quickly."
	icon = FA_ICON_COCKTAIL
	value = -2
	mob_trait = TRAIT_LIGHT_DRINKER
	gain_text = span_notice("Just the thought of drinking alcohol makes your head spin.")
	lose_text = span_danger("You're no longer severely affected by alcohol.")
	medical_record_text = "Patient demonstrates a low tolerance for alcohol. (Wimp)"
	hardcore_value = 3
	mail_goodies = list(/obj/item/reagent_containers/cup/glass/waterbottle)


/datum/quirk/item_quirk/nearsighted
	name = "Nearsighted"
	desc = "You are nearsighted without prescription glasses, but spawn with a pair."
	icon = FA_ICON_GLASSES
	value = -4
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

/datum/quirk/nyctophobia
	name = "Nyctophobia"
	desc = "As far as you can remember, you've always been afraid of the dark. While in the dark without a light source, you instinctively act careful, and constantly feel a sense of dread."
	icon = FA_ICON_LIGHTBULB
	value = -3
	medical_record_text = "Patient demonstrates a fear of the dark. (Seriously?)"
	hardcore_value = 5
	mail_goodies = list(/obj/effect/spawner/random/engineering/flashlight)

/datum/quirk/nyctophobia/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_holder_moved))

/datum/quirk/nyctophobia/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOVABLE_MOVED)
	quirk_holder.clear_mood_event("nyctophobia")

/// Called when the quirk holder moves. Updates the quirk holder's mood.
/datum/quirk/nyctophobia/proc/on_holder_moved(mob/living/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(quirk_holder.stat != CONSCIOUS || quirk_holder.IsSleeping() || quirk_holder.IsUnconscious())
		return

	if(HAS_TRAIT(quirk_holder, TRAIT_FEARLESS))
		return

	var/mob/living/carbon/human/human_holder = quirk_holder

	if(human_holder.dna?.species.id in list(SPECIES_SHADOW, SPECIES_NIGHTMARE))
		return

	if((human_holder.sight & SEE_TURFS) == SEE_TURFS)
		return

	var/turf/holder_turf = get_turf(quirk_holder)

	var/lums = holder_turf.get_lumcount()

	if(lums > LIGHTING_TILE_IS_DARK)
		quirk_holder.clear_mood_event("nyctophobia")
		return

	if(quirk_holder.m_intent == MOVE_INTENT_RUN)
		to_chat(quirk_holder, span_warning("Easy, easy, take it slow... you're in the dark..."))
		quirk_holder.toggle_move_intent()
	quirk_holder.add_mood_event("nyctophobia", /datum/mood_event/nyctophobia)

#define MOOD_CATEGORY_PHOTOPHOBIA "photophobia"

/datum/quirk/photophobia
	name = "Photophobia"
	desc = "Bright lights seem to bother you more than others. Maybe it's a medical condition."
	icon = FA_ICON_ARROWS_TO_EYE
	value = -4
	gain_text = span_danger("The safety of light feels off...")
	lose_text = span_notice("Enlightening.")
	medical_record_text = "Patient has acute phobia of light, and insists it is physically harmful."
	hardcore_value = 4
	mail_goodies = list(
		/obj/item/flashlight/flashdark,
		/obj/item/food/grown/mushroom/glowshroom/shadowshroom,
		/obj/item/skillchip/light_remover,
	)

/datum/quirk/photophobia/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(check_eyes))
	RegisterSignal(quirk_holder, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(restore_eyes))
	RegisterSignal(quirk_holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_holder_moved))
	update_eyes(quirk_holder.get_organ_slot(ORGAN_SLOT_EYES))

/datum/quirk/photophobia/remove()
	UnregisterSignal(quirk_holder, list(
		COMSIG_CARBON_GAIN_ORGAN,
		COMSIG_CARBON_LOSE_ORGAN,
		COMSIG_MOVABLE_MOVED,))
	quirk_holder.clear_mood_event(MOOD_CATEGORY_PHOTOPHOBIA)
	var/obj/item/organ/internal/eyes/normal_eyes = quirk_holder.get_organ_slot(ORGAN_SLOT_EYES)
	if(istype(normal_eyes))
		normal_eyes.flash_protect = initial(normal_eyes.flash_protect)

/datum/quirk/photophobia/proc/check_eyes(obj/item/organ/internal/eyes/sensitive_eyes)
	SIGNAL_HANDLER
	if(!istype(sensitive_eyes))
		return
	update_eyes(sensitive_eyes)

/datum/quirk/photophobia/proc/update_eyes(obj/item/organ/internal/eyes/target_eyes)
	if(!istype(target_eyes))
		return
	target_eyes.flash_protect = max(target_eyes.flash_protect - 1, FLASH_PROTECTION_HYPER_SENSITIVE)

/datum/quirk/photophobia/proc/restore_eyes(obj/item/organ/internal/eyes/normal_eyes)
	SIGNAL_HANDLER
	if(!istype(normal_eyes))
		return
	normal_eyes.flash_protect = initial(normal_eyes.flash_protect)

/datum/quirk/photophobia/proc/on_holder_moved(mob/living/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(quirk_holder.stat != CONSCIOUS || quirk_holder.IsSleeping() || quirk_holder.IsUnconscious())
		return

	if(HAS_TRAIT(quirk_holder, TRAIT_FEARLESS))
		return

	var/mob/living/carbon/human/human_holder = quirk_holder

	if(human_holder.sight & SEE_TURFS)
		return

	var/turf/holder_turf = get_turf(quirk_holder)

	var/lums = holder_turf.get_lumcount()

	var/eye_protection = quirk_holder.get_eye_protection()
	if(lums < LIGHTING_TILE_IS_DARK || eye_protection >= FLASH_PROTECTION_NONE)
		quirk_holder.clear_mood_event(MOOD_CATEGORY_PHOTOPHOBIA)
		return
	quirk_holder.add_mood_event(MOOD_CATEGORY_PHOTOPHOBIA, /datum/mood_event/photophobia)

	#undef MOOD_CATEGORY_PHOTOPHOBIA

/datum/quirk/softspoken
	name = "Soft-Spoken"
	desc = "You are soft-spoken, and your voice is hard to hear."
	icon = FA_ICON_COMMENT
	value = -2
	mob_trait = TRAIT_SOFTSPOKEN
	gain_text = span_danger("You feel like you're speaking more quietly.")
	lose_text = span_notice("You feel like you're speaking louder.")
	medical_record_text = "Patient is soft-spoken and difficult to hear."

/datum/quirk/clumsy
	name = "Clumsy"
	desc = "You're clumsy, a goofball, a silly dude. You big loveable himbo/bimbo you! Hope you weren't planning on using your hands for anything that takes even a LICK of dexterity."
	icon = FA_ICON_FACE_DIZZY
	value = -8
	mob_trait = TRAIT_CLUMSY
	gain_text = span_danger("You feel your IQ sink like your brain is liquid.")
	lose_text = span_notice("You feel like your IQ went up to at least average.")
	medical_record_text = "Patient has demonstrated an extreme difficulty with high motor skill paired with an inability to demonstrate critical thinking."

/datum/quirk/nonviolent
	name = "Pacifist"
	desc = "The thought of violence makes you sick. So much so, in fact, that you can't hurt anyone."
	icon = FA_ICON_PEACE
	value = -8
	mob_trait = TRAIT_PACIFISM
	gain_text = span_danger("You feel repulsed by the thought of violence!")
	lose_text = span_notice("You think you can defend yourself again.")
	medical_record_text = "Patient is unusually pacifistic and cannot bring themselves to cause physical harm."
	hardcore_value = 6
	mail_goodies = list(/obj/effect/spawner/random/decoration/flower, /obj/effect/spawner/random/contraband/cannabis) // flower power

/datum/quirk/bighands
	name = "Big Hands"
	desc = "You have big hands, it sure does make it hard to use a lot of things."
	icon = FA_ICON_HAND_DOTS
	value = -6
	mob_trait = TRAIT_CHUNKYFINGERS
	gain_text = span_danger("Your hands are huge! You can't use small things anymore!")
	lose_text = span_notice("Your hands are back to normal.")
	medical_record_text = "Patient has unusually large hands. Made me question my masculinity..."
	hardcore_value = 5

/datum/quirk/paraplegic
	name = "Paraplegic"
	desc = "Your legs do not function. Nothing will ever fix this. But hey, free wheelchair!"
	icon = FA_ICON_WHEELCHAIR
	value = -12
	gain_text = null // Handled by trauma.
	lose_text = null
	medical_record_text = "Patient has an untreatable impairment in motor function in the lower extremities."
	hardcore_value = 15
	mail_goodies = list(/obj/vehicle/ridden/wheelchair/motorized) //yes a fullsized unfolded motorized wheelchair does fit

/datum/quirk/paraplegic/add_unique(client/client_source)
	if(quirk_holder.buckled) // Handle late joins being buckled to arrival shuttle chairs.
		quirk_holder.buckled.unbuckle_mob(quirk_holder)

	var/turf/holder_turf = get_turf(quirk_holder)
	var/obj/structure/chair/spawn_chair = locate() in holder_turf

	var/obj/vehicle/ridden/wheelchair/wheels
	if(client_source?.get_award_status(/datum/award/score/hardcore_random) >= 5000) //More than 5k score? you unlock the gamer wheelchair.
		wheels = new /obj/vehicle/ridden/wheelchair/gold(holder_turf)
	else
		wheels = new(holder_turf)
	if(spawn_chair) // Makes spawning on the arrivals shuttle more consistent looking
		wheels.setDir(spawn_chair.dir)

	wheels.buckle_mob(quirk_holder)

	// During the spawning process, they may have dropped what they were holding, due to the paralysis
	// So put the things back in their hands.
	for(var/obj/item/dropped_item in holder_turf)
		if(dropped_item.fingerprintslast == quirk_holder.ckey)
			quirk_holder.put_in_hands(dropped_item)

/datum/quirk/paraplegic/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/paraplegic/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.cure_trauma_type(/datum/brain_trauma/severe/paralysis/paraplegic, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/hemiplegic
	name = "Hemiplegic"
	desc = "Half of your body doesn't work. Nothing will ever fix this."
	icon = FA_ICON_CIRCLE_HALF_STROKE
	value = -10 // slightly more bearable than paraplegic but not by much
	gain_text = null // Handled by trauma.
	lose_text = null
	medical_record_text = "Patient has an untreatable impairment in motor function on half of their body."
	hardcore_value = 10
	mail_goodies = list(
		/obj/item/stack/sheet/mineral/uranium/half, //half a stack of a material that has a half life
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/half_full,
	)

/datum/quirk/hemiplegic/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/trauma_type = pick(/datum/brain_trauma/severe/paralysis/hemiplegic/left, /datum/brain_trauma/severe/paralysis/hemiplegic/right)
	human_holder.gain_trauma(trauma_type, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/hemiplegic/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.cure_trauma_type(/datum/brain_trauma/severe/paralysis/hemiplegic, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/poor_aim
	name = "Stormtrooper Aim"
	desc = "You've never hit anything you were aiming for in your life."
	icon = FA_ICON_BULLSEYE
	value = -4
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

/datum/quirk/prosopagnosia
	name = "Prosopagnosia"
	desc = "You have a mental disorder that prevents you from being able to recognize faces at all."
	icon = FA_ICON_USER_SECRET
	value = -4
	mob_trait = TRAIT_PROSOPAGNOSIA
	medical_record_text = "Patient suffers from prosopagnosia and cannot recognize faces."
	hardcore_value = 5
	mail_goodies = list(/obj/item/skillchip/appraiser) // bad at recognizing faces but good at recognizing IDs

/datum/quirk/prosthetic_limb
	name = "Prosthetic Limb"
	desc = "An accident caused you to lose one of your limbs. Because of this, you now have a surplus prosthetic!"
	icon = "tg-prosthetic-leg"
	value = -3
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

/datum/quirk/quadruple_amputee
	name = "Quadruple Amputee"
	desc = "Oops! All Prosthetics! Due to some truly cruel cosmic punishment, all your limbs have been replaced with surplus prosthetics."
	icon = "tg-prosthetic-full"
	value = -6
	medical_record_text = "During physical examination, patient was found to have all low-budget prosthetic limbs."
	hardcore_value = 6
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/weldingtool/mini, /obj/item/stack/cable_coil/five)

/datum/quirk/quadruple_amputee/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.del_and_replace_bodypart(new /obj/item/bodypart/arm/left/robot/surplus, special = TRUE)
	human_holder.del_and_replace_bodypart(new /obj/item/bodypart/arm/right/robot/surplus, special = TRUE)
	human_holder.del_and_replace_bodypart(new /obj/item/bodypart/leg/left/robot/surplus, special = TRUE)
	human_holder.del_and_replace_bodypart(new /obj/item/bodypart/leg/right/robot/surplus, special = TRUE)

/datum/quirk/quadruple_amputee/post_add()
	to_chat(quirk_holder, span_boldannounce("All your limbs have been replaced with surplus prosthetics. They are fragile and will easily come apart under duress. \
	Additionally, you need to use a welding tool and cables to repair them, instead of bruise packs and ointment."))

/datum/quirk/prosthetic_organ
	name = "Prosthetic Organ"
	desc = "An accident caused you to lose one of your organs. Because of this, you now have a surplus prosthetic!"
	icon = FA_ICON_LUNGS
	value = -3
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

/datum/quirk/tin_man
	name = "Tin Man"
	desc = "Oops! All Prosthetics! Due to some truly cruel cosmic punishment, most of your internal organs have been replaced with surplus prosthetics."
	icon = FA_ICON_ROBOT
	value = -6
	medical_record_text = "During physical examination, patient was found to have numerous low-budget prosthetic internal organs. \
		<b>Removal of these organs is known to be dangerous to the patient as well as the practitioner.</b>"
	hardcore_value = 6
	mail_goodies = list(/obj/item/storage/organbox)

/datum/quirk/tin_man/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/static/list/organ_slots = list(
		ORGAN_SLOT_HEART = /obj/item/organ/internal/heart/cybernetic/surplus,
		ORGAN_SLOT_LUNGS = /obj/item/organ/internal/lungs/cybernetic/surplus,
		ORGAN_SLOT_LIVER = /obj/item/organ/internal/liver/cybernetic/surplus,
		ORGAN_SLOT_STOMACH = /obj/item/organ/internal/stomach/cybernetic/surplus,
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
	for(var/organ_slot in possible_organ_slots)
		var/organ_path = possible_organ_slots[organ_slot]
		var/obj/item/organ/new_organ = new organ_path()
		new_organ.Insert(human_holder, special = TRUE, drop_if_replaced = FALSE)

/datum/quirk/tin_man/post_add()
	to_chat(quirk_holder, span_boldannounce("Most of your internal organs have been replaced with surplus prosthetics. They are fragile and will easily come apart under duress. \
	Additionally, any EMP will make them stop working entirely."))

/datum/quirk/pushover
	name = "Pushover"
	desc = "Your first instinct is always to let people push you around. Resisting out of grabs will take conscious effort."
	icon = FA_ICON_HANDSHAKE
	value = -8
	mob_trait = TRAIT_GRABWEAKNESS
	gain_text = span_danger("You feel like a pushover.")
	lose_text = span_notice("You feel like standing up for yourself.")
	medical_record_text = "Patient presents a notably unassertive personality and is easy to manipulate."
	hardcore_value = 4
	mail_goodies = list(/obj/item/clothing/gloves/cargo_gauntlet)

/datum/quirk/insanity
	name = "Reality Dissociation Syndrome"
	desc = "You suffer from a severe disorder that causes very vivid hallucinations. \
		Mindbreaker toxin can suppress its effects, and you are immune to mindbreaker's hallucinogenic properties. \
		THIS IS NOT A LICENSE TO GRIEF."
	icon = FA_ICON_GRIN_TONGUE_WINK
	value = -8
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

/datum/quirk/social_anxiety
	name = "Social Anxiety"
	desc = "Talking to people is very difficult for you, and you often stutter or even lock up."
	icon = FA_ICON_COMMENT_SLASH
	value = -3
	gain_text = span_danger("You start worrying about what you're saying.")
	lose_text = span_notice("You feel easier about talking again.") //if only it were that easy!
	medical_record_text = "Patient is usually anxious in social encounters and prefers to avoid them."
	hardcore_value = 4
	mob_trait = TRAIT_ANXIOUS
	mail_goodies = list(/obj/item/storage/pill_bottle/psicodine)
	var/dumb_thing = TRUE

/datum/quirk/social_anxiety/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_MOB_EYECONTACT, PROC_REF(eye_contact))
	RegisterSignal(quirk_holder, COMSIG_MOB_EXAMINATE, PROC_REF(looks_at_floor))
	RegisterSignal(quirk_holder, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/quirk/social_anxiety/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_MOB_EYECONTACT, COMSIG_MOB_EXAMINATE, COMSIG_MOB_SAY))

/datum/quirk/social_anxiety/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if(HAS_TRAIT(quirk_holder, TRAIT_FEARLESS))
		return

	var/moodmod
	if(quirk_holder.mob_mood)
		moodmod = (1+0.02*(50-(max(50, quirk_holder.mob_mood.mood_level*(7-quirk_holder.mob_mood.sanity_level))))) //low sanity levels are better, they max at 6
	else
		moodmod = (1+0.02*(50-(max(50, 0.1*quirk_holder.nutrition))))
	var/nearby_people = 0
	for(var/mob/living/carbon/human/H in oview(3, quirk_holder))
		if(H.client)
			nearby_people++
	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		var/list/message_split = splittext(message, " ")
		var/list/new_message = list()
		var/mob/living/carbon/human/quirker = quirk_holder
		for(var/word in message_split)
			if(prob(max(5,(nearby_people*12.5*moodmod))) && word != message_split[1]) //Minimum 1/20 chance of filler
				new_message += pick("uh,","erm,","um,")
				if(prob(min(5,(0.05*(nearby_people*12.5)*moodmod)))) //Max 1 in 20 chance of cutoff after a successful filler roll, for 50% odds in a 15 word sentence
					quirker.set_silence_if_lower(6 SECONDS)
					to_chat(quirker, span_danger("You feel self-conscious and stop talking. You need a moment to recover!"))
					break
			if(prob(max(5,(nearby_people*12.5*moodmod)))) //Minimum 1/20 chance of stutter
				// Add a short stutter, THEN treat our word
				quirker.adjust_stutter(0.5 SECONDS)
				var/list/message_data = quirker.treat_message(word, capitalize_message = FALSE)
				new_message += message_data["message"]
			else
				new_message += word

		message = jointext(new_message, " ")
	var/mob/living/carbon/human/quirker = quirk_holder
	if(prob(min(50,(0.50*(nearby_people*12.5)*moodmod)))) //Max 50% chance of not talking
		if(dumb_thing)
			to_chat(quirker, span_userdanger("You think of a dumb thing you said a long time ago and scream internally."))
			dumb_thing = FALSE //only once per life
			if(prob(1))
				new/obj/item/food/spaghetti/pastatomato(get_turf(quirker)) //now that's what I call spaghetti code
		else
			to_chat(quirk_holder, span_warning("You think that wouldn't add much to the conversation and decide not to say it."))
			if(prob(min(25,(0.25*(nearby_people*12.75)*moodmod)))) //Max 25% chance of silence stacks after successful not talking roll
				to_chat(quirker, span_danger("You retreat into yourself. You <i>really</i> don't feel up to talking."))
				quirker.set_silence_if_lower(10 SECONDS)

		speech_args[SPEECH_MESSAGE] = pick("Uh.","Erm.","Um.")
	else
		speech_args[SPEECH_MESSAGE] = message

// small chance to make eye contact with inanimate objects/mindless mobs because of nerves
/datum/quirk/social_anxiety/proc/looks_at_floor(datum/source, atom/A)
	SIGNAL_HANDLER

	var/mob/living/mind_check = A
	if(prob(85) || (istype(mind_check) && mind_check.mind))
		return

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), quirk_holder, span_smallnotice("You make eye contact with [A].")), 3)

/datum/quirk/social_anxiety/proc/eye_contact(datum/source, mob/living/other_mob, triggering_examiner)
	SIGNAL_HANDLER

	if(prob(75))
		return
	var/msg
	if(triggering_examiner)
		msg = "You make eye contact with [other_mob], "
	else
		msg = "[other_mob] makes eye contact with you, "

	switch(rand(1,3))
		if(1)
			quirk_holder.set_jitter_if_lower(20 SECONDS)
			msg += "causing you to start fidgeting!"
		if(2)
			quirk_holder.set_stutter_if_lower(6 SECONDS)
			msg += "causing you to start stuttering!"
		if(3)
			quirk_holder.Stun(2 SECONDS)
			msg += "causing you to freeze up!"

	quirk_holder.add_mood_event("anxiety_eyecontact", /datum/mood_event/anxiety_eyecontact)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), quirk_holder, span_userdanger("[msg]")), 3) // so the examine signal has time to fire and this will print after
	return COMSIG_BLOCK_EYECONTACT

/datum/mood_event/anxiety_eyecontact
	description = "Sometimes eye contact makes me so nervous..."
	mood_change = -5
	timeout = 3 MINUTES

/datum/quirk/item_quirk/junkie
	name = "Junkie"
	desc = "You can't get enough of hard drugs."
	icon = FA_ICON_PILLS
	value = -6
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
	value = -4
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
	var/obj/item/organ/internal/lungs/smoker_lungs = quirk_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(smoker_lungs && IS_ORGANIC_ORGAN(smoker_lungs)) // robotic lungs aren't affected
		smoker_lungs.maxHealth = smoker_lungs.maxHealth * 0.75
		smoker_lungs.healing_factor = smoker_lungs.healing_factor * 0.75

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
	value = -4
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

/datum/quirk/item_quirk/chronic_illness
	name = "Chronic Illness"
	desc = "You have a chronic illness that requires constant medication to keep under control."
	icon = FA_ICON_DISEASE
	value = -12
	gain_text = span_danger("You feel a bit off today.")
	lose_text = span_notice("You feel a bit better today.")
	medical_record_text = "Patient has a chronic illness that requires constant medication to keep under control."
	hardcore_value = 12
	mail_goodies = list(/obj/item/storage/pill_bottle/sansufentanyl)

/datum/quirk/item_quirk/chronic_illness/add_unique(client/client_source)
	var/datum/disease/chronic_illness/hms = new /datum/disease/chronic_illness()
	quirk_holder.ForceContractDisease(hms)
	give_item_to_holder(/obj/item/storage/pill_bottle/sansufentanyl, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK),flavour_text = "You've been provided with medication to help manage your condition. Take it regularly to avoid complications.")
	give_item_to_holder(/obj/item/healthanalyzer/simple/disease, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK))

/datum/quirk/unstable
	name = "Unstable"
	desc = "Due to past troubles, you are unable to recover your sanity if you lose it. Be very careful managing your mood!"
	icon = FA_ICON_ANGRY
	value = -10
	mob_trait = TRAIT_UNSTABLE
	gain_text = span_danger("There's a lot on your mind right now.")
	lose_text = span_notice("Your mind finally feels calm.")
	medical_record_text = "Patient's mind is in a vulnerable state, and cannot recover from traumatic events."
	hardcore_value = 9
	mail_goodies = list(/obj/effect/spawner/random/entertainment/plushie)

/datum/quirk/item_quirk/allergic
	name = "Extreme Medicine Allergy"
	desc = "Ever since you were a kid, you've been allergic to certain chemicals..."
	icon = FA_ICON_PRESCRIPTION_BOTTLE
	value = -6
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

/datum/quirk/bad_touch
	name = "Bad Touch"
	desc = "You don't like hugs. You'd really prefer if people just left you alone."
	icon = "tg-bad-touch"
	mob_trait = TRAIT_BADTOUCH
	value = -1
	gain_text = span_danger("You just want people to leave you alone.")
	lose_text = span_notice("You could use a big hug.")
	medical_record_text = "Patient has disdain for being touched. Potentially has undiagnosed haphephobia."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	hardcore_value = 1
	mail_goodies = list(/obj/item/reagent_containers/spray/pepper) // show me on the doll where the bad man touched you

/datum/quirk/bad_touch/add(client/client_source)
	RegisterSignals(quirk_holder, list(COMSIG_LIVING_GET_PULLED, COMSIG_CARBON_HELP_ACT), PROC_REF(uncomfortable_touch))

/datum/quirk/bad_touch/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_LIVING_GET_PULLED, COMSIG_CARBON_HELP_ACT))

/// Causes a negative moodlet to our quirk holder on signal
/datum/quirk/bad_touch/proc/uncomfortable_touch(datum/source)
	SIGNAL_HANDLER

	if(quirk_holder.stat == DEAD)
		return

	new /obj/effect/temp_visual/annoyed(quirk_holder.loc)
	if(quirk_holder.mob_mood.sanity <= SANITY_NEUTRAL)
		quirk_holder.add_mood_event("bad_touch", /datum/mood_event/very_bad_touch)
	else
		quirk_holder.add_mood_event("bad_touch", /datum/mood_event/bad_touch)

/datum/quirk/claustrophobia
	name = "Claustrophobia"
	desc = "You are terrified of small spaces and certain jolly figures. If you are placed inside any container, locker, or machinery, a panic attack sets in and you struggle to breathe."
	icon = FA_ICON_BOX_OPEN
	value = -4
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

/datum/quirk/illiterate
	name = "Illiterate"
	desc = "You dropped out of school and are unable to read or write. This affects reading, writing, using computers and other electronics."
	icon = FA_ICON_GRADUATION_CAP
	value = -8
	mob_trait = TRAIT_ILLITERATE
	medical_record_text = "Patient is not literate."
	hardcore_value = 8
	mail_goodies = list(/obj/item/pai_card) // can read things for you


/datum/quirk/mute
	name = "Mute"
	desc = "For some reason you are completely unable to speak."
	icon = FA_ICON_VOLUME_XMARK
	value = -4
	mob_trait = TRAIT_MUTE
	gain_text = span_danger("You find yourself unable to speak!")
	lose_text = span_notice("You feel a growing strength in your vocal chords.")
	medical_record_text = "The patient is unable to use their voice in any capacity."
	hardcore_value = 4

/datum/quirk/body_purist
	name = "Body Purist"
	desc = "You believe your body is a temple and its natural form is an embodiment of perfection. Accordingly, you despise the idea of ever augmenting it with unnatural parts, cybernetic, prosthetic, or anything like it."
	icon = FA_ICON_PERSON_RAYS
	value = -2
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

/datum/quirk/cursed
	name = "Cursed"
	desc = "You are cursed with bad luck. You are much more likely to suffer from accidents and mishaps. When it rains, it pours."
	icon = FA_ICON_CLOUD_SHOWERS_HEAVY
	value = -8
	mob_trait = TRAIT_CURSED
	gain_text = span_danger("You feel like you're going to have a bad day.")
	lose_text = span_notice("You feel like you're going to have a good day.")
	medical_record_text = "Patient is cursed with bad luck."
	hardcore_value = 8

/datum/quirk/cursed/add(client/client_source)
	quirk_holder.AddComponent(/datum/component/omen/quirk)

/datum/quirk/indebted
	name = "Indebted"
	desc = "Bad life decisions, medical bills, student loans, whatever it may be, you've incurred quite the debt. A portion of all you receive will go towards extinguishing it."
	icon = FA_ICON_DOLLAR
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_HIDE_FROM_SCAN
	value = -2
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
