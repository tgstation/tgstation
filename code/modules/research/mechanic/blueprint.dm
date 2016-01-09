/obj/item/research_blueprint //These are NOT the engineer blueprints
	name = "blueprint"
	desc = "An electromagnetic blueprint design, used by mechanics. The white lines and doodles are just for show."
	icon = 'icons/obj/machines/mechanic.dmi'
	icon_state = "blueprint"
	var/datum/design/stored_design = null
	var/build_type = "" //istype is 2longafunction4me
	var/delete_on_use = 1 //whether the blueprint is used up on use

/obj/item/research_blueprint/nano //nano kind
	name = "nanoprint"
	icon_state = "nanoprint"
	desc = "An electromagnetic nanoprint design, used by mechanics. This nanopaper variant is more advanced than the normal version."
	delete_on_use = 0


/obj/item/research_blueprint/New(var/new_loc, var/datum/design/printed_design)
	..(new_loc)

	if(!istype(printed_design))
		return

	stored_design = printed_design
	build_type = stored_design.build_type

	if(stored_design) //if it doesn't have a source (like a printer), a blueprint can have no design
		name = "[build_type == FLATPACKER ? "machine" : "item"] " + name + " ([printed_design.name])"

	pixel_x = rand(-3, 3)
	pixel_y = rand(-5, 6)
