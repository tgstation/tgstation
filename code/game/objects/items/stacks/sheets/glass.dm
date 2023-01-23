/* Glass stack types
 * Contains:
 * Glass sheets
 * Reinforced glass sheets
 * Glass shards - TODO: Move this into code/game/object/item/weapons
 */

/*
 * Glass sheets
 */
GLOBAL_LIST_INIT(glass_recipes, list ( \
	new/datum/stack_recipe("directional window", /obj/structure/window/unanchored, time = 0, on_solid_ground = TRUE, window_checks = TRUE, category = CAT_WINDOWS), \
	new/datum/stack_recipe("fulltile window", /obj/structure/window/fulltile/unanchored, 2, time = 0, on_solid_ground = TRUE, window_checks = TRUE, category = CAT_WINDOWS), \
	new/datum/stack_recipe("glass shard", /obj/item/shard, time = 0, on_solid_ground = TRUE, category = CAT_MISC), \
	new/datum/stack_recipe("glass tile", /obj/item/stack/tile/glass, 1, 4, 20, category = CAT_TILES) \
))

/obj/item/stack/sheet/glass
	name = "glass"
	desc = "HOLY SHEET! That is a lot of glass."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	inhand_icon_state = "sheet-glass"
	mats_per_unit = list(/datum/material/glass=MINERAL_MATERIAL_AMOUNT)
	armor_type = /datum/armor/sheet_glass
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/glass
	grind_results = list(/datum/reagent/silicon = 20)
	material_type = /datum/material/glass
	point_value = 1
	tableVariant = /obj/structure/table/glass
	matter_amount = 4
	cost = 500
	source = /datum/robot_energy_storage/glass

/datum/armor/sheet_glass
	fire = 50
	acid = 100

/obj/item/stack/sheet/glass/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to slice [user.p_their()] neck with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/stack/sheet/glass/fifty
	amount = 50

/obj/item/stack/sheet/glass/get_main_recipes()
	. = ..()
	. += GLOB.glass_recipes

/obj/item/stack/sheet/glass/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if (get_amount() < 1 || CC.get_amount() < 5)
			to_chat(user, span_warning("You need five lengths of coil and one sheet of glass to make wired glass!"))
			return
		CC.use(5)
		use(1)
		to_chat(user, span_notice("You attach wire to the [name]."))
		var/obj/item/stack/light_w/new_tile = new(user.loc)
		if (!QDELETED(new_tile))
			new_tile.add_fingerprint(user)
		return
	if(istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/V = W
		if (V.get_amount() >= 1 && get_amount() >= 1)
			var/obj/item/stack/sheet/rglass/RG = new (get_turf(user))
			if(!QDELETED(RG))
				RG.add_fingerprint(user)
			var/replace = user.get_inactive_held_item() == src
			V.use(1)
			use(1)
			if(QDELETED(src) && replace && !QDELETED(RG))
				user.put_in_hands(RG)
		else
			to_chat(user, span_warning("You need one rod and one sheet of glass to make reinforced glass!"))
		return
	return ..()

GLOBAL_LIST_INIT(pglass_recipes, list ( \
	new/datum/stack_recipe("directional window", /obj/structure/window/plasma/unanchored, time = 0, on_solid_ground = TRUE, window_checks = TRUE, category = CAT_WINDOWS), \
	new/datum/stack_recipe("fulltile window", /obj/structure/window/plasma/fulltile/unanchored, 2, time = 0, on_solid_ground = TRUE, window_checks = TRUE, category = CAT_WINDOWS), \
	new/datum/stack_recipe("plasma glass shard", /obj/item/shard/plasma, time = 20, on_solid_ground = TRUE, category = CAT_MISC), \
	new/datum/stack_recipe("plasma glass tile", /obj/item/stack/tile/glass/plasma, 1, 4, 20, category = CAT_TILES) \
))

/obj/item/stack/sheet/plasmaglass
	name = "plasma glass"
	desc = "A glass sheet made out of a plasma-silicate alloy. It looks extremely tough and heavily fire resistant."
	singular_name = "plasma glass sheet"
	icon_state = "sheet-pglass"
	inhand_icon_state = "sheet-pglass"
	mats_per_unit = list(/datum/material/alloy/plasmaglass=MINERAL_MATERIAL_AMOUNT)
	material_type = /datum/material/alloy/plasmaglass
	armor_type = /datum/armor/sheet_plasmaglass
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/plasmaglass
	grind_results = list(/datum/reagent/silicon = 20, /datum/reagent/toxin/plasma = 10)
	material_flags = NONE
	tableVariant = /obj/structure/table/glass/plasmaglass

/obj/item/stack/sheet/plasmaglass/fifty
	amount = 50

/datum/armor/sheet_plasmaglass
	fire = 75
	acid = 100

/obj/item/stack/sheet/plasmaglass/get_main_recipes()
	. = ..()
	. += GLOB.pglass_recipes

/obj/item/stack/sheet/plasmaglass/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)

	if(istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/V = W
		if (V.get_amount() >= 1 && get_amount() >= 1)
			var/obj/item/stack/sheet/plasmarglass/RG = new (get_turf(user))
			if (!QDELETED(RG))
				RG.add_fingerprint(user)
			var/replace = user.get_inactive_held_item() == src
			V.use(1)
			use(1)
			if(QDELETED(src) && replace)
				user.put_in_hands(RG)
		else
			to_chat(user, span_warning("You need one rod and one sheet of plasma glass to make reinforced plasma glass!"))
			return
	else
		return ..()

/*
 * Reinforced glass sheets
 */
GLOBAL_LIST_INIT(reinforced_glass_recipes, list ( \
	new/datum/stack_recipe("windoor frame", /obj/structure/windoor_assembly, 5, time = 0, on_solid_ground = TRUE, window_checks = TRUE, category = CAT_WINDOWS), \
	null, \
	new/datum/stack_recipe("directional reinforced window", /obj/structure/window/reinforced/unanchored, time = 0, on_solid_ground = TRUE, window_checks = TRUE, category = CAT_WINDOWS), \
	new/datum/stack_recipe("fulltile reinforced window", /obj/structure/window/reinforced/fulltile/unanchored, 2, time = 0, on_solid_ground = TRUE, window_checks = TRUE, category = CAT_WINDOWS), \
	new/datum/stack_recipe("glass shard", /obj/item/shard, time = 10, on_solid_ground = TRUE, category = CAT_MISC), \
	new/datum/stack_recipe("reinforced glass tile", /obj/item/stack/tile/rglass, 1, 4, 20, category = CAT_TILES) \
))


/obj/item/stack/sheet/rglass
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"
	inhand_icon_state = "sheet-rglass"
	mats_per_unit = list(/datum/material/iron=MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/glass=MINERAL_MATERIAL_AMOUNT)
	armor_type = /datum/armor/sheet_rglass
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/rglass
	grind_results = list(/datum/reagent/silicon = 20, /datum/reagent/iron = 10)
	point_value = 4
	matter_amount = 6
	tableVariant = /obj/structure/table/reinforced/rglass

/datum/armor/sheet_rglass
	fire = 70
	acid = 100

/obj/item/stack/sheet/rglass/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	..()

/obj/item/stack/sheet/rglass/cyborg
	mats_per_unit = null
	cost = 250
	source = /datum/robot_energy_storage/iron

	/// What energy storage this draws glass from as a robot module.
	var/datum/robot_energy_storage/glasource = /datum/robot_energy_storage/glass
	/// The amount of energy this draws from the glass source per stack unit.
	var/glacost = 500

/obj/item/stack/sheet/rglass/cyborg/get_amount()
	return min(round(source.energy / cost), round(glasource.energy / glacost))

/obj/item/stack/sheet/rglass/cyborg/use(used, transfer = FALSE, check = TRUE) // Requires special checks, because it uses two storages
	if(get_amount(used)) //ensure we still have enough energy if called in a do_after chain
		source.use_charge(used * cost)
		glasource.use_charge(used * glacost)
		return TRUE

/obj/item/stack/sheet/rglass/cyborg/add(amount)
	source.add_charge(amount * cost)
	glasource.add_charge(amount * glacost)

/obj/item/stack/sheet/rglass/get_main_recipes()
	. = ..()
	. += GLOB.reinforced_glass_recipes

GLOBAL_LIST_INIT(prglass_recipes, list ( \
	new/datum/stack_recipe("directional reinforced window", /obj/structure/window/reinforced/plasma/unanchored, time = 0, on_solid_ground = TRUE, window_checks = TRUE, category = CAT_WINDOWS), \
	new/datum/stack_recipe("fulltile reinforced window", /obj/structure/window/reinforced/plasma/fulltile/unanchored, 2, time = 0, on_solid_ground = TRUE, window_checks = TRUE, category = CAT_WINDOWS), \
	new/datum/stack_recipe("plasma glass shard", /obj/item/shard/plasma, time = 40, on_solid_ground = TRUE, category = CAT_MISC), \
	new/datum/stack_recipe("reinforced plasma glass tile", /obj/item/stack/tile/rglass/plasma, 1, 4, 20, category = CAT_TILES) \
))

/obj/item/stack/sheet/plasmarglass
	name = "reinforced plasma glass"
	desc = "A glass sheet made out of a plasma-silicate alloy and a rod matrix. It looks hopelessly tough and nearly fire-proof!"
	singular_name = "reinforced plasma glass sheet"
	icon_state = "sheet-prglass"
	inhand_icon_state = "sheet-prglass"
	mats_per_unit = list(/datum/material/alloy/plasmaglass=MINERAL_MATERIAL_AMOUNT, /datum/material/iron = MINERAL_MATERIAL_AMOUNT * 0.5)
	armor_type = /datum/armor/sheet_plasmarglass
	resistance_flags = ACID_PROOF
	material_flags = NONE
	merge_type = /obj/item/stack/sheet/plasmarglass
	grind_results = list(/datum/reagent/silicon = 20, /datum/reagent/toxin/plasma = 10, /datum/reagent/iron = 10)
	point_value = 23
	matter_amount = 8
	tableVariant = /obj/structure/table/reinforced/plasmarglass

/datum/armor/sheet_plasmarglass
	melee = 20
	fire = 80
	acid = 100

/obj/item/stack/sheet/plasmarglass/get_main_recipes()
	. = ..()
	. += GLOB.prglass_recipes

GLOBAL_LIST_INIT(titaniumglass_recipes, list(
	new/datum/stack_recipe("shuttle window", /obj/structure/window/reinforced/shuttle/unanchored, 2, time = 0, on_solid_ground = TRUE, window_checks = TRUE, category = CAT_WINDOWS), \
	new/datum/stack_recipe("titanium glass shard", /obj/item/shard/titanium, time = 40, on_solid_ground = TRUE, category = CAT_MISC) \
	))

/obj/item/stack/sheet/titaniumglass
	name = "titanium glass"
	desc = "A glass sheet made out of a titanium-silicate alloy."
	singular_name = "titanium glass sheet"
	icon_state = "sheet-titaniumglass"
	inhand_icon_state = "sheet-titaniumglass"
	mats_per_unit = list(/datum/material/alloy/titaniumglass=MINERAL_MATERIAL_AMOUNT)
	material_type = /datum/material/alloy/titaniumglass
	armor_type = /datum/armor/sheet_titaniumglass
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/titaniumglass
	tableVariant = /obj/structure/table/reinforced/titaniumglass

/obj/item/stack/sheet/titaniumglass/fifty
	amount = 50

/datum/armor/sheet_titaniumglass
	fire = 80
	acid = 100

/obj/item/stack/sheet/titaniumglass/get_main_recipes()
	. = ..()
	. += GLOB.titaniumglass_recipes

GLOBAL_LIST_INIT(plastitaniumglass_recipes, list(
	new/datum/stack_recipe("plastitanium window", /obj/structure/window/reinforced/plasma/plastitanium/unanchored, 2, time = 0, on_solid_ground = TRUE, window_checks = TRUE, category = CAT_WINDOWS) \
	))

/obj/item/stack/sheet/plastitaniumglass
	name = "plastitanium glass"
	desc = "A glass sheet made out of a plasma-titanium-silicate alloy."
	singular_name = "plastitanium glass sheet"
	icon_state = "sheet-plastitaniumglass"
	inhand_icon_state = "sheet-plastitaniumglass"
	mats_per_unit = list(/datum/material/alloy/plastitaniumglass=MINERAL_MATERIAL_AMOUNT)
	material_type = /datum/material/alloy/plastitaniumglass
	armor_type = /datum/armor/sheet_plastitaniumglass
	material_flags = NONE
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/plastitaniumglass
	tableVariant = /obj/structure/table/reinforced/plastitaniumglass

/datum/armor/sheet_plastitaniumglass
	fire = 80
	acid = 100

/obj/item/stack/sheet/plastitaniumglass/get_main_recipes()
	. = ..()
	. += GLOB.plastitaniumglass_recipes

/obj/item/shard
	name = "shard"
	desc = "A nasty looking shard of glass."
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	w_class = WEIGHT_CLASS_TINY
	force = 5
	throwforce = 10
	inhand_icon_state = "shard-glass"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	custom_materials = list(/datum/material/glass=MINERAL_MATERIAL_AMOUNT)
	attack_verb_continuous = list("stabs", "slashes", "slices", "cuts")
	attack_verb_simple = list("stab", "slash", "slice", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	resistance_flags = ACID_PROOF
	armor_type = /datum/armor/item_shard
	max_integrity = 40
	sharpness = SHARP_EDGED
	var/icon_prefix
	var/shiv_type = /obj/item/knife/shiv
	var/craft_time = 3.5 SECONDS
	var/obj/item/stack/sheet/weld_material = /obj/item/stack/sheet/glass
	embedding = list("embed_chance" = 65)

/datum/armor/item_shard
	melee = 100
	energy = 100
	fire = 50
	acid = 100

/obj/item/shard/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is slitting [user.p_their()] [pick("wrists", "throat")] with the shard of glass! It looks like [user.p_theyre()] trying to commit suicide."))
	return BRUTELOSS

/obj/item/shard/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, min_damage = force)
	AddComponent(/datum/component/butchering, \
	speed = 15 SECONDS, \
	effectiveness = 65, \
	)
	icon_state = pick("large", "medium", "small")
	switch(icon_state)
		if("small")
			pixel_x = rand(-12, 12)
			pixel_y = rand(-12, 12)
		if("medium")
			pixel_x = rand(-8, 8)
			pixel_y = rand(-8, 8)
		if("large")
			pixel_x = rand(-5, 5)
			pixel_y = rand(-5, 5)
	if (icon_prefix)
		icon_state = "[icon_prefix][icon_state]"

	var/turf/T = get_turf(src)
	if(T && is_station_level(T.z))
		SSblackbox.record_feedback("tally", "station_mess_created", 1, name)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/shard/Destroy()
	. = ..()

	var/turf/T = get_turf(src)
	if(T && is_station_level(T.z))
		SSblackbox.record_feedback("tally", "station_mess_destroyed", 1, name)

/obj/item/shard/afterattack(atom/A as mob|obj, mob/user, proximity)
	. = ..()
	if(!proximity || !(src in user))
		return
	if(isturf(A))
		return
	if(istype(A, /obj/item/storage))
		return
	var/hit_hand = ((user.active_hand_index % 2 == 0) ? "r_" : "l_") + "arm"
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.gloves && !HAS_TRAIT(H, TRAIT_PIERCEIMMUNE)) // golems, etc
			to_chat(H, span_warning("[src] cuts into your hand!"))
			H.apply_damage(force*0.5, BRUTE, hit_hand)

/obj/item/shard/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/lightreplacer))
		var/obj/item/lightreplacer/lightreplacer = item
		lightreplacer.attackby(src, user)
	else if(istype(item, /obj/item/stack/sheet/cloth))
		var/obj/item/stack/sheet/cloth/cloth = item
		to_chat(user, span_notice("You begin to wrap the [cloth] around the [src]..."))
		if(do_after(user, craft_time, target = src))
			var/obj/item/knife/shiv/shiv = new shiv_type
			cloth.use(1)
			to_chat(user, span_notice("You wrap the [cloth] around the [src], forming a makeshift weapon."))
			remove_item_from_storage(src)
			qdel(src)
			user.put_in_hands(shiv)

	else
		return ..()

/obj/item/shard/welder_act(mob/living/user, obj/item/I)
	if(I.use_tool(src, user, 0, volume=50))
		var/obj/item/stack/sheet/new_glass = new weld_material
		to_chat(user, span_notice("You melt [src] down into [new_glass.name]."))
		new_glass.forceMove((Adjacent(user) ? user.drop_location() : loc)) //stack merging is handled automatically.
		qdel(src)
		return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/shard/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(isliving(AM))
		var/mob/living/L = AM
		if(!(L.movement_type & (FLYING|FLOATING)) || L.buckled)
			playsound(src, 'sound/effects/glass_step.ogg', HAS_TRAIT(L, TRAIT_LIGHT_STEP) ? 30 : 50, TRUE)

/obj/item/shard/plasma
	name = "purple shard"
	desc = "A nasty looking shard of plasma glass."
	force = 6
	throwforce = 11
	icon_state = "plasmalarge"
	inhand_icon_state = "shard-plasma"
	custom_materials = list(/datum/material/alloy/plasmaglass=MINERAL_MATERIAL_AMOUNT)
	icon_prefix = "plasma"
	weld_material = /obj/item/stack/sheet/plasmaglass
	shiv_type = /obj/item/knife/shiv/plasma
	craft_time = 7 SECONDS

/obj/item/shard/titanium
	name = "bright shard"
	desc = "A nasty looking shard of titanium infused glass."
	throwforce = 12
	icon_state = "titaniumlarge"
	inhand_icon_state = "shard-titanium"
	custom_materials = list(/datum/material/alloy/titaniumglass=MINERAL_MATERIAL_AMOUNT)
	icon_prefix = "titanium"
	weld_material = /obj/item/stack/sheet/titaniumglass
	shiv_type = /obj/item/knife/shiv/titanium
	craft_time = 7 SECONDS

/obj/item/shard/plastitanium
	name = "dark shard"
	desc = "A nasty looking shard of titanium infused plasma glass."
	force = 7
	throwforce = 12
	icon_state = "plastitaniumlarge"
	inhand_icon_state = "shard-plastitanium"
	custom_materials = list(/datum/material/alloy/plastitaniumglass=MINERAL_MATERIAL_AMOUNT)
	icon_prefix = "plastitanium"
	weld_material = /obj/item/stack/sheet/plastitaniumglass
	shiv_type = /obj/item/knife/shiv/plastitanium
	craft_time = 14 SECONDS
