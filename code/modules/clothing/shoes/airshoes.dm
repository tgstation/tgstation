/obj/item/clothing/shoes/bhop/airshoes // better jump shoes?
	name = "air shoes"
	desc = "Footwear that uses propulsion technology to keep you above the ground and let you move faster."
	icon_state = "airshoes"
	obj_flags = UNIQUE_RENAME
	resistance_flags = FIRE_PROOF // Insert super sonic running along lava clip here
	actions_types = list(/datum/action/item_action/airshoes) // This is defined in augments_legs.dm cuz i made the implant version first. - hyperjll
	armor_type = /datum/armor/shoes_airshoes
	jumpdistance = 7 //-1 from to see the actual distance, e.g 4 goes over 3 tiles
	jumpspeed = 5
	recharging_rate = 40 //default 4 seconds between each dash
	recharging_time = 0 //time until next dash

/datum/armor/shoes_airshoes
	bio = 90

/obj/item/clothing/shoes/bhop/airshoes/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/shoes)

/obj/item/clothing/shoes/bhop/airshoes/ui_action_click(mob/user, action)
	if(!isliving(user))
		return

	if(recharging_time > world.time)
		to_chat(user, span_warning("The boot's internal propulsion needs to recharge still!"))
		return

	var/atom/target = get_edge_target_turf(user, user.dir) //gets the user's direction

	ADD_TRAIT(user, TRAIT_MOVE_FLOATING, LEAPING_TRAIT)  //Throwing itself doesn't protect mobs against lava (because gulag).
	if (user.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE, callback = TRAIT_CALLBACK_REMOVE(user, TRAIT_MOVE_FLOATING, LEAPING_TRAIT)))
		playsound(src, 'sound/effects/airshoesdash.ogg', 50, TRUE, TRUE)
		user.visible_message(span_warning("[usr] dashes forward into the air!"))
		recharging_time = world.time + recharging_rate
	else
		to_chat(user, span_warning("Something prevents you from dashing forward!"))

