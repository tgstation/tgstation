/// The duration of the fakedeath coma.
#define LING_FAKEDEATH_TIME 40 SECONDS
/// The number of recent spoken lines to gain on absorbing a mob
#define LING_ABSORB_RECENT_SPEECH 8

/// Helper to format the text that gets thrown onto the chem hud element.
#define FORMAT_CHEM_CHARGES_TEXT(charges) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[round(charges)]</font></div>")

/datum/antagonist/changeling
	name = "\improper Changeling"
	roundend_category = "changelings"
	antagpanel_category = "Changeling"
	job_rank = ROLE_CHANGELING
	antag_moodlet = /datum/mood_event/focused
	antag_hud_name = "changeling"
	hijack_speed = 0.5
	ui_name = "AntagInfoChangeling"
	suicide_cry = "FOR THE HIVE!!"
	/// Whether to give this changeling objectives or not
	var/give_objectives = TRUE
	/// Weather we assign objectives which compete with other lings
	var/competitive_objectives = FALSE

	// Changeling Stuff.
	// If you want good boy points,
	// separate the changeling (antag)
	// and the changeling (mechanics).

	/// list of datum/changeling_profile
	var/list/stored_profiles = list()
	/// The original profile of this changeling.
	var/datum/changeling_profile/first_profile = null
	/// How many DNA strands the changeling can store for transformation.
	var/dna_max = 6
	/// The amount of DNA gained. Includes DNA sting.
	var/absorbed_count = 0
	/// The amount of DMA gained using absorb, not DMA sting.
	var/trueabsorbs = 0
	/// The number of chemicals the changeling currently has.
	var/chem_charges = 20
	/// The max chemical storage the changeling currently has.
	var/total_chem_storage = 75
	/// The chemical recharge rate per life tick.
	var/chem_recharge_rate = 0.5
	/// Any additional modifiers triggered by changelings that modify the chem_recharge_rate.
	var/chem_recharge_slowdown = 0
	/// The range this ling can sting things.
	var/sting_range = 2
	/// The number of genetics points (to buy powers) this ling currently has.
	var/genetic_points = 10
	/// The max number of genetics points (to buy powers) this ling can have..
	var/total_genetic_points = 10
	/// List of all powers we start with.
	var/list/innate_powers = list()
	/// List of all powers we have evolved / bought from the emporium.
	var/list/purchased_powers = list()

	/// The voice we're mimicing via the changeling voice ability.
	var/mimicing = ""
	/// Whether we can currently respec in the cellular emporium.
	var/can_respec = FALSE

	/// The currently active changeling sting.
	var/datum/action/changeling/sting/chosen_sting
	/// A reference to our cellular emporium datum.
	var/datum/cellular_emporium/cellular_emporium
	/// A reference to our cellular emporium action (which opens the UI for the datum).
	var/datum/action/innate/cellular_emporium/emporium_action

	/// The name of our "hive" that our ling came from. Flavor.
	var/hive_name

	/// Static typecache of all changeling powers that are usable.
	var/static/list/all_powers = typecacheof(/datum/action/changeling, TRUE)

	/// Satic list of what each slot associated with (in regard to changeling flesh items).
	var/static/list/slot2type = list(
		"head" = /obj/item/clothing/head/changeling,
		"wear_mask" = /obj/item/clothing/mask/changeling,
		"back" = /obj/item/changeling,
		"wear_suit" = /obj/item/clothing/suit/changeling,
		"w_uniform" = /obj/item/clothing/under/changeling,
		"shoes" = /obj/item/clothing/shoes/changeling,
		"belt" = /obj/item/changeling,
		"gloves" = /obj/item/clothing/gloves/changeling,
		"glasses" = /obj/item/clothing/glasses/changeling,
		"ears" = /obj/item/changeling,
		"wear_id" = /obj/item/changeling/id,
		"s_store" = /obj/item/changeling,
	)

	/// A list of all memories we've stolen through absorbs.
	var/list/stolen_memories = list()

/datum/antagonist/changeling/New()
	. = ..()
	hive_name = hive_name()
	for(var/datum/antagonist/changeling/other_ling in GLOB.antagonists)
		if(!other_ling.owner || other_ling.owner == owner)
			continue
		competitive_objectives = TRUE
		break

/datum/antagonist/changeling/Destroy()
	QDEL_NULL(emporium_action)
	QDEL_NULL(cellular_emporium)
	return ..()

/datum/antagonist/changeling/on_gain()
	create_emporium()
	create_innate_actions()
	create_initial_profile()
	if(give_objectives)
		forge_objectives()
	owner.current.grant_all_languages(FALSE, FALSE, TRUE) //Grants omnitongue. We are able to transform our body after all.
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ling_aler.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	return ..()

/datum/antagonist/changeling/apply_innate_effects(mob/living/mob_override)
	var/mob/mob_to_tweak = mob_override || owner.current
	if(!isliving(mob_to_tweak))
		return

	var/mob/living/living_mob = mob_to_tweak
	handle_clown_mutation(living_mob, "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself.")
	RegisterSignal(living_mob, COMSIG_MOB_LOGIN, .proc/on_login)
	RegisterSignal(living_mob, COMSIG_LIVING_LIFE, .proc/on_life)
	living_mob.hud_used?.lingchemdisplay.invisibility = 0
	living_mob.hud_used?.lingchemdisplay.maptext = FORMAT_CHEM_CHARGES_TEXT(chem_charges)

	if(!iscarbon(mob_to_tweak))
		return

	var/mob/living/carbon/carbon_mob = mob_to_tweak
	RegisterSignal(carbon_mob, list(COMSIG_MOB_MIDDLECLICKON, COMSIG_MOB_ALTCLICKON), .proc/on_click_sting)

	// Brains are optional for lings.
	var/obj/item/organ/brain/our_ling_brain = carbon_mob.getorganslot(ORGAN_SLOT_BRAIN)
	if(our_ling_brain)
		our_ling_brain.organ_flags &= ~ORGAN_VITAL
		our_ling_brain.decoy_override = TRUE

/datum/antagonist/changeling/remove_innate_effects(mob/living/mob_override)
	var/mob/living/living_mob = mob_override || owner.current
	handle_clown_mutation(living_mob, removing = FALSE)
	UnregisterSignal(living_mob, list(COMSIG_MOB_LOGIN, COMSIG_LIVING_LIFE, COMSIG_MOB_MIDDLECLICKON, COMSIG_MOB_ALTCLICKON))
	living_mob.hud_used?.lingchemdisplay.invisibility = INVISIBILITY_ABSTRACT

/datum/antagonist/changeling/on_removal()
	remove_changeling_powers(include_innate = TRUE)
	if(!iscarbon(owner.current))
		return
	var/mob/living/carbon/carbon_owner = owner.current
	var/obj/item/organ/brain/not_ling_brain = carbon_owner.getorganslot(ORGAN_SLOT_BRAIN)
	if(not_ling_brain && (not_ling_brain.decoy_override != initial(not_ling_brain.decoy_override)))
		not_ling_brain.organ_flags |= ORGAN_VITAL
		not_ling_brain.decoy_override = FALSE
	return ..()

/datum/antagonist/changeling/farewell()
	to_chat(owner.current, span_userdanger("You grow weak and lose your powers! You are no longer a changeling and are stuck in your current form!"))

/*
 * Instantiate the cellular emporium for the changeling.
 */
/datum/antagonist/changeling/proc/create_emporium()
	cellular_emporium = new(src)
	emporium_action = new(cellular_emporium)
	emporium_action.Grant(owner.current)

/*
 * Instantiate all the default actions of a ling (transform, dna sting, absorb, etc)
 * Any Changeling action with `dna_cost == 0` will be added here automatically
 */
/datum/antagonist/changeling/proc/create_innate_actions()
	for(var/datum/action/changeling/path as anything in all_powers)
		if(initial(path.dna_cost) != 0)
			continue

		var/datum/action/changeling/innate_ability = new path()
		innate_powers += innate_ability
		innate_ability.on_purchase(owner.current, TRUE)

/*
 * Signal proc for [COMSIG_MOB_LOGIN].
 * Gives us back our action buttons if we lose them on log-in.
 */
/datum/antagonist/changeling/proc/on_login(datum/source)
	SIGNAL_HANDLER

	if(!isliving(source))
		return
	var/mob/living/living_source = source
	if(!living_source.mind)
		return

	regain_powers()

/*
 * Signal proc for [COMSIG_LIVING_LIFE].
 * Handles regenerating chemicals on life ticks.
 */
/datum/antagonist/changeling/proc/on_life(datum/source, delta_time, times_fired)
	SIGNAL_HANDLER

	if(!iscarbon(owner.current))
		return

	// If dead, we only regenerate up to half chem storage.
	if(owner.current.stat == DEAD)
		adjust_chemicals((chem_recharge_rate - chem_recharge_slowdown) * delta_time, total_chem_storage * 0.5)

	// If we're not dead - we go up to the full chem cap.
	else
		adjust_chemicals((chem_recharge_rate - chem_recharge_slowdown) * delta_time)

/*
 * Signal proc for [COMSIG_MOB_MIDDLECLICKON] and [COMSIG_MOB_ALTCLICKON].
 * Allows the changeling to sting people with a click.
 */
/datum/antagonist/changeling/proc/on_click_sting(mob/living/carbon/ling, atom/clicked)
	SIGNAL_HANDLER

	if(!chosen_sting || clicked == ling || !istype(ling) || ling.stat != CONSCIOUS)
		return

	INVOKE_ASYNC(chosen_sting, /datum/action/changeling/sting.proc/try_to_sting, ling, clicked)

	return COMSIG_MOB_CANCEL_CLICKON

/*
 * Adjust the chem charges of the ling by [amount]
 * and clamp it between 0 and override_cap (if supplied) or total_chem_storage (if no override supplied)
 */
/datum/antagonist/changeling/proc/adjust_chemicals(amount, override_cap)
	if(!isnum(amount))
		return
	var/cap_to = isnum(override_cap) ? override_cap : total_chem_storage
	chem_charges = clamp(chem_charges + amount, 0, cap_to)

	owner.current.hud_used?.lingchemdisplay.maptext = FORMAT_CHEM_CHARGES_TEXT(chem_charges)

/*
 * Remove changeling powers from the current Changeling's purchased_powers list.
 *
 * if [include_innate] = TRUE, will also remove all powers from the Changeling's innate_powers list.
 */
/datum/antagonist/changeling/proc/remove_changeling_powers(include_innate = FALSE)
	if(!isliving(owner.current))
		return

	if(chosen_sting)
		chosen_sting.unset_sting(owner.current)

	for(var/datum/action/changeling/power as anything in purchased_powers)
		purchased_powers -= power
		power.Remove(owner.current)
		qdel(power)
	if(include_innate)
		for(var/datum/action/changeling/power as anything in innate_powers)
			innate_powers -= power
			power.Remove(owner.current)
			qdel(power)

	genetic_points = total_genetic_points
	chem_charges = min(chem_charges, total_chem_storage)
	chem_recharge_rate = initial(chem_recharge_rate)
	chem_recharge_slowdown = initial(chem_recharge_slowdown)

/*
 * For resetting all of the changeling's action buttons. (IE, re-granting them all.)
 */
/datum/antagonist/changeling/proc/regain_powers()
	emporium_action.Grant(owner.current)
	for(var/datum/action/changeling/power as anything in innate_powers)
		if(istype(power) && power.needs_button)
			power.Grant(owner.current)
	for(var/datum/action/changeling/power as anything in purchased_powers)
		if(istype(power) && power.needs_button)
			power.Grant(owner.current)

/*
 * The act of purchasing a certain power for a changeling.
 *
 * [sting_path] - the power that's being purchased / evolved.
 */
/datum/antagonist/changeling/proc/purchase_power(datum/action/changeling/sting_path)
	if(!ispath(sting_path) || !is_type_in_typecache(sting_path, all_powers))
		CRASH("Changeling purchase_power attempted to purchase an invalid typepath!")

	if(is_path_in_list_of_types(sting_path, purchased_powers))
		to_chat(owner.current, span_warning("We have already evolved this ability!"))
		return FALSE

	var/datum/action/changeling/new_action = new sting_path()

	if(!new_action)
		to_chat(owner.current, "This is awkward. Changeling power purchase failed, please report this bug to a coder!")
		CRASH("Changeling purchase_power was unable to create a new changeling action for path [sting_path]!")

	if(absorbed_count < new_action.req_dna)
		to_chat(owner.current, span_warning("We lack the energy to evolve this ability!"))
		qdel(new_action)
		return FALSE

	if(new_action.dna_cost < 0)
		to_chat(owner.current, span_warning("We cannot evolve this ability!"))
		qdel(new_action)
		return FALSE

	if(genetic_points < new_action.dna_cost)
		to_chat(owner.current, span_warning("We have reached our capacity for abilities!"))
		qdel(new_action)
		return FALSE

	if(HAS_TRAIT(owner.current, TRAIT_DEATHCOMA)) //To avoid potential exploits by buying new powers while in stasis, which clears your verblist.
		to_chat(owner.current, span_warning("We lack the energy to evolve new abilities right now!"))
		qdel(new_action)
		return FALSE

	genetic_points -= new_action.dna_cost
	purchased_powers += new_action
	new_action.on_purchase(owner.current) // Grant() is ran in this proc, see changeling_powers.dm.

/*
 * Changeling's ability to re-adapt all of their learned powers.
 */
/datum/antagonist/changeling/proc/readapt()
	if(!ishuman(owner.current))
		to_chat(owner.current, span_warning("We can't remove our evolutions in this form!"))
		return
	if(HAS_TRAIT_FROM(owner.current, TRAIT_DEATHCOMA, CHANGELING_TRAIT))
		to_chat(owner.current, span_warning("We are too busy reforming ourselves to readapt right now!"))
		return

	if(can_respec)
		to_chat(owner.current, span_notice("We have removed our evolutions from this form, and are now ready to readapt."))
		remove_changeling_powers()
		can_respec = FALSE
		SSblackbox.record_feedback("tally", "changeling_power_purchase", 1, "Readapt")
		return TRUE

	to_chat(owner.current, span_warning("You lack the power to readapt your evolutions!"))
	return FALSE

/*
 * Get the corresponding changeling profile for the passed name.
 */
/datum/antagonist/changeling/proc/get_dna(searched_dna_name)
	for(var/datum/changeling_profile/found_profile as anything in stored_profiles)
		if(searched_dna_name == found_profile.name)
			return found_profile

/*
 * Checks if we have a changeling profile with the passed DNA.
 */
/datum/antagonist/changeling/proc/has_profile_with_dna(datum/dna/searched_dna)
	for(var/datum/changeling_profile/found_profile as anything in stored_profiles)
		if(searched_dna.is_same_as(found_profile.dna))
			return TRUE
	return FALSE

/*
 * Checks if this changeling can absorb the DNA of [target].
 * if [verbose] = TRUE, give feedback as to why they cannot absorb the DNA.
 */
/datum/antagonist/changeling/proc/can_absorb_dna(mob/living/carbon/human/target, verbose = TRUE)
	if(!target)
		return FALSE
	if(!iscarbon(owner.current))
		return FALSE
	var/mob/living/carbon/user = owner.current

	if(stored_profiles.len)
		// If our current DNA is the stalest, we gotta ditch it before absorbing more.
		var/datum/changeling_profile/top_profile = stored_profiles[1]
		if(top_profile.dna.is_same_as(user.dna) && stored_profiles.len > dna_max)
			if(verbose)
				to_chat(user, span_warning("We have reached our capacity to store genetic information! We must transform before absorbing more."))
			return FALSE

	if(!target.has_dna())
		if(verbose)
			to_chat(user, span_warning("[target] is not compatible with our biology."))
		return FALSE
	if(has_profile_with_dna(target.dna))
		if(verbose)
			to_chat(user, span_warning("We already have this DNA in storage!"))
		return FALSE
	if(NO_DNA_COPY in target.dna.species?.species_traits)
		if(verbose)
			to_chat(user, span_warning("[target] is not compatible with our biology."))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_BADDNA))
		if(verbose)
			to_chat(user, span_warning("[target]'s DNA is ruined beyond usability!"))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_HUSK))
		if(verbose)
			to_chat(user, span_warning("[target]'s body is ruined beyond usability!"))
		return FALSE
	if(!ishuman(target))//Absorbing monkeys is entirely possible, but it can cause issues with transforming. That's what lesser form is for anyway!
		if(verbose)
			to_chat(user, span_warning("We could gain no benefit from absorbing a lesser creature."))
		return FALSE

	return TRUE

/*
 * Create a new changeling profile datum based off of [target].
 *
 * target - the human we're basing the new profile off of.
 * protect - if TRUE, set the new profile to protected, preventing it from being removed (without force).
 */
/datum/antagonist/changeling/proc/create_profile(mob/living/carbon/human/target, protect = 0)
	var/datum/changeling_profile/new_profile = new()

	target.dna.real_name = target.real_name //Set this again, just to be sure that it's properly set.

	// Set up a copy of their DNA in our profile.
	var/datum/dna/new_dna = new target.dna.type()
	target.dna.copy_dna(new_dna)
	new_profile.dna = new_dna
	new_profile.name = target.real_name
	new_profile.protected = protect

	// Clothes, of course
	new_profile.underwear = target.underwear
	new_profile.undershirt = target.undershirt
	new_profile.socks = target.socks

	// Grab skillchips they have
	new_profile.skillchips = target.clone_skillchip_list(TRUE)

	// Get any scars they may have
	for(var/datum/scar/target_scar as anything in target.all_scars)
		LAZYADD(new_profile.stored_scars, target_scar.format())

	// Make an icon snapshot of what they currently look like
	var/datum/icon_snapshot/entry = new()
	entry.name = target.name
	entry.icon = target.icon
	entry.icon_state = target.icon_state
	entry.overlays = target.get_overlays_copy(list(HANDS_LAYER, HANDCUFF_LAYER, LEGCUFF_LAYER))
	new_profile.profile_snapshot = entry

	// Grab the target's sechut icon.
	new_profile.id_icon = target.wear_id?.get_sechud_job_icon_state()

	var/list/slots = list("head", "wear_mask", "back", "wear_suit", "w_uniform", "shoes", "belt", "gloves", "glasses", "ears", "wear_id", "s_store")
	for(var/slot in slots)
		if(!(slot in target.vars))
			continue
		var/obj/item/clothing/clothing_item = target.vars[slot]
		if(!clothing_item)
			continue
		new_profile.name_list[slot] = clothing_item.name
		new_profile.appearance_list[slot] = clothing_item.appearance
		new_profile.flags_cover_list[slot] = clothing_item.flags_cover
		new_profile.lefthand_file_list[slot] = clothing_item.lefthand_file
		new_profile.righthand_file_list[slot] = clothing_item.righthand_file
		new_profile.inhand_icon_state_list[slot] = clothing_item.inhand_icon_state
		new_profile.worn_icon_list[slot] = clothing_item.worn_icon
		new_profile.worn_icon_state_list[slot] = clothing_item.worn_icon_state
		new_profile.exists_list[slot] = 1

	return new_profile

/*
 * Add a new profile to our changeling's profile list.
 * Pops the first profile in the list if we're above our limit of profiles.
 *
 * new_profile - the profile being added.
 */
/datum/antagonist/changeling/proc/add_profile(datum/changeling_profile/new_profile)
	if(stored_profiles.len > dna_max)
		if(!push_out_profile())
			return

	if(!first_profile)
		first_profile = new_profile

	stored_profiles += new_profile
	absorbed_count++

/*
 * Create a new profile from the given [profile_target]
 * and add it to our profile list via add_profile.
 *
 * profile_target - the human we're making a profile based off of
 * protect - if TRUE, mark the new profile as protected. If protected, it cannot be removed / popped from the profile list (without force).
 */
/datum/antagonist/changeling/proc/add_new_profile(mob/living/carbon/human/profile_target, protect = FALSE)
	var/datum/changeling_profile/new_profile = create_profile(profile_target, protect)
	add_profile(new_profile)
	return new_profile

/*
 * Remove a given profile from the profile list.
 *  *
 * profile_target - the human we want to remove from our profile list (looks for a profile with a matching name)
 * force - if TRUE, removes the profile even if it's protected.
 */
/datum/antagonist/changeling/proc/remove_profile(mob/living/carbon/human/profile_target, force = FALSE)
	for(var/datum/changeling_profile/found_profile as anything in stored_profiles)
		if(profile_target.real_name == found_profile.name)
			if(found_profile.protected && !force)
				continue
			stored_profiles -= found_profile
			qdel(found_profile)

/*
 * Removes the highest changeling profile from the list
 * that isn't protected and returns TRUE if successful.
 *
 * Returns TRUE if a profile was removed, FALSE otherwise.
 */
/datum/antagonist/changeling/proc/push_out_profile()
	var/datum/changeling_profile/profle_to_remove
	for(var/datum/changeling_profile/found_profile as anything in stored_profiles)
		if(!found_profile.protected)
			profle_to_remove = found_profile
			break

	if(profle_to_remove)
		stored_profiles -= profle_to_remove
		return TRUE
	return FALSE

/*
 * Create a profile based on the changeling's initial appearance.
 */
/datum/antagonist/changeling/proc/create_initial_profile()
	if(!ishuman(owner.current))
		return

	add_new_profile(owner.current)


/// Generate objectives for our changeling.
/datum/antagonist/changeling/proc/forge_objectives()
	//OBJECTIVES - random traitor objectives. Unique objectives "steal brain" and "identity theft".
	//No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	//If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone

	var/escape_objective_possible = TRUE

	switch(competitive_objectives ? rand(1,3) : 1)
		if(1)
			var/datum/objective/absorb/absorb_objective = new
			absorb_objective.owner = owner
			absorb_objective.gen_amount_goal(6, 8)
			objectives += absorb_objective
		if(2)
			var/datum/objective/absorb_most/ac = new
			ac.owner = owner
			objectives += ac
		if(3)
			var/datum/objective/absorb_changeling/ac = new
			ac.owner = owner
			objectives += ac

	if(prob(60))
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = owner
		steal_objective.find_target()
		objectives += steal_objective

	var/list/active_ais = active_ais()
	if(active_ais.len && prob(100/GLOB.joined_player_list.len))
		var/datum/objective/destroy/destroy_objective = new
		destroy_objective.owner = owner
		destroy_objective.find_target()
		objectives += destroy_objective
	else
		if(prob(70))
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			objectives += kill_objective
		else
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = owner
			maroon_objective.find_target()
			objectives += maroon_objective

			if (!(locate(/datum/objective/escape) in objectives) && escape_objective_possible)
				var/datum/objective/escape/escape_with_identity/identity_theft = new
				identity_theft.owner = owner
				identity_theft.target = maroon_objective.target
				identity_theft.update_explanation_text()
				objectives += identity_theft
				escape_objective_possible = FALSE

	if (!(locate(/datum/objective/escape) in objectives) && escape_objective_possible)
		if(prob(50))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			objectives += escape_objective
		else
			var/datum/objective/escape/escape_with_identity/identity_theft = new
			identity_theft.owner = owner
			identity_theft.find_target()
			objectives += identity_theft
		escape_objective_possible = FALSE

/datum/antagonist/changeling/get_admin_commands()
	. = ..()
	if(stored_profiles.len && (owner.current.real_name != first_profile.name))
		.["Transform to initial appearance."] = CALLBACK(src,.proc/admin_restore_appearance)

/*
 * Restores the appearance of the changeling to the original DNA.
 */
/datum/antagonist/changeling/proc/admin_restore_appearance(mob/admin)
	if(!stored_profiles.len || !iscarbon(owner.current))
		to_chat(admin, span_danger("Resetting DNA failed!"))
		return

	var/mob/living/carbon/carbon_owner = owner.current
	first_profile.dna.transfer_identity(carbon_owner, transfer_SE = TRUE)
	carbon_owner.real_name = first_profile.name
	carbon_owner.updateappearance(mutcolor_update = TRUE)
	carbon_owner.domutcheck()

/*
 * Transform the currentc hangeing [user] into the [chosen_profile].
 */
/datum/antagonist/changeling/proc/transform(mob/living/carbon/human/user, datum/changeling_profile/chosen_profile)
	var/static/list/slot2slot = list(
		"head" = ITEM_SLOT_HEAD,
		"wear_mask" = ITEM_SLOT_MASK,
		"neck" = ITEM_SLOT_NECK,
		"back" = ITEM_SLOT_BACK,
		"wear_suit" = ITEM_SLOT_OCLOTHING,
		"w_uniform" = ITEM_SLOT_ICLOTHING,
		"shoes" = ITEM_SLOT_FEET,
		"belt" = ITEM_SLOT_BELT,
		"gloves" = ITEM_SLOT_GLOVES,
		"glasses" = ITEM_SLOT_EYES,
		"ears" = ITEM_SLOT_EARS,
		"wear_id" = ITEM_SLOT_ID,
		"s_store" = ITEM_SLOT_SUITSTORE,
	)

	var/datum/dna/chosen_dna = chosen_profile.dna
	user.real_name = chosen_profile.name
	user.underwear = chosen_profile.underwear
	user.undershirt = chosen_profile.undershirt
	user.socks = chosen_profile.socks

	chosen_dna.transfer_identity(user, TRUE)

	user.Digitigrade_Leg_Swap(!(DIGITIGRADE in chosen_dna.species?.species_traits))
	user.updateappearance(mutcolor_update = TRUE)
	user.update_body()
	user.domutcheck()

	// Get rid of any scars from previous Changeling-ing
	for(var/datum/scar/old_scar as anything in user.all_scars)
		if(old_scar.fake)
			user.all_scars -= old_scar
			qdel(old_scar)

	// Now, we do skillchip stuff, AFTER DNA code.
	// (There's a mutation that increases max chip complexity available, even though we force-implant skillchips.)

	// Remove existing skillchips.
	user.destroy_all_skillchips(silent = FALSE)

	// Add new set of skillchips.
	for(var/chip in chosen_profile.skillchips)
		var/chip_type = chip["type"]
		var/obj/item/skillchip/skillchip = new chip_type(user)

		if(!istype(skillchip))
			stack_trace("Failure to implant changeling from [chosen_profile] with skillchip [skillchip]. Tried to implant with non-skillchip type [chip_type]")
			qdel(skillchip)
			continue

		// Try force-implanting and activating. If it doesn't work, there's nothing much we can do. There may be some
		// incompatibility out of our hands
		var/implant_msg = user.implant_skillchip(skillchip, TRUE)
		if(implant_msg)
			// Hopefully recording the error message will help debug it.
			stack_trace("Failure to implant changeling from [chosen_profile] with skillchip [skillchip]. Error msg: [implant_msg]")
			qdel(skillchip)
			continue

		// Time to set the metadata. This includes trying to activate the chip.
		var/set_meta_msg = skillchip.set_metadata(chip)

		if(set_meta_msg)
			// Hopefully recording the error message will help debug it.
			stack_trace("Failure to activate changeling skillchip from [chosen_profile] with skillchip [skillchip] using [chip] metadata. Error msg: [set_meta_msg]")
			continue

	//vars hackery. not pretty, but better than the alternative.
	for(var/slot in slot2type)
		if(istype(user.vars[slot], slot2type[slot]) && !(chosen_profile.exists_list[slot])) // Remove unnecessary flesh items
			qdel(user.vars[slot])
			continue

		if((user.vars[slot] && !istype(user.vars[slot], slot2type[slot])) || !(chosen_profile.exists_list[slot]))
			continue

		if(istype(user.vars[slot], slot2type[slot]) && slot == "wear_id") // Always remove old flesh IDs - so they get properly updated.
			qdel(user.vars[slot])

		var/obj/item/new_flesh_item
		var/equip = FALSE
		if(!user.vars[slot])
			var/slot_type = slot2type[slot]
			equip = TRUE
			new_flesh_item = new slot_type(user)

		else if(istype(user.vars[slot], slot2type[slot]))
			new_flesh_item = user.vars[slot]

		new_flesh_item.appearance = chosen_profile.appearance_list[slot]
		new_flesh_item.name = chosen_profile.name_list[slot]
		new_flesh_item.flags_cover = chosen_profile.flags_cover_list[slot]
		new_flesh_item.lefthand_file = chosen_profile.lefthand_file_list[slot]
		new_flesh_item.righthand_file = chosen_profile.righthand_file_list[slot]
		new_flesh_item.inhand_icon_state = chosen_profile.inhand_icon_state_list[slot]
		new_flesh_item.worn_icon = chosen_profile.worn_icon_list[slot]
		new_flesh_item.worn_icon_state = chosen_profile.worn_icon_state_list[slot]

		if(istype(new_flesh_item, /obj/item/changeling/id) && chosen_profile.id_icon)
			var/obj/item/changeling/id/flesh_id = new_flesh_item
			flesh_id.hud_icon = chosen_profile.id_icon

		if(equip)
			user.equip_to_slot_or_del(new_flesh_item, slot2slot[slot])
			if(!QDELETED(new_flesh_item))
				ADD_TRAIT(new_flesh_item, TRAIT_NODROP, CHANGELING_TRAIT)

	for(var/stored_scar_line in chosen_profile.stored_scars)
		var/datum/scar/attempted_fake_scar = user.load_scar(stored_scar_line)
		if(attempted_fake_scar)
			attempted_fake_scar.fake = TRUE

	user.regenerate_icons()

// Changeling profile themselves. Store a data to store what every DNA instance looked like.
/datum/changeling_profile
	/// The name of the profile / the name of whoever this profile source.
	var/name = "a bug"
	/// Whether this profile is protected - if TRUE, it cannot be removed from a changeling's profiles without force
	var/protected = FALSE
	/// The DNA datum associated with our profile from the profile source
	var/datum/dna/dna
	/// Assoc list of item slot to item name - stores the name of every item of this profile.
	var/list/name_list = list()
	/// Assoc list of item slot to apperance - stores the appearance of every item of this profile.
	var/list/appearance_list = list()
	/// Assoc list of item slot to flag - stores the flags_cover of every item of this profile.
	var/list/flags_cover_list = list()
	/// Assoc list of item slot to boolean - stores whether an item in that slot exists
	var/list/exists_list = list()
	/// Assoc list of item slot to file - stores the lefthand file of the item in that slot
	var/list/lefthand_file_list = list()
	/// Assoc list of item slot to file - stores the righthand file of the item in that slot
	var/list/righthand_file_list = list()
	/// Assoc list of item slot to file - stores the inhand file of the item in that slot
	var/list/inhand_icon_state_list = list()
	/// Assoc list of item slot to file - stores the worn icon file of the item in that slot
	var/list/worn_icon_list = list()
	/// Assoc list of item slot to string - stores the worn icon state of the item in that slot
	var/list/worn_icon_state_list = list()
	/// The underwear worn by the profile source
	var/underwear
	/// The undershirt worn by the profile source
	var/undershirt
	/// The socks worn by the profile source
	var/socks
	/// A list of paths for any skill chips the profile source had installed
	var/list/skillchips = list()
	/// What scars the profile sorce had, in string form (like persistent scars)
	var/list/stored_scars
	/// Icon snapshot of the profile
	var/datum/icon_snapshot/profile_snapshot
	/// ID HUD icon associated with the profile
	var/id_icon

/datum/changeling_profile/Destroy()
	qdel(dna)
	LAZYCLEARLIST(stored_scars)
	return ..()

/*
 * Copy every aspect of this file into a new instance of a profile.
 * Must be suppied with an instance.
 */
/datum/changeling_profile/proc/copy_profile(datum/changeling_profile/new_profile)
	new_profile.name = name
	new_profile.protected = protected
	new_profile.dna = new dna.type()
	dna.copy_dna(new_profile.dna)
	new_profile.name_list = name_list.Copy()
	new_profile.appearance_list = appearance_list.Copy()
	new_profile.flags_cover_list = flags_cover_list.Copy()
	new_profile.exists_list = exists_list.Copy()
	new_profile.lefthand_file_list = lefthand_file_list.Copy()
	new_profile.righthand_file_list = righthand_file_list.Copy()
	new_profile.inhand_icon_state_list = inhand_icon_state_list.Copy()
	new_profile.underwear = underwear
	new_profile.undershirt = undershirt
	new_profile.socks = socks
	new_profile.worn_icon_list = worn_icon_list.Copy()
	new_profile.worn_icon_state_list = worn_icon_state_list.Copy()
	new_profile.skillchips = skillchips.Copy()
	new_profile.stored_scars = stored_scars.Copy()
	new_profile.profile_snapshot = profile_snapshot
	new_profile.id_icon = id_icon

/datum/antagonist/changeling/roundend_report()
	var/list/parts = list()

	var/changeling_win = TRUE
	if(!owner.current)
		changeling_win = FALSE

	parts += printplayer(owner)
	parts += "<b>Genomes Extracted:</b> [absorbed_count]<br>"

	if(objectives.len)
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_greentext("Success!</b>")]"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_redtext("Fail.")]"
				changeling_win = FALSE
			count++

	if(changeling_win)
		parts += span_greentext("The changeling was successful!")
	else
		parts += span_redtext("The changeling has failed.")

	return parts.Join("<br>")

/datum/antagonist/changeling/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(/datum/outfit/changeling)
	var/icon/split_icon = render_preview_outfit(/datum/outfit/job/engineer)

	final_icon.Shift(WEST, world.icon_size / 2)
	final_icon.Shift(EAST, world.icon_size / 2)

	split_icon.Shift(EAST, world.icon_size / 2)
	split_icon.Shift(WEST, world.icon_size / 2)

	final_icon.Blend(split_icon, ICON_OVERLAY)

	return finish_preview_icon(final_icon)

/datum/antagonist/changeling/ui_data(mob/user)
	var/list/data = list()
	var/list/memories = list()

	for(var/memory_key in stolen_memories)
		memories += list(list("name" = memory_key, "story" = stolen_memories[memory_key]))

	data["memories"] = memories
	data["hive_name"] = hive_name
	data["stolen_antag_info"] = antag_memory
	data["objectives"] = get_objectives()
	return data

// Changelings spawned from non-changeling headslugs (IE, due to being transformed into a headslug as a non-ling). Weaker than a normal changeling.
/datum/antagonist/changeling/headslug
	name = "\improper Headslug Changeling"
	show_in_antagpanel = FALSE
	give_objectives = FALSE
	soft_antag = TRUE

	genetic_points = 5
	total_genetic_points = 5
	chem_charges = 10
	total_chem_storage = 50

/datum/antagonist/changeling/headslug/greet()
	to_chat(owner, span_boldannounce("You are a fresh changeling birthed from a headslug! You aren't as strong as a normal changeling, as you are newly born."))

	var/policy = get_policy(ROLE_HEADSLUG_CHANGELING)
	if(policy)
		to_chat(owner, policy)

/datum/outfit/changeling
	name = "Changeling"

	head = /obj/item/clothing/head/helmet/changeling
	suit = /obj/item/clothing/suit/armor/changeling
	l_hand = /obj/item/melee/arm_blade
