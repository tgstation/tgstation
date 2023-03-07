/datum/antagonist/bloodsucker
	name = "\improper Bloodsucker"
	show_in_antagpanel = TRUE
	roundend_category = "bloodsuckers"
	antagpanel_category = "Bloodsucker"
	job_rank = ROLE_BLOODSUCKER
	show_name_in_check_antagonists = TRUE
	can_coexist_with_others = FALSE
	hijack_speed = 0.5

	antag_hud_name = "bloodsucker"

	// TIMERS //
	///Timer between alerts for Burn messages
	COOLDOWN_DECLARE(static/bloodsucker_spam_sol_burn)
	///Timer between alerts for Healing messages
	COOLDOWN_DECLARE(static/bloodsucker_spam_healing)

	ui_name = "AntagInfoBloodsucker"

	preview_outfit = /datum/outfit/bloodsucker_outfit

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
	///Blood required to enter Frenzy
	var/frenzy_threshold = FRENZY_THRESHOLD_ENTER
	///If we are currently in a Frenzy
	var/frenzied = FALSE
	///If we have a task assigned
	var/current_task = FALSE
	///How many times have we used a blood altar
	var/altar_uses = 0

	///ALL Powers currently owned
	var/list/datum/action/powers = list()
	///Bloodsucker Clan - Used for dealing with Sol
	var/datum/team/vampireclan/clan
	///Frenzy Grab Martial art given to Bloodsuckers in a Frenzy
	var/datum/martial_art/frenzygrab/frenzygrab = new
	///You get assigned a Clan once you Rank up enough
	var/my_clan = NONE

	///Vassals under my control. Periodically remove the dead ones.
	var/list/datum/antagonist/vassal/vassals = list()
	///Have we selected our Favorite Vassal yet?
	var/has_favorite_vassal = FALSE
	/// Who made me? For both Vassals AND Bloodsuckers (though Master Vamps won't have one)
	var/datum/mind/creator

	var/bloodsucker_level
	var/bloodsucker_level_unspent = 1
	var/passive_blood_drain = -0.1
	var/additional_regen
	var/bloodsucker_regen_rate = 0.3
	var/max_blood_volume = 600

	// Used for Bloodsucker Objectives
	var/area/lair
	var/obj/structure/closet/crate/coffin
	var/total_blood_drank = 0
	var/frenzy_blood_drank = 0
	var/task_blood_drank = 0
	var/frenzies = 0

	/// Static typecache of all bloodsucker powers.
	var/static/list/all_bloodsucker_powers = subtypesof(/datum/action/bloodsucker)
	/// Antagonists that cannot be Vassalized no matter what
	var/list/vassal_banned_antags = list(
		/datum/antagonist/bloodsucker,
		/datum/antagonist/monsterhunter,
		/datum/antagonist/changeling,
		/datum/antagonist/cult,
		/datum/antagonist/heretic,
		/datum/antagonist/xeno,
		/datum/antagonist/obsessed
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
		TRAIT_TRUE_NIGHT_VISION,
	)

	var/dust_timer

/mob/living/proc/explain_powers()
	set name = "Bloodsucker Help"
	set category = "Mentor"

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = mind.has_antag_datum(/datum/antagonist/bloodsucker)
	var/choice = input(usr, "What Power are you looking into?", "Mentorhelp v2") in bloodsuckerdatum.powers
	if(!choice)
		return
	var/datum/action/bloodsucker/power = choice
	to_chat(usr, span_warning("[power.power_explanation]"))

/// These handles the application of antag huds/special abilities
/datum/antagonist/bloodsucker/apply_innate_effects(mob/living/mob_override)
	. = ..()
	RegisterSignal(owner.current, COMSIG_LIVING_LIFE, .proc/LifeTick)
	if((owner.assigned_role == "Clown"))
		var/mob/living/carbon/H = owner.current
		if(H && istype(H))
			if(!silent)
				H.dna.remove_mutation(/datum/mutation/human/clumsy)
				to_chat(owner, "As a vampiric clown, you are no longer a danger to yourself. Your clownish nature has been subdued by your thirst for blood.")
	add_team_hud(owner.current, /datum/antagonist/bloodsucker)

/datum/antagonist/bloodsucker/remove_innate_effects(mob/living/mob_override)
	. = ..()
	UnregisterSignal(owner.current, COMSIG_LIVING_LIFE)
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/H = owner.current
		if(H && istype(H))
			H.dna.add_mutation(/datum/mutation/human/clumsy)

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

/datum/antagonist/bloodsucker/get_admin_commands()
	. = ..()
	.["Give Level"] = CALLBACK(src, .proc/RankUp)
	if(bloodsucker_level_unspent >= 1)
		.["Remove Level"] = CALLBACK(src, .proc/RankDown)

	if(broke_masquerade)
		.["Fix Masquerade"] = CALLBACK(src, .proc/fix_masquerade)
	else
		.["Break Masquerade"] = CALLBACK(src, .proc/break_masquerade)

/// Called by the add_antag_datum() mind proc after the instanced datum is added to the mind's antag_datums list.
/datum/antagonist/bloodsucker/on_gain()
	if(IS_VASSAL(owner.current)) // Vassals shouldnt be getting the same benefits as Bloodsuckers.
		bloodsucker_level_unspent = 0
	else
		// Start Sunlight if first Bloodsucker
		clan.check_start_sunlight()
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
	/// End Sunlight? (if last Vamp)
	clan.check_cancel_sunlight()
	ClearAllPowersAndStats()
	return ..()

/datum/antagonist/bloodsucker/greet()
	. = ..()
	var/fullname = ReturnFullName(TRUE)
	to_chat(owner, span_userdanger("You are [fullname], a strain of vampire known as a Bloodsucker!"))
	owner.announce_objectives()
	if(bloodsucker_level_unspent >= 2)
		to_chat(owner, span_announce("As a latejoiner, you have [bloodsucker_level_unspent] bonus Ranks, entering your claimed coffin allows you to spend a Rank."))
	owner.current.playsound_local(null, 'sound/ambience/antag/bloodsuckeralert.ogg', 100, FALSE, pressure_affected = FALSE)
	antag_memory += "Although you were born a mortal, in undeath you earned the name <b>[fullname]</b>.<br>"

/datum/antagonist/bloodsucker/farewell()
	to_chat(owner.current, span_userdanger("<FONT size = 3>With a snap, your curse has ended. You are no longer a Bloodsucker. You live once more!</FONT>"))
	// Refill with Blood so they don't instantly die.
	owner.current.blood_volume = max(owner.current.blood_volume, BLOOD_VOLUME_NORMAL)

/datum/antagonist/bloodsucker/proc/add_objective(datum/objective/added_objective)
	objectives += added_objective

/datum/antagonist/bloodsucker/proc/remove_objectives(datum/objective/removed_objective)
	objectives -= removed_objective

// Called when using admin tools to give antag status, admin spawned bloodsuckers don't get turned human if plasmaman.
/datum/antagonist/bloodsucker/admin_add(datum/mind/new_owner, mob/admin)
	var/levels = input("How many unspent Ranks would you like [new_owner] to have?","Bloodsucker Rank", bloodsucker_level_unspent) as null | num
	var/msg = " made [key_name_admin(new_owner)] into \a [name]"
	if(!isnull(levels))
		bloodsucker_level_unspent = levels
		msg += " with [levels] extra unspent Ranks."
	message_admins("[key_name_admin(usr)][msg]")
	log_admin("[key_name(usr)][msg]")
	new_owner.add_antag_datum(src)

/**
 *	# Vampire Clan
 *
 *	This is used for dealing with the Vampire Clan.
 *	This handles Sol for Bloodsuckers, making sure to not have several.
 *	None of this should appear in game, we are using it JUST for Sol. All Bloodsuckers should have their individual report.
 */

/datum/team/vampireclan
	name = "Clan"

	/// Sunlight Timer. Created on first Bloodsucker assign. Destroyed on last removed Bloodsucker.
	var/obj/effect/sunlight/bloodsucker_sunlight

/datum/antagonist/bloodsucker/create_team(datum/team/vampireclan/team)
	if(!team)
		for(var/datum/antagonist/bloodsucker/bloodsuckerdatums in GLOB.antagonists)
			if(!bloodsuckerdatums.owner)
				continue
			if(bloodsuckerdatums.clan)
				clan = bloodsuckerdatums.clan
				return
		clan = new /datum/team/vampireclan
		return
	if(!istype(team))
		stack_trace("Wrong team type passed to [type] initialization.")
	clan = team

/datum/antagonist/bloodsucker/get_team()
	return clan

/datum/team/vampireclan/roundend_report()
	if(members.len <= 0)
		return
	var/list/report = list()
	report += "<span class='header'>Lurking in the darkness, the Bloodsuckers were:</span><br>"
	for(var/datum/mind/mind_members in members)
		for(var/datum/antagonist/bloodsucker/individual_bloodsuckers in mind_members.antag_datums)
			if(mind_members.has_antag_datum(/datum/antagonist/vassal)) // Skip over Ventrue's Favorite Vassal
				continue
			report += individual_bloodsuckers.roundend_report()

	return "<div class='panel redborder'>[report.Join("<br>")]</div>"

/// Individual roundend report
/datum/antagonist/bloodsucker/roundend_report()
	// Get the default Objectives
	var/list/report = list()
	// Vamp name
	report += "<br><span class='header'><b>\[[ReturnFullName(TRUE)]\]</b></span>"
	report += printplayer(owner)
	// Clan (Actual Clan, not Team) name
	if(my_clan != NONE)
		report += "They were part of the <b>[my_clan]</b>!"

	// Default Report
	var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	// Now list their vassals
	if(vassals.len > 0)
		report += "<span class='header'>Their Vassals were...</span>"
		for(var/datum/antagonist/vassal/all_vassals in vassals)
			if(all_vassals.owner)
				var/jobname = all_vassals.owner.assigned_role ? "the [all_vassals.owner.assigned_role]" : ""
				report += "<b>[all_vassals.owner.name]</b> [jobname][all_vassals.favorite_vassal == TRUE ? " and was the <b>Favorite Vassal</b>" : ""]"

	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report

/**
 *	# Assigning Sol
 *
 *	Sol is the sunlight, during this period, all Bloodsuckers must be in their coffin, else they burn.
 *	This was originally dealt with by the gamemode, but as gamemodes no longer exist, it is dealt with by the team.
 */

/// Start Sol, called when someone is assigned Bloodsucker
/datum/team/vampireclan/proc/check_start_sunlight()
	if(members.len <= 1)
		message_admins("New Sol has been created due to Bloodsucker assignment.")
		bloodsucker_sunlight = new()

/// End Sol, if you're the last Bloodsucker
/datum/team/vampireclan/proc/check_cancel_sunlight()
	// No minds in the clan? Delete Sol.
	if(members.len <= 1)
		message_admins("Sol has been deleted due to the lack of Bloodsuckers")
		QDEL_NULL(bloodsucker_sunlight)

/// Buying powers
/datum/antagonist/bloodsucker/proc/BuyPower(datum/action/bloodsucker/power)
	powers += power
	power.Grant(owner.current)

/datum/antagonist/bloodsucker/proc/RemovePower(datum/action/bloodsucker/power)
	for(var/datum/action/bloodsucker/all_powers as anything in powers)
		if(initial(power.name) == all_powers.name)
			power = all_powers
			break
	if(power.active)
		power.DeactivatePower()
	powers -= power
	power.Remove(owner.current)

/datum/antagonist/bloodsucker/proc/AssignStarterPowersAndStats()
	// Purchase Roundstart Powers
	BuyPower(new /datum/action/bloodsucker/feed)
	BuyPower(new /datum/action/bloodsucker/masquerade)
	if(!IS_VASSAL(owner.current)) // Favorite Vassal gets their own.
		BuyPower(new /datum/action/bloodsucker/veil)
	add_verb(owner.current, /mob/living/proc/explain_powers)
	// Traits: Species
	if(iscarbon(owner.current))
		var/mob/living/carbon/carbon_vamp = owner.current
		for(var/obj/item/bodypart/part in carbon_vamp.bodyparts) //Hope that you aren't getting them dismembered
			part.unarmed_damage_low += 1
			part.unarmed_damage_high += 1
	var/mob/living/carbon/human/user = owner.current
	if(ishuman(owner.current))
		var/datum/species/user_species = user.dna.species
		user_species.species_traits += DRINKSBLOOD
		user.dna?.remove_all_mutations()
	/// Give Bloodsucker Traits
	for(var/all_traits in bloodsucker_traits)
		ADD_TRAIT(owner.current, all_traits, BLOODSUCKER_TRAIT)
	/// No Skittish "People" allowed
	if(HAS_TRAIT(owner.current, TRAIT_SKITTISH))
		REMOVE_TRAIT(owner.current, TRAIT_SKITTISH, ROUNDSTART_TRAIT)
	// Tongue & Language
	owner.current.grant_all_languages(FALSE, FALSE, TRUE)
	owner.current.grant_language(/datum/language/vampiric)
	/// Clear Disabilities & Organs
	heal_vampire_organs()

/datum/antagonist/bloodsucker/proc/ClearAllPowersAndStats()
	/// Remove huds
	remove_hud()
	// Powers
	remove_verb(owner.current, /mob/living/proc/explain_powers)
	while(powers.len)
		var/datum/action/bloodsucker/power = pick(powers)
		powers -= power
		power.Remove(owner.current)
		// owner.RemoveSpell(power)
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
	owner.current.setMaxHealth(100)
	// Language
	owner.current.remove_language(/datum/language/vampiric)
	/// Heart
	RemoveVampOrgans()
	/// Eyes
	var/mob/living/carbon/user = owner.current
	var/obj/item/organ/internal/eyes/user_eyes = user.getorganslot(ORGAN_SLOT_EYES)
	if(user_eyes)
		user_eyes.flash_protect += 1
		user_eyes.sight_flags = 0
	user.update_sight()

/datum/antagonist/bloodsucker/proc/RankUp()
	set waitfor = FALSE
	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(owner.current)
	if(!owner || !owner.current || vassaldatum)
		return
	bloodsucker_level_unspent++ //same thing as below
	passive_blood_drain -= 0.03 * bloodsucker_level //do something. It's here because if you are gaining points through other means you are doing good
	// Spend Rank Immediately?
	if(istype(owner.current.loc, /obj/structure/closet/crate/coffin))
		if(my_clan == CLAN_VENTRUE)
			to_chat(owner, "<span class='announce'>You have recieved a new Rank to level up your Favorite Vassal with!</span><br>")
			return
		to_chat(owner, span_notice("<EM>You have grown more ancient! Sleep in a coffin that you have claimed to thicken your blood and become more powerful.</EM>"))
		if(bloodsucker_level_unspent >= 2)
			to_chat(owner, span_announce("Bloodsucker Tip: If you cannot find or steal a coffin to use, you can build one from wood or metal."))

/datum/antagonist/bloodsucker/proc/RankDown()
	bloodsucker_level_unspent--

/datum/antagonist/bloodsucker/proc/remove_nondefault_powers()
	for(var/datum/action/bloodsucker/power as anything in powers)
		if(istype(power, /datum/action/bloodsucker/feed) || istype(power, /datum/action/bloodsucker/masquerade) || istype(power, /datum/action/bloodsucker/veil))
			continue
		RemovePower(power)

/datum/antagonist/bloodsucker/proc/LevelUpPowers()
	for(var/datum/action/bloodsucker/power as anything in powers)
		power.level_current++

///Disables all powers, accounting for torpor
/datum/antagonist/bloodsucker/proc/DisableAllPowers()
	for(var/datum/action/bloodsucker/power as anything in powers)
		if((power.check_flags & BP_CANT_USE_IN_TORPOR) && HAS_TRAIT(owner.current, TRAIT_NODEATH))
			if(power.active)
				power.DeactivatePower()

/datum/antagonist/bloodsucker/proc/SpendRank(spend_rank = TRUE)
	set waitfor = FALSE

	if(!owner || !owner.current || !owner.current.client || (spend_rank && bloodsucker_level_unspent <= 0.5))
		return
	// Purchase Power Prompt
	var/list/options = list()
	for(var/datum/action/bloodsucker/power as anything in all_bloodsucker_powers)
		if(my_clan == CLAN_TREMERE)
			if(LevelUpTremerePower(owner.current))
				// Did we buy a power? Break here.
				break
			else
				// Didnt buy one? Dont continue on, then.
				return
		if(initial(power.purchase_flags) & BLOODSUCKER_CAN_BUY && !(locate(power) in powers))
			options[initial(power.name)] = power


	if(!options.len)
		to_chat(owner.current, span_notice("You grow more ancient by the night!"))
	else
		// Give them the UI to purchase a power.
		var/choice = tgui_input_list(owner.current, "You have the opportunity to grow more ancient, increasing the level of all your powers by 1. Select a power to advance your Rank.", "Your Blood Thickens...", options)
		// Prevent Bloodsuckers from closing/reopning their coffin to spam Levels.
		if(spend_rank && bloodsucker_level_unspent <= 0)
			return
		// Did you choose a power?
		if(!choice || !options[choice])
			to_chat(owner.current, span_notice("You prevent your blood from thickening just yet, but you may try again later."))
			return
		if(!istype(owner.current.loc, /obj/structure/closet/crate/coffin))
			to_chat(owner.current, span_warning("You must be in your Coffin to purchase Powers."))
			return

		// Good to go - Buy Power!
		var/datum/action/bloodsucker/purchased_power = options[choice]
		BuyPower(new purchased_power)
		to_chat(owner.current, span_notice("You have learned how to use [choice]!"))

	// Advance Powers - Includes the one you just purchased.
	LevelUpPowers()
	// Bloodsucker-only Stat upgrades
	bloodsucker_regen_rate += 0.05
	max_blood_volume += 100
	// Misc. Stats Upgrades
	if(iscarbon(owner.current))
		var/mob/living/carbon/carbon_vamp = owner.current
		for(var/obj/item/bodypart/part in carbon_vamp.bodyparts) //Hope that you aren't getting dismembered
			part.unarmed_damage_low += 0.5
			part.unarmed_damage_high += 0.5

	// We're almost done - Spend your Rank now.
	bloodsucker_level++
	if(spend_rank)
		bloodsucker_level_unspent--
	// Ranked up enough? Let them join a Clan.
	if(bloodsucker_level == 3)
		AssignClanAndBane()

	// Ranked up enough to get your true Reputation?
	if(bloodsucker_level == 4)
		SelectReputation(am_fledgling = FALSE, forced = TRUE)

	// Done! Let them know & Update their HUD.
	to_chat(owner.current, span_notice("You are now a rank [bloodsucker_level] Bloodsucker. Your strength, health, feed rate, regen rate, and maximum blood capacity have all increased!\n\
	* Your existing powers have all ranked up as well!"))
	update_hud(owner.current)
	owner.current.playsound_local(null, 'sound/effects/pope_entry.ogg', 25, TRUE, pressure_affected = FALSE)

/datum/antagonist/bloodsucker/proc/SpendVassalRank(mob/living/target, SpendRank = TRUE)
	set waitfor = FALSE

	var/datum/antagonist/vassal/vassaldatum = target.mind.has_antag_datum(/datum/antagonist/vassal)
	/// Purchase Power Prompt
	var/list/options = list()
	for(var/pickedpower in typesof(/datum/action/bloodsucker))
		var/datum/action/bloodsucker/power = pickedpower
		/// Check If I don't own it & I'm allowed to buy it.
		if(!(locate(power) in vassaldatum.powers) && initial(power.purchase_flags) & VASSAL_CAN_BUY)
			options[initial(power.name)] = power

	/// No powers to purchase? Abort.
	if(options.len >= 1)
		/// Give them the UI to purchase a power.
		var/choice = tgui_input_list(owner.current, "You have the opportunity to level up your Favorite Vassal. Select a power you wish them to recieve.", "You feel like a Leader!", options)
		/// Did you choose a power? Do you already have it? - Added due to window stacking.
		if(!choice || !options[choice] || (locate(options[choice]) in vassaldatum.powers))
			to_chat(owner.current, "<span class='notice'>You prevent your blood from thickening just yet, but you may try again later.</span>")
			return
		/// Good to go - Buy Power!
		var/datum/action/bloodsucker/P = options[choice]
		vassaldatum.BuyPower(new P)
		to_chat(owner.current, "<span class='notice'>You taught [target] how to use [initial(P.name)]!</span>")
		to_chat(target, "<span class='notice'>Your master taught you how to use [initial(P.name)]!</span>")

	else
		to_chat(owner.current, "<span class='notice'>You grow more ancient by the night!</span>")

	/* # As we don't level up normally, Bloodsuckers will Rank Up themselves this way.
	*/

	/// Advance your and your Vassal's Powers - Includes the one you just purchased.
	vassaldatum.LevelUpPowers()
	LevelUpPowers()
	/// Bloodsucker-only Stat upgrades
	bloodsucker_regen_rate += 0.05
	max_blood_volume += 100
	/// Misc. Stats Upgrades
	if(iscarbon(owner.current))
		var/mob/living/carbon/carbon_vamp = owner.current
		for(var/obj/item/bodypart/part in carbon_vamp.bodyparts) //Hope that you aren't getting dismembered
			part.unarmed_damage_low += 0.5
			part.unarmed_damage_high += 0.5
	owner.current.setMaxHealth(owner.current.maxHealth + 5) // Why is this a thing...

	/// We're almost done - Spend your Rank now.
	vassaldatum.vassal_level++
	bloodsucker_level++
	if(SpendRank)
		bloodsucker_level_unspent--

	/// Vassals will turn more into a 'Bloodsucker' overtime
	if(vassaldatum.vassal_level == 2)
		ADD_TRAIT(target, TRAIT_COLDBLOODED, BLOODSUCKER_TRAIT)
		ADD_TRAIT(target, TRAIT_NOBREATH, BLOODSUCKER_TRAIT)
		ADD_TRAIT(target, TRAIT_AGEUSIA, BLOODSUCKER_TRAIT)
		to_chat(target, "<span class='notice'>Your blood begins you feel cold, as ash sits on your tongue, you stop breathing...</span>")
	if(vassaldatum.vassal_level == 3)
		ADD_TRAIT(target, TRAIT_NOCRITDAMAGE, BLOODSUCKER_TRAIT)
		ADD_TRAIT(target, TRAIT_NOSOFTCRIT, BLOODSUCKER_TRAIT)
	if(vassaldatum.vassal_level == 4)
		ADD_TRAIT(target, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
		ADD_TRAIT(target, TRAIT_VIRUSIMMUNE, BLOODSUCKER_TRAIT)
		to_chat(target, "<span class='notice'>You feel your Master's blood begin to protect you from bacteria.</span>")
		var/mob/living/carbon/human/human_target = target
		if(human_target)
			human_target.skin_tone = "albino"
	if(vassaldatum.vassal_level == 5)
		ADD_TRAIT(target, TRAIT_NOHARDCRIT, BLOODSUCKER_TRAIT)
		ADD_TRAIT(target, TRAIT_HARDLY_WOUNDED, BLOODSUCKER_TRAIT)
		to_chat(target, "<span class='notice'>You feel yourself able to take cuts and stabbings like it's nothing.</span>")
	if(vassaldatum.vassal_level == 6)
		ADD_TRAIT(target, TRAIT_NOPULSE, BLOODSUCKER_TRAIT)
		ADD_TRAIT(target, TRAIT_STABLEHEART, BLOODSUCKER_TRAIT)
		to_chat(target, "<span class='notice'>You feel your heart stop pumping for the last time as you begin to thirst for blood, you will no longer naturally regenerate Blood!</span>")
		vassaldatum.BuyPower(new /datum/action/bloodsucker/feed)

////////////////////////////////////////////////////////////////////////////////////////////////

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
	var/list/rolled_objectives = list()
	switch(rand(1, 3))
		if(1) // Protege and Drink Objective
			rolled_objectives = list(new /datum/objective/bloodsucker/protege, new /datum/objective/bloodsucker/gourmand)
			for(var/datum/objective/bloodsucker/objective in rolled_objectives)
				objective.owner = owner
				objectives += objective
		if(2) // Heart Thief and Protege Objective
			rolled_objectives = list(new /datum/objective/bloodsucker/protege, new /datum/objective/bloodsucker/heartthief)
			for(var/datum/objective/bloodsucker/objective in rolled_objectives)
				objective.owner = owner
				objectives += objective
		if(3) // All of them
			rolled_objectives = list(new /datum/objective/bloodsucker/protege, new /datum/objective/bloodsucker/heartthief, new /datum/objective/bloodsucker/gourmand)
			for(var/datum/objective/bloodsucker/objective in rolled_objectives)
				objective.owner = owner
				objectives += objective

/// Name shown on antag list
/datum/antagonist/bloodsucker/antag_listing_name()
	return ..() + "([ReturnFullName(TRUE)])"

/// Whatever interesting things happened to the antag admins should know about
/// Include additional information about antag in this part
/datum/antagonist/bloodsucker/antag_listing_status()
	if(owner && !considered_alive(owner))
		return "<font color=red>Final Death</font>"
	return ..()

/*
 *	# Bloodsucker Names
 *
 *	All Bloodsuckers get a name, and gets a better one when they hit Rank 4.
 */

/// Names
/datum/antagonist/bloodsucker/proc/SelectFirstName()
	if(owner.current.gender == MALE)
		bloodsucker_name = pick(
			"Desmond","Rudolph","Dracula","Vlad","Pyotr","Gregor",
			"Cristian","Christoff","Marcu","Andrei","Constantin",
			"Gheorghe","Grigore","Ilie","Iacob","Luca","Mihail","Pavel",
			"Vasile","Octavian","Sorin","Sveyn","Aurel","Alexe","Iustin",
			"Theodor","Dimitrie","Octav","Damien","Magnus","Caine","Abel", // Romanian/Ancient
			"Lucius","Gaius","Otho","Balbinus","Arcadius","Romanos","Alexios","Vitellius", // Latin
			"Melanthus","Teuthras","Orchamus","Amyntor","Axion", // Greek
			"Thoth","Thutmose","Osorkon,","Nofret","Minmotu","Khafra", // Egyptian
			"Dio",
		)
	else
		bloodsucker_name = pick(
			"Islana","Tyrra","Greganna","Pytra","Hilda",
			"Andra","Crina","Viorela","Viorica","Anemona",
			"Camelia","Narcisa","Sorina","Alessia","Sophia",
			"Gladda","Arcana","Morgan","Lasarra","Ioana","Elena",
			"Alina","Rodica","Teodora","Denisa","Mihaela",
			"Svetla","Stefania","Diyana","Kelssa","Lilith", // Romanian/Ancient
			"Alexia","Athanasia","Callista","Karena","Nephele","Scylla","Ursa", // Latin
			"Alcestis","Damaris","Elisavet","Khthonia","Teodora", // Greek
			"Nefret","Ankhesenpep", // Egyptian
		)

/datum/antagonist/bloodsucker/proc/SelectTitle(am_fledgling = 0, forced = FALSE)
	// Already have Title
	if(!forced && bloodsucker_title != null)
		return
	// Titles [Master]
	if(!am_fledgling)
		if(owner.current.gender == MALE)
			bloodsucker_title = pick ("Count","Baron","Viscount","Prince","Duke","Tzar","Dreadlord","Lord","Master")
		else
			bloodsucker_title = pick ("Countess","Baroness","Viscountess","Princess","Duchess","Tzarina","Dreadlady","Lady","Mistress")
		to_chat(owner, span_announce("You have earned a title! You are now known as <i>[ReturnFullName(TRUE)]</i>!"))
	// Titles [Fledgling]
	else
		bloodsucker_title = null

/datum/antagonist/bloodsucker/proc/SelectReputation(am_fledgling = FALSE, forced = FALSE)
	// Already have Reputation
	if(!forced && bloodsucker_reputation != null)
		return

	if(am_fledgling)
		bloodsucker_reputation = pick(
			"Crude","Callow","Unlearned","Neophyte","Novice","Unseasoned",
			"Fledgling","Young","Neonate","Scrapling","Untested","Unproven",
			"Unknown","Newly Risen","Born","Scavenger","Unknowing","Unspoiled",
			"Disgraced","Defrocked","Shamed","Meek","Timid","Broken","Fresh",
		)
	else if(owner.current.gender == MALE && prob(10))
		bloodsucker_reputation = pick("King of the Damned", "Blood King", "Emperor of Blades", "Sinlord", "God-King")
	else if(owner.current.gender == FEMALE && prob(10))
		bloodsucker_reputation = pick("Queen of the Damned", "Blood Queen", "Empress of Blades", "Sinlady", "God-Queen")
	else
		bloodsucker_reputation = pick(
			"Butcher","Blood Fiend","Crimson","Red","Black","Terror",
			"Nightman","Feared","Ravenous","Fiend","Malevolent","Wicked",
			"Ancient","Plaguebringer","Sinister","Forgotten","Wretched","Baleful",
			"Inqisitor","Harvester","Reviled","Robust","Betrayer","Destructor",
			"Damned","Accursed","Terrible","Vicious","Profane","Vile",
			"Depraved","Foul","Slayer","Manslayer","Sovereign","Slaughterer",
			"Forsaken","Mad","Dragon","Savage","Villainous","Nefarious",
			"Inquisitor","Marauder","Horrible","Immortal","Undying","Overlord",
			"Corrupt","Hellspawn","Tyrant","Sanguineous",
		)

	to_chat(owner, span_announce("You have earned a reputation! You are now known as <i>[ReturnFullName(TRUE)]</i>!"))


/datum/antagonist/bloodsucker/proc/AmFledgling()
	return !bloodsucker_title

/datum/antagonist/bloodsucker/proc/ReturnFullName(include_rep = FALSE)

	var/fullname
	// Name First
	fullname = (bloodsucker_name ? bloodsucker_name : owner.current.name)
	// Title
	if(bloodsucker_title)
		fullname = bloodsucker_title + " " + fullname
	// Rep
	if(include_rep && bloodsucker_reputation)
		fullname = fullname + " the " + bloodsucker_reputation

	return fullname

///When a Bloodsucker breaks the Masquerade, they get their HUD icon changed, and Malkavian Bloodsuckers get alerted.
/datum/antagonist/bloodsucker/proc/break_masquerade()
	if(broke_masquerade)
		return
	owner.current.playsound_local(null, 'sound/effects/lunge_warn.ogg', 100, FALSE, pressure_affected = FALSE)
	to_chat(owner.current, span_cultboldtalic("You have broken the Masquerade!"))
	to_chat(owner.current, span_warning("Bloodsucker Tip: When you break the Masquerade, you become open for termination by fellow Bloodsuckers, and your Vassals are no longer completely loyal to you, as other Bloodsuckers can steal them for themselves!"))
	broke_masquerade = TRUE
	antag_hud_name = "masquerade_broken"
	for(var/datum/mind/clan_minds as anything in get_antag_minds(/datum/antagonist/bloodsucker))
		if(owner == clan_minds)
			continue
		if(!isliving(clan_minds.current))
			continue
		to_chat(clan_minds, span_userdanger("[owner.current] has broken the Masquerade! Ensure they are eliminated at all costs!"))
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = clan_minds.has_antag_datum(/datum/antagonist/bloodsucker)
		var/datum/objective/assassinate/masquerade_objective = new /datum/objective/assassinate
		masquerade_objective.target = owner.current
		masquerade_objective.explanation_text = "Ensure [owner.current], who has broken the Masquerade, is Final Death'ed."
		bloodsuckerdatum.objectives += masquerade_objective
		clan_minds.announce_objectives()

///This is admin-only of reverting a broken masquerade, sadly it doesn't remove the Malkavian objectives yet.
/datum/antagonist/bloodsucker/proc/fix_masquerade()
	if(!broke_masquerade)
		return
	antag_hud_name = initial(antag_hud_name)
	to_chat(owner.current, span_cultboldtalic("You have re-entered the Masquerade."))
	broke_masquerade = FALSE


/////////////////////////////////////
//  BLOOD COUNTER & RANK MARKER !  //
/////////////////////////////////////

/datum/antagonist/bloodsucker/proc/remove_hud()
	owner.current.hud_used.blood_display.invisibility = INVISIBILITY_ABSTRACT
	owner.current.hud_used.vamprank_display.invisibility = INVISIBILITY_ABSTRACT
	owner.current.hud_used.sunlight_display.invisibility = INVISIBILITY_ABSTRACT

/// Update Blood Counter + Rank Counter
/datum/antagonist/bloodsucker/proc/update_hud(updateRank = FALSE)
	if(!owner.current.hud_used)
		return
	var/valuecolor
	if(owner.current.hud_used && owner.current.hud_used.blood_display)
		if(owner.current.blood_volume > BLOOD_VOLUME_SAFE)
			valuecolor = "#FFDDDD"
		else if(owner.current.blood_volume > BLOOD_VOLUME_BAD)
			valuecolor = "#FFAAAA"
		owner.current.hud_used.blood_display.update_counter(owner.current.blood_volume, valuecolor)
	if(owner.current.hud_used && owner.current.hud_used.vamprank_display)
		owner.current.hud_used.vamprank_display.update_counter(bloodsucker_level, valuecolor)
		/// Only change icon on special request.
		if(updateRank)
			owner.current.hud_used.vamprank_display.icon_state = (bloodsucker_level_unspent > 0) ? "rank_up" : "rank"

/// Update Sun Time
/datum/antagonist/bloodsucker/proc/update_sunlight(value, amDay = FALSE)
	if(!owner.current.hud_used)
		return
	var/valuecolor
	if(owner.current.hud_used && owner.current.hud_used.sunlight_display)
		var/sunlight_display_icon = "sunlight_"
		if(amDay)
			sunlight_display_icon += "day"
			valuecolor = "#FF5555"
		else
			switch(round(value, 1))
				if(0 to 30)
					sunlight_display_icon += "30"
					valuecolor = "#FFCCCC"
				if(31 to 60)
					sunlight_display_icon += "60"
					valuecolor = "#FFE6CC"
				if(61 to 90)
					sunlight_display_icon += "90"
					valuecolor = "#FFFFCC"
				else
					sunlight_display_icon += "night"
					valuecolor = "#FFFFFF"

		var/value_string = (value >= 60) ? "[round(value / 60, 1)] m" : "[round(value, 1)] s"
		owner.current.hud_used.sunlight_display.update_counter(value_string, valuecolor)
		owner.current.hud_used.sunlight_display.icon_state = sunlight_display_icon

/atom/movable/screen/bloodsucker/blood_counter/update_counter(value, valuecolor)
	..()
	maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[round(value,1)]</font></div>"

/atom/movable/screen/bloodsucker/rank_counter/update_counter(value, valuecolor)
	..()
	maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[round(value,1)]</font></div>"

/atom/movable/screen/bloodsucker/sunlight_counter/update_counter(value, valuecolor)
	..()
	maptext = "<div align='center' valign='bottom' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[value]</font></div>"


/**
 *	# Assigning Bloodsucker status
 *
 *	Here we assign the Bloodsuckers themselves, ensuring they arent Plasmamen
 *	Also deals with Vassalization status.
 */

/datum/mind/proc/can_make_bloodsucker(datum/mind/convertee, datum/mind/converter)
	// Species Must have a HEART (Sorry Plasmamen)
	var/mob/living/carbon/human/user = convertee.current
	if(!(user.dna?.species) || !(user.mob_biotypes & MOB_ORGANIC))
		user.set_species(/datum/species/human)
		user.apply_pref_name("human", user.client)
	// Check for Fledgeling
	if(converter)
		message_admins("[convertee] has become a Bloodsucker, and was created by [converter].")
		log_admin("[convertee] has become a Bloodsucker, and was created by [converter].")
	return TRUE

/datum/mind/proc/make_bloodsucker(datum/mind/bloodsucker)
	if(!can_make_bloodsucker(bloodsucker))
		return FALSE
	add_antag_datum(/datum/antagonist/bloodsucker)
	return TRUE

/datum/mind/proc/remove_bloodsucker()
	var/datum/antagonist/bloodsucker/removed_bloodsucker = has_antag_datum(/datum/antagonist/bloodsucker)
	if(removed_bloodsucker)
		remove_antag_datum(/datum/antagonist/bloodsucker)
		special_role = null

/datum/antagonist/bloodsucker/proc/can_make_vassal(mob/living/converted, datum/mind/converter, can_vassal_sleeping = FALSE)//, check_antag_or_loyal=FALSE)
	// Not Correct Type: Abort
	if(!iscarbon(converted) || !converter)
		return FALSE
	if(converted.stat > UNCONSCIOUS && !can_vassal_sleeping)
		return FALSE
	// No Mind!
	if(!converted.mind)
		to_chat(converter, span_danger("[converted] isn't self-aware enough to be made into a Vassal."))
		return FALSE
	// Already MY Vassal
	var/datum/antagonist/vassal/vassaldatum = converted.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(istype(vassaldatum) && vassaldatum.master)
		if(vassaldatum.master.owner == converter)
			to_chat(converter, span_danger("[converted] is already your loyal Vassal!"))
		else
			to_chat(converter, span_danger("[converted] is the loyal Vassal of another Bloodsucker!"))
		return FALSE
	// Already Antag or Loyal (Vamp Hunters count as antags)
	if(!isnull(converted.mind.enslaved_to) || AmInvalidAntag(converted))
		to_chat(converter, span_danger("[converted] resists the power of your blood to dominate their mind!"))
		return FALSE
	return TRUE

/datum/antagonist/bloodsucker/proc/AmValidAntag(mob/target)
	/// Check if they are an antag, if so, check if they're Invalid.
	if(target.mind?.special_role || !isnull(target.mind?.antag_datums))
		return !AmInvalidAntag(target)
	/// Otherwise, just cancel out.
	return FALSE

/datum/antagonist/bloodsucker/proc/AmInvalidAntag(mob/target)
	/// Not an antag?
	if(!is_special_character(target))
		return FALSE
	/// Checks if the person is an antag banned from being vassalized, stored in bloodsucker's datum.
	for(var/datum/antagonist/antag_datum in target.mind.antag_datums)
		if(antag_datum.type in vassal_banned_antags)
			//message_admins("DEBUG VASSAL: Found Invalid: [antag_datum] // [antag_datum.type]")
			return TRUE
//	message_admins("DEBUG VASSAL: Valid Antags! (total of [target.antag_datums.len])")
	// WHEN YOU DELETE THE ABOVE: Remove the 3 second timer on converting the vassal too.
	return FALSE

/datum/antagonist/bloodsucker/proc/attempt_turn_vassal(mob/living/carbon/convertee, can_vassal_sleeping = FALSE)
	return make_vassal(convertee, owner, can_vassal_sleeping)

/datum/antagonist/bloodsucker/proc/make_vassal(mob/living/convertee, datum/mind/converter, sleeping = FALSE)
	if(!can_make_vassal(convertee, converter, can_vassal_sleeping = sleeping))
		return FALSE
	// Make Vassal
	var/datum/antagonist/vassal/vassaldatum = new(convertee.mind)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = converter.has_antag_datum(/datum/antagonist/bloodsucker)
	vassaldatum.master = bloodsuckerdatum
	convertee.mind.add_antag_datum(vassaldatum, vassaldatum.master.get_team())
	// Update Bloodsucker Title
	bloodsuckerdatum.SelectTitle(am_fledgling = FALSE) // Only works if you have no title yet.
	// Log it
	message_admins("[convertee] has become a Vassal, and is enslaved to [converter].")
	log_admin("[convertee] has become a Vassal, and is enslaved to [converter].")
	return TRUE

/datum/outfit/bloodsucker_outfit
	name = "Bloodsucker outfit (Preview only)"
	suit = /obj/item/clothing/suit/costume/dracula

/datum/outfit/bloodsucker_outfit/post_equip(mob/living/carbon/human/enrico, visualsOnly=FALSE)
	enrico.hairstyle = "Undercut"
	enrico.hair_color = "FFF"
	enrico.skin_tone = "african2"
	enrico.eye_color_left = "#663300"
	enrico.eye_color_right = "#663300"

	enrico.update_body(is_creating = TRUE)

/datum/antagonist/bloodsucker/get_preview_icon()

	var/icon/final_icon = render_preview_outfit(/datum/outfit/bloodsucker_outfit)
	final_icon.Blend(icon('icons/effects/blood.dmi', "uniformblood"), ICON_OVERLAY)

	return finish_preview_icon(final_icon)
