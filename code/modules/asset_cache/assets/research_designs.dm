// Representative icons for each research design
/datum/asset/spritesheet/research_designs
	name = "design"

/datum/asset/spritesheet/research_designs/create_spritesheets()
	for (var/datum/design/path as anything in subtypesof(/datum/design))
		if(initial(path.id) == DESIGN_ID_IGNORE)
			continue

		var/icon_file
		var/icon_state
		var/icon/I

		if(initial(path.research_icon) && initial(path.research_icon_state)) //If the design has an icon replacement skip the rest
			icon_file = initial(path.research_icon)
			icon_state = initial(path.research_icon_state)
			if (PERFORM_ALL_TESTS(focus_only/invalid_research_designs))
				if(!(icon_state in icon_states(icon_file)))
					stack_trace("design [path] with icon '[icon_file]' missing state '[icon_state]'")
					continue
			I = icon(icon_file, icon_state, SOUTH)

		else
			// construct the icon and slap it into the resource cache
			var/atom/item = initial(path.build_path)
			if (!ispath(item, /atom))
				// biogenerator reagent designs display their default container
				if(initial(path.make_reagent))
					var/datum/reagent/reagent = initial(path.make_reagent)
					item = initial(reagent.default_container)
				else
					continue  // shouldn't happen, but just in case

			// circuit boards become their resulting machines or computers
			if (ispath(item, /obj/item/circuitboard))
				var/obj/item/circuitboard/C = item
				var/machine = initial(C.build_path)
				if (machine)
					item = machine

			// Check for GAGS support where necessary
			var/greyscale_config = initial(item.greyscale_config)
			var/greyscale_colors = initial(item.greyscale_colors)
			if (greyscale_config && greyscale_colors)
				icon_file = SSgreyscale.GetColoredIconByType(greyscale_config, greyscale_colors)
			else
				icon_file = initial(item.icon)

			icon_state = initial(item.icon_state)
			if (PERFORM_ALL_TESTS(focus_only/invalid_research_designs))
				if(!(icon_state in icon_states(icon_file)))
					stack_trace("design [path] with icon '[icon_file]' missing state '[icon_state]'")
					continue
			I = icon(icon_file, icon_state, SOUTH)

			// computers (and snowflakes) get their screen and keyboard sprites
			if (ispath(item, /obj/machinery/computer) || ispath(item, /obj/machinery/power/solar_control))
				var/obj/machinery/computer/C = item
				var/screen = initial(C.icon_screen)
				var/keyboard = initial(C.icon_keyboard)
				var/all_states = icon_states(icon_file)
				if (screen && (screen in all_states))
					I.Blend(icon(icon_file, screen, SOUTH), ICON_OVERLAY)
				if (keyboard && (keyboard in all_states))
					I.Blend(icon(icon_file, keyboard, SOUTH), ICON_OVERLAY)

		Insert(initial(path.id), I)
