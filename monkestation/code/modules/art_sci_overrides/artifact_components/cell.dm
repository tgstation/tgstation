/datum/artifact_effect/cell
	type_name = "Power Cell Effect"
	weight = ARTIFACT_UNCOMMON
	artifact_size = ARTIFACT_SIZE_TINY
	valid_activators = list(
		/datum/artifact_activator/range/heat,
		/datum/artifact_activator/range/shock,
		/datum/artifact_activator/range/radiation
	)

	examine_discovered = span_warning("It appears to hold power")

/datum/artifact_effect/cell/setup()
	var/obj/item/stock_parts/cell/artifact/cell = our_artifact.holder
	cell.corrupted = prob(10) //trolled
	cell.maxcharge = rand(5 KW, 500 MW) // the heavenly battery
	cell.charge = cell.maxcharge / 2
	cell.chargerate = rand(5000, round(cell.maxcharge * 0.4))
	potency += cell.maxcharge / 900
	potency += cell.chargerate / 4000

/datum/artifact_effect/cell/effect_activate()
	var/obj/item/stock_parts/cell/artifact/cell = our_artifact.holder
	cell.ratingdesc = TRUE

/datum/artifact_effect/cell/effect_deactivate()
	var/obj/item/stock_parts/cell/artifact/cell = our_artifact.holder
	cell.ratingdesc = FALSE
