/obj/item/ashtray
	name = "ashtray"
	desc = "It's a tray. For ash."

	icon = 'icons/obj/ashtrays.dmi'
	icon_state = "ashtray"

	color = "#2d3438"

	appearance_flags = KEEP_APART | LONG_GLIDE | PIXEL_SCALE | TILE_BOUND

	var/max_cigs = 30
	var/cig_count = 0
	var/list/allowed_types = list(
		/obj/item/cigarette,
		/obj/item/match,
		/obj/item/cigbutt
	)

/obj/item/ashtray/material
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/obj/item/ashtray/material/iron
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT)

/obj/item/ashtray/material/glass
	custom_materials = list(/datum/material/glass=SHEET_MATERIAL_AMOUNT)

/obj/effect/spawner/random/ashtray
	name = "random ashtray spawner"
	icon = 'icons/obj/ashtrays.dmi'
	icon_state = "random"
	loot = list(
		/obj/item/ashtray/,
		/obj/item/ashtray/material/iron,
		/obj/item/ashtray/material/glass
	)

/obj/item/ashtray/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_CAN_BE_WASHED_IN_SINK, PROC_REF(can_be_washed_in_sink))
	RegisterSignal(src, COMSIG_ITEM_WASHED_IN_SINK, PROC_REF(on_washed_in_sink))	// i have no clue what i'm doing
	cig_count = rand(0, 3)
	update_appearance()

/obj/item/ashtray/item_interaction(mob/living/user,	obj/item/C,	list/modifiers)
	if (cig_count >= max_cigs)
		balloon_alert(user, "it's full!")
		return

	if (is_type_in_list(C, allowed_types))
		cig_count++
		qdel(C)
		update_appearance()
		user.visible_message(
			span_notice("[user] puts [C] into [src]."),
			span_notice("You put [C] into [src].")
		)
		return

	balloon_alert(user, "wrong item!")

/obj/item/ashtray/proc/set_cig_count(new_amount = 0)
	if(cig_count == new_amount)
		return
	cig_count = new_amount
	update_appearance()

/obj/item/ashtray/update_overlays()
	. = ..()

	overlays = list()

	var/image/overlay = null

	switch(cig_count)
		if(1)
			overlay += image("one")
		if(2)
			overlay += image("two")
		if(3)
			overlay += image("three")
		if(4 to 6)
			overlay += image("more")
		if(7 to 12)
			overlay += image("evenMore")
		if(13 to 18)
			overlay += image("whatTheFuck")
		if(19 to 24)
			overlay += image("pleaseStop")
		if(25 to INFINITY)
			overlay += image("full")

	if (overlay)
		overlay.appearance_flags = RESET_COLOR | RESET_ALPHA	// applying these flags to further prevent color
		overlays += overlay		// and alpha from being affected by material


/obj/item/ashtray/update_appearance()
	. = ..()
	// appearance_flags &= ~KEEP_TOGETHER		// to keep overlays unaffected by material's color/alpha
	// TODO: figure out a way to get rid of KEEP_TOGETHER flag

// designs
/datum/design/ashtray/material
	name = "Ashtray"
	id = "ashtraymat"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE
	materials = list(MAT_CATEGORY_ITEM_MATERIAL = SMALL_MATERIAL_AMOUNT)
	build_path = /obj/item/ashtray/material
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_KITCHEN,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/ashtray/black
	name = "Black Ashtray"
	id = "ashtraybl"
	build_path = /obj/item/ashtray
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT,)
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_KITCHEN,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

// washing in sink
/obj/item/ashtray/proc/can_be_washed_in_sink()
	return TRUE

/obj/item/ashtray/proc/on_washed_in_sink()
	set_cig_count(new_amount = 0)
