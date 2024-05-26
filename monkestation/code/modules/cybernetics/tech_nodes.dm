
/datum/techweb_node/ntlink_low
	id = "ntlink_low"
	display_name = "Cybernetic Application"
	description = "Creation of NT-secure basic cyberlinks for low-grade cybernetic augmentation"
	prereq_ids = list("adv_biotech","adv_biotech", "datatheory")
	design_ids = list("ci-nt_low", "ci-cyberconnector")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/ntlink_high
	id = "ntlink_high"
	display_name = "Advanced Cybernetic Application"
	description = "Creation of NT-secure advanced cyberlinks for high-grade cybernetic augmentation"
	prereq_ids = list("ntlink_low", "adv_cyber_implants","high_efficiency")
	design_ids = list("ci-nt_high")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

/datum/techweb_node/job_approved_item_set
	id = "job_itemsets"
	display_name = "NT Approved Job Item Sets"
	description = "A list of approved item sets that can be implanted into the crew to allow easier access to their tools."
	prereq_ids = list("adv_biotech","adv_biotech", "datatheory")
	design_ids = list(
		"ci-set-cook",
		"ci-set-janitor",
		"ci-set-detective",
		"ci-set-chemical",
		"ci-set-atmospherics",
		"ci-set-connector",
		"ci-set-botany",
		"ci-set-mining",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/security_authorized_implants
	id = "job_itemsets-sec"
	display_name = "NT Approved Security Implants"
	description = "A list of approved item sets that can be implanted into the crew to allow easier access to their tools."
	prereq_ids = "A list of approved implants for security officers."
	prereq_ids = list("ntlink_high")
	design_ids = list(
		"ci-set-mantis",
		"ci-set-combat",
		"ci-tg",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
