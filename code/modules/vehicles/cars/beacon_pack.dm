/obj/item/choice_beacon/car
	name = "Car delivery beacon"
	desc = "Summon your car."
	icon_state = "designator_syndicate"
	inhand_icon_state = "nukietalkie"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	company_source = "Quantum Ride"
	company_message = span_bold("Autonomous delivery initiated. Anticipate the arrival of your vehicle.")
	w_class = WEIGHT_CLASS_TINY

/obj/item/choice_beacon/car/generate_display_names()
	var/static/list/cars
	if(!cars)
		cars = list()
		var/list/possible_cars = list(
			/obj/vampire_car/retro,
			/obj/vampire_car/retro/second,
			/obj/vampire_car/retro/third,
			/obj/vampire_car/rand,
			/obj/vampire_car/rand/camarilla,
			/obj/vampire_car/retro/rand/camarilla,
			/obj/vampire_car/rand/anarch,
			/obj/vampire_car/retro/rand/anarch,
			/obj/vampire_car/rand/clinic,
			/obj/vampire_car/retro/rand/clinic,
			/obj/vampire_car/limousine,
			/obj/vampire_car/limousine/giovanni,
			/obj/vampire_car/limousine/camarilla,
			/obj/vampire_car/police,
			/obj/vampire_car/track,
			/obj/vampire_car/track/volkswagen,
			/obj/vampire_car/track/ambulance,
		)
		for(var/obj/vampire_car/car as anything in possible_cars)
			cars[initial(car.name) + " [car.icon_state]" ] = car
	return cars


/datum/supply_pack/goody/car_beacon
	name = "Nanotrasen Brand New Car"
	desc = "Contains long-range bluespace delivery beacon from car dealership store."
	cost = PAYCHECK_COMMAND * 5
	contains = list(/obj/item/choice_beacon/car)

/datum/supply_pack/goody/gasoline
	name = "Nanotrasen Brand New Car"
	desc = "Contains long-range bluespace delivery beacon from car dealership store."
	cost = PAYCHECK_COMMAND
	contains = list(/obj/item/gas_can/full)
