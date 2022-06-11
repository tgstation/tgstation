
/obj/item/reagent_containers/glass/watering_can
	name = "watering can"
	desc = "It's a watering can. It is scientific proved that using a watering can to simulate rain increase plant happiness!"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "watering_can"
	inhand_icon_state = "watering_can"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	custom_materials = list(/datum/material/iron = 200)
	w_class = WEIGHT_CLASS_NORMAL
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(20,100)
	volume = 100

/obj/item/reagent_containers/glass/watering_can/wood
	name = "wood watering can"
	desc = "An old metal-made watering can but shoddily painted to look like it was made of wood for some dubious reason..."
	icon_state = "watering_can_wood"
	inhand_icon_state = "watering_can_wood"

/obj/item/reagent_containers/glass/watering_can/advanced
	desc = "Everything a botanist would want in a watering can. This marvel of technology generates it's own water!"
	name = "advanced watering can"
	icon_state = "adv_watering_can"
	inhand_icon_state = "adv_watering_can"
	custom_materials = list(/datum/material/iron = 2500, /datum/material/glass = 200)
	///Enables/Disables the self refilling, if you want to mix some nutriments on your can
	var/refill_enabled = TRUE
	///Refill rate for the watering can
	var/refill_rate = 5
	//Determins what reagent to use for refilling
	var/datum/reagent/refill_reagent = /datum/reagent/water
	list_reagents = list(/datum/reagent/water = 100)

/obj/item/reagent_containers/glass/watering_can/advanced/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/glass/watering_can/advanced/attack_self(mob/user)
	if(refill_enabled)
		START_PROCESSING(SSobj, src)
		icon_state = "[initial(icon_state)]-off"
		refill_enabled = FALSE
	else
		STOP_PROCESSING(SSobj,src)
		icon_state = "[initial(icon_state)]"
		refill_enabled = TRUE
	to_chat(user, span_notice("You set the '[refill_reagent.name]' generator switch to the '[refill_enabled ? "ON" : "OFF"]' position."))
	playsound(loc, 'sound/machines/click.ogg', 30, TRUE)
	update_appearance()

/obj/item/reagent_containers/glass/watering_can/advanced/process(delta_time)
	if(!refill_enabled)
		return
	///How much to refill
	var/refill_add = min(volume - reagents.total_volume, refill_rate * delta_time)
	if(refill_add > 0)
		reagents.add_reagent(refill_reagent, refill_add)

/obj/item/reagent_containers/glass/watering_can/advanced/examine(mob/user)
	return ..()
	. += span_notice("The '[refill_reagent.name]' generator switch is set to <b>[refill_enabled ? "ON" : "OFF"]</b>.")

/obj/item/reagent_containers/glass/watering_can/advanced/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()
