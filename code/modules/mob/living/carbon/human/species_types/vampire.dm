
///how many vampires exist in each house
#define VAMPIRES_PER_HOUSE 5
///maximum a vampire will drain, they will drain less if they hit their cap
#define VAMP_DRAIN_AMOUNT 50

/datum/species/vampire
	name = "Vampire"
	id = SPECIES_VAMPIRE
	examine_limb_id = SPECIES_HUMAN
	inherent_traits = list(
		TRAIT_BLOOD_CLANS,
		TRAIT_DRINKS_BLOOD,
		TRAIT_NOBREATH,
		TRAIT_NOHUNGER,
		TRAIT_USES_SKINTONES,
		TRAIT_NO_MIRROR_REFLECTION,
	)
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	mutant_bodyparts = list("wings" = "None")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN
	exotic_bloodtype = "U"
	blood_deficiency_drain_rate = BLOOD_DEFICIENCY_MODIFIER // vampires already passively lose blood, so this just makes them lose it slightly more quickly when they have blood deficiency.
	mutantheart = /obj/item/organ/internal/heart/vampire
	mutanttongue = /obj/item/organ/internal/tongue/vampire
	mutantstomach = null
	mutantlungs = null
	skinned_type = /obj/item/stack/sheet/animalhide/human
	///some starter text sent to the vampire initially, because vampires have shit to do to stay alive
	var/info_text = "You are a <span class='danger'>Vampire</span>. You will slowly but constantly lose blood if outside of a coffin. If inside a coffin, you will slowly heal. You may gain more blood by grabbing a live victim and using your drain ability."

/datum/species/vampire/check_roundstart_eligible()
	if(check_holidays(HALLOWEEN))
		return TRUE
	return ..()

/datum/species/vampire/on_species_gain(mob/living/carbon/human/new_vampire, datum/species/old_species)
	. = ..()
	to_chat(new_vampire, "[info_text]")
	new_vampire.skin_tone = "albino"
	new_vampire.update_body(0)
	RegisterSignal(new_vampire, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(damage_weakness))

/datum/species/vampire/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)

/datum/species/vampire/spec_life(mob/living/carbon/human/vampire, seconds_per_tick, times_fired)
	. = ..()
	if(istype(vampire.loc, /obj/structure/closet/crate/coffin))
		var/need_mob_update = FALSE
		need_mob_update += vampire.heal_overall_damage(brute = 2 * seconds_per_tick, burn = 2 * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
		need_mob_update += vampire.adjustToxLoss(-2 * seconds_per_tick, updating_health = FALSE,)
		need_mob_update += vampire.adjustOxyLoss(-2 * seconds_per_tick, updating_health = FALSE,)
		if(need_mob_update)
			vampire.updatehealth()
		return
	vampire.blood_volume -= 0.125 * seconds_per_tick
	if(vampire.blood_volume <= BLOOD_VOLUME_SURVIVE)
		to_chat(vampire, span_danger("You ran out of blood!"))
		vampire.investigate_log("has been dusted by a lack of blood (vampire).", INVESTIGATE_DEATHS)
		vampire.dust()
	var/area/A = get_area(vampire)
	if(istype(A, /area/station/service/chapel))
		to_chat(vampire, span_warning("You don't belong here!"))
		vampire.adjustFireLoss(10 * seconds_per_tick)
		vampire.adjust_fire_stacks(3 * seconds_per_tick)
		vampire.ignite_mob()

/datum/species/vampire/proc/damage_weakness(datum/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER

	if(istype(attacking_item, /obj/item/nullrod/whip))
		damage_mods += 2

/datum/species/vampire/get_physical_attributes()
	return "Vampires are afflicted with the Thirst, needing to sate it by draining the blood out of another living creature. However, they do not need to breathe or eat normally. \
		They will instantly turn into dust if they run out of blood or enter a holy area. However, coffins stabilize and heal them, and they can transform into bats!"

/datum/species/vampire/get_species_description()
	return "A classy Vampire! They descend upon Space Station Thirteen Every year to spook the crew! \"Bleeg!!\""

/datum/species/vampire/get_species_lore()
	return list(
		"Vampires are unholy beings blessed and cursed with The Thirst. \
		The Thirst requires them to feast on blood to stay alive, and in return it gives them many bonuses. \
		Because of this, Vampires have split into two clans, one that embraces their powers as a blessing and one that rejects it.",
	)

/datum/species/vampire/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bed",
			SPECIES_PERK_NAME = "Coffin Brooding",
			SPECIES_PERK_DESC = "Vampires can delay The Thirst and heal by resting in a coffin. So THAT'S why they do that!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "book-dead",
			SPECIES_PERK_NAME = "Vampire Clans",
			SPECIES_PERK_DESC = "Vampires belong to one of two clans - the Inoculated, and the Outcast. The Outcast \
				don't follow many vampiric traditions, while the Inoculated are given unique names and flavor.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "cross",
			SPECIES_PERK_NAME = "Against God and Nature",
			SPECIES_PERK_DESC = "Almost all higher powers are disgusted by the existence of \
				Vampires, and entering the Chapel is essentially suicide. Do not do it!",
		),
	)

	return to_add

// Vampire blood is special, so it needs to be handled with its own entry.
/datum/species/vampire/create_pref_blood_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "tint",
		SPECIES_PERK_NAME = "The Thirst",
		SPECIES_PERK_DESC = "In place of eating, Vampires suffer from The Thirst. \
			Thirst of what? Blood! Their tongue allows them to grab people and drink \
			their blood, and they will die if they run out. As a note, it doesn't \
			matter whose blood you drink, it will all be converted into your blood \
			type when consumed.",
	))

	return to_add

// There isn't a "Minor Undead" biotype, so we have to explain it in an override (see: dullahans)
/datum/species/vampire/create_pref_biotypes_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "skull",
		SPECIES_PERK_NAME = "Minor Undead",
		SPECIES_PERK_DESC = "[name] are minor undead. \
			Minor undead enjoy some of the perks of being dead, like \
			not needing to breathe or eat, but do not get many of the \
			environmental immunities involved with being fully undead.",
	))

	return to_add

/obj/item/organ/internal/tongue/vampire
	name = "vampire tongue"
	actions_types = list(/datum/action/item_action/organ_action/vampire)
	color = COLOR_CRAYON_BLACK
	COOLDOWN_DECLARE(drain_cooldown)

/datum/action/item_action/organ_action/vampire
	name = "Drain Victim"
	desc = "Leech blood from any carbon victim you are passively grabbing."

/datum/action/item_action/organ_action/vampire/Trigger(trigger_flags)
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/H = owner
		var/obj/item/organ/internal/tongue/vampire/V = target
		if(!COOLDOWN_FINISHED(V, drain_cooldown))
			to_chat(H, span_warning("You just drained blood, wait a few seconds!"))
			return
		if(H.pulling && iscarbon(H.pulling))
			var/mob/living/carbon/victim = H.pulling
			if(H.blood_volume >= BLOOD_VOLUME_MAXIMUM)
				to_chat(H, span_warning("You're already full!"))
				return
			if(victim.stat == DEAD)
				to_chat(H, span_warning("You need a living victim!"))
				return
			if(!victim.blood_volume || (victim.dna && (HAS_TRAIT(victim, TRAIT_NOBLOOD) || victim.dna.species.exotic_blood)))
				to_chat(H, span_warning("[victim] doesn't have blood!"))
				return
			COOLDOWN_START(V, drain_cooldown, 3 SECONDS)
			if(victim.can_block_magic(MAGIC_RESISTANCE_HOLY, charge_cost = 0))
				victim.show_message(span_warning("[H] tries to bite you, but stops before touching you!"))
				to_chat(H, span_warning("[victim] is blessed! You stop just in time to avoid catching fire."))
				return
			if(victim.has_reagent(/datum/reagent/consumable/garlic))
				victim.show_message(span_warning("[H] tries to bite you, but recoils in disgust!"))
				to_chat(H, span_warning("[victim] reeks of garlic! you can't bring yourself to drain such tainted blood."))
				return
			if(!do_after(H, 3 SECONDS, target = victim, hidden = TRUE))
				return
			var/blood_volume_difference = BLOOD_VOLUME_MAXIMUM - H.blood_volume //How much capacity we have left to absorb blood
			var/drained_blood = min(victim.blood_volume, VAMP_DRAIN_AMOUNT, blood_volume_difference)
			victim.show_message(span_danger("[H] is draining your blood!"))
			to_chat(H, span_notice("You drain some blood!"))
			playsound(H, 'sound/items/drink.ogg', 30, TRUE, -2)
			victim.blood_volume = clamp(victim.blood_volume - drained_blood, 0, BLOOD_VOLUME_MAXIMUM)
			H.blood_volume = clamp(H.blood_volume + drained_blood, 0, BLOOD_VOLUME_MAXIMUM)
			if(!victim.blood_volume)
				to_chat(H, span_notice("You finish off [victim]'s blood supply."))

/obj/item/organ/internal/heart/vampire
	name = "vampire heart"
	color = COLOR_CRAYON_BLACK

/obj/item/organ/internal/heart/vampire/on_mob_insert(mob/living/carbon/receiver)
	. = ..()
	RegisterSignal(receiver, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))

/obj/item/organ/internal/heart/vampire/on_mob_remove(mob/living/carbon/heartless)
	. = ..()
	UnregisterSignal(heartless, COMSIG_MOB_GET_STATUS_TAB_ITEMS)

/obj/item/organ/internal/heart/vampire/proc/get_status_tab_item(mob/living/carbon/source, list/items)
	SIGNAL_HANDLER
	items += "Blood Level: [source.blood_volume]/[BLOOD_VOLUME_MAXIMUM]"

#undef VAMPIRES_PER_HOUSE
#undef VAMP_DRAIN_AMOUNT
