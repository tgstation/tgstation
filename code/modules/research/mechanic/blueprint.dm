/obj/item/research_blueprint //These are NOT the engineer blueprints
	name = "blueprint"
	desc = "An electromagnetic blueprint design, used by mechanics. The white lines and doodles are just for show."
	icon = 'icons/obj/machines/mechanic.dmi'
	icon_state = "blueprint"
	var/datum/design/mechanic_design/stored_design = null
	var/design_type = "" //istype is 2longafunction4me
	var/delete_on_use = 1 //whether the blueprint is used up on use
	var/change_design_count = 1

/obj/item/research_blueprint/nano //nano kind
	name = "nanoprint"
	icon_state = "nanoprint"
	desc = "An electromagnetic nanoprint design, used by mechanics. This nanopaper variant is more advanced than the normal version."
	change_design_count = 0

/obj/item/research_blueprint/New(var/new_loc, var/datum/design/mechanic_design/printed_design, var/maxuses = 0 as num)
	..(new_loc)

	if(!istype(printed_design))
		return

	stored_design = printed_design
	design_type = stored_design.design_type

	if(stored_design) //if it doesn't have a source (like a printer), a blueprint can have no design
		name = "[design_type] " + name + " ([printed_design.name])"

	if(change_design_count && maxuses > 0) //can't change nano uses
		printed_design.uses = maxuses
	else
		printed_design.uses = -1

	pixel_x = rand(-3, 3)
	pixel_y = rand(-5, 6)