#define MAX_CIGS 30

/obj/item/ashtray
	name = "ashtray"
	desc = "It's a tray. For ash."

	icon = 'icons/obj/ashtrays.dmi'
	icon_state = "ashtray"

	overlays = list()

	color = "#2d3438"

	appearance_flags = KEEP_APART | LONG_GLIDE | PIXEL_SCALE | TILE_BOUND

	var/cigCount = 0
	var/list/allowedTypes = list(
		/obj/item/cigarette,
		/obj/item/match,
		/obj/item/cigbutt
	)

/obj/item/ashtray/material
	color = "#ffffff"
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/obj/item/ashtray/material/iron
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT)

/obj/item/ashtray/material/iron/black
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_AFFECT_STATISTICS
	color = "#2d3438"

/obj/item/ashtray/material/glass
	custom_materials = list(/datum/material/glass=SHEET_MATERIAL_AMOUNT)

/obj/effect/spawner/random/ashtray
	name = "random ashtray spawner"
	icon = 'icons/obj/ashtrays.dmi'
	icon_state = "random"
	loot = list(
		/obj/item/ashtray/material/iron,
		/obj/item/ashtray/material/iron/black,
		/obj/item/ashtray/material/glass
	)

/obj/item/ashtray/Initialize()
	cigCount = rand(0, 3)
	update_appearance()
	..()
	appearance_flags &= ~KEEP_TOGETHER		// to keep overlays unaffected by material's color/alpha

/obj/item/ashtray/attackby(obj/item/C, mob/living/user)
    if (cigCount >= MAX_CIGS)
        to_chat(user, span_notice("The ashtray is full!"))
        return

    for (var/type in allowedTypes)
        if (istype(C, type))
            cigCount++
            qdel(C)
            update_appearance()
            user.visible_message(
                span_notice("[user] puts out a [C] into the ashtray."),
                span_notice("You put out a [C] into the ashtray.")
            )
            return

    to_chat(user, span_notice("You can't put it in there."))


/obj/item/ashtray/update_appearance()

	overlays = list()

	var/image/overlay = null

	if (cigCount == 1)
		overlay += image("one")
	else if (cigCount == 2)
		overlay += image("two")
	else if (cigCount == 3)
		overlay += image("three")
	else if (cigCount >= 4 && cigCount <= 6)
		overlay += image("more")
	else if (cigCount >= 7 && cigCount <= 12)
		overlay += image("evenMore")
	else if (cigCount >= 13 && cigCount <= 18)
		overlay += image("whatTheFuck")
	else if (cigCount >= 19 && cigCount <= 24)
		overlay += image("pleaseStop")
	else if (cigCount >= 25)
		overlay += image("full")

	if (overlay)
		overlay.appearance_flags = RESET_COLOR | RESET_ALPHA		// applying these flags to further prevent color
		overlays += overlay											// and alpha from being affected by material

	..()

// designs
/datum/design/ashtray/iron
	name = "Iron Ashtray"
	id = "ashtrayir"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/ashtray/material/iron
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_KITCHEN,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/ashtray/iron/black
	name = "Black Iron Ashtray"
	id = "ashtrayirbl"
	build_path = /obj/item/ashtray/material/iron/black

/datum/design/ashtray/glass
	name = "Glass Ashtray"
	id = "ashtraygl"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE
	materials = list(
		/datum/material/glass = SMALL_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/ashtray/material/glass
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_KITCHEN,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE
