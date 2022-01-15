/datum/species/jelly
	// Entirely alien beings that seem to be made entirely out of gel. They have three eyes and a skeleton visible within them.
	name = "Jellyperson"
	id = SPECIES_JELLYPERSON
	default_color = "00FF90"
	say_mod = "chirps"
	species_traits = list(MUTCOLORS,EYECOLOR,NOBLOOD)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_TOXINLOVER,
	)
	mutantlungs = /obj/item/organ/lungs/slime
	meat = /obj/item/food/meat/slab/human/mutant/slime
	exotic_blood = /datum/reagent/toxin/slimejelly
	damage_overlay_type = ""
	var/datum/action/innate/regenerate_limbs/regenerate_limbs
	liked_food = MEAT
	toxic_food = NONE
	coldmod = 6   // = 3x cold damage
	heatmod = 0.5 // = 1/4x heat damage
	burnmod = 0.5 // = 1/2x generic burn damage
	payday_modifier = 0.75
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	inherent_factions = list("slime")
	species_language_holder = /datum/language_holder/jelly
	ass_image = 'icons/ass/assslime.png'

/datum/species/jelly/on_species_loss(mob/living/carbon/C)
	if(regenerate_limbs)
		regenerate_limbs.Remove(C)
	..()

/datum/species/jelly/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		regenerate_limbs = new
		regenerate_limbs.Grant(C)

/datum/species/jelly/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	if(H.stat == DEAD) //can't farm slime jelly from a dead slime/jelly person indefinitely
		return

	if(!H.blood_volume)
		H.blood_volume += 2.5 * delta_time
		H.adjustBruteLoss(2.5 * delta_time)
		to_chat(H, span_danger("You feel empty!"))

	if(H.blood_volume < BLOOD_VOLUME_NORMAL)
		if(H.nutrition >= NUTRITION_LEVEL_STARVING)
			H.blood_volume += 1.5 * delta_time
			H.adjust_nutrition(-1.25 * delta_time)

	if(H.blood_volume < BLOOD_VOLUME_OKAY)
		if(DT_PROB(2.5, delta_time))
			to_chat(H, span_danger("You feel drained!"))

	if(H.blood_volume < BLOOD_VOLUME_BAD)
		Cannibalize_Body(H)

	if(regenerate_limbs)
		regenerate_limbs.UpdateButtonIcon()

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
	H.blood_volume += 20

/datum/action/innate/regenerate_limbs
	name = "Regenerate Limbs"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeheal"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/regenerate_limbs/IsAvailable()
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
	name = "Slimeperson"
	id = SPECIES_SLIMEPERSON
	default_color = "00FFFF"
	species_traits = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR,NOBLOOD)
	hair_color = "mutcolor"
	hair_alpha = 150
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	var/datum/action/innate/split_body/slime_split
	var/list/mob/living/carbon/bodies
	var/datum/action/innate/swap_body/swap_body

/datum/species/jelly/slime/on_species_loss(mob/living/carbon/C)
	if(slime_split)
		slime_split.Remove(C)
	if(swap_body)
		swap_body.Remove(C)
	bodies -= C // This means that the other bodies maintain a link
	// so if someone mindswapped into them, they'd still be shared.
	bodies = null
	C.blood_volume = min(C.blood_volume, BLOOD_VOLUME_NORMAL)
	..()

/datum/species/jelly/slime/on_species_gain(mob/living/carbon/C, datum/species/old_species)
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

/datum/species/jelly/slime/spec_death(gibbed, mob/living/carbon/human/H)
	if(slime_split)
		if(!H.mind || !H.mind.active)
			return

		var/list/available_bodies = (bodies - H)
		for(var/mob/living/L in available_bodies)
			if(!swap_body.can_swap(L))
				available_bodies -= L

		if(!LAZYLEN(available_bodies))
			return

		swap_body.swap_to_dupe(H.mind, pick(available_bodies))

//If you're cloned you get your body pool back
/datum/species/jelly/slime/copy_properties_from(datum/species/jelly/slime/old_species)
	bodies = old_species.bodies

/datum/species/jelly/slime/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	if(H.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
		if(DT_PROB(2.5, delta_time))
			to_chat(H, span_notice("You feel very bloated!"))

	else if(H.nutrition >= NUTRITION_LEVEL_WELL_FED)
		H.blood_volume += 1.5 * delta_time
		H.adjust_nutrition(-1.25 * delta_time)

	..()

/datum/action/innate/split_body
	name = "Split Body"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimesplit"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/split_body/IsAvailable()
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
	H.visible_message("<span class='notice'>[owner] gains a look of \
		concentration while standing perfectly still.</span>",
		"<span class='notice'>You focus intently on moving your body while \
		standing perfectly still...</span>")

	H.notransform = TRUE

	if(do_after(owner, delay = 6 SECONDS, target = owner, timed_action_flags = IGNORE_HELD_ITEM))
		if(H.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
			make_dupe()
		else
			to_chat(H, span_warning("...but there is not enough of you to go around! You must attain more mass to split!"))
	else
		to_chat(H, span_warning("...but fail to stand perfectly still!"))

	H.notransform = FALSE

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
	H.notransform = 0

	var/datum/species/jelly/slime/origin_datum = H.dna.species
	origin_datum.bodies |= spare

	var/datum/species/jelly/slime/spare_datum = spare.dna.species
	spare_datum.bodies = origin_datum.bodies

	H.transfer_trait_datums(spare)
	H.mind.transfer_to(spare)
	spare.visible_message("<span class='warning'>[H] distorts as a new body \
		\"steps out\" of [H.p_them()].</span>",
		"<span class='notice'>...and after a moment of disorentation, \
		you're besides yourself!</span>")


/datum/action/innate/swap_body
	name = "Swap Body"
	check_flags = NONE
	button_icon_state = "slimeswap"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

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
			if(UNCONSCIOUS)
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

/datum/action/innate/swap_body/ui_act(action, params)
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
		M.current.visible_message("<span class='notice'>[M.current] \
			stops moving and starts staring vacantly into space.</span>",
			span_notice("You stop moving this body..."))
	else
		to_chat(M.current, span_notice("You abandon this body..."))
	M.current.transfer_trait_datums(dupe)
	M.transfer_to(dupe)
	dupe.visible_message("<span class='notice'>[dupe] blinks and looks \
		around.</span>",
		span_notice("...and move this one instead."))


///////////////////////////////////LUMINESCENTS//////////////////////////////////////////

//Luminescents are able to consume and use slime extracts, without them decaying.

/datum/species/jelly/luminescent
	name = "Luminescent"
	id = SPECIES_LUMINESCENT
	var/glow_intensity = LUMINESCENT_DEFAULT_GLOW
	var/obj/effect/dummy/luminescent_glow/glow
	var/obj/item/slime_extract/current_extract
	var/datum/action/innate/integrate_extract/integrate_extract
	var/datum/action/innate/use_extract/extract_minor
	var/datum/action/innate/use_extract/major/extract_major
	var/extract_cooldown = 0

//Species datums don't normally implement destroy, but JELLIES SUCK ASS OUT OF A STEEL STRAW
/datum/species/jelly/luminescent/Destroy(force, ...)
	current_extract = null
	QDEL_NULL(glow)
	QDEL_NULL(integrate_extract)
	QDEL_NULL(extract_major)
	QDEL_NULL(extract_minor)
	return ..()


/datum/species/jelly/luminescent/on_species_loss(mob/living/carbon/C)
	..()
	if(current_extract)
		current_extract.forceMove(C.drop_location())
		current_extract = null
	QDEL_NULL(glow)
	QDEL_NULL(integrate_extract)
	QDEL_NULL(extract_major)
	QDEL_NULL(extract_minor)

/datum/species/jelly/luminescent/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	glow = new(C)
	update_glow(C)
	integrate_extract = new(src)
	integrate_extract.Grant(C)
	extract_minor = new(src)
	extract_minor.Grant(C)
	extract_major = new(src)
	extract_major.Grant(C)

/datum/species/jelly/luminescent/proc/update_slime_actions()
	integrate_extract.update_name()
	integrate_extract.UpdateButtonIcon()
	extract_minor.UpdateButtonIcon()
	extract_major.UpdateButtonIcon()

/datum/species/jelly/luminescent/proc/update_glow(mob/living/carbon/C, intensity)
	if(intensity)
		glow_intensity = intensity
	glow.set_light_range_power_color(glow_intensity, glow_intensity, C.dna.features["mcolor"])

/obj/effect/dummy/luminescent_glow
	name = "luminescent glow"
	desc = "Tell a coder if you're seeing this."
	icon_state = "nothing"
	light_system = MOVABLE_LIGHT
	light_range = LUMINESCENT_DEFAULT_GLOW
	light_power = 2.5
	light_color = COLOR_WHITE

/obj/effect/dummy/luminescent_glow/Initialize(mapload)
	. = ..()
	if(!isliving(loc))
		return INITIALIZE_HINT_QDEL


/datum/action/innate/integrate_extract
	name = "Integrate Extract"
	desc = "Eat a slime extract to use its properties."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeconsume"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/integrate_extract/proc/update_name()
	var/datum/species/jelly/luminescent/species = target
	if(!species || !species.current_extract)
		name = "Integrate Extract"
		desc = "Eat a slime extract to use its properties."
	else
		name = "Eject Extract"
		desc = "Eject your current slime extract."

/datum/action/innate/integrate_extract/UpdateButtonIcon(status_only, force)
	var/datum/species/jelly/luminescent/species = target
	if(!species || !species.current_extract)
		button_icon_state = "slimeconsume"
	else
		button_icon_state = "slimeeject"
	..()

/datum/action/innate/integrate_extract/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force)
	..(current_button, TRUE)
	var/datum/species/jelly/luminescent/species = target
	if(species?.current_extract)
		current_button.add_overlay(mutable_appearance(species.current_extract.icon, species.current_extract.icon_state))

/datum/action/innate/integrate_extract/Activate()
	var/mob/living/carbon/human/H = owner
	var/datum/species/jelly/luminescent/species = target
	if(!is_species(H, /datum/species/jelly/luminescent) || !species)
		return
	CHECK_DNA_AND_SPECIES(H)

	if(species.current_extract)
		var/obj/item/slime_extract/S = species.current_extract
		if(!H.put_in_active_hand(S))
			S.forceMove(H.drop_location())
		species.current_extract = null
		to_chat(H, span_notice("You eject [S]."))
		species.update_slime_actions()
	else
		var/obj/item/I = H.get_active_held_item()
		if(istype(I, /obj/item/slime_extract))
			var/obj/item/slime_extract/S = I
			if(!S.Uses)
				to_chat(H, span_warning("[I] is spent! You cannot integrate it."))
				return
			if(!H.temporarilyRemoveItemFromInventory(S))
				return
			S.forceMove(H)
			species.current_extract = S
			to_chat(H, span_notice("You consume [I], and you feel it pulse within you..."))
			species.update_slime_actions()
		else
			to_chat(H, span_warning("You need to hold an unused slime extract in your active hand!"))

/datum/action/innate/use_extract
	name = "Extract Minor Activation"
	desc = "Pulse the slime extract with energized jelly to activate it."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeuse1"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	var/activation_type = SLIME_ACTIVATE_MINOR

/datum/action/innate/use_extract/IsAvailable()
	if(..())
		var/datum/species/jelly/luminescent/species = target
		if(species && species.current_extract && (world.time > species.extract_cooldown))
			return TRUE
		return FALSE

/datum/action/innate/use_extract/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force)
	..(current_button, TRUE)

	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/gazer = owner
	var/datum/species/jelly/luminescent/species = gazer?.dna?.species

	if(!istype(species, /datum/species/jelly/luminescent))
		return

	if(species.current_extract)
		current_button.add_overlay(mutable_appearance(species.current_extract.icon, species.current_extract.icon_state))

/datum/action/innate/use_extract/Activate()
	var/mob/living/carbon/human/H = owner
	var/datum/species/jelly/luminescent/species = H.dna.species
	if(!is_species(H, /datum/species/jelly/luminescent) || !species)
		return
	CHECK_DNA_AND_SPECIES(H)

	if(species.current_extract)
		species.extract_cooldown = world.time + 100
		var/cooldown = species.current_extract.activate(H, species, activation_type)
		species.extract_cooldown = world.time + cooldown

/datum/action/innate/use_extract/major
	name = "Extract Major Activation"
	desc = "Pulse the slime extract with plasma jelly to activate it."
	button_icon_state = "slimeuse2"
	activation_type = SLIME_ACTIVATE_MAJOR

///////////////////////////////////STARGAZERS//////////////////////////////////////////

//Stargazers are the telepathic branch of jellypeople, able to project psychic messages and to link minds with willing participants.

/datum/species/jelly/stargazer
	name = "Stargazer"
	id = SPECIES_STARGAZER
	var/datum/action/innate/project_thought/project_thought
	var/datum/action/innate/link_minds/link_minds
	var/datum/action/innate/linked_speech/master_speech
	var/list/mob/living/linked_mobs = list()
	var/datum/weakref/slimelink_owner
	var/current_link_id = 0

//Species datums don't normally implement destroy, but JELLIES SUCK ASS OUT OF A STEEL STRAW
/datum/species/jelly/stargazer/Destroy()
	for(var/mob/living/link_to_clear as anything in linked_mobs)
		unlink_mob(link_to_clear)
	linked_mobs.Cut()
	QDEL_NULL(project_thought)
	QDEL_NULL(link_minds)
	QDEL_NULL(master_speech)
	slimelink_owner = null
	return ..()

/datum/species/jelly/stargazer/on_species_loss(mob/living/carbon/C)
	..()
	for(var/mob/living/link_to_clear as anything in linked_mobs)
		unlink_mob(link_to_clear)
	if(project_thought)
		QDEL_NULL(project_thought)
	if(link_minds)
		QDEL_NULL(link_minds)
	if(master_speech)
		QDEL_NULL(master_speech)
	slimelink_owner = null

/datum/species/jelly/stargazer/spec_death(gibbed, mob/living/carbon/human/H)
	..()
	for(var/mob/living/link_to_clear as anything in linked_mobs)
		unlink_mob(link_to_clear)

/datum/species/jelly/stargazer/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	project_thought = new(src)
	project_thought.Grant(C)
	link_minds = new(src)
	link_minds.Grant(C)
	master_speech = new(src)
	master_speech.Grant(C)
	slimelink_owner = WEAKREF(C)

/**
 * Adds a living, not mind/psych shielded mob to the linked_mobs list and gives him
 * the ability to chat with other mobs in the same lists.
 * Don't call this proc on the owner; stat, mindshield, antimagic checks and superfluous comsigs
 * will only lead to bugs in that case. He has his own ability.
 */
/datum/species/jelly/stargazer/proc/link_mob(mob/living/mob_linked)
	if(QDELETED(mob_linked) || mob_linked.stat == DEAD)
		return FALSE
	if(HAS_TRAIT(mob_linked, TRAIT_MINDSHIELD)) //mindshield implant, no dice
		return FALSE
	if(mob_linked.anti_magic_check(MAGIC_RESISTANCE_MIND, charge_cost = 0))
		return FALSE
	if(mob_linked in linked_mobs)
		return FALSE
	var/mob/living/carbon/human/owner = slimelink_owner.resolve()
	if(!owner)
		return FALSE
	to_chat(mob_linked, span_notice("You are now connected to [owner.real_name]'s Slime Link."))
	var/datum/action/innate/linked_speech/action = new(src)
	action.Grant(mob_linked)
	linked_mobs[mob_linked] = action
	RegisterSignal(mob_linked, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING, SIGNAL_ADDTRAIT(TRAIT_MINDSHIELD)), .proc/unlink_mob)
	return TRUE

/datum/species/jelly/stargazer/proc/unlink_mob(mob/living/mob_linked)
	SIGNAL_HANDLER
	if(!linked_mobs.Find(mob_linked))
		return
	UnregisterSignal(mob_linked, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING, SIGNAL_ADDTRAIT(TRAIT_MINDSHIELD)))
	var/datum/action/innate/linked_speech/action = linked_mobs[mob_linked]
	var/mob/living/carbon/human/owner = slimelink_owner.resolve()
	if(owner)
		to_chat(mob_linked, span_notice("You are no longer connected to [owner.real_name]'s Slime Link."))
	linked_mobs -= mob_linked
	qdel(action)

/datum/action/innate/linked_speech
	name = "Slimelink"
	desc = "Send a psychic message to everyone connected to your slime link."
	button_icon_state = "link_speech"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/linked_speech/Activate()
	var/mob/living/carbon/human/human_user = owner
	if(human_user.stat == DEAD)
		return

	var/datum/species/jelly/stargazer/master_species = target
	var/mob/living/carbon/human/star_owner = master_species.slimelink_owner.resolve()

	if(star_owner != human_user && !(human_user in master_species.linked_mobs))
		to_chat(human_user, span_warning("The link seems to have been severed..."))
		return

	var/message = sanitize(tgui_input_text(human_user, "Enter a message", "Slime Telepathy"))

	if(!message)
		return

	if(QDELETED(master_species) || (star_owner != human_user && !(human_user in master_species.linked_mobs)))
		to_chat(human_user, span_warning("The link seems to have been severed..."))
		return

	var/msg = "<i><font color=#008CA2>\[[star_owner.real_name]'s Slime Link\] <b>[human_user]:</b> [message]</font></i>"
	log_directed_talk(human_user, star_owner, msg, LOG_SAY, "slime link")
	to_chat(star_owner, msg)
	for(var/mob/living/recipient as anything in master_species.linked_mobs)
		to_chat(recipient, msg)

	for(var/mob/recipient as anything in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(recipient, human_user)
		to_chat(recipient, "[link] [msg]")

/datum/action/innate/project_thought
	name = "Send Thought"
	desc = "Send a private psychic message to someone you can see."
	button_icon_state = "send_mind"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

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
	if(isnull(recipient))
		return
	var/msg = tgui_input_text(telepath, title = "Telepathy")
	if(isnull(msg))
		return
	if(recipient.anti_magic_check((MAGIC_RESISTANCE | MAGIC_RESISTANCE_MIND), charge_cost = 0))
		to_chat(telepath, span_notice("As you try to communicate with [recipient], you're suddenly stopped by a vision of a massive tinfoil wall that streches beyond visible range. It seems you've been foiled."))
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
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/link_minds/Activate()
	var/mob/living/carbon/human/human_user = owner
	if(!is_species(human_user, /datum/species/jelly/stargazer))
		return

	if(!human_user.pulling || !isliving(human_user.pulling) || human_user.grab_state < GRAB_AGGRESSIVE)
		to_chat(human_user, span_warning("You need to aggressively grab someone to link minds!"))
		return

	var/mob/living/living_target = human_user.pulling
	var/datum/species/jelly/stargazer/user_species = human_user.dna.species

	to_chat(human_user, span_notice("You begin linking [living_target]'s mind to yours..."))
	to_chat(living_target, span_warning("You feel a foreign presence within your mind..."))
	if(do_after(human_user, 60, target = living_target))
		if(human_user.pulling != living_target || human_user.grab_state < GRAB_AGGRESSIVE)
			return
		if(user_species?.link_mob(living_target))
			to_chat(human_user, span_notice("You connect [living_target]'s mind to your slime link!"))
		else
			to_chat(human_user, span_warning("You can't seem to link [living_target]'s mind..."))
			to_chat(living_target, span_warning("The foreign presence leaves your mind."))
