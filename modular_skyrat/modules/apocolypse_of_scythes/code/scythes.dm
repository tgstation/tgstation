/obj/item/scythe
	name = "scythe"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow."
	icon = 'modular_skyrat/modules/apocolypse_of_scythes/icons/items_and_weapons.dmi'
	icon_state = "scythe"
	worn_icon = 'modular_skyrat/modules/apocolypse_of_scythes/icons/back.dmi'
	lefthand_file = 'modular_skyrat/modules/apocolypse_of_scythes/icons/polearms_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/apocolypse_of_scythes/icons/polearms_righthand.dmi'
	force = 10
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	flags_1 = CONDUCT_1
	armour_penetration = 10
	slot_flags = ITEM_SLOT_BACK
	attack_verb_continuous = list("chops", "slices", "cuts", "reaps")
	attack_verb_simple = list("chop", "slice", "cut", "reap")
	hitsound = 'sound/weapons/bladeslice.ogg'

	var/hit_range = 0
	var/swiping = FALSE

/obj/item/scythe/pre_attack(atom/A, mob/living/user, params)
	if(!istype(A, /obj/structure/spacevine) && !istype(A, /mob/living/simple_animal/hostile/venus_human_trap))
		return ..()
	if(swiping)
		return ..()
	swiping = TRUE
	if(istype(A, /obj/structure/spacevine) && hit_range >= 1)
		for(var/obj/structure/spacevine/choose_vine in view(hit_range, A))
			melee_attack_chain(user, choose_vine)
		swiping = FALSE
		return
	swiping = FALSE

/obj/item/scythe/tier1
	name = "scythe (tier 1)"
	icon_state = "scythe_t1"

/obj/item/scythe/tier2
	name = "scythe (tier 2)"
	icon_state = "scythe_t2"
	force = 13
	hit_range = 1

/obj/item/scythe/tier3
	name = "scythe (tier 3)"
	icon_state = "scythe_t3"
	force = 16
	hit_range = 2

/obj/item/scythe/tier4
	name = "scythe (tier 4)"
	icon_state = "scythe_t4"
	force = 20
	hit_range = 3

/datum/design/scythe_t1
	name = "Scythe (Tier 1)"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow."
	id = "scythet1"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/scythe/tier1
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/scythe_t2
	name = "Scythe (Tier 2)"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow."
	id = "scythet2"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/scythe/tier2
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/techweb_node/scythe_t1
	id = "t1scythe"
	display_name = "Scythe (Tier 1)"
	description = "Culling tools"
	prereq_ids = list("adv_engi", "biotech", "botany")
	design_ids = list(
		"scythet1",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	discount_experiments = list(/datum/experiment/scanning/random/plants/wild = 500)

/datum/techweb_node/scythe_t2
	id = "t2scythe"
	display_name = "Scythe (Tier 2)"
	description = "Culling tools"
	prereq_ids = list("t1scythe")
	design_ids = list(
		"scythet2",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	discount_experiments = list(/datum/experiment/scanning/random/plants/wild = 1000)

/datum/supply_pack/organic/tier3_scythe
	name = "Tier 3 Scythe"
	desc = "Have pesky vines and need a way to chop it down faster? Order this crate now!"
	cost = CARGO_CRATE_VALUE * 20
	contains = list(/obj/item/scythe/tier3)
	crate_name = "tier 3 scythe supply crate"

/datum/supply_pack/organic/tier4_scythe
	name = "Tier 4 Scythe"
	desc = "Have pesky vines and need a way to chop it down faster? Order this crate now!"
	cost = CARGO_CRATE_VALUE * 40
	contains = list(/obj/item/scythe/tier4)
	crate_name = "tier 4 scythe supply crate"
