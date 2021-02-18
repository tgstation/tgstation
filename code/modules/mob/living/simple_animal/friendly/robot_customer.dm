///Robot customers
/mob/living/simple_animal/robot_customer
	name = "space-tourist bot"
	desc = "I wonder what they'll order..."
	icon = 'icons/mob/tourists.dmi'
	icon_state = "amerifat"
	icon_living = "amerifat"
	///Override so it uses datum ai
	can_have_ai = FALSE
	AIStatus = AI_OFF
	del_on_death = TRUE
	ai_controller = /datum/ai_controller/robot_customer
	var/clothes_set = "amerifat_clothes"
	var/datum/atom_hud/hud_to_show_on_hover


/mob/living/simple_animal/robot_customer/Initialize(mapload, datum/customer_data/customer_data = /datum/customer_data/american, datum/venue/attending_venue = SSrestaurant.all_venues[/datum/venue/restaurant])
	ADD_TRAIT(src, TRAIT_NOMOBSWAP, INNATE_TRAIT) //dont push me bitch
	AddComponent(/datum/component/footstep, FOOTSTEP_OBJ_ROBOT, 1, -6, vary = TRUE)
	var/datum/customer_data/customer_info = SSrestaurant.all_customers[customer_data]
	clothes_set = pick(customer_info.clothing_sets)
	ai_controller = customer_info.ai_controller_used
	. = ..()
	ai_controller.blackboard[BB_CUSTOMER_CUSTOMERINFO] = customer_info
	ai_controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE] = attending_venue
	ai_controller.blackboard[BB_CUSTOMER_PATIENCE] = customer_info.total_patience
	update_icon()

///Clean up on the mobs seat etc when its deleted (Either by murder or because it left)
/mob/living/simple_animal/robot_customer/Destroy()
	var/datum/venue/attending_venue = ai_controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	attending_venue.current_visitors -= src
	SSrestaurant.claimed_seats[ai_controller.blackboard[BB_CUSTOMER_MY_SEAT]] = null
	return ..()

/mob/living/simple_animal/robot_customer/MouseEntered(location, control, params)
	. = ..()
	hud_to_show_on_hover?.add_hud_to(usr)

/mob/living/simple_animal/robot_customer/MouseExited(location, control, params)
	. = ..()
	hud_to_show_on_hover?.remove_hud_from(usr)

/mob/living/simple_animal/robot_customer/update_overlays()
	. = ..()
	var/mutable_appearance/greyscale = mutable_appearance(icon, "[icon_state]_greyscale")
	greyscale.color = rgb(rand(150,255), rand(150,255), rand(150,255)) //"#[random_color()]"
	greyscale.appearance_flags = RESET_COLOR
	. += greyscale

	var/mutable_appearance/clothes = mutable_appearance(icon, clothes_set)
	. += clothes
