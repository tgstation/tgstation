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

/datum/component/artifact/cell/setup()
	var/obj/item/stock_parts/cell/artifact/cell = holder
	cell.corrupted = prob(10) //trolled
	cell.maxcharge = rand(5 KW, 8 GW) // the heavenly battery
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
