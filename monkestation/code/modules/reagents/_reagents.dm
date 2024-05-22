/datum/reagent
	/// What can process this? ORGANIC, SYNTHETIC, or ORGANIC | SYNTHETIC?. We'll assume by default that it affects organics.
	var/process_flags = ORGANIC
	/// Is this chemical exempt from istype restrictions?
	var/bypass_restriction = FALSE
	/// Chemicals that aren't typepathed but are useless so we remove.
	var/restricted = FALSE
	/// The weight of the reagent to use when randomly selecting a reagent.
	var/random_weight = 10
