/obj/structure/window
	/// A variable for mappers to make the window start polarized, with a specific
	/// id linked, for the polarization controller to link to. Mapping stuff.
	/// Should usually be a string, so it doesn't get confused with what players
	/// can make the id on the controller be.
	/// HAS NO EFFECT AFTER THE WINDOW HAS BEEN THROUGH `Initialize()`!!!
	var/polarizer_id_on_spawn = ""

/obj/structure/window/Initialize(mapload, direct)
	. = ..()

	if(polarizer_id_on_spawn)
		AddComponent(/datum/component/polarization_controller, polarizer_id = polarizer_id_on_spawn)


/obj/effect/spawner/structure/window
	/// A variable for mappers to make the windows spawned by this spawner to
	/// start polarized, with a specific id linked, for the polarization
	/// controller to link to. Mapping stuff. Should usually be a string, so it
	/// doesn't get confused with what players can make the id on the controller be.
	/// FOR MAPPERS ONLY. DONE THIS WAY TO AVOID HAVING TO CREATE A TON OF SUBTYPES.
	var/polarizer_id = ""


/obj/effect/spawner/structure/window/Initialize(mapload)
	if(!polarizer_id)
		return ..()

	// We do this so that we spawn everything in order, but we also add the
	// polarization_controller component to all the windows that we spawn.
	for(var/spawn_type in spawn_list)
		var/obj/structure/window/spawned_window = new spawn_type(loc)

		if(!istype(spawned_window))
			continue

		spawned_window.AddComponent(/datum/component/polarization_controller, polarizer_id = polarizer_id)


	spawn_list = list()

	return ..()

/obj/structure/window/fulltile/colony_fabricator
	name = "prefabricated window"
	desc = "A conservatively built metal frame with a thick sheet of space-grade glass slotted into it."
	icon = 'monkestation/code/modules/blueshift/icons/prefab_window.dmi'
	icon_state = "prefab-0"
	base_icon_state = "prefab"
	fulltile = TRUE
	glass_type = /obj/item/stack/sheet/plastic_wall_panel
	glass_amount = 1

/obj/structure/grille/attackby(obj/item/item_in_question, mob/user, params)
	if(!istype(item_in_question, /obj/item/stack/sheet/plastic_wall_panel))
		return ..()

	if(broken)
		return
	var/obj/item/stack/stack_in_question = item_in_question
	if(stack_in_question.get_amount() < 1)
		to_chat(user, span_warning("You need at least one plastic panel for that!"))
		return
	var/dir_to_set = SOUTHWEST
	if(!anchored)
		to_chat(user, span_warning("[src] needs to be fastened to the floor first!"))
		return
	for(var/obj/structure/window/window_on_turf in loc)
		to_chat(user, span_warning("There is already a window there!"))
		return
	if(!clear_tile(user))
		return
	to_chat(user, span_notice("You start placing the window..."))
	if(!do_after(user, 1 SECONDS, target = src))
		return
	if(!src.loc || !anchored) //Grille broken or unanchored while waiting
		return
	for(var/obj/structure/window/window_on_turf in loc) //Another window already installed on grille
		return
	if(!clear_tile(user))
		return
	var/obj/structure/window/new_window = new /obj/structure/window/fulltile/colony_fabricator(drop_location())
	new_window.setDir(dir_to_set)
	new_window.state = 0
	stack_in_question.use(1)
	to_chat(user, span_notice("You place [new_window] on [src]."))
