/datum/antagonist/bloodsucker
	name = "\improper Bloodsucker"
	show_in_antagpanel = TRUE
	roundend_category = "bloodsuckers"
	antagpanel_category = "Bloodsucker"
	job_rank = ROLE_BLOODSUCKER
	antag_hud_name = "bloodsucker"
	show_name_in_check_antagonists = TRUE
	can_coexist_with_others = FALSE
	hijack_speed = 0.5
	hud_icon = 'fulp_modules/features/antagonists/bloodsuckers/icons/bloodsucker_icons.dmi'
	ui_name = "AntagInfoBloodsucker"
	preview_outfit = /datum/outfit/bloodsucker_outfit
	tip_theme = "spookyconsole"
	antag_tips = list(
		"You are a Bloodsucker, an undead blood-seeking monster living aboard Space Station 13.",
		"You regenerate your health slowly, you're weak to fire, and you depend on blood to survive. Don't allow your blood to run too low, or you'll enter a Frenzy!",
		"Use your Antagonist UI page to enter a Clan and learn how your Powers work.",
		"While not in a Clan, you will be unable to rank up, Feed, or do any other Bloodsucker activities.",
	)

	/// How much blood we have, starting off at default blood levels.
	var/bloodsucker_blood_volume = BLOOD_VOLUME_NORMAL
	/// How much blood we can have at once, increases per level.
	var/max_blood_volume = 600

	var/datum/bloodsucker_clan/my_clan

	// TIMERS //
	///Timer between alerts for Burn messages
	COOLDOWN_DECLARE(static/bloodsucker_spam_sol_burn)
	///Timer between alerts for Healing messages
	COOLDOWN_DECLARE(static/bloodsucker_spam_healing)

	///Used for assigning your name
	var/bloodsucker_name
	///Used for assigning your title
	var/bloodsucker_title
	///Used for assigning your reputation
	var/bloodsucker_reputation

	///Amount of Humanity lost
	var/humanity_lost = 0
	///Have we been broken the Masquerade?
	var/broke_masquerade = FALSE
	///How many Masquerade Infractions do we have?
	var/masquerade_infractions = 0
	///Blood required to enter Frenzy
	var/frenzy_threshold = FRENZY_THRESHOLD_ENTER
	///If we are currently in a Frenzy
	var/frenzied = FALSE

	///ALL Powers currently owned
	var/list/datum/action/bloodsucker/powers = list()
	///Frenzy Grab Martial art given to Bloodsuckers in a Frenzy
	var/datum/martial_art/frenzygrab/frenzygrab = new

	///Vassals under my control. Periodically remove the dead ones.
	var/list/datum/antagonist/vassal/vassals = list()
	///Special vassals I own, to not have double of the same type.
	var/list/datum/antagonist/vassal/special_vassals = list()

	var/bloodsucker_level = 0
	var/bloodsucker_level_unspent = 1
	var/additional_regen
	var/bloodsucker_regen_rate = 0.3

	// Used for Bloodsucker Objectives
	var/area/bloodsucker_lair_area
	var/obj/structure/closet/crate/coffin
	var/total_blood_drank = 0
	/// If we're currently getting dusted, we won't final death repeatedly.
	var/dust_timer

	///Blood display HUD
	var/atom/movable/screen/bloodsucker/blood_counter/blood_display
	///Vampire level display HUD
	var/atom/movable/screen/bloodsucker/rank_counter/vamprank_display
	///Sunlight timer HUD
	var/atom/movable/screen/bloodsucker/sunlight_counter/sunlight_display

	/// Static typecache of all bloodsucker powers.
	var/static/list/all_bloodsucker_powers = typecacheof(/datum/action/bloodsucker, ignore_root_path = TRUE)
	/// Antagonists that cannot be Vassalized no matter what
	var/static/list/vassal_banned_antags = list(
		/datum/antagonist/bloodsucker,
		/datum/antagonist/monsterhunter,
		/datum/antagonist/changeling,
		/datum/antagonist/cult,
		/datum/antagonist/ert/safety_moth,
	)
	///Default Bloodsucker traits
	var/static/list/bloodsucker_traits = list(
		TRAIT_NOBREATH,
		TRAIT_SLEEPIMMUNE,
		TRAIT_NOCRITDAMAGE,
		TRAIT_RESISTCOLD,
		TRAIT_RADIMMUNE,
		TRAIT_GENELESS,
		TRAIT_STABLEHEART,
		TRAIT_NOSOFTCRIT,
		TRAIT_NOHARDCRIT,
		TRAIT_AGEUSIA,
		TRAIT_NOPULSE,
		TRAIT_COLDBLOODED,
		TRAIT_VIRUSIMMUNE,
		TRAIT_TOXIMMUNE,
		TRAIT_HARDLY_WOUNDED,
	)

/datum/antagonist/bloodsucker/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(!.)
		return FALSE
	if(!new_owner.can_make_bloodsucker())
		return FALSE
	return TRUE

/**
 * Apply innate effects is everything given to the mob
 * When a body is tranferred, this is called on the new mob
 * while on_gain is called ONCE per ANTAG, this is called ONCE per BODY.
 */
/datum/antagonist/bloodsucker/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	RegisterSignal(current_mob, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(current_mob, COMSIG_LIVING_LIFE, PROC_REF(LifeTick))
	handle_clown_mutation(current_mob, mob_override ? null : "As a vampiric clown, you are no longer a danger to yourself. Your clownish nature has been subdued by your thirst for blood.")
	add_team_hud(current_mob)

	if(current_mob.hud_used)
		on_hud_created()
	else
		RegisterSignal(current_mob, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))

/**
 * Remove innate effects is everything given to the mob
 * When a body is tranferred, this is called on the new mob
 * while on_removal is called ONCE per ANTAG, this is called ONCE per BODY.
 */
/datum/antagonist/bloodsucker/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	UnregisterSignal(current_mob, list(COMSIG_LIVING_LIFE, COMSIG_PARENT_EXAMINE))
	handle_clown_mutation(current_mob, removing = FALSE)

	if(current_mob.hud_used)
		var/datum/hud/hud_used = current_mob.hud_used
		hud_used.infodisplay -= blood_display
		hud_used.infodisplay -= vamprank_display
		hud_used.infodisplay -= sunlight_display
		QDEL_NULL(blood_display)
		QDEL_NULL(vamprank_display)
		QDEL_NULL(sunlight_display)

/datum/antagonist/bloodsucker/proc/on_hud_created(datum/source)
	SIGNAL_HANDLER
	var/datum/hud/bloodsucker_hud = owner.current.hud_used

	blood_display = new /atom/movable/screen/bloodsucker/blood_counter()
	blood_display.hud = bloodsucker_hud
	bloodsucker_hud.infodisplay += blood_display

	vamprank_display = new /atom/movable/screen/bloodsucker/rank_counter()
	vamprank_display.hud = bloodsucker_hud
	bloodsucker_hud.infodisplay += vamprank_display

	sunlight_display = new /atom/movable/screen/bloodsucker/sunlight_counter()
	sunlight_display.hud = bloodsucker_hud
	bloodsucker_hud.infodisplay += sunlight_display

	bloodsucker_hud.show_hud(bloodsucker_hud.hud_version)
	UnregisterSignal(owner.current, COMSIG_MOB_HUD_CREATED)

/datum/antagonist/bloodsucker/get_admin_commands()
	. = ..()
	.["Give Level"] = CALLBACK(src, PROC_REF(RankUp))
	if(bloodsucker_level_unspent >= 1)
		.["Remove Level"] = CALLBACK(src, PROC_REF(RankDown))

	if(broke_masquerade)
		.["Fix Masquerade"] = CALLBACK(src, PROC_REF(fix_masquerade))
	else
		.["Break Masquerade"] = CALLBACK(src, PROC_REF(break_masquerade))

///Called when you get the antag datum, called only ONCE per antagonist.
/datum/antagonist/bloodsucker/on_gain()
	RegisterSignal(SSsunlight, COMSIG_SOL_RANKUP_BLOODSUCKERS, PROC_REF(sol_rank_up))
	RegisterSignal(SSsunlight, COMSIG_SOL_NEAR_START, PROC_REF(sol_near_start))
	RegisterSignal(SSsunlight, COMSIG_SOL_END, PROC_REF(on_sol_end))
	RegisterSignal(SSsunlight, COMSIG_SOL_RISE_TICK, PROC_REF(handle_sol))
	RegisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN, PROC_REF(give_warning))

	if(IS_FAVORITE_VASSAL(owner.current)) // Vassals shouldnt be getting the same benefits as Bloodsuckers.
		bloodsucker_level_unspent = 0
		show_in_roundend = FALSE
	else
		// Start Sunlight if first Bloodsucker
		check_start_sunlight()
		// Name and Titles
		SelectFirstName()
		SelectTitle(am_fledgling = TRUE)
		SelectReputation(am_fledgling = TRUE)
		// Objectives
		forge_bloodsucker_objectives()

	. = ..()
	// Assign Powers
	AssignStarterPowersAndStats()

/// Called by the remove_antag_datum() and remove_all_antag_datums() mind procs for the antag datum to handle its own removal and deletion.
/datum/antagonist/bloodsucker/on_removal()
	UnregisterSignal(SSsunlight, list(COMSIG_SOL_RANKUP_BLOODSUCKERS, COMSIG_SOL_NEAR_START, COMSIG_SOL_END, COMSIG_SOL_RISE_TICK, COMSIG_SOL_WARNING_GIVEN))
	ClearAllPowersAndStats()
	check_cancel_sunlight() //check if sunlight should end
	QDEL_NULL(my_clan)
	return ..()

/datum/antagonist/bloodsucker/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	for(var/datum/action/bloodsucker/all_powers as anything in powers)
		all_powers.Remove(old_body)
		all_powers.Grant(new_body)
	var/obj/item/bodypart/old_left_arm = old_body.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/old_right_arm = old_body.get_bodypart(BODY_ZONE_R_ARM)
	var/old_left_arm_unarmed_damage_low
	var/old_left_arm_unarmed_damage_high
	var/old_right_arm_unarmed_damage_low
	var/old_right_arm_unarmed_damage_high
	if(ishuman(old_body))
		var/mob/living/carbon/human/old_user = old_body
		var/datum/species/old_species = old_user.dna.species
		old_species.species_traits -= DRINKSBLOOD
		//Keep track of what they were
		old_left_arm_unarmed_damage_low = old_left_arm.unarmed_damage_low
		old_left_arm_unarmed_damage_high = old_left_arm.unarmed_damage_high
		old_right_arm_unarmed_damage_low = old_right_arm.unarmed_damage_low
		old_right_arm_unarmed_damage_high = old_right_arm.unarmed_damage_high
		//Then reset them
		old_left_arm.unarmed_damage_low = initial(old_left_arm.unarmed_damage_low)
		old_left_arm.unarmed_damage_high = initial(old_left_arm.unarmed_damage_high)
		old_right_arm.unarmed_damage_low = initial(old_right_arm.unarmed_damage_low)
		old_right_arm.unarmed_damage_high = initial(old_right_arm.unarmed_damage_high)
	if(ishuman(new_body))
		var/mob/living/carbon/human/new_user = new_body
		var/datum/species/new_species = new_user.dna.species
		new_species.species_traits += DRINKSBLOOD
		var/obj/item/bodypart/new_left_arm
		var/obj/item/bodypart/new_right_arm
		//Give old punch damage values
		new_left_arm = new_body.get_bodypart(BODY_ZONE_L_ARM)
		new_right_arm = new_body.get_bodypart(BODY_ZONE_R_ARM)
		new_left_arm.unarmed_damage_low = old_left_arm_unarmed_damage_low
		new_left_arm.unarmed_damage_high = old_left_arm_unarmed_damage_high
		new_right_arm.unarmed_damage_low = old_right_arm_unarmed_damage_low
		new_right_arm.unarmed_damage_high = old_right_arm_unarmed_damage_high

	//Give Bloodsucker Traits
	for(var/all_traits in bloodsucker_traits)
		REMOVE_TRAIT(old_body, all_traits, BLOODSUCKER_TRAIT)
		ADD_TRAIT(new_body, all_traits, BLOODSUCKER_TRAIT)

/datum/antagonist/bloodsucker/greet()
	. = ..()
	var/fullname = return_full_name()
	to_chat(owner, span_userdanger("You are [fullname], a strain of vampire known as a Bloodsucker!"))
	owner.announce_objectives()
	if(bloodsucker_level_unspent >= 2)
		to_chat(owner, span_announce("As a latejoiner, you have [bloodsucker_level_unspent] bonus Ranks, entering your claimed coffin allows you to spend a Rank."))
	owner.current.playsound_local(null, 'fulp_modules/features/antagonists/bloodsuckers/sounds/BloodsuckerAlert.ogg', 100, FALSE, pressure_affected = FALSE)
	antag_memory += "Although you were born a mortal, in undeath you earned the name <b>[fullname]</b>.<br>"

/datum/antagonist/bloodsucker/farewell()
	to_chat(owner.current, span_userdanger("<FONT size = 3>With a snap, your curse has ended. You are no longer a Bloodsucker. You live once more!</FONT>"))
	// Refill with Blood so they don't instantly die.
	owner.current.blood_volume = max(owner.current.blood_volume, BLOOD_VOLUME_NORMAL)

// Called when using admin tools to give antag status
/datum/antagonist/bloodsucker/admin_add(datum/mind/new_owner, mob/admin)
	var/levels = input("How many unspent Ranks would you like [new_owner] to have?","Bloodsucker Rank", bloodsucker_level_unspent) as null | num
	var/msg = " made [key_name_admin(new_owner)] into \a [name]"
	if(levels > 1)
		bloodsucker_level_unspent = levels
		msg += " with [levels] extra unspent Ranks."
	message_admins("[key_name_admin(usr)][msg]")
	log_admin("[key_name(usr)][msg]")
	new_owner.add_antag_datum(src)

/datum/antagonist/bloodsucker/get_preview_icon()

	var/icon/final_icon = render_preview_outfit(/datum/outfit/bloodsucker_outfit)
	final_icon.Blend(icon('icons/effects/blood.dmi', "uniformblood"), ICON_OVERLAY)

	return finish_preview_icon(final_icon)

/datum/antagonist/bloodsucker/ui_static_data(mob/user)
	var/list/data = list()
	//we don't need to update this that much.
	data["in_clan"] = !!my_clan
	var/list/clan_data = list()
	if(my_clan)
		clan_data["clan_name"] = my_clan.name
		clan_data["clan_description"] = my_clan.description
		clan_data["clan_icon"] = my_clan.join_icon_state

	data["clan"] += list(clan_data)

	for(var/datum/action/bloodsucker/power as anything in powers)
		var/list/power_data = list()

		power_data["power_name"] = power.name
		power_data["power_explanation"] = power.power_explanation
		power_data["power_icon"] = power.button_icon_state

		data["power"] += list(power_data)

	return data + ..()

/datum/antagonist/bloodsucker/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/bloodsucker_icons),
	)

/datum/antagonist/bloodsucker/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("join_clan")
			assign_clan_and_bane()
			ui.send_full_update(force = TRUE)
			return

/datum/antagonist/bloodsucker/proc/AssignStarterPowersAndStats()
	// Purchase Roundstart Powers
	for(var/datum/action/bloodsucker/all_powers as anything in all_bloodsucker_powers)
		if(!(initial(all_powers.purchase_flags) & BLOODSUCKER_DEFAULT_POWER))
			continue
		BuyPower(new all_powers)
	//Traits: Species
	var/mob/living/carbon/human/user = owner.current
	if(ishuman(owner.current))
		var/datum/species/user_species = user.dna.species
		var/obj/item/bodypart/user_left_arm = user.get_bodypart(BODY_ZONE_L_ARM)
		var/obj/item/bodypart/user_right_arm = user.get_bodypart(BODY_ZONE_R_ARM)
		user_species.species_traits += DRINKSBLOOD
		user.dna?.remove_all_mutations()
		user_left_arm.unarmed_damage_low += 1 //lowest possible punch damage - 0
		user_left_arm.unarmed_damage_high += 1 //highest possible punch damage - 9
		user_right_arm.unarmed_damage_low += 1 //lowest possible punch damage - 0
		user_right_arm.unarmed_damage_high += 1 //highest possible punch damage - 9
	//Give Bloodsucker Traits
	for(var/all_traits in bloodsucker_traits)
		ADD_TRAIT(owner.current, all_traits, BLOODSUCKER_TRAIT)
	//Clear Addictions
	for(var/addiction_type in subtypesof(/datum/addiction))
		owner.current.mind.remove_addiction_points(addiction_type, MAX_ADDICTION_POINTS)
	//No Skittish "People" allowed
	if(HAS_TRAIT(owner.current, TRAIT_SKITTISH))
		REMOVE_TRAIT(owner.current, TRAIT_SKITTISH, ROUNDSTART_TRAIT)
	// Tongue & Language
	owner.current.grant_all_languages(FALSE, FALSE, TRUE)
	owner.current.grant_language(/datum/language/vampiric)
	/// Clear Disabilities & Organs
	heal_vampire_organs()

/datum/antagonist/bloodsucker/proc/ClearAllPowersAndStats()
	// Powers
	for(var/datum/action/bloodsucker/all_powers as anything in powers)
		RemovePower(all_powers)
	/// Stats
	if(ishuman(owner.current))
		var/mob/living/carbon/human/user = owner.current
		var/datum/species/user_species = user.dna.species
		user_species.species_traits -= DRINKSBLOOD
		// Clown
		if(istype(user) && owner.assigned_role == "Clown")
			user.dna.add_mutation(/datum/mutation/human/clumsy)
	/// Remove ALL Traits, as long as its from BLOODSUCKER_TRAIT's source. - This is because of unique cases like Nosferatu getting Ventcrawling.
	for(var/all_status_traits in owner.current.status_traits)
		REMOVE_TRAIT(owner.current, all_status_traits, BLOODSUCKER_TRAIT)
	/// Update Health
	owner.current.setMaxHealth(MAX_LIVING_HEALTH)
	// Language
	owner.current.remove_language(/datum/language/vampiric)
	/// Heart
	RemoveVampOrgans()
	/// Eyes
	var/mob/living/carbon/user = owner.current
	var/obj/item/organ/internal/eyes/user_eyes = user.getorganslot(ORGAN_SLOT_EYES)
	if(user_eyes)
		user_eyes.flash_protect = initial(user_eyes.flash_protect)
		user_eyes.color_cutoffs = initial(user_eyes.color_cutoffs)
		user_eyes.sight_flags = initial(user_eyes.sight_flags)
	user.update_sight()

/// Name shown on antag list
/datum/antagonist/bloodsucker/antag_listing_name()
	return ..() + "([return_full_name()])"

/// Whatever interesting things happened to the antag admins should know about
/// Include additional information about antag in this part
/datum/antagonist/bloodsucker/antag_listing_status()
	if(owner && !considered_alive(owner))
		return "<font color=red>Final Death</font>"
	return ..()

/datum/antagonist/bloodsucker/proc/forge_bloodsucker_objectives()
	// Claim a Lair Objective
	var/datum/objective/bloodsucker/lair/lair_objective = new
	lair_objective.owner = owner
	objectives += lair_objective
	// Survive Objective
	var/datum/objective/survive/bloodsucker/survive_objective = new
	survive_objective.owner = owner
	objectives += survive_objective

	// Objective 1: Vassalize a Head/Command, or a specific target
	switch(rand(1, 3))
		if(1) // Conversion Objective
			var/datum/objective/bloodsucker/conversion/chosen_subtype = pick(subtypesof(/datum/objective/bloodsucker/conversion))
			var/datum/objective/bloodsucker/conversion/conversion_objective = new chosen_subtype
			conversion_objective.owner = owner
			conversion_objective.objective_name = "Optional Objective"
			objectives += conversion_objective
		if(2) // Heart Thief Objective
			var/datum/objective/bloodsucker/heartthief/heartthief_objective = new
			heartthief_objective.owner = owner
			heartthief_objective.objective_name = "Optional Objective"
			objectives += heartthief_objective
		if(3) // Drink Blood Objective
			var/datum/objective/bloodsucker/gourmand/gourmand_objective = new
			gourmand_objective.owner = owner
			gourmand_objective.objective_name = "Optional Objective"
			objectives += gourmand_objective
