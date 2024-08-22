
/**
 * # Power cell
 *
 * Power cells, used primarily for handheld and portable things. Holds a reasonable amount of power.
 */
/obj/item/stock_parts/power_store/cell
	name = "power cell"
	desc = "A rechargeable electrochemical power cell."
	icon = 'icons/obj/machines/cell_charger.dmi'
	icon_state = "cell"
	inhand_icon_state = "cell"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	force = 5
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*7, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.5)
	grind_results = list(/datum/reagent/lithium = 15, /datum/reagent/iron = 5, /datum/reagent/silicon = 5)

/* Cell variants*/
/obj/item/stock_parts/power_store/cell/empty
	empty = TRUE

/obj/item/stock_parts/power_store/cell/crap
	name = "\improper Nanotrasen brand rechargeable AA cell"
	desc = "You can't top the plasma top." //TOTALLY TRADEMARK INFRINGEMENT
	icon_state = "aa_cell"
	maxcharge = STANDARD_CELL_CHARGE * 0.5
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.4)

/obj/item/stock_parts/power_store/cell/crap/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	return ..()

/obj/item/stock_parts/power_store/cell/crap/empty
	empty = TRUE

/obj/item/stock_parts/power_store/cell/upgraded
	name = "upgraded power cell"
	desc = "A power cell with a slightly higher capacity than normal!"
	icon_state = "9v_cell"
	maxcharge = STANDARD_CELL_CHARGE * 2.5
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.5)
	chargerate = STANDARD_CELL_RATE * 0.5

/obj/item/stock_parts/power_store/cell/upgraded/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	return ..()

/obj/item/stock_parts/power_store/cell/upgraded/plus
	name = "upgraded power cell+"
	desc = "A power cell with an even higher capacity than the base model!"
	maxcharge = STANDARD_CELL_CHARGE * 5

/obj/item/stock_parts/power_store/cell/secborg
	name = "security borg rechargeable D cell"
	maxcharge = STANDARD_CELL_CHARGE * 0.6
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.4)

/obj/item/stock_parts/power_store/cell/secborg/empty
	empty = TRUE

/obj/item/stock_parts/power_store/cell/mini_egun
	name = "miniature energy gun power cell"
	maxcharge = STANDARD_CELL_CHARGE * 0.6

/obj/item/stock_parts/power_store/cell/hos_gun
	name = "X-01 multiphase energy gun power cell"
	maxcharge = STANDARD_CELL_CHARGE * 1.2

/obj/item/stock_parts/power_store/cell/pulse //200 pulse shots
	name = "pulse rifle power cell"
	maxcharge = STANDARD_CELL_CHARGE * 40
	chargerate = STANDARD_CELL_RATE * 0.75

/obj/item/stock_parts/power_store/cell/pulse/carbine //25 pulse shots
	name = "pulse carbine power cell"
	maxcharge = STANDARD_CELL_CHARGE * 5

/obj/item/stock_parts/power_store/cell/pulse/pistol //10 pulse shots
	name = "pulse pistol power cell"
	maxcharge = STANDARD_CELL_CHARGE * 2

/obj/item/stock_parts/power_store/cell/ninja
	name = "black power cell"
	icon_state = "bscell"
	maxcharge = STANDARD_CELL_CHARGE * 10
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.6)
	chargerate = STANDARD_CELL_RATE

/obj/item/stock_parts/power_store/cell/high
	name = "high-capacity power cell"
	icon_state = "hcell"
	maxcharge = STANDARD_CELL_CHARGE * 10
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.6)
	chargerate = STANDARD_CELL_RATE * 0.75

/obj/item/stock_parts/power_store/cell/high/empty
	empty = TRUE

/obj/item/stock_parts/power_store/cell/super
	name = "super-capacity power cell"
	icon_state = "scell"
	maxcharge = STANDARD_CELL_CHARGE * 20
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT * 3)
	chargerate = STANDARD_CELL_RATE

/obj/item/stock_parts/power_store/cell/super/empty
	empty = TRUE

/obj/item/stock_parts/power_store/cell/hyper
	name = "hyper-capacity power cell"
	icon_state = "hpcell"
	maxcharge = STANDARD_CELL_CHARGE * 30
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT * 4)
	chargerate = STANDARD_CELL_RATE * 1.5

/obj/item/stock_parts/power_store/cell/hyper/empty
	empty = TRUE

/obj/item/stock_parts/power_store/cell/bluespace
	name = "bluespace power cell"
	desc = "A rechargeable transdimensional power cell."
	icon_state = "bscell"
	maxcharge = STANDARD_CELL_CHARGE * 40
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*6)
	chargerate = STANDARD_CELL_RATE * 2

/obj/item/stock_parts/power_store/cell/bluespace/empty
	empty = TRUE

/obj/item/stock_parts/power_store/cell/infinite
	name = "infinite-capacity power cell"
	icon_state = "icell"
	maxcharge = INFINITY //little disappointing if you examine it and it's not huge
	custom_materials = list(/datum/material/glass=HALF_SHEET_MATERIAL_AMOUNT)
	chargerate = INFINITY
	ratingdesc = FALSE

/obj/item/stock_parts/power_store/cell/infinite/use(used, force = FALSE)
	return TRUE

/obj/item/stock_parts/power_store/cell/infinite/abductor
	name = "void core"
	desc = "An alien power cell that produces energy seemingly out of nowhere."
	icon = 'icons/obj/antags/abductor.dmi'
	icon_state = "cell"
	maxcharge = STANDARD_CELL_CHARGE * 50
	ratingdesc = FALSE

/obj/item/stock_parts/power_store/cell/infinite/abductor/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	return ..()

/obj/item/stock_parts/power_store/cell/potato
	name = "potato battery"
	desc = "A rechargeable starch based power cell."
	icon = 'icons/obj/service/hydroponics/harvest.dmi'
	icon_state = "potato"
	maxcharge = STANDARD_CELL_CHARGE * 0.3
	charge_light_type = null
	connector_type = null
	custom_materials = null
	grown_battery = TRUE //it has the overlays for wires
	custom_premium_price = PAYCHECK_CREW

/obj/item/stock_parts/power_store/cell/potato/Initialize(mapload, override_maxcharge)
	charge = maxcharge * 0.3
	. = ..()

/obj/item/stock_parts/power_store/cell/emproof
	name = "\improper EMP-proof cell"
	desc = "An EMP-proof cell."
	maxcharge = STANDARD_CELL_CHARGE * 0.5

/obj/item/stock_parts/power_store/cell/emproof/Initialize(mapload)
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)
	return ..()

/obj/item/stock_parts/power_store/cell/emproof/empty
	empty = TRUE

/obj/item/stock_parts/power_store/cell/emproof/corrupt()
	return

/obj/item/stock_parts/power_store/cell/emproof/slime
	name = "EMP-proof slime core"
	desc = "A yellow slime core infused with plasma. Its organic nature makes it immune to EMPs."
	icon = 'icons/mob/simple/slimes.dmi'
	icon_state = "yellow-core"
	custom_materials = null
	maxcharge = STANDARD_CELL_CHARGE * 5
	charge_light_type = null
	connector_type = "slimecore"

/obj/item/stock_parts/power_store/cell/emergency_light
	name = "miniature power cell"
	desc = "A tiny power cell with a very low power capacity. Used in light fixtures to power them in the event of an outage."
	maxcharge = STANDARD_CELL_CHARGE * 0.12 //Emergency lights use 0.2 W per tick, meaning ~10 minutes of emergency power from a cell
	custom_materials = list(/datum/material/glass = SMALL_MATERIAL_AMOUNT*0.2)
	w_class = WEIGHT_CLASS_TINY

/obj/item/stock_parts/power_store/cell/emergency_light/Initialize(mapload)
	. = ..()
	var/area/area = get_area(src)
	if(area)
		if(!area.lightswitch || !area.light_power)
			charge = 0 //For naturally depowered areas, we start with no power

/obj/item/stock_parts/power_store/cell/crystal_cell
	name = "crystal power cell"
	desc = "A very high power cell made from crystallized plasma"
	icon_state = "crystal_cell"
	maxcharge = STANDARD_CELL_CHARGE * 50
	chargerate = 0
	charge_light_type = null
	connector_type = "crystal"
	custom_materials = null
	grind_results = null

/obj/item/stock_parts/power_store/cell/inducer_supply
	maxcharge = STANDARD_CELL_CHARGE * 5

/obj/item/stock_parts/power_store/cell/ethereal
	name = "ahelp it"
	desc = "you sohuldn't see this"
	maxcharge = ETHEREAL_CHARGE_DANGEROUS
	charge = ETHEREAL_CHARGE_FULL
	icon_state = null
	charge_light_type = null
	connector_type = null
	custom_materials = null
	grind_results = null

/obj/item/stock_parts/power_store/cell/ethereal/examine(mob/user)
	. = ..()
	CRASH("[src.type] got examined by [user]")
