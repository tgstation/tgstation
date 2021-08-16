/obj/machinery/atmospherics/update_icon()
	layer = initial(layer) + piping_layer / 1000
	return ..()

/**
 * Getter for piping layer shifted, pipe colored overlays
 *
 * Creates the image for the pipe underlay that all components use, called by get_pipe_underlay() in components_base.dm
 * Arguments:
 * * iconfile  - path of the iconstate we are using (ex: 'icons/obj/atmospherics/components/thermomachine.dmi')
 * * iconstate - the image we are using inside the file
 * * direction - the direction of our device
 * * color - the color (in hex value, like #559900) that the pipe should have
 * * piping_layer - the piping_layer the device is in, used inside PIPING_LAYER_SHIFT
 * * trinary - if TRUE we also use PIPING_FORWARD_SHIFT on layer 1 and 5 for trinary devices (filters and mixers)
 */
/obj/machinery/atmospherics/proc/getpipeimage(iconfile, iconstate, direction, color = COLOR_VERY_LIGHT_GRAY, piping_layer = 3, trinary = FALSE)
	var/image/pipe_overlay = image(iconfile, iconstate, dir = direction)
	pipe_overlay.color = color
	PIPING_LAYER_SHIFT(pipe_overlay, piping_layer)
	if(trinary == TRUE && (piping_layer == 1 || piping_layer == 5))
		PIPING_FORWARD_SHIFT(pipe_overlay, piping_layer, 2)
	return pipe_overlay

/**
 * Update the layer in which the pipe/device is in, that way pipes have consistent layer depending on piping_layer
 */
/obj/machinery/atmospherics/proc/update_layer()
	layer = initial(layer) + (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_LCHANGE + (GLOB.pipe_colors_ordered[pipe_color] * 0.01)

/**
 * Called by the RPD.dm pre_attack(), overriden by pipes.dm
 * Arguments:
 * * paint_color - color that the pipe will be painted in (colors in hex like #4f4f4f)
 */
/obj/machinery/atmospherics/proc/paint(paint_color)
	return FALSE
