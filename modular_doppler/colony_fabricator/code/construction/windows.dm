/obj/structure/window/fulltile/colony_fabricator
	name = "prefabricated window"
	desc = "A conservatively built metal frame with a thick sheet of space-grade glass slotted into it."
	icon = 'modular_doppler/colony_fabricator/icons/prefab_window.dmi'
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
