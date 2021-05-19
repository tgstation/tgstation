/**
 * # Light Component
 *
 * Emits a light of a specific brightness and colour. Requires a shell.
 */
/obj/item/component/light
	display_name = "Light"

	/// The colours of the light
	var/datum/port/input/red
	var/datum/port/input/green
	var/datum/port/input/blue

	/// The brightness
	var/datum/port/input/brightness

	/// Whether the light is on or not
	var/datum/port/input/on

	var/max_power = 5

/obj/item/component/light/Initialize()
	. = ..()
	red = add_input_port("Red", PORT_TYPE_NUMBER)
	green = add_input_port("Green", PORT_TYPE_NUMBER)
	blue = add_input_port("Blue", PORT_TYPE_NUMBER)
	brightness = add_input_port("Brightness", PORT_TYPE_NUMBER)

	on = add_input_port("On", PORT_TYPE_NUMBER)


/obj/item/component/light/Destroy()
	red = null
	green = null
	blue = null
	brightness = null
	on = null
	return ..()

/obj/item/component/light/register_shell(atom/movable/shell)
	. = ..()
	set_atom_light(shell)

/obj/item/component/light/unregister_shell(atom/movable/shell)
	shell.set_light_on(FALSE)
	return ..()

/obj/item/component/light/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(parent.shell)
		set_atom_light(parent.shell)

/obj/item/component/light/proc/set_atom_light(atom/movable/target_atom)
	target_atom.set_light_power(brightness.input_value)
	target_atom.set_light_range(brightness.input_value)
	target_atom.set_light_color(rgb(red.input_value, green.input_value, blue.input_value))
	target_atom.set_light_on(on.input_value)
