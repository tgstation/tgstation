/datum/species/monkey
	name = "Monkey"
	id = SPECIES_MONKEY
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_MONKEY
	external_organs = list(
		/obj/item/organ/external/tail/monkey = "Monkey"
	)
	mutanttongue = /obj/item/organ/internal/tongue/monkey
	mutantbrain = /obj/item/organ/internal/brain/primate
	skinned_type = /obj/item/stack/sheet/animalhide/monkey
	meat = /obj/item/food/meat/slab/monkey
	knife_butcher_results = list(/obj/item/food/meat/slab/monkey = 5, /obj/item/stack/sheet/animalhide/monkey = 1)
	species_traits = list(
		NO_UNDERWEAR,
		LIPS,
		NOEYESPRITES,
		NOBLOODOVERLAY,
		NOTRANSSTING,
		NOAUGMENTS,
	)
	inherent_traits = list(
		TRAIT_GUN_NATURAL,
		TRAIT_VENTCRAWLER_NUDE,
		TRAIT_WEAK_SOUL,
		TRAIT_HUMAN_BITER,
	)
	no_equip_flags = ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_SUITSTORE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN | SLIME_EXTRACT
	liked_food = MEAT | FRUIT | BUGS
	disliked_food = CLOTH
	sexes = FALSE
	species_language_holder = /datum/language_holder/monkey

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/monkey,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/monkey,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/monkey,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/monkey,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/monkey,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/monkey,
	)
	fire_overlay = "monkey"
	dust_anim = "dust-m"
	gib_anim = "gibbed-m"

	payday_modifier = 1.5
	ai_controlled_species = TRUE



/datum/species/monkey/random_name(gender,unique,lastname)
	var/randname = "monkey ([rand(1,999)])"

	return randname

/datum/species/monkey/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.pass_flags |= PASSTABLE
	H.butcher_results = knife_butcher_results
	H.dna.add_mutation(/datum/mutation/human/race, MUT_NORMAL)
	H.dna.activate_mutation(/datum/mutation/human/race)
	RegisterSignal(H, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(monkey_melee))
	RegisterSignal(H, COMSIG_CLICK_CTRL, PROC_REF(ctrl_clicked))

/datum/species/monkey/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.pass_flags = initial(C.pass_flags)
	C.butcher_results = null
	C.dna.remove_mutation(/datum/mutation/human/race)
	UnregisterSignal(C, COMSIG_HUMAN_MELEE_UNARMED_ATTACK)
	UnregisterSignal(C, COMSIG_CLICK_CTRL)

/datum/species/monkey/proc/monkey_melee(mob/living/carbon/human/source, atom/target, proximity_flag, modifiers)
	SIGNAL_HANDLER

	// if we aren't an advanced tool user, we call attack_paw and cancel the preceeding attack chain
	if(!ISADVANCEDTOOLUSER(source) && proximity_flag) // This prox flag check is not necessary but we'll keep it just in case
		target.attack_paw(source, modifiers)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/species/monkey/proc/ctrl_clicked(mob/living/carbon/human/source, mob/user)
	SIGNAL_HANDLER
	// bad code ahead: redirects ctrl click to "xeno ctrl click" for the purpose of the xenobiology camera console
	SEND_SIGNAL(user, COMSIG_XENO_MONKEY_CLICK_CTRL, src)

/datum/species/monkey/check_roundstart_eligible()
	if(check_holidays(MONKEYDAY))
		return TRUE
	return ..()

/datum/species/monkey/get_scream_sound(mob/living/carbon/human/monkey)
	return pick(
		'sound/creatures/monkey/monkey_screech_1.ogg',
		'sound/creatures/monkey/monkey_screech_2.ogg',
		'sound/creatures/monkey/monkey_screech_3.ogg',
		'sound/creatures/monkey/monkey_screech_4.ogg',
		'sound/creatures/monkey/monkey_screech_5.ogg',
		'sound/creatures/monkey/monkey_screech_6.ogg',
		'sound/creatures/monkey/monkey_screech_7.ogg',
	)

/datum/species/monkey/get_species_description()
	return "Monkeys are a type of primate that exist between humans and animals on the evolutionary chain. \
		Every year, on Monkey Day, Nanotrasen shows their respect for the little guys by allowing them to roam the station freely."

/datum/species/monkey/get_species_lore()
	return list(
		"Monkeys are commonly used as test subjects on board Space Station Thirteen. \
		But what if... for one day... the Monkeys were allowed to be the scientists? \
		What experiments would they come up it? Would they (stereotypically) be related to bananas somehow? \
		There's only one way to find out.",
	)

/datum/species/monkey/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "spider",
			SPECIES_PERK_NAME = "Vent Crawling",
			SPECIES_PERK_DESC = "Monkeys can crawl through the vent and scrubber networks while wearing no clothing. \
				Stay out of the kitchen!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "paw",
			SPECIES_PERK_NAME = "Primal Primate",
			SPECIES_PERK_DESC = "Monkeys are primitive humans, and can't do most things a human can do. Computers are impossible, \
				complex machines are right out, and most clothes don't fit your smaller form.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "capsules",
			SPECIES_PERK_NAME = "Mutadone Averse",
			SPECIES_PERK_DESC = "Monkeys are reverted into normal humans upon being exposed to Mutadone.",
		),
	)

	return to_add

/datum/species/monkey/create_pref_language_perk()
	var/list/to_add = list()
	// Holding these variables so we can grab the exact names for our perk.
	var/datum/language/common_language = /datum/language/common
	var/datum/language/monkey_language = /datum/language/monkey

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "comment",
		SPECIES_PERK_NAME = "Primitive Tongue",
		SPECIES_PERK_DESC = "You may be able to understand [initial(common_language.name)], but you can't speak it. \
			You can only speak [initial(monkey_language.name)].",
	))

	return to_add

/obj/item/organ/internal/brain/primate //Ook Ook
	name = "Primate Brain"
	desc = "This wad of meat is small, but has enlaged occipital lobes for spotting bananas."
	organ_traits = list(TRAIT_CAN_STRIP, TRAIT_PRIMITIVE) // No literacy or advanced tool usage.
	actions_types = list(/datum/action/item_action/organ_action/toggle_trip)
	/// Will this monkey stumble if they are crossed by a simple mob or a carbon in combat mode? Toggable by monkeys with clients, and is messed automatically set to true by monkey AI.
	var/tripping = TRUE

/datum/action/item_action/organ_action/toggle_trip
	name = "Toggle Tripping"
	button_icon = 'icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "lesser_form"
	background_icon_state = "bg_default_on"
	overlay_icon_state = "bg_default_border"

/datum/action/item_action/organ_action/toggle_trip/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	var/obj/item/organ/internal/brain/primate/monkey_brain = target
	if(monkey_brain.tripping)
		monkey_brain.tripping = FALSE
		background_icon_state = "bg_default"
		to_chat(monkey_brain.owner, span_notice("You will now avoid stumbling while colliding with people who are in combat mode."))
	else
		monkey_brain.tripping = TRUE
		background_icon_state = "bg_default_on"
		to_chat(monkey_brain.owner, span_notice("You will now stumble while while colliding with people who are in combat mode."))
	build_all_button_icons()


/obj/item/organ/internal/brain/primate/on_insert(mob/living/carbon/primate)
	. = ..()
	RegisterSignal(primate, COMSIG_MOVABLE_CROSS, PROC_REF(on_crossed), TRUE)

/obj/item/organ/internal/brain/primate/on_remove(mob/living/carbon/primate)
	. = ..()
	UnregisterSignal(primate, COMSIG_MOVABLE_CROSS)

/obj/item/organ/internal/brain/primate/proc/on_crossed(datum/source, atom/movable/crossed)
	SIGNAL_HANDLER
	if(!tripping)
		return
	if(IS_DEAD_OR_INCAP(owner) || !isliving(crossed))
		return
	var/mob/living/in_the_way_mob = crossed
	if(iscarbon(in_the_way_mob) && !in_the_way_mob.combat_mode)
		return
	if(in_the_way_mob.pass_flags & PASSTABLE)
		return
	in_the_way_mob.knockOver(owner)

/obj/item/organ/internal/brain/primate/get_attacking_limb(atom/clicking_on)
	return owner.get_bodypart(BODY_ZONE_HEAD)
