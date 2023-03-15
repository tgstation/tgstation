/**
 * # Viewer Component
 *
 * Receive the location of a target organism
 */
/obj/item/circuit_component/viewer
	display_name = "Viewer"
	display_desc = "A component that returns a list of every entity the shell can see."

	//The list of mobs returned by the component
	var/datum/port/output/entities

	//The shell the bot is currently in
	var/atom/movable/self

	COOLDOWN_DECLARE(viewer_cooldown)

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/viewer/get_ui_notices()
	. = ..()
	. += create_ui_notice("Viewer Cooldown: [DisplayTimeText(1 SECONDS)]", "orange", "stopwatch")

/obj/item/circuit_component/viewer/Initialize(mapload)
	. = ..()

	entities = add_output_port("Entities", PORT_TYPE_LIST)

/obj/item/circuit_component/viewer/Destroy()
	entities = null
	return ..()

/obj/item/circuit_component/viewer/register_shell(atom/movable/shell)
	self = shell

/obj/item/circuit_component/viewer/unregister_shell(atom/movable/shell)
	self = null

/obj/item/circuit_component/viewer/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(!COOLDOWN_FINISHED(src, viewer_cooldown))
		return

	entities.set_output(viewers(get_turf(self)))
	COOLDOWN_START(src, viewer_cooldown, 1 SECONDS)
