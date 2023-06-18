/// Dynamically calculate nightshift brightness. How TG does it is painful to modify.
#define NIGHTSHIFT_LIGHT_MODIFIER 0.15
#define NIGHTSHIFT_COLOR_MODIFIER 0.10

/atom
	light_power = 1.25

/obj/machinery/light
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/lights/icons/lighting.dmi'
	overlay_icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/lights/icons/lighting_overlay.dmi'
	brightness = 6.5
	fire_brightness = 4.5
	fire_colour = "#D47F9B"
	bulb_colour = LIGHT_COLOR_FAINT_BLUE
	bulb_power = 1.15
	nightshift_light_color = null // Let the dynamic night shift color code handle this.
	bulb_low_power_colour = "#FF6600"
	bulb_low_power_brightness_mul = 0.4
	bulb_low_power_pow_min = 0.4
	bulb_emergency_colour = "#FF0000"
	bulb_major_emergency_brightness_mul = 0.7
	power_consumption_rate = 5.62
	var/maploaded = FALSE //So we don't have a lot of stress on startup.
	var/turning_on = FALSE //More stress stuff.
	var/constant_flickering = FALSE // Are we always flickering?
	var/flicker_timer = null
	var/roundstart_flicker = FALSE

/obj/machinery/light/proc/turn_on(trigger, play_sound = TRUE)
	if(QDELETED(src))
		return
	turning_on = FALSE
	if(!on)
		return
	var/area/local_area  = get_room_area(src)
	var/new_brightness = brightness
	var/new_power = bulb_power
	var/new_color = bulb_colour
	if (local_area?.fire)
		new_color = fire_colour
		new_brightness = fire_brightness
	else if(color)
		new_color = color
	else if (nightshift_enabled)
		new_brightness -= new_brightness * NIGHTSHIFT_LIGHT_MODIFIER
		new_power -= new_power * NIGHTSHIFT_LIGHT_MODIFIER
		if(!color && nightshift_light_color)
			new_color = nightshift_light_color
		else if(color) // In case it's spraypainted.
			new_color = color
		else // Adjust light values to be warmer. I doubt caching would speed this up by any worthwhile amount, as it's all very fast number and string operations.
			// Convert to numbers for easier manipulation.
			var/red = GETREDPART(bulb_colour)
			var/green = GETGREENPART(bulb_colour)
			var/blue = GETBLUEPART(bulb_colour)

			red += round(red * NIGHTSHIFT_COLOR_MODIFIER)
			green -= round(green * NIGHTSHIFT_COLOR_MODIFIER * 0.3)
			red = clamp(red, 0, 255) // clamp to be safe, or you can end up with an invalid hex value
			green = clamp(green, 0, 255)
			blue = clamp(blue, 0, 255)
			new_color = "#[num2hex(red, 2)][num2hex(green, 2)][num2hex(blue, 2)]"  // Splice the numbers together and turn them back to hex.

	var/matching = light && new_brightness == light.light_range && new_power == light.light_power && new_color == light.light_color
	if(!matching)
		switchcount++
		if( prob( min(60, (switchcount**2)*0.01) ) )
			if(trigger)
				burn_out()
		else
			use_power = ACTIVE_POWER_USE
			set_light(new_brightness, new_power, new_color)
			if(play_sound)
				playsound(src.loc, 'modular_skyraptor/modules/aesthetics/inherited_skyrat/lights/sound/light_on.ogg', 65, 1)

/obj/machinery/light/proc/start_flickering()
	on = FALSE
	update(FALSE, TRUE, FALSE)

	constant_flickering = TRUE

	flicker_timer = addtimer(CALLBACK(src, PROC_REF(flicker_on)), rand(5, 10))

/obj/machinery/light/proc/stop_flickering()
	constant_flickering = FALSE

	if(flicker_timer)
		deltimer(flicker_timer)
		flicker_timer = null

	set_on(has_power())

/obj/machinery/light/proc/alter_flicker(enable = TRUE)
	if(!constant_flickering)
		return
	if(has_power())
		on = enable
		update(FALSE, TRUE, FALSE)

/obj/machinery/light/proc/flicker_on()
	alter_flicker(TRUE)
	flicker_timer = addtimer(CALLBACK(src, PROC_REF(flicker_off)), rand(5, 10))

/obj/machinery/light/proc/flicker_off()
	alter_flicker(FALSE)
	flicker_timer = addtimer(CALLBACK(src, PROC_REF(flicker_on)), rand(5, 50))

/obj/machinery/light/Initialize(mapload = TRUE)
	. = ..()
	if(on)
		maploaded = TRUE

	if(roundstart_flicker)
		start_flickering()

/obj/item/light/tube
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/lights/icons/lighting.dmi'
	lefthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/lights/icons/lights_lefthand.dmi'
	righthand_file = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/lights/icons/lights_righthand.dmi'


/obj/machinery/light/multitool_act(mob/living/user, obj/item/multitool)
	if(!constant_flickering)
		balloon_alert(user, "ballast is already working!")
		return TOOL_ACT_TOOLTYPE_SUCCESS

	balloon_alert(user, "repairing the ballast...")
	if(do_after(user, 2 SECONDS, src))
		stop_flickering()
		balloon_alert(user, "ballast repaired!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	return ..()

#undef NIGHTSHIFT_LIGHT_MODIFIER
#undef NIGHTSHIFT_COLOR_MODIFIER
