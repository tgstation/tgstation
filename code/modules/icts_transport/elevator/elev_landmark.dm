/**
 * lift_id landmarks. used to map in specific_transport_id to trams. when the trams transport_controller encounters one on a trams tile
 * it sets its specific_transport_id to that landmark. allows you to have multiple trams and multiple controls linking to their specific tram
 */
/obj/effect/landmark/lift_id
	name = "lift id setter"
	icon_state = "lift_id"

	///what specific id we give to the tram we're placed on, should explicitely set this if its a subtype, or weird things might happen
	var/specific_transport_id
