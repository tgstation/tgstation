/obj/item/reagent_containers/cup/watering_can
	name = "watering can"
	desc = "It's a watering can. It is scientifically proved that using a watering can to simulate rain increases plant happiness!"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "watering_can"
	inhand_icon_state = "watering_can"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	custom_materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT * 2)
	w_class = WEIGHT_CLASS_NORMAL
	volume = 100
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(20,100)

/obj/item/reagent_containers/cup/watering_can/wood
	name = "wood watering can"
	desc = "An old metal-made watering can but shoddily painted to look like it was made of wood for some dubious reason..."
	icon_state = "watering_can_wood"
	inhand_icon_state = "watering_can_wood"
	volume = 70
	possible_transfer_amounts = list(20,70)

/obj/item/reagent_containers/cup/watering_can/advanced
	desc = "Everything a botanist would want in a watering can. This marvel of technology generates its own water!"
	name = "advanced watering can"
	icon_state = "adv_watering_can"
	inhand_icon_state = "adv_watering_can"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*1.25, /datum/material/glass =SMALL_MATERIAL_AMOUNT * 2)
	list_reagents = list(/datum/reagent/water = 100)
	///Refill rate for the watering can
	var/refill_rate = 5
	///Determins what reagent to use for refilling
	var/datum/reagent/refill_reagent = /datum/reagent/water

/obj/item/reagent_containers/cup/watering_can/advanced/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/cup/watering_can/advanced/process(seconds_per_tick)
	///How much to refill
	var/refill_add = min(volume - reagents.total_volume, refill_rate * seconds_per_tick)
	if(refill_add > 0)
		reagents.add_reagent(refill_reagent, refill_add)

/obj/item/reagent_containers/cup/watering_can/advanced/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()
