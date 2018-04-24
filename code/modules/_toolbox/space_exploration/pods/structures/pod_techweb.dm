/*
* Techweb nodes
*/

/datum/techweb_node/podsbasic
	id = "podsbasic"
	display_name = "Basic Space Pods"
	description = "Basic Space Pod parts."
	prereq_ids = list("base")
	design_ids = list("ptaser","pdisabler","pdrill","pengineplasma","pengineuranium","penginewood","pcargolittle","pcargoindustrial","pcleftframe","pcrightframe","pccircuits","pccontrol","pccovers","pcarmorlight","porecollector","pgps")
	research_cost = 2500
	export_price = 5000

/datum/techweb_node/podscombat
	id = "podscombat"
	display_name = "Space Pods Weaponry"
	description = "Basic Space Pod weaponry."
	prereq_ids = list("base","weaponry")
	design_ids = list("plaser","pphaser","p45r","p45ammo","p9mmr","p9mmammo")
	research_cost = 2500
	export_price = 5000

/datum/techweb_node/podsstandard
	id = "podsstandard"
	display_name = "Standard Space Pods"
	description = "Basic Space Pod parts."
	prereq_ids = list("podsbasic","datatheory","engineering","emp_basic")
	design_ids = list("pplasmaforcefield","pneutronshield","pcargomedium","pcarmorgold","pautoloader","plifeformsensor","pplasmacutter")
	research_cost = 2500
	export_price = 5000

/datum/techweb_node/podsadvanced
	id = "podsadvanced"
	display_name = "Advanced Space Pods"
	description = "High end Space Pod parts."
	prereq_ids = list("podsstandard","podscombat","adv_engi","adv_plasma")
	design_ids = list("phiggsbosonshield","pengineplasmaadvanced","pengineuraniumadvanced","penginewoodadvanced","pcargolarge","pcarmorheavy","pcarmorindustrial","psmokescreen")
	research_cost = 2500
	export_price = 5000

/datum/techweb_node/podscombatadvanced
	id = "podscombatadvanced"
	display_name = "Advanced Space Pod Weaponry"
	description = "High end Space Pod Weaponry."
	prereq_ids = list("podsadvanced","adv_weaponry")
	design_ids = list("pxraylaser","pheavylaser","p10mmr","p10mmammo","pgimbal")
	research_cost = 2500
	export_price = 5000

/*
* Techweb Nodes for individual high end pod attachments
*/
//weapons
/datum/techweb_node/p_deathlaser
	id = "pod_deathlaser"
	display_name = "Laser carbine Mk III"
	description = "Powerful laser designed for a Space Pod."
	prereq_ids = list("podscombatadvanced")
	design_ids = list("pdeathlaser")
	research_cost = 2500
	export_price = 5000

/datum/techweb_node/p_r75
	id = "pod_75mmr"
	display_name = "Space Pod .75 HE repeater"
	description = "High end Space Pod Projectiles."
	prereq_ids = list("podscombatadvanced")
	design_ids = list("p75mmr","p75ammo")
	research_cost = 2500
	export_price = 5000

/datum/techweb_node/p_disruptor
	id = "pod_disruptor"
	display_name = "Space Pod Disruptor Laser"
	description = "High end Space Pod Energy Weapon."
	prereq_ids = list("podscombatadvanced")
	design_ids = list("pdisruptor")
	research_cost = 3000
	export_price = 6000

//shields
/datum/techweb_node/p_antimatter_shield
	id = "pod_antimattershield"
	display_name = "Space Pod Antimatter Shield"
	description = "Powerful high end Force field for the Space Pod."
	prereq_ids = list("podscombatadvanced")
	design_ids = list("pantimattershield")
	research_cost = 2500
	export_price = 5000

//armor
/datum/techweb_node/p_advanced_armor
	id = "pod_advanced_armor"
	display_name = "Advanced Prototype Space Pod Armor"
	description = "Advanced Space Pod Armor"
	prereq_ids = list("podscombatadvanced")
	design_ids = list("pantimattershield","pcarmorprecursor")
	research_cost = 5000
	export_price = 7500

/*
* Adding designs to existing techweb nodes
*/

/datum/techweb_node/base/New()
	design_ids += "podfab"
	. = ..()