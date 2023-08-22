// RAPID LIGHTING DEVICE

#define GLOW_MODE 3
#define LIGHT_MODE 2
#define REMOVE_MODE 1

/obj/item/construction/rld
	name = "Rapid Lighting Device"
	desc = "A device used to rapidly provide lighting sources to an area. Reload with iron, plasteel, glass or compressed matter cartridges."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rld"
	worn_icon_state = "RPD"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	matter = 200
	max_matter = 200
	slot_flags = ITEM_SLOT_BELT
	has_ammobar = TRUE
	ammo_sections = 6
	///it does not make sense why any of these should be installed
	banned_upgrades = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS | RCD_UPGRADE_FURNISHING | RCD_UPGRADE_ANTI_INTERRUPT | RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN

	var/mode = LIGHT_MODE
	var/wallcost = 10
	var/floorcost = 15
	var/launchcost = 5
	var/deconcost = 10

	var/condelay = 10
	var/decondelay = 15

	///reference to thr original icons
	var/list/original_options = list(
		"Color Pick" = icon(icon = 'icons/hud/radial.dmi', icon_state = "omni"),
		"Glow Stick" = icon(icon = 'icons/obj/lighting.dmi', icon_state = "glowstick"),
		"Deconstruct" = icon(icon = 'icons/obj/tools.dmi', icon_state = "wrench"),
		"Light Fixture" = icon(icon = 'icons/obj/lighting.dmi', icon_state = "ltube"),
	)
	///will contain the original icons modified with the color choice
	var/list/display_options = list()
	var/color_choice = "#ffffff"

/obj/item/construction/rld/Initialize(mapload)
	. = ..()
	for(var/option in original_options)
		display_options[option] = icon(original_options[option])

/obj/item/construction/rld/attack_self(mob/user)
	. = ..()

	if((upgrade & RCD_UPGRADE_SILO_LINK) && display_options["Silo Link"] == null) //silo upgrade instaled but option was not updated then update it just one
		display_options["Silo Link"] = icon(icon = 'icons/obj/mining.dmi', icon_state = "silo")

	var/choice = show_radial_menu(user, src, display_options, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	if(!choice)
		return

	switch(choice)
		if("Light Fixture")
			mode = LIGHT_MODE
			to_chat(user, span_notice("You change RLD's mode to 'Permanent Light Construction'."))
		if("Glow Stick")
			mode = GLOW_MODE
			to_chat(user, span_notice("You change RLD's mode to 'Light Launcher'."))
		if("Color Pick")
			var/new_choice = input(user,"","Choose Color",color_choice) as color
			if(new_choice == null)
				return

			var/list/new_rgb = ReadRGB(new_choice)
			for(var/option in original_options)
				if(option == "Color Pick" || option == "Deconstruct" || option == "Silo Link")
					continue
				var/icon/icon = icon(original_options[option])
				icon.SetIntensity(new_rgb[1]/255, new_rgb[2]/255, new_rgb[3]/255) //apply new scale
				display_options[option] = icon

			color_choice = new_choice
		if("Deconstruct")
			mode = REMOVE_MODE
			to_chat(user, span_notice("You change RLD's mode to 'Deconstruct'."))
		else
			toggle_silo(user)

/obj/item/construction/rld/afterattack(atom/A, mob/user)
	. = ..()
	if(!range_check(A,user))
		return
	var/turf/start = get_turf(src)
	switch(mode)
		if(REMOVE_MODE)
			if(!istype(A, /obj/machinery/light/))
				return FALSE

			//resource sanity checks before & after delay
			if(!checkResource(deconcost, user))
				return FALSE
			var/beam = user.Beam(A,icon_state="light_beam", time = 15)
			playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
			if(!do_after(user, decondelay, target = A))
				qdel(beam)
				return FALSE
			if(!checkResource(deconcost, user))
				return FALSE

			if(!useResource(deconcost, user))
				return FALSE
			activate()
			qdel(A)
			return TRUE

		if(LIGHT_MODE)
			//resource sanity checks before & after delay
			if(!checkResource(floorcost, user))
				return FALSE
			var/beam = user.Beam(A,icon_state="light_beam", time = condelay)
			playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
			playsound(loc, 'sound/effects/light_flicker.ogg', 50, FALSE)
			if(!do_after(user, condelay, target = A))
				qdel(beam)
				return FALSE
			if(!checkResource(floorcost, user))
				return FALSE

			if(iswallturf(A))
				var/turf/open/winner = null
				var/winning_dist = null
				var/skip = FALSE
				for(var/direction in GLOB.cardinals)
					var/turf/C = get_step(A, direction)
					//turf already has a light
					skip = FALSE
					for(var/obj/machinery/light/dupe in C)
						if(istype(dupe, /obj/machinery/light))
							skip = TRUE
							break
					if(skip)
						continue
					//can't put a light here
					if(!(isspaceturf(C) || TURF_SHARES(C)))
						continue
					//find turf closest to our player
					var/x0 = C.x
					var/y0 = C.y
					var/contender = CHEAP_HYPOTENUSE(start.x, start.y, x0, y0)
					if(!winner)
						winner = C
						winning_dist = contender
					else if(contender < winning_dist) // lower is better
						winner = C
						winning_dist = contender
				if(!winner)
					balloon_alert(user, "no valid target!")
					return FALSE

				if(!useResource(wallcost, user))
					return FALSE
				activate()
				var/obj/machinery/light/L = new /obj/machinery/light(get_turf(winner))
				L.setDir(get_dir(winner, A))
				L.color = color_choice
				L.set_light_color(color_choice)
				return TRUE

			if(isfloorturf(A))
				var/turf/target = get_turf(A)
				for(var/obj/machinery/light/floor/dupe in target)
					if(istype(dupe))
						return FALSE

				if(!useResource(floorcost, user))
					return FALSE
				activate()
				var/obj/machinery/light/floor/FL = new /obj/machinery/light/floor(target)
				FL.color = color_choice
				FL.set_light_color(color_choice)
				return TRUE

		if(GLOW_MODE)
			if(!useResource(launchcost, user))
				return FALSE
			activate()
			var/obj/item/flashlight/glowstick/G = new /obj/item/flashlight/glowstick(start)
			G.color = color_choice
			G.set_light_color(G.color)
			G.throw_at(A, 9, 3, user)
			G.on = TRUE
			G.update_brightness()

			return TRUE

/obj/item/construction/rld/mini
	name = "mini-rapid-light-device"
	desc = "A device used to rapidly provide lighting sources to an area. Reload with iron, plasteel, glass or compressed matter cartridges."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rld"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	matter = 100
	max_matter = 100

#undef GLOW_MODE
#undef LIGHT_MODE
#undef REMOVE_MODE
