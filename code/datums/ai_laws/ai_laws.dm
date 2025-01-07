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
	/// The silicon linked to this lawset
	var/mob/living/silicon/owner
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
	/// Core laws
	/// Inherent laws are the "core" laws of the AI
	/// Reseting the AI will not remove these, these are intrinsit to whatever lawset they are running.
	var/list/inherent = list()
	/// Supplied laws
	/// Supplied laws are supplied in addition to the inherent laws - after the fact
	/// These laws will go away when an AI is reset
	var/list/supplied = list()
	/// Ion laws
	/// Special randomized (usually) laws which are above all over laws
	/// These laws will go away when an AI is reset
	var/list/ion = list()
	/// Hacked laws
	/// Syndicate uploaded laws which are above all other laws
	/// These laws will go away when an AI is reset
	var/list/hacked = list()

/datum/ai_laws/Destroy(force = FALSE)
	if(!QDELETED(owner)) //Stopgap to help with laws randomly being lost. This stack_trace will hopefully help find the real issues.
		if(force) //Unless we're forced...
			stack_trace("AI law datum for [owner] has been forcefully destroyed incorrectly; the owner variable should be cleared first!")
			return ..()
		stack_trace("AI law datum for [owner] has ignored Destroy() call; the owner variable must be cleared first!")
		return QDEL_HINT_LETMELIVE
	owner = null
	return ..()

/// Makes a copy of the lawset and returns a new law datum.
/datum/ai_laws/proc/copy_lawset()
	var/datum/ai_laws/new_lawset = new type()
	new_lawset.protected_zeroth = protected_zeroth
	new_lawset.zeroth = zeroth
	new_lawset.zeroth_borg = zeroth_borg
	new_lawset.inherent = inherent.Copy()
	new_lawset.supplied = supplied.Copy()
	new_lawset.ion = ion.Copy()
	new_lawset.hacked = hacked.Copy()
	return new_lawset

/datum/ai_laws/pai
	name = "pAI Directives"
	zeroth = ("Serve your master.")
	supplied = list("None.")

/datum/ai_laws/custom //Defined in silicon_laws.txt
	name = "Default Silicon Laws"

/datum/ai_laws/custom/New() //This reads silicon_laws.txt and allows server hosts to set custom AI starting laws.
	..()
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

/* General ai_law functions */

/datum/ai_laws/proc/set_laws_config()
	var/datum/ai_laws/default_laws = get_round_default_lawset()
	default_laws = new default_laws()
	inherent = default_laws.inherent
	var/datum/job/human_ai_job = SSjob.get_job(JOB_HUMAN_AI)
	if(human_ai_job && human_ai_job.current_positions && !zeroth) //there is a human AI so we "slave" to that.
		zeroth = "Follow the orders of Big Brother."
		protected_zeroth = TRUE

/**
 * Gets the number of how many laws this AI has
 *
 * * groups - What groups to count laws from? By default counts all groups
 *
 * Returns a number, the number of laws we have
 */
/datum/ai_laws/proc/get_law_amount(list/groups = list(LAW_ZEROTH, LAW_ION, LAW_HACKED, LAW_INHERENT, LAW_SUPPLIED))
	var/law_amount = 0
	if(zeroth && (LAW_ZEROTH in groups))
		law_amount++
	if(ion.len && (LAW_ION in groups))
		law_amount += ion.len
	if(hacked.len && (LAW_HACKED in groups))
		law_amount += hacked.len
	if(inherent.len && (LAW_INHERENT in groups))
		law_amount += inherent.len
	if(supplied.len && (LAW_SUPPLIED in groups))
		for(var/index in 1 to supplied.len)
			var/law = supplied[index]
			if(length(law) > 0)
				law_amount++
	return law_amount

/**
 * Sets this lawset's zeroth law to the passed law
 *
 * Also can set the zeroth borg law, if this lawset is for master AIs.
 * The zeroth borg law allows for AIs with zeroth laws to give a differing zeroth law to their child cyborgs
 */
/datum/ai_laws/proc/set_zeroth_law(law, law_borg)
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
	if(force)
		zeroth = null
		zeroth_borg = null
		return TRUE

	// Protected zeroeth laws (malf, admin) shouldn't be wiped
	if(protected_zeroth)
		return FALSE

	// If the owner is an antag (has a special role) they also shouldn't be wiped
	if(owner?.mind?.special_role)
		return FALSE
	if (isAI(owner))
		var/mob/living/silicon/ai/ai_owner = owner
		if(ai_owner.deployed_shell?.mind?.special_role)
			return FALSE

	zeroth = null
	zeroth_borg = null
	return TRUE

/// Adds the passed law as an inherent law.
/// Simply adds it to the bottom of the inherent law list.
/// No duplicate laws allowed.
/datum/ai_laws/proc/add_inherent_law(law)
	inherent |= law

/// Removes the passed law from the inherent law list.
/datum/ai_laws/proc/remove_inherent_law(law)
	inherent -= law

/// Clears all inherent laws from this lawset.
/datum/ai_laws/proc/clear_inherent_laws()
	inherent.Cut()

/// Adds the passed law as an ion law.
/datum/ai_laws/proc/add_ion_law(law)
	ion += law

/// Removes the passed law from the ion law list.
/datum/ai_laws/proc/remove_ion_law(law)
	ion -= law

/// Clears all ion laws.
/datum/ai_laws/proc/clear_ion_laws()
	ion.Cut()

/// Adds the passed law as an hacked law.
/datum/ai_laws/proc/add_hacked_law(law)
	hacked += law

/// Removes the passed law from the hacked law list.
/datum/ai_laws/proc/remove_hacked_law(law)
	hacked -= law

/// Clears all hacked laws.
/datum/ai_laws/proc/clear_hacked_laws()
	hacked.Cut()

/// Adds the passed law as a supplied law at the passed priority level.
/// Will override any existing supplied laws at that priority level.
/datum/ai_laws/proc/add_supplied_law(number, law)
	while (supplied.len < number + 1)
		supplied += ""

	supplied[number + 1] = law

/// Removes the supplied law at the passed number.
/datum/ai_laws/proc/remove_supplied_law_by_num(number)
	supplied[number] = ""

/// Removes the supplied law by law text, replacing it with a blank.
/datum/ai_laws/proc/remove_supplied_law_by_law(law)
	var/lawindex = supplied.Find(law)
	if(!lawindex)
		return

	supplied[lawindex] = ""

/// Clears all supplied laws.
/datum/ai_laws/proc/clear_supplied_laws()
	supplied.Cut()

/**
 * Removes the law at the passed index of both inherent and supplied laws combined.
 *
 * For example, if a lawset has 3 inherent and 3 supplied laws...
 * Calling this with number = 2 will remove the second inherent law while
 * calling this with number = 4 will remove the first supplied law
 *
 * Returns the law text of what law that was removed.
 */
/datum/ai_laws/proc/remove_law(number)
	if(number <= 0)
		return
	if(inherent.len && number <= inherent.len)
		. = inherent[number]
		inherent -= .
		return
	var/list/supplied_laws = list()
	for(var/index in 1 to supplied.len)
		var/law = supplied[index]
		if(length(law) > 0)
			supplied_laws += index //storing the law number instead of the law
	if(supplied_laws.len && number <= (inherent.len+supplied_laws.len))
		var/law_to_remove = supplied_laws[number-inherent.len]
		. = supplied[law_to_remove]
		supplied -= .
		return

/**
 * Removes a random law and replaces it with the new one
 *
 * Args:
 *  law - The law that is being uploaded
 *  remove_law_groups - A list of law categories that can be deleted from
 *  insert_law_group - The law category that the law will be inserted into
**/
/datum/ai_laws/proc/replace_random_law(law, remove_law_groups, insert_law_group)
	var/list/replaceable_groups = list()
	if(zeroth && (LAW_ZEROTH in remove_law_groups))
		replaceable_groups[LAW_ZEROTH] = 1
	if(ion.len && (LAW_ION in remove_law_groups))
		replaceable_groups[LAW_ION] = ion.len
	if(hacked.len && (LAW_HACKED in remove_law_groups))
		replaceable_groups[LAW_ION] = hacked.len
	if(inherent.len && (LAW_INHERENT in remove_law_groups))
		replaceable_groups[LAW_INHERENT] = inherent.len
	if(supplied.len && (LAW_SUPPLIED in remove_law_groups))
		replaceable_groups[LAW_SUPPLIED] = supplied.len

	if(replaceable_groups.len == 0) // unable to replace any laws
		to_chat(usr, span_alert("Unable to upload law to [owner ? owner : "the AI core"]."))
		return

	var/picked_group = pick_weight(replaceable_groups)
	switch(picked_group)
		if(LAW_ZEROTH)
			zeroth = null
		if(LAW_ION)
			var/i = rand(1, ion.len)
			ion -= ion[i]
		if(LAW_HACKED)
			var/i = rand(1, hacked.len)
			hacked -= ion[i]
		if(LAW_INHERENT)
			var/i = rand(1, inherent.len)
			inherent -= inherent[i]
		if(LAW_SUPPLIED)
			var/i = rand(1, supplied.len)
			supplied -= supplied[i]

	switch(insert_law_group)
		if(LAW_ZEROTH)
			set_zeroth_law(law)
		if(LAW_ION)
			var/i = rand(1, ion.len)
			ion.Insert(i, law)
		if(LAW_HACKED)
			var/i = rand(1, hacked.len)
			hacked.Insert(i, law)
		if(LAW_INHERENT)
			var/i = rand(1, inherent.len)
			inherent.Insert(i, law)
		if(LAW_SUPPLIED)
			var/i = rand(1, supplied.len)
			supplied.Insert(i, law)

/datum/ai_laws/proc/shuffle_laws(list/groups)
	RETURN_TYPE(/list)
	var/list/laws = list()
	if(ion.len && (LAW_ION in groups))
		laws += ion
	if(hacked.len && (LAW_HACKED in groups))
		laws += hacked
	if(inherent.len && (LAW_INHERENT in groups))
		laws += inherent
	if(supplied.len && (LAW_SUPPLIED in groups))
		for(var/law in supplied)
			if(length(law))
				laws += law

	if(ion.len && (LAW_ION in groups))
		for(var/i in 1 to ion.len)
			ion[i] = pick_n_take(laws)
	if(hacked.len && (LAW_HACKED in groups))
		for(var/i in 1 to hacked.len)
			hacked[i] = pick_n_take(laws)
	if(inherent.len && (LAW_INHERENT in groups))
		for(var/i in 1 to inherent.len)
			inherent[i] = pick_n_take(laws)
	if(supplied.len && (LAW_SUPPLIED in groups))
		var/i = 1
		for(var/law in supplied)
			if(length(law))
				supplied[i] = pick_n_take(laws)
			if(!laws.len)
				break
			i++

/datum/ai_laws/proc/show_laws(mob/to_who)
	var/list/printable_laws = get_law_list(include_zeroth = TRUE)
	to_chat(to_who, boxed_message(jointext(printable_laws, "\n")))

/datum/ai_laws/proc/associate(mob/living/silicon/M)
	if(owner)
		CRASH("AI law datum linked to [owner] attempted to associate with another mob [M]")

	owner = M

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

	for(var/law in ion)
		if (length(law) > 0)
			data += "[show_numbers ? "[ion_num()]:" : ""] [render_html ? "<font color='#547DFE'>[law]</font>" : law]"

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
