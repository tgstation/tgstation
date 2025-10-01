/datum/export/seed
	cost = CARGO_CRATE_VALUE * 0.25 // Gets multiplied by potency
	k_elasticity = 1 //price inelastic/quantity elastic, only need to export a few samples
	unit_name = "new plant species sample"
	export_types = list(/obj/item/seeds)
	var/needs_discovery = FALSE // Only for undiscovered species
	var/static/list/discovered_plants = list()

/datum/export/seed/get_base_cost(obj/item/seeds/S)
	if(!needs_discovery && (S.type in discovered_plants))
		return 0
	if(needs_discovery && !(S.type in discovered_plants))
		return 0
	return ..() * S.rarity // That's right, no bonus for potency. Send a crappy sample first to "show improvement" later.

/datum/export/seed/sell_object(obj/O, datum/export_report/report, dry_run, apply_elastic)
	. = ..()
	if(. && !dry_run)
		var/obj/item/seeds/S = O
		discovered_plants[S.type] = S.potency


/datum/export/seed/potency
	cost = CARGO_CRATE_VALUE * 0.0125 // Gets multiplied by potency and rarity.
	unit_name = "improved plant sample"
	export_types = list(/obj/item/seeds)
	needs_discovery = TRUE // Only for already discovered species

/datum/export/seed/potency/get_base_cost(obj/item/seeds/S)
	return round(..() * S.potency - discovered_plants[S.type])
