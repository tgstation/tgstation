/obj/item/bodybag/lost_crew
	name = "long-term body bag"
	desc = "A folded bag designed for the long-term storage and transportation of cadavers."
	unfoldedbag_path = /obj/structure/closet/body_bag/lost_crew
	icon_state = "bodybag_lost_folded"

/obj/structure/closet/body_bag/lost_crew
	name = "long-term body bag"
	desc = "A plastic bag designed for the long-term storage and transportation of cadavers."

	icon_state = "bodybag_lost"

	foldedbag_path = /obj/item/bodybag/lost_crew

/// Filled with one body. If folded, gives the parent type so we dont make infinite corpses
/obj/structure/closet/body_bag/lost_crew/with_body
	/// Whether or not we spawn a paper with everything thats happened to the body
	var/debug = FALSE

/obj/structure/closet/body_bag/lost_crew/with_body/PopulateContents()
	. = ..()

	var/list/recovered_items = list()
	var/list/protected_items = list()
	var/list/lost_crew_data = list()
	var/mob/living/corpse = GLOB.lost_crew_manager.create_lost_crew(revivable = TRUE, recovered_items = recovered_items, protected_items = protected_items, body_data = lost_crew_data)
	corpse.mind_initialize()
	corpse.forceMove(src)

	// Drop stuff like dropped limbs and organs with them in the bag
	for(var/obj/object in recovered_items)
		object.forceMove(src)

	// Spawn a mind lockbox with job stuffs for them to work with when they return
	if(protected_items.len && corpse.mind)
		var/obj/item/storage/lockbox/mind/box = new(src)
		box.mind = corpse.mind
		for(var/obj/object in protected_items)
			object.forceMove(box)

	process_data(lost_crew_data)

/obj/structure/closet/body_bag/lost_crew/with_body/proc/process_data(list/crew_data)
	if(!debug)
		return

	var/obj/item/paper/paper = new(src)
	paper.add_raw_text(english_list(crew_data), advanced_html = TRUE)

/// Subtype for debugging damage types
/obj/structure/closet/body_bag/lost_crew/with_body/debug
	debug = TRUE
