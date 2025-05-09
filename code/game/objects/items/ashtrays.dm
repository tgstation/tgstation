#define MAX_CIGS 30

/obj/item/ashtray
	name = "ashtray"
	desc = "It's a tray. For ash."

	icon = 'icons/obj/ashtrays.dmi'
	icon_state = "ashtray"

	color = "#2d3438"

	appearance_flags = KEEP_APART | LONG_GLIDE | PIXEL_SCALE | TILE_BOUND

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
	cig_count = rand(0, 3)
	update_appearance()

/obj/item/ashtray/item_interaction(mob/living/user,	obj/item/C,	list/modifiers)
	if (cig_count >= MAX_CIGS)
		balloon_alert(user, "it's full!")
		return

	if (is_type_in_list(C, allowed_types))
		cig_count++
		qdel(C)
		update_appearance()
		user.visible_message(
			span_notice("[user] puts out [C] into [src]."),
			span_notice("You put out [C] into [src].")
		)
		return

	to_chat(user,	span_notice("You can't put it in there."))

/obj/item/ashtray/update_overlays()
	overlays = list()

	var/image/overlay = null

	if (cig_count == 1)
		overlay += image("one")
	else if (cig_count == 2)
		overlay += image("two")
	else if (cig_count == 3)
		overlay += image("three")
	else if (cig_count >= 4 && cig_count <= 6)
		overlay += image("more")
	else if (cig_count >= 7 && cig_count <= 12)
		overlay += image("evenMore")
	else if (cig_count >= 13 && cig_count <= 18)
		overlay += image("whatTheFuck")
	else if (cig_count >= 19 && cig_count <= 24)
		overlay += image("pleaseStop")
	else if (cig_count >= 25)
		overlay += image("full")

	if (overlay)
		overlay.appearance_flags = RESET_COLOR | RESET_ALPHA		// applying these flags to further prevent color
		overlays += overlay											// and alpha from being affected by material


/obj/item/ashtray/update_appearance()
	. = ..()
	update_overlays()
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

#undef MAX_CIGS
