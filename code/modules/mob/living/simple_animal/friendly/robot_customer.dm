///Robot customers
/mob/living/simple_animal/robot_customer
	name = "fox"
	desc = "It's a fox."
	icon = 'icons/mob/tourists.dmi'
	icon_state = "amerifat"
	icon_living = "amerifat"
	icon_dead = "fox_dead"
	///Override so it uses datum ai
	can_have_ai = FALSE
	AIStatus = AI_OFF
	del_on_death = TRUE

	ai_controller = /datum/ai_controller/robot_customer


/mob/living/simple_animal/robot_customer/Initialize(mapload, datum/customer_data/customer_data, datum/venue/attending_venue)
	var/datum/customer_data/customer_info = SSrestaurant.all_customers[customer_data]
	ai_controller = customer_info.ai_controller_used
	. = ..()
	ai_controller.blackboard[BB_CUSTOMER_CUSTOMERINFO] = customer_info
	ai_controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE] = attending_venue
	ai_controller.blackboard[BB_CUSTOMER_PATIENCE] = customer_info.total_patience

///Clean up on the mobs seat etc when its deleted (Either by murder or because it left)
/mob/living/simple_animal/robot_customer/Destroy()
	var/datum/venue/attending_venue = ai_controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	attending_venue.current_visitors -= src
	SSrestaurant.claimed_seats[ai_controller.blackboard[BB_CUSTOMER_MY_SEAT]] = null
