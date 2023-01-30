/obj/item/stock_parts/cell/artifact
	name = "Artifact"
	desc = "Yell at coderbus."
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1"
	resistance_flags = LAVA_PROOF | ACID_PROOF
	ratingdesc = FALSE
	charge_light_type = NULL
	armor_type = /datum/armor/obj_machinery/artifact
	var/datum/artifact/cell/assoc_datum = /datum/artifact/cell

//dumbed down of obj/item/artifact
/obj/item/stock_parts/cell/artifact/Initialize(mapload, var/forced_origin = null)
	. = ..()
	assoc_datum = new assoc_datum()
	assoc_datum.setup(src,forced_origin)

/obj/item/stock_parts/cell/artifact/Destroy()
	. = ..()
	SSartifacts.artifacts -= src

/obj/item/stock_parts/cell/artifact/atom_destruction()
	assoc_datum?.Destroyed()

/obj/item/stock_parts/cell/artifact/emp_act(severity)
	. = ..()
	assoc_datum?.emp_act(severity)

/obj/item/stock_parts/cell/artifact/pickup(mob/living/user)
	assoc_datum?.Touched(user)

/obj/item/stock_parts/cell/artifact/attackby(obj/item/I, mob/user, params)
	if(assoc_datum?.attack_by(I,user))
		return ..()

/obj/item/stock_parts/cell/artifact/ex_act(severity)
	. = ..()
	assoc_datum?.ex_act(severity)

/datum/artifact/cell
	associated_object = /obj/item/stock_parts/cell/artifact
	artifact_size = ARTIFACT_SIZE_TINY

/datum/artifact/cell/setup()
	..()
	var/obj/item/stock_parts/cell/artifact/cell = holder
	cell.corrupted = prob(10) //trolled
	cell.maxcharge = rand(5000,80000) //2x of bluespace
	cell.charge = maxcharge / 2
	cell.chargerate = rand(5000,round(cell.maxcharge * 0.4))

/datum/artifact/cell/effect_activate()
	var/obj/item/stock_parts/cell/artifact/cell = holder
	cell.ratingdesc = TRUE

/datum/artifact/cell/effect_deactivate()
	var/obj/item/stock_parts/cell/artifact/cell = holder
	cell.ratingdesc = FALSE

/obj/item/stock_parts/cell/artifact/use(amount, force)
	. = FALSE
	if(assoc_datum.active)
		return ..()