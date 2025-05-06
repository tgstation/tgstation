///The rate at which slimes regenerate their jelly normally
#define JELLY_REGEN_RATE 1.5
///The rate at which slimes regenerate their jelly when they completely run out of it and start taking damage, usually after having cannibalized all their limbs already
#define JELLY_REGEN_RATE_EMPTY 2.5
///The blood volume at which slimes begin to start losing nutrition -- so that IV drips can work for blood deficient slimes
#define BLOOD_VOLUME_LOSE_NUTRITION 550

/datum/species/jelly
	// Entirely alien beings that seem to be made entirely out of gel. They have three eyes and a skeleton visible within them.
	name = "\improper Jellyperson"
	plural_form = "Jellypeople"
	id = SPECIES_JELLYPERSON
	examine_limb_id = SPECIES_JELLYPERSON
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_SLIME
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_TOXINLOVER,
		TRAIT_NOBLOOD,
	)
	mutanttongue = /obj/item/organ/tongue/jelly
	mutantlungs = /obj/item/organ/lungs/slime
	mutanteyes = /obj/item/organ/eyes/jelly
	mutantheart = null
	meat = /obj/item/food/meat/slab/human/mutant/slime
	exotic_blood = /datum/reagent/toxin/slimejelly
	exotic_bloodtype = BLOOD_TYPE_TOX
	blood_deficiency_drain_rate = JELLY_REGEN_RATE + BLOOD_DEFICIENCY_MODIFIER
	coldmod = 6   // = 3x cold damage
	heatmod = 0.5 // = 1/4x heat damage
	payday_modifier = 1.0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	inherent_factions = list(FACTION_SLIME)
	species_language_holder = /datum/language_holder/jelly
	hair_color_mode = USE_MUTANT_COLOR
	hair_alpha = 150
	facial_hair_alpha = 150
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/jelly,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/jelly,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/jelly,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/jelly,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/jelly,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/jelly,
	)
	var/datum/action/innate/regenerate_limbs/regenerate_limbs

/datum/species/jelly/on_species_gain(mob/living/carbon/new_jellyperson, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if(ishuman(new_jellyperson))
		regenerate_limbs = new
		regenerate_limbs.Grant(new_jellyperson)
	new_jellyperson.AddElement(/datum/element/soft_landing)
	RegisterSignal(new_jellyperson, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(slime_blood))

/datum/species/jelly/on_species_loss(mob/living/carbon/former_jellyperson, datum/species/new_species, pref_load)
	if(regenerate_limbs)
		regenerate_limbs.Remove(former_jellyperson)
	former_jellyperson.RemoveElement(/datum/element/soft_landing)
	UnregisterSignal(former_jellyperson, COMSIG_HUMAN_ON_HANDLE_BLOOD)
	return ..()

/datum/species/jelly/proc/slime_blood(mob/living/carbon/human/slime, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	if(slime.stat == DEAD)
		return HANDLE_BLOOD_HANDLED

	if(slime.blood_volume <= 0)
		slime.blood_volume += JELLY_REGEN_RATE_EMPTY * slime.physiology.blood_regen_mod * seconds_per_tick
		slime.adjustBruteLoss(2.5 * seconds_per_tick)
		to_chat(slime, span_danger("You feel empty!"))

	if(slime.blood_volume < BLOOD_VOLUME_NORMAL)
		if(slime.nutrition >= NUTRITION_LEVEL_STARVING)
			slime.blood_volume += JELLY_REGEN_RATE * slime.physiology.blood_regen_mod * seconds_per_tick
			if(slime.blood_volume <= BLOOD_VOLUME_LOSE_NUTRITION) // don't lose nutrition if we are above a certain threshold, otherwise slimes on IV drips will still lose nutrition
				slime.adjust_nutrition(-1.25 * seconds_per_tick)

	if(slime.blood_volume < BLOOD_VOLUME_OKAY)
		if(SPT_PROB(2.5, seconds_per_tick))
			to_chat(slime, span_danger("You feel drained!"))

	if(slime.blood_volume < BLOOD_VOLUME_BAD)
		Cannibalize_Body(slime)

	regenerate_limbs?.build_all_button_icons(UPDATE_BUTTON_STATUS)
	return HANDLE_BLOOD_NO_NUTRITION_DRAIN|HANDLE_BLOOD_NO_OXYLOSS

/datum/species/jelly/proc/Cannibalize_Body(mob/living/carbon/human/H)
	var/list/limbs_to_consume = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG) - H.get_missing_limbs()
	var/obj/item/bodypart/consumed_limb
	if(!length(limbs_to_consume))
		H.losebreath++
		return
	if(H.num_legs) //Legs go before arms
		limbs_to_consume -= list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM)
	consumed_limb = H.get_bodypart(pick(limbs_to_consume))
	consumed_limb.drop_limb()
	to_chat(H, span_userdanger("Your [consumed_limb] is drawn back into your body, unable to maintain its shape!"))
	qdel(consumed_limb)
	H.blood_volume += 65 * H.physiology.blood_regen_mod //DOPPLER EDIT - CHANGE - ORIGINAL: 20 - This is because losing a limb now costs them 60 blood, so this refunds it with a pinch extra so it doesn't. Y'know. Kill you.

/datum/species/jelly/get_species_description()
	return "Jellypeople are a strange and alien species with three eyes, made entirely out of gel."

/datum/species/jelly/get_species_lore()
	return list(
		"Jellypeople are actively being experimented on my Nanotrasen scientists, who are trying to unlock the secrets of their unique biology.",
	)

/datum/species/jelly/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features["mcolor"] = COLOR_PINK
	human.hairstyle = "Bob Hair 2"
	human.hair_color = COLOR_PINK
	human.update_body(is_creating = TRUE)

// Slimes have both TRAIT_NOBLOOD and an exotic bloodtype set, so they need to be handled uniquely here.
// They may not be roundstart but in the unlikely event they become one might as well not leave a glaring issue open.
/datum/species/jelly/create_pref_blood_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "tint",
		SPECIES_PERK_NAME = "Jelly Blood",
		SPECIES_PERK_DESC = "[plural_form] don't have blood, but instead have toxic [initial(exotic_blood.name)]! \
			Jelly is extremely important, as losing it will cause you to lose limbs. Having low jelly will make medical treatment very difficult.",
	))

	return to_add

/datum/action/innate/regenerate_limbs
	name = "Regenerate Limbs"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeheal"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/regenerate_limbs/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs()
	if(!length(limbs_to_heal))
		return FALSE
	if(H.blood_volume >= BLOOD_VOLUME_OKAY+40)
		return TRUE

/datum/action/innate/regenerate_limbs/Activate()
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs()
	if(!length(limbs_to_heal))
		to_chat(H, span_notice("You feel intact enough as it is."))
		return
	to_chat(H, span_notice("You focus intently on your missing [length(limbs_to_heal) >= 2 ? "limbs" : "limb"]..."))
	if(H.blood_volume >= 40*length(limbs_to_heal)+BLOOD_VOLUME_OKAY)
		H.regenerate_limbs()
		H.blood_volume -= 40*length(limbs_to_heal)
		to_chat(H, span_notice("...and after a moment you finish reforming!"))
		return
	else if(H.blood_volume >= 40)//We can partially heal some limbs
		while(H.blood_volume >= BLOOD_VOLUME_OKAY+40)
			var/healed_limb = pick(limbs_to_heal)
			H.regenerate_limb(healed_limb)
			limbs_to_heal -= healed_limb
			H.blood_volume -= 40
		to_chat(H, span_warning("...but there is not enough of you to fix everything! You must attain more mass to heal completely!"))
		return
	to_chat(H, span_warning("...but there is not enough of you to go around! You must attain more mass to heal!"))

////////////////////////////////////////////////////////SLIMEPEOPLE///////////////////////////////////////////////////////////////////

//Slime people are able to split like slimes, retaining a single mind that can swap between bodies at will, even after death.

/datum/species/jelly/slime
	name = "\improper Slimeperson"
	plural_form = "Slimepeople"
	id = SPECIES_SLIMEPERSON
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	mutanteyes = /obj/item/organ/eyes
	var/datum/action/innate/split_body/slime_split
	var/list/mob/living/carbon/bodies
	var/datum/action/innate/swap_body/swap_body

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/jelly/slime,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/jelly/slime,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/jelly/slime,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/jelly/slime,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/jelly/slime,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/jelly/slime,
	)

/datum/species/jelly/slime/get_physical_attributes()
	return "Slimepeople have jelly for blood and their vacuoles can extremely quickly convert plasma to it if they're breathing it in.\
		They can then use the excess blood to split off an excess body, which their consciousness can transfer to at will or on death.\
		Most things that are toxic heal them, but most things that prevent toxicity damage them!"

/datum/species/jelly/slime/on_species_loss(mob/living/carbon/C)
	if(slime_split)
		slime_split.Remove(C)
	if(swap_body)
		swap_body.Remove(C)
	bodies -= C // This means that the other bodies maintain a link
	// so if someone mindswapped into them, they'd still be shared.
	bodies = null
	C.blood_volume = min(C.blood_volume, BLOOD_VOLUME_NORMAL)
	UnregisterSignal(C, COMSIG_LIVING_DEATH)
	..()

/datum/species/jelly/slime/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	..()
	if(ishuman(C))
		slime_split = new
		slime_split.Grant(C)
		swap_body = new
		swap_body.Grant(C)

		if(!bodies || !length(bodies))
			bodies = list(C)
		else
			bodies |= C

	RegisterSignal(C, COMSIG_LIVING_DEATH, PROC_REF(on_death_move_body))

/datum/species/jelly/slime/proc/on_death_move_body(mob/living/carbon/human/source, gibbed)
	SIGNAL_HANDLER

	if(!slime_split)
		return
	if(!source.mind?.active)
		return

	var/list/available_bodies = bodies - source
	for(var/mob/living/other_body as anything in available_bodies)
		if(!swap_body.can_swap(other_body))
			available_bodies -= other_body

	if(!length(available_bodies))
		return

	swap_body.swap_to_dupe(source.mind, pick(available_bodies))

//If you're cloned you get your body pool back
/datum/species/jelly/slime/copy_properties_from(datum/species/jelly/slime/old_species)
	bodies = old_species.bodies

/datum/species/jelly/slime/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	. = ..()
	if(H.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
		if(SPT_PROB(2.5, seconds_per_tick))
			to_chat(H, span_notice("You feel very bloated!"))

	else if(H.nutrition >= NUTRITION_LEVEL_WELL_FED)
		H.blood_volume += 1.5 * seconds_per_tick
		if(H.blood_volume <= BLOOD_VOLUME_LOSE_NUTRITION)
			H.adjust_nutrition(-1.25 * seconds_per_tick)

/datum/action/innate/split_body
	name = "Split Body"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimesplit"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/split_body/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = owner
	if(H.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
		return TRUE
	return FALSE

/datum/action/innate/split_body/Activate()
	var/mob/living/carbon/human/H = owner
	if(!isslimeperson(H))
		return
	CHECK_DNA_AND_SPECIES(H)
	H.visible_message(
		span_notice("[owner] gains a look of concentration while standing perfectly still."),
		span_notice("You focus intently on moving your body while standing perfectly still..."),
	)

	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, REF(src))

	if(do_after(owner, delay = 6 SECONDS, target = owner, timed_action_flags = IGNORE_HELD_ITEM))
		if(H.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
			make_dupe()
		else
			to_chat(H, span_warning("...but there is not enough of you to go around! You must attain more mass to split!"))
	else
		to_chat(H, span_warning("...but fail to stand perfectly still!"))

	REMOVE_TRAIT(src, TRAIT_NO_TRANSFORM, REF(src))

/datum/action/innate/split_body/proc/make_dupe()
	var/mob/living/carbon/human/H = owner
	CHECK_DNA_AND_SPECIES(H)

	var/mob/living/carbon/human/spare = new /mob/living/carbon/human(H.loc)

	spare.underwear = "Nude"
	H.dna.transfer_identity(spare, transfer_SE=1)
	spare.dna.features["mcolor"] = "#[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"
	spare.dna.update_uf_block(DNA_MUTANT_COLOR_BLOCK)
	spare.real_name = spare.dna.real_name
	spare.name = spare.dna.real_name
	spare.updateappearance(mutcolor_update=1)
	spare.domutcheck()
	spare.Move(get_step(H.loc, pick(NORTH,SOUTH,EAST,WEST)))

	H.blood_volume *= 0.45
	REMOVE_TRAIT(H, TRAIT_NO_TRANSFORM, REF(src))

	var/datum/species/jelly/slime/origin_datum = H.dna.species
	origin_datum.bodies |= spare

	var/datum/species/jelly/slime/spare_datum = spare.dna.species
	spare_datum.bodies = origin_datum.bodies

	H.transfer_quirk_datums(spare)
	H.mind.transfer_to(spare)
	spare.visible_message(
		span_warning("[H] distorts as a new body \"steps out\" of [H.p_them()]."),
		span_notice("...and after a moment of disorentation, you're besides yourself!"),
	)


/datum/action/innate/swap_body
	name = "Swap Body"
	check_flags = NONE
	button_icon_state = "slimeswap"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/swap_body/Activate()
	if(!isslimeperson(owner))
		to_chat(owner, span_warning("You are not a slimeperson."))
		Remove(owner)
	else
		ui_interact(owner)

/datum/action/innate/swap_body/ui_host(mob/user)
	return owner

/datum/action/innate/swap_body/ui_state(mob/user)
	return GLOB.always_state

/datum/action/innate/swap_body/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlimeBodySwapper", name)
		ui.open()

/datum/action/innate/swap_body/ui_data(mob/user)
	var/mob/living/carbon/human/H = owner
	if(!isslimeperson(H))
		return

	var/datum/species/jelly/slime/SS = H.dna.species

	var/list/data = list()
	data["bodies"] = list()
	for(var/b in SS.bodies)
		var/mob/living/carbon/human/body = b
		if(!body || QDELETED(body) || !isslimeperson(body))
			SS.bodies -= b
			continue

		var/list/L = list()
		L["htmlcolor"] = body.dna.features["mcolor"]
		L["area"] = get_area_name(body, TRUE)
		var/stat = "error"
		switch(body.stat)
			if(CONSCIOUS)
				stat = "Conscious"
			if(SOFT_CRIT to HARD_CRIT) // Also includes UNCONSCIOUS
				stat = "Unconscious"
			if(DEAD)
				stat = "Dead"
		var/occupied
		if(body == H)
			occupied = "owner"
		else if(body.mind && body.mind.active)
			occupied = "stranger"
		else
			occupied = "available"

		L["status"] = stat
		L["exoticblood"] = body.blood_volume
		L["name"] = body.name
		L["ref"] = "[REF(body)]"
		L["occupied"] = occupied
		var/button
		if(occupied == "owner")
			button = "selected"
		else if(occupied == "stranger")
			button = "danger"
		else if(can_swap(body))
			button = null
		else
			button = "disabled"

		L["swap_button_state"] = button
		L["swappable"] = (occupied == "available") && can_swap(body)

		data["bodies"] += list(L)

	return data

/datum/action/innate/swap_body/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = owner
	if(!isslimeperson(owner))
		return
	if(!H.mind || !H.mind.active)
		return
	switch(action)
		if("swap")
			var/datum/species/jelly/slime/SS = H.dna.species
			var/mob/living/carbon/human/selected = locate(params["ref"]) in SS.bodies
			if(!can_swap(selected))
				return
			SStgui.close_uis(src)
			swap_to_dupe(H.mind, selected)

/datum/action/innate/swap_body/proc/can_swap(mob/living/carbon/human/dupe)
	var/mob/living/carbon/human/H = owner
	if(!isslimeperson(H))
		return FALSE
	var/datum/species/jelly/slime/SS = H.dna.species

	if(QDELETED(dupe)) //Is there a body?
		SS.bodies -= dupe
		return FALSE

	if(!isslimeperson(dupe)) //Is it a slimeperson?
		SS.bodies -= dupe
		return FALSE

	if(dupe.stat == DEAD) //Is it alive?
		return FALSE

	if(dupe.stat != CONSCIOUS) //Is it awake?
		return FALSE

	if(dupe.mind && dupe.mind.active) //Is it unoccupied?
		return FALSE

	if(!(dupe in SS.bodies)) //Do we actually own it?
		return FALSE

	return TRUE

/datum/action/innate/swap_body/proc/swap_to_dupe(datum/mind/M, mob/living/carbon/human/dupe)
	if(!can_swap(dupe)) //sanity check
		return
	if(M.current.stat == CONSCIOUS)
		M.current.visible_message(span_notice("[M.current] stops moving and starts staring vacantly into space."),
			span_notice("You stop moving this body..."))
	else
		to_chat(M.current, span_notice("You abandon this body..."))
	M.current.transfer_quirk_datums(dupe)
	M.transfer_to(dupe)
	dupe.visible_message(span_notice("[dupe] blinks and looks around."), span_notice("...and move this one instead."))


///////////////////////////////////LUMINESCENTS//////////////////////////////////////////

//Luminescents are able to consume and use slime extracts, without them decaying.

/datum/species/jelly/luminescent
	name = "Luminescent"
	plural_form = null
	id = SPECIES_LUMINESCENT
	examine_limb_id = SPECIES_LUMINESCENT
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/jelly/luminescent,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/jelly/luminescent,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/jelly/luminescent,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/jelly/luminescent,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/jelly/luminescent,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/jelly/luminescent,
	)
	mutanteyes = /obj/item/organ/eyes
	/// How strong is our glow
	var/glow_intensity = LUMINESCENT_DEFAULT_GLOW
	/// Internal dummy used to glow (very cool)
	var/obj/effect/dummy/lighting_obj/moblight/glow
	/// The slime extract we currently have integrated
	var/obj/item/slime_extract/current_extract
	/// A list of all luminescent related actions we have
	var/list/luminescent_actions
	/// The cooldown of us using exteracts
	COOLDOWN_DECLARE(extract_cooldown)

/datum/species/jelly/luminescent/get_physical_attributes()
	return "Luminescent are able to integrate slime extracts into themselves for wondrous effects. \
		Most things that are toxic heal them, but most things that prevent toxicity damage them!"

//Species datums don't normally implement destroy, but JELLIES SUCK ASS OUT OF A STEEL STRAW and have to i guess
/datum/species/jelly/luminescent/Destroy(force)
	current_extract = null
	QDEL_NULL(glow)
	QDEL_LIST(luminescent_actions)
	return ..()

/datum/species/jelly/luminescent/on_species_gain(mob/living/carbon/new_jellyperson, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	glow = new_jellyperson.mob_light(light_type = /obj/effect/dummy/lighting_obj/moblight/species)
	update_glow(new_jellyperson)

	luminescent_actions = list()

	var/datum/action/innate/integrate_extract/integrate_extract = new(src)
	integrate_extract.Grant(new_jellyperson)
	luminescent_actions += integrate_extract

	var/datum/action/innate/use_extract/extract_minor = new(src)
	extract_minor.Grant(new_jellyperson)
	luminescent_actions += extract_minor

	var/datum/action/innate/use_extract/major/extract_major = new(src)
	extract_major.Grant(new_jellyperson)
	luminescent_actions += extract_major

/datum/species/jelly/luminescent/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(current_extract)
		current_extract.forceMove(C.drop_location())
		current_extract = null
	QDEL_NULL(glow)
	QDEL_LIST(luminescent_actions)

/// Updates the glow of our internal glow object
/datum/species/jelly/luminescent/proc/update_glow(mob/living/carbon/human/glowie, intensity)
	if(intensity)
		glow_intensity = intensity
	glow.set_light_range_power_color(glow_intensity, glow_intensity, glowie.dna.features["mcolor"])

/datum/action/innate/integrate_extract
	name = "Integrate Extract"
	desc = "Eat a slime extract to use its properties."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeconsume"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/integrate_extract/New(Target)
	. = ..()
	AddComponent(/datum/component/action_item_overlay, item_callback = CALLBACK(src, PROC_REF(locate_extract)))

/// Callback for /datum/component/action_item_overlay to find the slime extract from within the species
/datum/action/innate/integrate_extract/proc/locate_extract()
	var/datum/species/jelly/luminescent/species = target
	if(!istype(species))
		return null

	return species.current_extract

/datum/action/innate/integrate_extract/update_button_name(atom/movable/screen/movable/action_button/button, force = FALSE)
	var/datum/species/jelly/luminescent/species = target
	if(!istype(species) || !species.current_extract)
		name = "Integrate Extract"
		desc = "Eat a slime extract to use its properties."
	else
		name = "Eject Extract"
		desc = "Eject your current slime extract."

	return ..()

/datum/action/innate/integrate_extract/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force)
	var/datum/species/jelly/luminescent/species = target
	if(!istype(species) || !species.current_extract)
		button_icon_state = "slimeconsume"
	else
		button_icon_state = "slimeeject"

	return ..()

/datum/action/innate/integrate_extract/Activate()
	var/mob/living/carbon/human/human_owner = owner
	var/datum/species/jelly/luminescent/species = target
	if(!istype(species))
		return

	if(species.current_extract)
		var/obj/item/slime_extract/to_remove = species.current_extract
		if(!human_owner.put_in_active_hand(to_remove))
			to_remove.forceMove(human_owner.drop_location())

		species.current_extract = null
		human_owner.balloon_alert(human_owner, "[to_remove.name] ejected")

	else
		var/obj/item/slime_extract/to_integrate = human_owner.get_active_held_item()
		if(!istype(to_integrate) || to_integrate.extract_uses <= 0)
			human_owner.balloon_alert(human_owner, "need an unused slime extract!")
			return
		if(!human_owner.temporarilyRemoveItemFromInventory(to_integrate))
			return
		to_integrate.forceMove(human_owner)
		species.current_extract = to_integrate
		human_owner.balloon_alert(human_owner, "[to_integrate.name] consumed")

	for(var/datum/action/to_update as anything in species.luminescent_actions)
		to_update.build_all_button_icons()

/datum/action/innate/use_extract
	name = "Extract Minor Activation"
	desc = "Pulse the slime extract with energized jelly to activate it."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeuse1"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	var/activation_type = SLIME_ACTIVATE_MINOR

/datum/action/innate/use_extract/New(Target)
	. = ..()
	AddComponent(/datum/component/action_item_overlay, item_callback = CALLBACK(src, PROC_REF(locate_extract)))

/// Callback for /datum/component/action_item_overlay to find the slime extract from within the species
/datum/action/innate/use_extract/proc/locate_extract()
	var/datum/species/jelly/luminescent/species = target
	if(!istype(species))
		return null

	return species.current_extract

/datum/action/innate/use_extract/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return

	var/datum/species/jelly/luminescent/species = target
	if(istype(species) && species.current_extract && (COOLDOWN_FINISHED(species, extract_cooldown)))
		return TRUE
	return FALSE

/datum/action/innate/use_extract/Activate()
	var/mob/living/carbon/human/human_owner = owner
	var/datum/species/jelly/luminescent/species = human_owner.dna?.species
	if(!istype(species) || !species.current_extract)
		return

	COOLDOWN_START(species, extract_cooldown, 10 SECONDS)
	var/after_use_cooldown = species.current_extract.activate(human_owner, species, activation_type)
	COOLDOWN_START(species, extract_cooldown, after_use_cooldown)

/datum/action/innate/use_extract/major
	name = "Extract Major Activation"
	desc = "Pulse the slime extract with plasma jelly to activate it."
	button_icon_state = "slimeuse2"
	activation_type = SLIME_ACTIVATE_MAJOR

///////////////////////////////////STARGAZERS//////////////////////////////////////////

//Stargazers are the telepathic branch of jellypeople, able to project psychic messages and to link minds with willing participants.

/datum/species/jelly/stargazer
	name = "\improper Stargazer"
	plural_form = null
	id = SPECIES_STARGAZER
	examine_limb_id = SPECIES_JELLYPERSON
	/// Special "project thought" telepathy action for stargazers.
	var/datum/action/innate/project_thought/project_action

/datum/species/jelly/stargazer/get_physical_attributes()
	return "Stargazers can link others' minds with their own, creating a private communication channel. \
		Most things that are toxic heal them, but most things that prevent toxicity damage them!"

/datum/species/jelly/stargazer/on_species_gain(mob/living/carbon/grant_to, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	project_action = new(src)
	project_action.Grant(grant_to)

	grant_to.AddComponent( \
		/datum/component/mind_linker/active_linking, \
		network_name = "Slime Link", \
		signals_which_destroy_us = list(COMSIG_SPECIES_LOSS), \
		linker_action_path = /datum/action/innate/link_minds, \
	)

//Species datums don't normally implement destroy, but JELLIES SUCK ASS OUT OF A STEEL STRAW
/datum/species/jelly/stargazer/Destroy()
	QDEL_NULL(project_action)
	return ..()

/datum/species/jelly/stargazer/on_species_loss(mob/living/carbon/remove_from)
	QDEL_NULL(project_action)
	return ..()

/datum/action/innate/project_thought
	name = "Send Thought"
	desc = "Send a private psychic message to someone you can see."
	button_icon_state = "send_mind"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/project_thought/Activate()
	var/mob/living/carbon/human/telepath = owner
	if(telepath.stat == DEAD)
		return
	if(!is_species(telepath, /datum/species/jelly/stargazer))
		return
	var/list/recipient_options = list()
	for(var/mob/living/recipient in oview(telepath))
		recipient_options.Add(recipient)
	if(!length(recipient_options))
		to_chat(telepath, span_warning("You don't see anyone to send your thought to."))
		return
	var/mob/living/recipient = tgui_input_list(telepath, "Choose a telepathic message recipient", "Telepathy", sort_names(recipient_options))
	if(isnull(recipient) || telepath.stat == DEAD || !is_species(telepath, /datum/species/jelly/stargazer))
		return
	var/msg = tgui_input_text(telepath, title = "Telepathy", max_length = MAX_MESSAGE_LEN)
	if(isnull(msg) || telepath.stat == DEAD || !is_species(telepath, /datum/species/jelly/stargazer))
		return
	if(!(recipient in oview(telepath)))
		to_chat(telepath, span_warning("You can't see [recipient] anymore!"))
		return
	if(recipient.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0))
		to_chat(telepath, span_warning("As you reach into [recipient]'s mind, you are stopped by a mental blockage. It seems you've been foiled."))
		return
	log_directed_talk(telepath, recipient, msg, LOG_SAY, "slime telepathy")
	to_chat(recipient, "[span_notice("You hear an alien voice in your head... ")]<font color=#008CA2>[msg]</font>")
	to_chat(telepath, span_notice("You telepathically said: \"[msg]\" to [recipient]"))
	for(var/dead in GLOB.dead_mob_list)
		if(!isobserver(dead))
			continue
		var/follow_link_user = FOLLOW_LINK(dead, telepath)
		var/follow_link_target = FOLLOW_LINK(dead, recipient)
		to_chat(dead, "[follow_link_user] [span_name("[telepath]")] [span_alertalien("Slime Telepathy --> ")] [follow_link_target] [span_name("[recipient]")] [span_noticealien("[msg]")]")

/datum/action/innate/link_minds
	name = "Link Minds"
	desc = "Link someone's mind to your Slime Link, allowing them to communicate telepathically with other linked minds."
	button_icon_state = "mindlink"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	/// The species required to use this ability. Typepath.
	var/req_species = /datum/species/jelly/stargazer
	/// Whether we're currently linking to someone.
	var/currently_linking = FALSE

/datum/action/innate/link_minds/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		stack_trace("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")
		qdel(src)

/datum/action/innate/link_minds/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	if(!ishuman(owner) || !is_species(owner, req_species))
		return FALSE
	if(currently_linking)
		return FALSE

	return TRUE

/datum/action/innate/link_minds/Activate()
	if(!isliving(owner.pulling) || owner.grab_state < GRAB_AGGRESSIVE)
		to_chat(owner, span_warning("You need to aggressively grab someone to link minds!"))
		return

	var/mob/living/living_target = owner.pulling
	if(living_target.stat == DEAD)
		to_chat(owner, span_warning("They're dead!"))
		return

	to_chat(owner, span_notice("You begin linking [living_target]'s mind to yours..."))
	to_chat(living_target, span_warning("You feel a foreign presence within your mind..."))
	currently_linking = TRUE

	if(!do_after(owner, 6 SECONDS, target = living_target, extra_checks = CALLBACK(src, PROC_REF(while_link_callback), living_target)))
		to_chat(owner, span_warning("You can't seem to link [living_target]'s mind."))
		to_chat(living_target, span_warning("The foreign presence leaves your mind."))
		currently_linking = FALSE
		return

	currently_linking = FALSE
	if(QDELETED(src) || QDELETED(owner) || QDELETED(living_target))
		return

	var/datum/component/mind_linker/linker = target
	if(!linker.link_mob(living_target))
		to_chat(owner, span_warning("You can't seem to link [living_target]'s mind."))
		to_chat(living_target, span_warning("The foreign presence leaves your mind."))


/// Callback ran during the do_after of Activate() to see if we can keep linking with someone.
/datum/action/innate/link_minds/proc/while_link_callback(mob/living/linkee)
	if(!is_species(owner, req_species))
		return FALSE
	if(!owner.pulling)
		return FALSE
	if(owner.pulling != linkee)
		return FALSE
	if(owner.grab_state < GRAB_AGGRESSIVE)
		return FALSE
	if(linkee.stat == DEAD)
		return FALSE

	return TRUE

#undef JELLY_REGEN_RATE
#undef JELLY_REGEN_RATE_EMPTY
#undef BLOOD_VOLUME_LOSE_NUTRITION
