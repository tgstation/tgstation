//CHЁBUREK ACTION DATUMS
/datum/action/vehicle/sealed/gopnik
	button_icon = 'modular_meta/features/cheburek_car/icons/actions_vehicle.dmi'
	name = "Toggle Gop Mode"
	desc = "Grabs your Vodka and Semki!"
	button_icon_state = "gop_mode"
	COOLDOWN_DECLARE(gopnik_time_cooldown) //yes, you need some time for repaint your rusty garbage

/datum/action/vehicle/sealed/gopnik/Trigger(trigger_flags)
	if(!istype(vehicle_entered_target, /obj/vehicle/sealed/car/cheburek))
		return
	if(!COOLDOWN_FINISHED(src, gopnik_time_cooldown))
		return
	COOLDOWN_START(src, gopnik_time_cooldown, 3 SECONDS)
	var/obj/vehicle/sealed/car/cheburek/C = vehicle_entered_target
	C.toggle_gopmode(owner)

/datum/action/vehicle/sealed/gear_up
	button_icon = 'modular_meta/features/cheburek_car/icons/actions_vehicle.dmi'
	name = "Gear UP"
	desc = "Make your vedro move faster!"
	button_icon_state = "car_gear_up"
	COOLDOWN_DECLARE(shift_up_cooldown)

/datum/action/vehicle/sealed/gear_up/Trigger(trigger_flags)
	if(!istype(vehicle_entered_target, /obj/vehicle/sealed/car/cheburek))
		return
	if(!COOLDOWN_FINISHED(src, shift_up_cooldown))
		return
	COOLDOWN_START(src, shift_up_cooldown, 1 SECONDS)
	var/obj/vehicle/sealed/car/cheburek/G = vehicle_entered_target
	G.increase_gear(owner)

/datum/action/vehicle/sealed/gear_down
	button_icon = 'modular_meta/features/cheburek_car/icons/actions_vehicle.dmi'
	name = "Gear DOWN"
	desc = "Make your vedro move slower!"
	button_icon_state = "car_gear_down"
	COOLDOWN_DECLARE(shift_down_cooldown)

/datum/action/vehicle/sealed/gear_down/Trigger(trigger_flags)
	if(!istype(vehicle_entered_target, /obj/vehicle/sealed/car/cheburek))
		return
	if(!COOLDOWN_FINISHED(src, shift_down_cooldown))
		return
	COOLDOWN_START(src, shift_down_cooldown, 1 SECONDS)
	var/obj/vehicle/sealed/car/cheburek/G = vehicle_entered_target
	G.decrease_gear(owner)

/datum/action/vehicle/sealed/headlights
	name = "Toggle Headlights"
	desc = "Turn on your brights!"
	button_icon_state = "car_headlights"

/datum/action/vehicle/sealed/headlights/Trigger(trigger_flags)
	to_chat(owner, span_notice("You flip the switch for the vehicle's headlights."))
	vehicle_entered_target.headlights_toggle = !vehicle_entered_target.headlights_toggle
	vehicle_entered_target.set_light_on(vehicle_entered_target.headlights_toggle)
	vehicle_entered_target.update_appearance()
	playsound(owner, vehicle_entered_target.headlights_toggle ? 'sound/items/weapons/magin.ogg' : 'sound/items/weapons/magout.ogg', 40, TRUE)
	var/obj/vehicle/sealed/car/cheburek/L = vehicle_entered_target
	L.car_lights_toggle(owner)

/datum/action/vehicle/sealed/blinkers
	button_icon = 'modular_meta/features/cheburek_car/icons/actions_vehicle.dmi'
	name = "Avariyka"
	desc = "Useful if you need to park your bucket anywhere"
	button_icon_state = "car_blinker"

/datum/action/vehicle/sealed/blinkers/Trigger(trigger_flags)
	if(!istype(vehicle_entered_target, /obj/vehicle/sealed/car/cheburek))
		return
	var/obj/vehicle/sealed/car/cheburek/T = vehicle_entered_target
	T.toggle_blinkers(owner)
