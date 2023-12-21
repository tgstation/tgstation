/datum/component/artifact/cell
	associated_object = /obj/item/stock_parts/cell/artifact
	artifact_size = ARTIFACT_SIZE_TINY
	type_name = "Power Cell"
	weight = ARTIFACT_UNCOMMON
	xray_result = "SEGMENTED"
	valid_activators = list(
		/datum/artifact_activator/range/heat,
		/datum/artifact_activator/range/shock,
		/datum/artifact_activator/range/radiation
	)
	valid_faults = list(
		/datum/artifact_fault/ignite = 10,
		/datum/artifact_fault/warp = 10,
		/datum/artifact_fault/reagent/poison = 10,
		/datum/artifact_fault/death = 2,
		/datum/artifact_fault/tesla_zap = 5,
		/datum/artifact_fault/grow = 10,
		/datum/artifact_fault/explosion = 2,
	)

/datum/component/artifact/cell/setup()
	var/obj/item/stock_parts/cell/artifact/cell = holder
	cell.corrupted = prob(10) //trolled
	cell.maxcharge = rand(5 KW, 500 MW) // the heavenly battery
	cell.charge = cell.maxcharge / 2
	cell.chargerate = rand(5000, round(cell.maxcharge * 0.4))
	potency += cell.maxcharge / 900
	potency += cell.chargerate / 4000

/datum/component/artifact/cell/effect_activate()
	var/obj/item/stock_parts/cell/artifact/cell = holder
	cell.ratingdesc = TRUE

/datum/component/artifact/cell/effect_deactivate()
	var/obj/item/stock_parts/cell/artifact/cell = holder
	cell.ratingdesc = FALSE
