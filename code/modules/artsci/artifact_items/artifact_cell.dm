/obj/item/stock_parts/cell/artifact
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1"
	resistance_flags = LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	ratingdesc = FALSE
	charge_light_type = null
	var/datum/component/artifact/assoc_comp = /datum/component/artifact/cell

ARTIFACT_SETUP(/obj/item/stock_parts/cell/artifact, SSobj)


/datum/component/artifact/cell
	associated_object = /obj/item/stock_parts/cell/artifact
	artifact_size = ARTIFACT_SIZE_TINY
	type_name = "Power Cell"
	weight = ARTIFACT_UNCOMMON
	xray_result = "SEGMENTED"
	valid_triggers = list(/datum/artifact_trigger/heat, /datum/artifact_trigger/shock, /datum/artifact_trigger/radiation)

/datum/component/artifact/cell/setup()
	var/obj/item/stock_parts/cell/artifact/cell = holder
	cell.corrupted = prob(10) //trolled
	cell.maxcharge = rand(5000,80000) //2x of bluespace
	cell.charge = cell.maxcharge / 2
	cell.chargerate = rand(5000,round(cell.maxcharge * 0.4))
	potency += cell.maxcharge / 900
	potency += cell.chargerate / 4000

/datum/component/artifact/cell/effect_activate()
	var/obj/item/stock_parts/cell/artifact/cell = holder
	cell.ratingdesc = TRUE

/datum/component/artifact/cell/effect_deactivate()
	var/obj/item/stock_parts/cell/artifact/cell = holder
	cell.ratingdesc = FALSE

/obj/item/stock_parts/cell/artifact/use(amount, force) //dont use power unless active
	. = FALSE
	if(assoc_comp.active)
		return ..()
