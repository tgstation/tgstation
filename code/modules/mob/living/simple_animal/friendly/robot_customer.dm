///Robot customers
/mob/living/simple_animal/robot_customer
	name = "fox"
	desc = "It's a fox."
	icon = 'icons/mob/pets.dmi'
	icon_state = "fox"
	icon_living = "fox"
	icon_dead = "fox_dead"
	///Override so it uses datum ai
	can_have_ai = FALSE
	AIStatus == AI_OFF

	ai_controller = /datum/ai_controller/robot_customer


/mob/living/simple_animal/robot_customer/Initialize(mapload, datum_to_use = /datum/venue_customer/american)
	var/datum/venue_customer/customer = SSrestaurant.all_customers[datum_to_use]
	ai_controller = customer.ai_controller_used
	. = ..()
	ai_controller[BB_CUSTOMER_CUSTOMERINFO] = customer
