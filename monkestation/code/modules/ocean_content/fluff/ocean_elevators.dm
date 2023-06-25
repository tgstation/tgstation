/// these need to be different than regular elevators as we have the mining z-level detached from the station.
/// Why we have them detached? we use a single image as the ocean overlay and this can't be used with plane cube
/// as we need to provide an offset atom which can't be done with a single one


/obj/machinery/ocean_elevator
	name = "ocean elevator"
	desc = "an elevator used to move things up and down the ocean floors."

	icon = ''
	icon_state = "elevator"

	///this is an array that sorts elevators by id and if they are up or down
	var/static/list/elevator_list = list()
	///the id to use for sorting and activation
	var/elevator_id = "generic"
