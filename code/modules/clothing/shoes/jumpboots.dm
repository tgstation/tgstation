/obj/item/clothing/shoes/bhop
	name = "jump boots"
	desc = "A specialized pair of combat boots with a built-in propulsion system for rapid foward movement."
	icon_state = "jetboots"
	inhand_icon_state = null
	resistance_flags = FIRE_PROOF
	actions_types = list(/datum/action/item_action/bhop)
	armor_type = /datum/armor/shoes_bhop
	strip_delay = 30
	var/jumpdistance = 5 //-1 from to see the actual distance, e.g 4 goes over 3 tiles
	var/jumpspeed = 3
	var/recharging_rate = 60 //default 6 seconds between each dash
	var/recharging_time = 0 //time until next dash

/datum/armor/shoes_bhop
	bio = 90

/obj/item/clothing/shoes/bhop/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/shoes)

/obj/item/clothing/shoes/bhop/ui_action_click(mob/user, action)
	if(!isliving(user))
		return

	if(recharging_time > world.time)
		to_chat(user, span_warning("The boot's internal propulsion needs to recharge still!"))
		return

	var/atom/target = get_edge_target_turf(user, user.dir) //gets the user's direction

	ADD_TRAIT(user, TRAIT_MOVE_FLOATING, LEAPING_TRAIT)  //Throwing itself doesn't protect mobs against lava (because gulag).
	if (user.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE, callback = TRAIT_CALLBACK_REMOVE(user, TRAIT_MOVE_FLOATING, LEAPING_TRAIT)))
		playsound(src, 'sound/effects/stealthoff.ogg', 50, TRUE, TRUE)
		user.visible_message(span_warning("[usr] dashes forward into the air!"))
		recharging_time = world.time + recharging_rate
	else
		to_chat(user, span_warning("Something prevents you from dashing forward!"))

/obj/item/clothing/shoes/bhop/rocket
	name = "rocket boots"
	desc = "Very special boots with built-in rocket thrusters! SHAZBOT!"
	icon_state = "rocketboots"
	inhand_icon_state = null
	actions_types = list(/datum/action/item_action/bhop/brocket)
	jumpdistance = 20 //great for throwing yourself into walls and people at high speeds
	jumpspeed = 5
