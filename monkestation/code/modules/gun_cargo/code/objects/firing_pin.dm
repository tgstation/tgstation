GLOBAL_VAR_INIT(permit_pin_unrestricted, FALSE)
// Firing pin that can be used off station freely, and requires a permit to use on-station
/obj/item/firing_pin/permit_pin
	name = "permit-locked firing pin"
	desc = "A firing pin for a station who can't trust their crew. Only allows you to fire the weapon off-station or with a firearms permit.."
	icon_state = "firing_pin_explorer"
	fail_message = "<span class='warning'>You must have a permit or be off-station to fire this!</span>"
	can_remove = TRUE

// This checks that the user isn't on the station Z-level.
/obj/item/firing_pin/permit_pin/pin_auth(mob/living/user)
	var/turf/station_check = get_turf(user)

	if(obj_flags & EMAGGED)
		return TRUE

	if(GLOB.permit_pin_unrestricted)
		return TRUE

	var/obj/item/card/id/the_id = user.get_idcard()

	if(!the_id && is_station_level(station_check.z))
		return FALSE

	if(!is_station_level(station_check.z) || (ACCESS_WEAPONS in the_id.GetAccess()))
		return TRUE


/obj/item/firing_pin
	var/can_remove = TRUE

/obj/item/firing_pin/emag_act(mob/user)
	. = ..()
	can_remove = TRUE
