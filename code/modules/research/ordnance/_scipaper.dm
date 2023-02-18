/// Scientific paper datum for retrieval and re-reading. A lot of the variables are there for fluff & flavor.
/datum/scientific_paper
	/// The title of our paper.
	var/title
	/// The principal author of our paper.
	var/author
	/// Whether this paper is co-authored or not.
	var/et_alia = FALSE
	/// Abstract.
	var/abstract
	/// The coop and funding gains from the paper.
	var/list/gains
	/// Experiment typepath.
	var/datum/experiment/ordnance/experiment_path
	/// The main "score" of a particular experiment.
	var/tracked_variable
	/**
	  * Derived from tracked_variable. Used for indexing and to reduce duplicates.
	  * Only one paper can be published in each tier for each experiment.
	*/
	var/tier
	/// The selected sponsor for our paper. Pathtype form.
	var/datum/scientific_partner/partner_path

/datum/scientific_paper/New()
	. = ..()
	set_amount()

/**
 * Calculate the gains of an experiment.
 * Gain calculation follows a sigmoid curve.
 * f(x) = L / (1+e^(-k(x-xo)))
 * L is the upper limit. This should be the gain variable * 2.
 * k is the steepness.
 * x0 is the midpoint.
 * x is our tracked variable.
 * Returns the expected value of that tier.
 */
/datum/scientific_paper/proc/calculate_gains(calculated_tier)
	if(!experiment_path || !tracked_variable)
		return FALSE

	var/datum/experiment/ordnance/initialized_experiment = locate(experiment_path) in SSresearch.ordnance_experiments
	var/gain = initialized_experiment.gain[calculated_tier]
	var/target_amount = initialized_experiment.target_amount[calculated_tier]
	/// Steepness is calculated so that f(x=0) is always 1.
	var/steepness = log(gain*2 - 1) / target_amount
	var/calculated_gain = gain*2 / (1+NUM_E**(-steepness*(tracked_variable-target_amount)))
	return calculated_gain

/// Determine which tier can we publish at. Lower limit for an allowed tier is 10% of gain. Empty list if none are allowed.
/datum/scientific_paper/proc/calculate_tier()
	var/list/allowed_tiers = list()
	if(!experiment_path || !tracked_variable)
		return allowed_tiers
	var/datum/experiment/ordnance/initialized_experiment = locate(experiment_path) in SSresearch.ordnance_experiments
	for (var/each_tier in 1 to min(length(initialized_experiment.target_amount), length(initialized_experiment.gain)))
		var/calculated_gain = calculate_gains(each_tier)
		if(calculated_gain > 0.1 * initialized_experiment.gain[each_tier])
			allowed_tiers += each_tier
	return allowed_tiers

/**
 * Experiment -> Tier -> Gains
 * Experiment -> Partners -> Gains
 * Changing anything in the chain means those following it should be recounted.
 */

/**
 * Used when assigning an experiment to a specific paper.
 * Failing to provide a proper path, a tracked variable, or a correct data should null every non-fluff data.
 * Implement this in the children procs.
 */
/datum/scientific_paper/proc/set_experiment(ex_path = null, variable = null, data = null)
	return

/// Sets a tier for us. Nulls the tier when called without args.  Re-counts the amount.
/datum/scientific_paper/proc/set_tier(assigned_tier = null)
	tier = null
	if(assigned_tier && (assigned_tier in calculate_tier()))
		tier = assigned_tier
	set_amount()

/** Sets a specific partner for our paper. Partners give money and boost points.
 * Partners exist separately from experiments and wont need to be reset every time something changes.
 */
/datum/scientific_paper/proc/set_partner(new_partner = null)
	partner_path = null
	if(ispath(new_partner, /datum/scientific_partner))
		var/datum/scientific_partner/partner = locate(new_partner) in SSresearch.scientific_partners
		if(experiment_path in partner.accepted_experiments)
			partner_path = new_partner
	set_amount()

/** Does the counting for gains.
 * Call this whenever experiments/tier/partners are changed.
 * Handled automatically, calling this proc externally shouldn't be necessary.
 * Also doubles as an initialization for the gains list.
 */
/datum/scientific_paper/proc/set_amount()
	gains = list(SCIPAPER_COOPERATION_INDEX = 0, SCIPAPER_FUNDING_INDEX = 0)
	if(!tier || !experiment_path || !tracked_variable)
		return FALSE
	var/gain = calculate_gains(tier)
	for (var/gain_type in 1 to gains.len)
		gains[gain_type] = gain
		if(!partner_path)
			continue
		var/datum/scientific_partner/partner = locate(partner_path) in SSresearch.scientific_partners
		gains[gain_type] *= partner.multipliers[gain_type]

/** Fully check if our paper have all the required variables, and prevent duplicate papers being published in the same tier.
 * Things to check: tier, gain, and partner here. ex_path and record datums in subtypes.
 */
/datum/scientific_paper/proc/allowed_to_publish(datum/techweb/techweb_to_check)
	if(!tier || !gains || !partner_path || (0 in gains))
		return FALSE
	return !techweb_to_check.published_papers[experiment_path][tier]

/datum/scientific_paper/proc/publish_paper(datum/techweb/techweb_to_publish)
	autofill()
	techweb_to_publish.published_papers[experiment_path][tier] = src
	techweb_to_publish.scientific_cooperation[partner_path] += gains[SCIPAPER_COOPERATION_INDEX]
	if(istype(techweb_to_publish, /datum/techweb/science))
		var/datum/bank_account/dept_budget = SSeconomy.get_dep_account(ACCOUNT_SCI)
		if(dept_budget)
			dept_budget.adjust_money(gains[SCIPAPER_FUNDING_INDEX] * SCIPAPER_GAIN_TO_MONEY)

/**
 * Clones into a new paper type.
 * Important (non-fluff) variables will be carried over and should be cleaned with set_experiment by whoever is calling this.
 *
 * clone_into your own typepath will be like a normal clone.
 *
 * If you want to subtype this, do it in a way that doesn't mess with the type change.
 */
/datum/scientific_paper/proc/clone_into(typepath)
	var/datum/scientific_paper/new_paper = new typepath
	new_paper.title = title
	new_paper.author = author
	new_paper.et_alia = et_alia
	new_paper.abstract = abstract
	new_paper.gains = gains
	new_paper.experiment_path = experiment_path
	new_paper.tracked_variable = tracked_variable
	new_paper.tier = tier
	new_paper.partner_path = partner_path
	return new_paper

/// Returns the formatted, readable gist of our paper in a list.
/datum/scientific_paper/proc/return_gist()
	var/list/gist = list()
	var/list/transcripted_gains = list(SCIPAPER_COOPERATION_INDEX, SCIPAPER_FUNDING_INDEX)
	for (var/index in 1 to transcripted_gains.len)
		if (!gains)
			transcripted_gains[index] = "None"
			continue
		switch (round(gains[index]))
			if(-INFINITY to 0)
				transcripted_gains[index] = "None"
			if(1 to 24)
				transcripted_gains[index] = "Little"
			if(25 to 49)
				transcripted_gains[index] = "Moderate"
			if(50 to 99)
				transcripted_gains[index] = "Significant"
			if(100 to INFINITY)
				transcripted_gains[index] = "Huge"
			else
				transcripted_gains[index] = "Undefined"
	gist["gains"] = transcripted_gains
	gist["title"] = title
	gist["author"] = author
	gist["etAlia"] = et_alia
	gist["abstract"] = abstract
	gist["experimentName"] = initial(experiment_path?.name)
	gist["tier"] = tier
	gist["partner"] = initial(partner_path?.name)
	return gist

/datum/scientific_paper/proc/autofill()
	if(!title)
		title = "On [initial(experiment_path.name)] - [tier]"
	if(!author)
		author = "Unknown"
		et_alia = FALSE
	if(!abstract)
		abstract = "Published on [station_time_timestamp()]"

/datum/scientific_paper/explosive
	/**
	 * Used to check explosive experiments that needs to be unique.
	 * References a tachyon record where applicable.
	*/
	var/datum/data/tachyon_record/explosion_record

/// Check if our explosion has already been published and whether the experiment path is correct or not.
/datum/scientific_paper/explosive/allowed_to_publish(datum/techweb/techweb_to_check)
	if(!ispath(experiment_path, /datum/experiment/ordnance/explosive))
		return FALSE
	if(!istype(explosion_record))
		return FALSE
	var/list/published_papers = techweb_to_check.published_papers
	for(var/experiment_path in published_papers)
		for(var/datum/scientific_paper/explosive/papers in published_papers[experiment_path])
			var/datum/data/tachyon_record/record_to_check = papers.explosion_record
			if(explosion_record.explosion_identifier == record_to_check.explosion_identifier)
				return FALSE
	return ..()

/datum/scientific_paper/explosive/set_experiment(ex_path = null, variable = null, data = null)
	if(!ispath(ex_path, /datum/experiment/ordnance/explosive) || !variable || !istype(data, /datum/data/tachyon_record))
		experiment_path = null
		tracked_variable = null
		explosion_record = null
	else
		experiment_path = ex_path
		tracked_variable = variable
		explosion_record = data

	set_tier()
	set_partner()

/datum/scientific_paper/explosive/clone_into(typepath)
	if(typepath != type)
		return ..()

	var/datum/scientific_paper/explosive/new_paper = ..(typepath)
	new_paper.explosion_record = explosion_record
	return new_paper

/datum/scientific_paper/gaseous
	var/datum/data/compressor_record/compressor_record

/**
 * Check if our record datum is a duplicate or no.
 * No index number is necessary because compressor records cant be replicated.
 * Also checks the experiment path.
 */
/datum/scientific_paper/gaseous/allowed_to_publish(datum/techweb/techweb_to_check)
	if(!ispath(experiment_path, /datum/experiment/ordnance/gaseous))
		return FALSE
	if(!istype(compressor_record))
		return FALSE
	var/list/published_papers = techweb_to_check.published_papers
	for(var/experiment_path in published_papers)
		for(var/datum/scientific_paper/gaseous/papers in published_papers[experiment_path])
			if(compressor_record == papers.compressor_record)
				return FALSE
	. = ..()

/datum/scientific_paper/gaseous/set_experiment(ex_path = null, variable = null, data = null)
	var/invalid = FALSE

	invalid = invalid || !ispath(ex_path, /datum/experiment/ordnance/gaseous)
	invalid = invalid || !variable
	invalid = invalid || !istype(data, /datum/data/compressor_record)

	if(invalid)
		experiment_path = null
		tracked_variable = null
		compressor_record = null
	else
		experiment_path = ex_path
		tracked_variable = variable
		compressor_record = data

	set_tier()
	set_partner()

/datum/scientific_paper/gaseous/clone_into(typepath)
	if(typepath != type)
		return ..()

	var/datum/scientific_paper/gaseous/new_paper = ..(typepath)
	new_paper.compressor_record = compressor_record
	return new_paper

/// Various informations on companies/scientific programs/journals etc that the players can sign on to.
/datum/scientific_partner
	/// Name of the partner, shown in the Science program's UI.
	var/name
	/// Brief explanation of the associated program. Can be used for lore.
	var/flufftext
	/// Cash and renown multiplier for allying with this partner.
	var/list/multipliers = list(SCIPAPER_COOPERATION_INDEX = 1, SCIPAPER_FUNDING_INDEX = 1)
	/// List of ordnance experiments that our partner is willing to accept. If this list is not filled it means the partner will accept everything.
	var/list/accepted_experiments = list()
	/// Associative list of which technology the partner might be able to boost and by how much.
	var/list/boosted_nodes = list()


/datum/scientific_partner/proc/purchase_boost(datum/techweb/purchasing_techweb, datum/techweb_node/node)
	if(!allowed_to_boost(purchasing_techweb, node.id))
		return FALSE
	purchasing_techweb.boost_techweb_node(node, list(TECHWEB_POINT_TYPE_GENERIC=boosted_nodes[node.id]))
	purchasing_techweb.scientific_cooperation[type] -= boosted_nodes[node.id] * SCIENTIFIC_COOPERATION_PURCHASE_MULTIPLIER
	return TRUE

/datum/scientific_partner/proc/allowed_to_boost(datum/techweb/purchasing_techweb, node_id)
	if(purchasing_techweb.scientific_cooperation[type] < (boosted_nodes[node_id] * SCIENTIFIC_COOPERATION_PURCHASE_MULTIPLIER)) // Too expensive
		return FALSE
	if(!(node_id in purchasing_techweb.get_available_nodes())) // Not currently available
		return FALSE
	if((TECHWEB_POINT_TYPE_GENERIC in purchasing_techweb.boosted_nodes[node_id]) && (purchasing_techweb.boosted_nodes[node_id][TECHWEB_POINT_TYPE_GENERIC] >= boosted_nodes[node_id])) // Already bought or we have a bigger discount
		return FALSE
	return TRUE
