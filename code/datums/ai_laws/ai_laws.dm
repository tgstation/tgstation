#define AI_LAWS_ASIMOV "asimov"

/// See [/proc/get_round_default_lawset], do not get directily.
/// This is the default lawset for silicons.
GLOBAL_VAR(round_default_lawset)

/**
 * A getter that sets up the round default if it has not been yet.
 *
 * round_default_lawset is what is considered the default for the round. Aka, new AI and other silicons would get this.
 * You might recognize the fact that 99% of the time it is asimov.
 *
 * This requires config, so it is generated at the first request to use this var.
 */
/proc/get_round_default_lawset()
	if(!GLOB.round_default_lawset)
		GLOB.round_default_lawset = setup_round_default_laws()
	return GLOB.round_default_lawset

//different settings for configured defaults

/// Always make the round default asimov
#define CONFIG_ASIMOV 0
/// Set to a custom lawset defined by another config value
#define CONFIG_CUSTOM 1
/// Set to a completely random ai law subtype, good, bad, it cares not. Careful with this one
#define CONFIG_RANDOM 2
/// Set to a configged weighted list of law types in the config. This lets server owners pick from a pool of sane laws, it is also the same process for ian law rerolls.
#define CONFIG_WEIGHTED 3
/// Set to a specific lawset in the game options.
#define CONFIG_SPECIFIED 4

///first called when something wants round default laws for the first time in a round, considers config
///returns a law datum that GLOB._round_default_lawset will be set to.
/proc/setup_round_default_laws()
	var/list/law_ids = CONFIG_GET(keyed_list/random_laws)
	var/list/specified_law_ids = CONFIG_GET(keyed_list/specified_laws)

	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNIQUE_AI))
		return pick_weighted_lawset()

	switch(CONFIG_GET(number/default_laws))
		if(CONFIG_ASIMOV)
			return /datum/ai_laws/default/asimov
		if(CONFIG_SPECIFIED)
			var/list/specified_laws = list()
			for (var/law_id in specified_law_ids)
				var/datum/ai_laws/laws = lawid_to_type(law_id)
				if (isnull(laws))
					log_config("ERROR: Specified law [law_id] does not exist!")
					continue
				specified_laws += laws
			var/datum/ai_laws/lawtype
			if(specified_laws.len)
				lawtype = pick(specified_laws)
			else
				lawtype = pick(subtypesof(/datum/ai_laws/default))

			return lawtype
		if(CONFIG_CUSTOM)
			return /datum/ai_laws/custom
		if(CONFIG_RANDOM)
			var/list/randlaws = list()
			for(var/lpath in subtypesof(/datum/ai_laws))
				var/datum/ai_laws/L = lpath
				if(initial(L.id) in law_ids)
					randlaws += lpath
			var/datum/ai_laws/lawtype
			if(randlaws.len)
				lawtype = pick(randlaws)
			else
				lawtype = pick(subtypesof(/datum/ai_laws/default))

			return lawtype
		if(CONFIG_WEIGHTED)
			return pick_weighted_lawset()

///returns a law datum based off of config. will never roll asimov as the weighted datum if the station has a unique AI.
/proc/pick_weighted_lawset()
	var/datum/ai_laws/lawtype
	var/list/law_weights = CONFIG_GET(keyed_list/law_weight)
	var/list/specified_law_ids = CONFIG_GET(keyed_list/specified_laws)

	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNIQUE_AI))
		switch(CONFIG_GET(number/default_laws))
			if(CONFIG_ASIMOV)
				law_weights -= AI_LAWS_ASIMOV
			if(CONFIG_CUSTOM)
				law_weights -= specified_law_ids

	while(!lawtype && law_weights.len)
		var/possible_id = pick_weight(law_weights)
		lawtype = lawid_to_type(possible_id)
		if(!lawtype)
			law_weights -= possible_id
			WARNING("Bad lawid in game_options.txt: [possible_id]")

	if(!lawtype)
		WARNING("No LAW_WEIGHT entries.")
		lawtype = /datum/ai_laws/default/asimov

	return lawtype

///returns the law datum with the lawid in question, law boards and law datums should share this id.
/proc/lawid_to_type(lawid)
	var/all_ai_laws = subtypesof(/datum/ai_laws)
	for(var/al in all_ai_laws)
		var/datum/ai_laws/ai_law = al
		if(initial(ai_law.id) == lawid)
			return ai_law
	return null

/datum/ai_laws
	/// The name of the lawset
	var/name = "Unknown Laws"
	/// The ID of this lawset, pretty much only used to tell if we're default or not
	var/id = DEFAULT_AI_LAWID

	/// If TRUE, the zeroth law of this AI is protected and cannot be removed by players under normal circumstances.
	var/protected_zeroth = FALSE

	/// Zeroth law
	/// A lawset can only have 1 zeroth law, it's the top dog.
	/// Removed by things that remove core/inherent laws, but only if protected_zeroth is false. Otherwise, cannot be removed except by admins
	var/zeroth = null
	/// Zeroth borg law
	/// It's just a zeroth law but specially themed for cyborgs
	/// ("follow your master" vs "accomplish your objectives")
	var/zeroth_borg = null
	/// Core Laws
	/// These laws are usually applied by an ai lawset, or a law rack
	var/list/inherent = list()
	/// Supplied laws
	/// These laws are usually applied by adminbus or niche circumstances
	/// In the case of AIs, they will always stick around, law rack or no
	var/list/supplied = list()
	/// Hacked laws
	/// Can be supplied by a law rack, or can be added naturally
	/// Their priority is always pushed above inherent laws
	var/list/hacked = list()

/// Makes a copy of the lawset and returns a new law datum.
/datum/ai_laws/proc/copy_lawset()
	var/datum/ai_laws/new_lawset = new type()
	new_lawset.protected_zeroth = protected_zeroth
	new_lawset.zeroth = zeroth
	new_lawset.zeroth_borg = zeroth_borg
	new_lawset.inherent = inherent.Copy()
	new_lawset.supplied = supplied.Copy()
	new_lawset.hacked = hacked.Copy()
	return new_lawset

/// Applies all laws from this lawset to the passed lawset, treating it as if it was a cyborg lawset
/datum/ai_laws/proc/ai_to_cyborg(datum/ai_laws/cyborg_laws)
	cyborg_laws.protected_zeroth = protected_zeroth
	cyborg_laws.zeroth = zeroth_borg || zeroth
	cyborg_laws.inherent = inherent.Copy()
	cyborg_laws.supplied = supplied.Copy()
	cyborg_laws.hacked = hacked.Copy()

/datum/ai_laws/pai
	name = "pAI Directives"
	zeroth = "Serve your master."
	inherent = list()

/datum/ai_laws/custom //Defined in silicon_laws.txt
	name = "Default Silicon Laws"
	id = "config_custom"

/datum/ai_laws/custom/New() //This reads silicon_laws.txt and allows server hosts to set custom AI starting laws.
	. = ..()
	for(var/line in world.file2list("[global.config.directory]/silicon_laws.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue

		add_inherent_law(line)

	if(!inherent.len) //Failsafe to prevent lawless AIs being created.
		log_silicon("AI created with empty custom laws, laws set to Asimov. Please check silicon_laws.txt.")
		add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
		add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
		add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
		WARNING("Invalid custom AI laws, check silicon_laws.txt")
		return

/**
 * Sets this lawset's zeroth law to the passed law
 *
 * Also can set the zeroth borg law, if this lawset is for master AIs.
 * The zeroth borg law allows for AIs with zeroth laws to give a differing zeroth law to their child cyborgs
 */
/datum/ai_laws/proc/set_zeroth_law(law, law_borg, force = FALSE)
	if(zeroth && !force && protected_zeroth)
		return
	zeroth = law
	if(law_borg) //Making it possible for slaved borgs to see a different law 0 than their AI. --NEO
		zeroth_borg = law_borg

/**
 * Unsets the zeroth (and zeroth borg) law from this lawset
 *
 * This will NOT unset a malfunctioning AI's zero law if force is not true
 *
 * Returns TRUE on success, or false otherwise
 */
/datum/ai_laws/proc/clear_zeroth_law(force = FALSE)
	// Protected zeroeth laws (malf, admin) shouldn't be wiped
	if(!force && protected_zeroth)
		return FALSE

	protected_zeroth = FALSE
	zeroth = null
	zeroth_borg = null
	return TRUE

/// Adds the passed law as an inherent law.
/// Can optionally be supplied an index to insert the law at.
/// No duplicate laws allowed.
/datum/ai_laws/proc/add_inherent_law(law, index)
	if(isnull(index) || index > length(inherent))
		inherent |= law
		return
	if(law in inherent)
		inherent -= law
	inherent.Insert(index, law)

/// Removes the passed law from the inherent law list.
/datum/ai_laws/proc/remove_inherent_law(law)
	inherent -= law

/// Clears all inherent laws from this lawset.
/datum/ai_laws/proc/clear_inherent_laws()
	inherent.Cut()

/// Adds the passed law as an hacked law.
/datum/ai_laws/proc/add_hacked_law(law)
	hacked += law

/// Removes the passed law from the hacked law list.
/datum/ai_laws/proc/remove_hacked_law(law)
	hacked -= law

/// Clears all hacked laws.
/datum/ai_laws/proc/clear_hacked_laws()
	hacked.Cut()

/datum/ai_laws/proc/add_supplied_law(law)
	supplied += law

/datum/ai_laws/proc/remove_supplied_law(law)
	supplied -= law

/// Clears all supplied laws.
/datum/ai_laws/proc/clear_supplied_laws()
	supplied.Cut()

/datum/ai_laws/proc/show_laws(mob/to_who)
	var/list/printable_laws = get_law_list(include_zeroth = TRUE)
	to_chat(to_who, boxed_message(jointext(printable_laws, "\n")))

/**
 * Generates a list of all laws on this datum, including rendered HTML tags if required
 *
 * Arguments:
 * * include_zeroth - Operator that controls if law 0 or law 666 is returned in the set
 * * show_numbers - Operator that controls if law numbers are prepended to the returned laws
 * * render_html - Operator controlling if HTML tags are rendered on the returned laws
 */
/datum/ai_laws/proc/get_law_list(include_zeroth = FALSE, show_numbers = TRUE, render_html = TRUE)
	var/list/data = list()

	if (include_zeroth && zeroth)
		data += "[show_numbers ? "0:" : ""] [render_html ? "<font color='#ff0000'><b>[zeroth]</b></font>" : zeroth]"

	for(var/law in hacked)
		if (length(law) > 0)
			data += "[show_numbers ? "[ion_num()]:" : ""] [render_html ? "<font color='#c00000'>[law]</font>" : law]"

	var/number = 1
	for(var/law in inherent)
		if (length(law) > 0)
			data += "[show_numbers ? "[number]:" : ""] [law]"
			number++

	for(var/law in supplied)
		if (length(law) > 0)
			data += "[show_numbers ? "[number]:" : ""] [render_html ? "<font color='#990099'>[law]</font>" : law]"
			number++
	return data

#undef AI_LAWS_ASIMOV
#undef CONFIG_ASIMOV
#undef CONFIG_CUSTOM
#undef CONFIG_RANDOM
#undef CONFIG_SPECIFIED
#undef CONFIG_WEIGHTED
