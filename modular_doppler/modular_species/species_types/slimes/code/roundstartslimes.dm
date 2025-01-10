#define SLIME_ACTIONS_ICON_FILE 'modular_nova/master_files/icons/mob/actions/actions_slime.dmi'
/// This is the level of waterstacks that start doing noteworthy bloodloss to a slimeperson.
#define WATER_STACKS_DAMAGING 5
/// This is the level of waterstacks that prevent a slimeperson from regenerating, doing minimal bloodloss in the process.
#define WATER_STACKS_NO_REGEN 1

/datum/species/jelly
	hair_alpha = 160 //a notch brighter so it blends better.
	facial_hair_alpha = 160
	mutantliver = /obj/item/organ/liver/slime
	mutantstomach = /obj/item/organ/stomach/slime
	mutantbrain = /obj/item/organ/brain/slime
	mutantears = /obj/item/organ/ears/jelly
	hair_color_mode = null
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_NOBLOOD,
		TRAIT_TOXINLOVER,
		TRAIT_EASYDISMEMBER,
	)
	/// Ability to allow them to shapeshift their body around.
	var/datum/action/innate/alter_form/alter_form
	/// Ability to allow them to clean themselves and their stuff.
	var/datum/action/cooldown/spell/slime_washing/slime_washing
	/// Ability to allow them to resist the effects of water.
	var/datum/action/cooldown/spell/slime_hydrophobia/slime_hydrophobia
	/// Ability to allow them to turn their core's GPS on or off.
	var/datum/action/innate/core_signal/core_signal

	digitigrade_customization = DIGITIGRADE_OPTIONAL
	digi_leg_overrides = list(
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade,
	)

/datum/species/jelly/on_species_gain(mob/living/carbon/new_jellyperson, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if(ishuman(new_jellyperson))
		slime_washing = new
		slime_washing.Grant(new_jellyperson)
		core_signal = new
		core_signal.Grant(new_jellyperson)

/datum/species/jelly/on_species_loss(mob/living/carbon/former_jellyperson, datum/species/new_species, pref_load)
	. = ..()
	if(slime_washing)
		slime_washing.Remove(former_jellyperson)
	if(core_signal)
		core_signal.Remove(former_jellyperson)

/obj/item/organ/eyes/jelly
	name = "photosensitive eyespots"
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/eyes/roundstartslime
	name = "photosensitive eyespots"
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/ears/jelly
	name = "core audiosomes"
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/tongue/jelly
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/lungs/slime
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/liver/slime
	name = "endoplasmic reticulum"
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/stomach/slime
	name = "golgi apparatus"
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/brain/slime
	name = "slime core"
	desc = "The central core of a slimeperson, technically their 'extract', and where the cytoplasm, membrane, and organelles come from. Cutting edge research in xenobiology suggests this could also be a mitochondria."
	icon = 'modular_doppler/modular_species/species_types/slimes/icons/slimecore.dmi'
	icon_state = "slime_core"
	zone = BODY_ZONE_CHEST
	/// This is the VFX for what happens when they melt and die.
	var/obj/effect/death_melt_type = /obj/effect/temp_visual/wizard/out
	/// Color of the slimeperson's 'core' brain, defaults to white.
	var/core_color = COLOR_WHITE
	/// This tracks whether their core has been ejected or not after they die.
	var/core_ejected = FALSE
	/// This tracks whether their GPS microchip is enabled or not, only becomes TRUE on activation of the below ability /datum/action/innate/core_signal.
	var/gps_active = FALSE
	throw_range = 9 //Oh! That's a baseball!
	throw_speed = 0.5
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | LAVA_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/item/organ/brain/slime/Initialize(mapload, mob/living/carbon/organ_owner, list/examine_list)
	. = ..()
	colorize()

/obj/item/organ/brain/slime/examine()
	. = ..()
	if(gps_active)
		. += span_notice("A dim light lowly pulsates from the center of the core, indicating an outgoing signal from a tracking microchip.")
		. += span_red("You could probably snuff that out.")
	. += span_hypnophrase("You remember that pouring plasma on it, if it's non-embodied, would make it regrow one.")

/obj/item/organ/brain/slime/attack_self(mob/living/user) // Allows a player (presumably an antag) to deactivate the GPS signal on a slime core
	if(!(gps_active))
		return
	user.visible_message(span_warning("[user] begins jamming [user.p_their()] hand into a slime core! Slime goes everywhere!"),
	span_notice("You jam your hand into the core, feeling for the densest point! Your arm is covered in slime!"),
	span_notice("You hear an obscene squelching sound.")
	)
	playsound(user, 'sound/items/handling/surgery/organ1.ogg', 80, TRUE)

	if(!do_after(user, 30 SECONDS, src))
		user.visible_message(span_warning("[user]'s hand slips out of the core before [user.p_they()] can cause any harm!'"),
		span_warning("Your hand slips out of the goopy core before you can find its densest point."),
		span_notice("You hear a resounding plop.")
		)
		return

	user.visible_message(span_warning("[user] crunches something deep in the slime core! It gradually stops glowing..."),
	span_notice("You find the densest point, crushing it in your palm. The blinking light in the core slowly dissipates."),
	span_notice("You hear a wet crunching sound."))
	playsound(user, 'sound/effects/wounds/crackandbleed.ogg', 80, TRUE)
	gps_active = FALSE
	qdel(GetComponent(/datum/component/gps))

/obj/item/organ/brain/slime/on_mob_insert(mob/living/carbon/organ_owner, special = FALSE, movement_flags)
	. = ..()
	colorize()
	core_ejected = FALSE
	RegisterSignal(organ_owner, COMSIG_LIVING_DEATH, PROC_REF(on_slime_death))

/obj/item/organ/brain/slime/on_mob_remove(mob/living/carbon/organ_owner)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_LIVING_DEATH)

/**
* Colors the slime's core (their brain) the same as their first mutant color.
*/
/obj/item/organ/brain/slime/proc/colorize()
	if(owner && isjellyperson(owner))
		core_color = owner.dna.features["mcolor"]
		add_atom_colour(core_color, FIXED_COLOUR_PRIORITY)

/**
* Handling for tracking when the slime in question dies (except through gibbing), which then segues into the core ejection proc.
*/
/obj/item/organ/brain/slime/proc/on_slime_death(mob/living/victim, gibbed)
	SIGNAL_HANDLER
	UnregisterSignal(victim, COMSIG_LIVING_DEATH)

	if(gibbed)
		qdel(src)
		UnregisterSignal(victim, COMSIG_LIVING_DEATH)
		return

	addtimer(CALLBACK(src, PROC_REF(core_ejection), victim), 0) // explode them after the current proc chain ends, to avoid weirdness

/**
* CORE EJECTION PROC -
* Makes it so that when a slime dies, their core ejects and their body is qdel'd.
*/
/obj/item/organ/brain/slime/proc/core_ejection(mob/living/victim, new_stat, turf/loc_override)
	if(core_ejected)
		return
	core_ejected = TRUE
	victim.visible_message(span_warning("[victim]'s body completely dissolves, collapsing outwards!"), span_notice("Your body completely dissolves, collapsing outwards!"), span_notice("You hear liquid splattering."))
	var/atom/death_loc = victim.drop_location()
	victim.unequip_everything()
	if(victim.get_organ_slot(ORGAN_SLOT_BRAIN) == src)
		Remove(victim)
	if(death_loc)
		forceMove(death_loc)
	src.wash(CLEAN_WASH)
	new death_melt_type(death_loc, victim.dir)

	do_steam_effects(get_turf(victim))
	playsound(victim, 'sound/effects/blob/blobattack.ogg', 80, TRUE)

	if(gps_active) // adding the gps signal if they have activated the ability
		AddComponent(/datum/component/gps, "[victim]'s Core")

	qdel(victim)
	UnregisterSignal(victim, COMSIG_LIVING_DEATH)

/**
* Procs the ethereal jaunt liquid effect when the slime dissolves on death.
*/
/obj/item/organ/brain/slime/proc/do_steam_effects(turf/loc)
	var/datum/effect_system/steam_spread/steam = new()
	steam.set_up(10, FALSE, loc)
	steam.start()

/**
* CHECK FOR REPAIR SECTION
* Makes it so that when a slime's core has plasma poured on it, it builds a new body and moves the brain into it.
*/
/obj/item/organ/brain/slime/check_for_repair(obj/item/item, mob/user)
	if(damage && item.is_drainable() && item.reagents.has_reagent(/datum/reagent/toxin/plasma) && item.reagents.get_reagent_amount(/datum/reagent/toxin/plasma) >= 100 && (organ_flags & ORGAN_ORGANIC)) //attempt to heal the brain

		user.visible_message(span_notice("[user] starts to slowly pour the contents of [item] onto [src]. It seems to bubble and roil, beginning to stretch its cytoskeleton outwards..."), span_notice("You start to slowly pour the contents of [item] onto [src]. It seems to bubble and roil, beginning to stretch its membrane outwards..."))
		if(!do_after(user, 60 SECONDS, src))
			to_chat(user, span_warning("You fail to pour the contents of [item] onto [src]!"))
			return TRUE

		user.visible_message(span_notice("[user] pours the contents of [item] onto [src], causing it to form a proper cytoplasm and outer membrane."), span_notice("You pour the contents of [item] onto [src], causing it to form a proper cytoplasm and outer membrane."))
		item.reagents.clear_reagents() //removes the whole shit
		set_organ_damage(-maxHealth) //fully heals the brain

		if(gps_active) // making sure the gps signal is removed if it's active on revival
			gps_active = FALSE
			qdel(GetComponent(/datum/component/gps))

		//we have the plasma. we can rebuild them.
		if(isnull(brainmob))
			user.balloon_alert("This brain is not a viable candidate for repair!")
			return TRUE
		if(isnull(brainmob.stored_dna))
			user.balloon_alert("No DNA!")
			return TRUE
		if(isnull(brainmob.client))
			user.balloon_alert("No mind at the moment!")
			return TRUE
		var/mob/living/carbon/human/new_body = new /mob/living/carbon/human(src.loc)

		brainmob.client?.prefs?.safe_transfer_prefs_to(new_body)
		new_body.underwear = "Nude"
		new_body.bra = "Nude"
		new_body.undershirt = "Nude" //Which undershirt the player wants
		new_body.socks = "Nude" //Which socks the player wants
		brainmob.stored_dna.transfer_identity(new_body, transfer_SE=1)
		new_body.dna.features["mcolor"] = new_body.dna.features["mcolor"]
		new_body.dna.update_uf_block(DNA_MUTANT_COLOR_BLOCK)
		new_body.real_name = new_body.dna.real_name
		new_body.name = new_body.dna.real_name
		new_body.updateappearance(mutcolor_update=1)
		new_body.domutcheck()
		new_body.forceMove(get_turf(src))
		new_body.blood_volume = BLOOD_VOLUME_SAFE+60
		REMOVE_TRAIT(new_body, TRAIT_NO_TRANSFORM, REF(src))
		SSquirks.AssignQuirks(new_body, brainmob.client)
		src.replace_into(new_body)
		for(var/obj/item/bodypart/bodypart as anything in new_body.bodyparts)
			if(!istype(bodypart, /obj/item/bodypart/chest))
				bodypart.drop_limb()
				continue
		new_body.visible_message(span_warning("[new_body]'s torso \"forms\" from [new_body.p_their()] core, yet to form the rest."))
		to_chat(owner, span_purple("Your torso fully forms out of your core, yet to form the rest."))
		brainmob.mind.transfer_to(new_body)
		return TRUE
	return FALSE



// HEALING SECTION
// Handles passive healing and water damage.
/datum/species/jelly/spec_life(mob/living/carbon/human/slime, seconds_per_tick, times_fired)
	. = ..()
	if(slime.stat != CONSCIOUS)
		return

	var/healing = TRUE

	var/datum/status_effect/fire_handler/wet_stacks/wetness = locate() in slime.status_effects
	if(istype(wetness) && wetness.stacks > (WATER_STACKS_DAMAGING))
		slime.blood_volume -= 2 * seconds_per_tick
		if(SPT_PROB(25, seconds_per_tick))
			slime.visible_message(span_danger("[slime]'s form begins to lose cohesion, seemingly diluting with the water!"), span_warning("The water starts to dilute your body, dry it off!"))

	if(istype(wetness) && wetness.stacks > (WATER_STACKS_NO_REGEN))
		healing = FALSE
		if(SPT_PROB(1, seconds_per_tick))
			to_chat(slime, span_warning("You can't pull your body together and regenerate with water inside it!"))
			slime.blood_volume -= 1 * seconds_per_tick

	if(slime.blood_volume >= BLOOD_VOLUME_NORMAL && healing)
		if(slime.stat != CONSCIOUS)
			return
		slime.heal_overall_damage(brute = 1.5 * seconds_per_tick, burn = 1.5 * seconds_per_tick, required_bodytype = BODYTYPE_ORGANIC)
		slime.adjustOxyLoss(-1 * seconds_per_tick)


/**
* SLIME CLEANING ABILITY -
* When toggled, slimes clean themselves and their equipment.
*/
/datum/action/cooldown/spell/slime_washing
	name = "Toggle Slime Cleaning"
	desc = "Filter grime through your outer membrane, cleaning yourself and your equipment for sustenance. Also cleans the floor. For sustenance."
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "activate_wash"

	cooldown_time = 1 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/slime_washing/cast(mob/living/carbon/human/user = usr)
	. = ..()

	if(user.has_status_effect(/datum/status_effect/slime_washing))
		slime_washing_deactivate(user)
		return

	user.apply_status_effect(/datum/status_effect/slime_washing)
	user.visible_message(span_purple("[user]'s outer membrane starts to develop a cloudy film on the outside, absorbing grime into [user.p_their()] inner layer!"), span_purple("Your outer membrane develops a cloudy film on the outside, absorbing grime off yourself and your clothes; as well as the floor beneath you."))

/**
* Called when you activate it again after casting the ability-- turning it off, so to say.
*/
/datum/action/cooldown/spell/slime_washing/proc/slime_washing_deactivate(mob/living/carbon/human/user)
	if(!user.has_status_effect(/datum/status_effect/slime_washing))
		return

	user.remove_status_effect(/datum/status_effect/slime_washing)
	user.visible_message(span_notice("[user]'s outer membrane returns to normal, no longer cleaning [user.p_their()] surroundings."), span_notice("Your outer membrane returns to normal, filth no longer being cleansed."))

/datum/status_effect/slime_washing
	id = "slime_washing"
	alert_type = null
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/slime_washing/tick(seconds_between_ticks, seconds_per_tick)
	if(ishuman(owner))
		var/mob/living/carbon/human/slime = owner
		for(var/obj/item/slime_items in slime.get_equipped_items(INCLUDE_ACCESSORIES | INCLUDE_HELD))
			slime_items.wash(CLEAN_WASH)
			slime.wash(CLEAN_WASH)
		if((slime.wear_suit?.body_parts_covered | slime.w_uniform?.body_parts_covered | slime.shoes?.body_parts_covered) & FEET)
			return
		else
			var/turf/open/open_turf = get_turf(slime)
			if(istype(open_turf))
				open_turf.wash(CLEAN_WASH)
				return TRUE
			if(SPT_PROB(5, seconds_per_tick))
				slime.adjust_nutrition((rand(5,25)))

/datum/status_effect/slime_washing/get_examine_text()
	return span_notice("[owner.p_Their()] outer layer is pulling in grime, filth sinking inside of [owner.p_their()] body and vanishing.")

// CHEMICAL HANDLING
// Here's where slimes heal off plasma and where they hate drinking water.

/datum/species/jelly/handle_chemical(datum/reagent/chem, mob/living/carbon/human/slime, seconds_per_tick, times_fired)
	. = ..()
	if(. & COMSIG_MOB_STOP_REAGENT_CHECK)
		return
	// slimes use plasma to fix wounds, and if they have enough blood, organs
	var/static/list/organs_we_mend = list(
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
	)
	if(chem.type == /datum/reagent/toxin/plasma || chem.type == /datum/reagent/toxin/hot_ice)
		for(var/datum/wound/iter_wound as anything in slime.all_wounds)
			iter_wound.on_xadone(4 * REM * seconds_per_tick)
			slime.reagents.remove_reagent(chem.type, min(chem.volume * 0.22, 10))
		if(slime.blood_volume > BLOOD_VOLUME_SLIME_SPLIT)
			slime.adjustOrganLoss(
			pick(organs_we_mend),
			- 2 * seconds_per_tick,
		)
		if(SPT_PROB(5, seconds_per_tick))
			to_chat(slime, span_purple("Your body's thirst for plasma is quenched, your inner and outer membrane using it to regenerate."))

	if(chem.type == /datum/reagent/water)
		slime.blood_volume -= 3 * seconds_per_tick
		slime.reagents.remove_reagent(chem.type, min(chem.volume * 0.22, 10))
		if(SPT_PROB(1, seconds_per_tick))
			to_chat(slime, span_warning("The water starts to weaken and adulterate your insides!"))
		return COMSIG_MOB_STOP_REAGENT_CHECK

/datum/species/jelly/roundstartslime
	name = "Xenobiological Slime Hybrid"
	id = SPECIES_SLIMESTART
	preview_outfit = /datum/outfit/slime_preview
	examine_limb_id = SPECIES_SLIMEPERSON
	coldmod = 3
	heatmod = 1
	specific_alpha = 155
	mutanteyes = /obj/item/organ/eyes/roundstartslime
	mutanttongue = /obj/item/organ/tongue/jelly

	bodypart_overrides = list( //Overriding jelly bodyparts
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/jelly/slime/roundstart,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/jelly/slime/roundstart,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/jelly/slime/roundstart,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/jelly/slime/roundstart,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/jelly/slime/roundstart,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/jelly/slime/roundstart,
	)

/datum/outfit/slime_preview
	name = "Slimeperson (Species Preview)"
	uniform = /obj/item/clothing/under/costume/bunnysuit
	head = /obj/item/clothing/head/maid_headband

/datum/species/jelly/roundstartslime/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features["mcolor"] = "#EF313F"
	human.dna.ear_type = BUNNY
	human.dna.features["ears"] = "Lop (Sexy)"
	human.dna.features["ears_color_1"] = "#EF313F"
	human.dna.features["ears_color_2"] = "#EF313F"
	human.dna.features["ears_color_3"] = "#EF313F"
	human.hair_color = "#EF313F"
	human.hairstyle = "Slime Droplet"
	regenerate_organs(human, src, visual_only = TRUE)
	human.update_body(TRUE)

/datum/species/jelly/roundstartslime/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "scissors",
			SPECIES_PERK_NAME = "Headcase",
			SPECIES_PERK_DESC = "Given slimepeople have all their organs in their chest, and no neck to boot, they can be decapitated easily.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "circle",
			SPECIES_PERK_NAME = "Single-Celled Organism",
			SPECIES_PERK_DESC = "Slimes only have one discrete organ, their core. It comes pre-installed with a togglable microchip for ease in location; their other organelles are unremovable.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "notes-medical",
			SPECIES_PERK_NAME = "Regenerator",
			SPECIES_PERK_DESC = "Slimes, if they have a proper amount of jelly inside, are capable of regenerating damage and limbs. If they're exposed to plasma at a high jelly volume, they can regenerate wounds.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "droplet-slash",
			SPECIES_PERK_NAME = "Dissolution",
			SPECIES_PERK_DESC = "If slimes have their limbs chopped off, they disintegrate and cannot be recovered. If their body dies as a whole, it dissolves away from their core and requires 100u of liquid plasma to fix.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "hand-holding-droplet",
			SPECIES_PERK_NAME = "Washes Right Out",
			SPECIES_PERK_DESC = "Slimes are capable of cleaning themselves and their clothing, siphoning the dirt off it and into themselves; even off the floor, if they're barefoot. This gives them a mild amount of nutrition.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "person-swimming",
			SPECIES_PERK_NAME = "Major Hydrophobia",
			SPECIES_PERK_DESC = "Slimes dissolve when exposed to water under normal circumstances, water nuking their blood volume and stopping their ability to regenerate.",
		),
	)

	return to_add

/**
 * Toggle Death Signal simply adds and removes the trait required for slimepeople to transmit a GPS signal upon core ejection.
 */
/datum/action/innate/core_signal
	name = "Toggle Core Signal"
	desc = "Interface with the microchip placed in your core, modifying whether it emits a GPS signal or not. Due to how thick your liquid body is, the signal won't reach out until your core is outside of it."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'modular_doppler/modular_species/species_types/slimes/icons/slimecore.dmi'
	button_icon_state = "slime_core"
	background_icon_state = "bg_alien"
	/// Do you need to be a slime-person to use this ability?
	var/slime_restricted = TRUE

/datum/action/innate/core_signal/Activate()
	var/mob/living/carbon/human/slime = owner
	var/obj/item/organ/brain/slime/core = slime.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(slime_restricted && !isjellyperson(slime))
		return
	if(core.gps_active)
		to_chat(owner,span_notice("You tune out the electromagnetic signals from your core so they are ignored by GPS receivers upon its rejection."))
		core.gps_active = FALSE
	else
		to_chat(owner, span_notice("You fine-tune the electromagnetic signals from your core to be picked up by GPS receivers upon its rejection."))
		core.gps_active = TRUE

#undef SLIME_ACTIONS_ICON_FILE
#undef WATER_STACKS_DAMAGING
#undef WATER_STACKS_NO_REGEN
