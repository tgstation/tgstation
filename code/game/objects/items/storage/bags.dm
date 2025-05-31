#define ORE_BAG_BALOON_COOLDOWN (2 SECONDS)

/*
 * These absorb the functionality of the plant bag, ore satchel, etc.
 * They use the use_to_pickup, quick_gather, and quick_empty functions
 * that were already defined in weapon/storage, but which had been
 * re-implemented in other classes.
 *
 * Contains:
 * Trash Bag
 * Mining Satchel
 * Plant Bag
 * Sheet Snatcher
 * Book Bag
 * Biowaste Bag
 *
 * -Sayu
 */

//  Generic non-item
/obj/item/storage/bag
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_BULKY
	storage_type = /datum/storage/bag

/obj/item/storage/bag/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/service/janitor.dmi'
	icon_state = "trashbag"
	inhand_icon_state = "trashbag"
	worn_icon_state = "trashbag"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	storage_type = /datum/storage/bag/trash
	///If true, can be inserted into the janitor cart
	var/insertable = TRUE

/obj/item/storage/bag/trash/Initialize(mapload)
	. = ..()

	RegisterSignal(atom_storage, COMSIG_STORAGE_DUMP_POST_TRANSFER, PROC_REF(post_insertion))

/// If you dump a trash bag into something, anything that doesn't get inserted will spill out onto your feet
/obj/item/storage/bag/trash/proc/post_insertion(datum/storage/source, atom/dest_object, mob/user)
	SIGNAL_HANDLER
	// If there's no item in there, don't do anything
	if(!(locate(/obj/item) in src))
		return

	// Otherwise, we're gonna dump into the dest object
	var/turf/dump_onto = get_turf(dest_object)
	user.visible_message(
		span_notice("[user] dumps the contents of [src] all out on \the [dump_onto]"),
		span_notice("The remaining trash in \the [src] falls out onto \the [dump_onto]"),
	)
	source.remove_all(dump_onto)

/obj/item/storage/bag/trash/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] puts [src] over [user.p_their()] head and starts chomping at the insides! Disgusting!"))
	playsound(loc, 'sound/items/eatfood.ogg', 50, TRUE, -1)
	return TOXLOSS

/obj/item/storage/bag/trash/update_icon_state()
	switch(contents.len)
		if(20 to INFINITY)
			icon_state = "[initial(icon_state)]3"
		if(11 to 20)
			icon_state = "[initial(icon_state)]2"
		if(1 to 11)
			icon_state = "[initial(icon_state)]1"
		else
			icon_state = "[initial(icon_state)]"
	return ..()

/obj/item/storage/bag/trash/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)

/obj/item/storage/bag/trash/filled/PopulateContents()
	. = ..()
	for(var/i in 1 to rand(1, 7))
		new /obj/effect/spawner/random/trash/garbage(src)
	update_icon_state()

/obj/item/storage/bag/trash/bluespace
	name = "trash bag of holding"
	desc = "The latest and greatest in custodial convenience, a trashbag that is capable of holding vast quantities of garbage."
	icon_state = "bluetrashbag"
	inhand_icon_state = "bluetrashbag"
	item_flags = NO_MAT_REDEMPTION
	storage_type = /datum/storage/bag/trash/bluespace

/obj/item/storage/bag/trash/bluespace/cyborg
	insertable = FALSE

/obj/item/storage/bag/ore
	name = "mining satchel"
	desc = "This little bugger can be used to store and transport ores."
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	worn_icon_state = "satchel"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_POCKETS
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/bag/ore
	///If this is TRUE, the holder won't receive any messages when they fail to pick up ore through crossing it
	var/spam_protection = FALSE
	var/mob/listeningTo
	///Cooldown on balloon alerts when picking ore
	COOLDOWN_DECLARE(ore_bag_balloon_cooldown)

/obj/item/storage/bag/ore/equipped(mob/user)
	. = ..()
	if(listeningTo == user)
		return
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(pickup_ores))
	listeningTo = user

/obj/item/storage/bag/ore/dropped()
	. = ..()
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		listeningTo = null

/obj/item/storage/bag/ore/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/boulder))
		to_chat(user, span_warning("You can't fit [tool] into [src]. \
			Perhaps you should break it down first, or find an ore box."))
		return ITEM_INTERACT_BLOCKING

	return NONE

/obj/item/storage/bag/ore/proc/pickup_ores(mob/living/user)
	SIGNAL_HANDLER

	var/show_message = FALSE
	var/obj/structure/ore_box/box
	var/turf/tile = get_turf(user)

	if(!isturf(tile))
		return

	if(istype(user.pulling, /obj/structure/ore_box))
		box = user.pulling

	if(atom_storage)
		for(var/thing in tile)
			if(!is_type_in_typecache(thing, atom_storage.can_hold))
				continue
			if(box)
				user.transferItemToLoc(thing, box)
				show_message = TRUE
			else if(atom_storage.attempt_insert(thing, user))
				show_message = TRUE
			else
				if(!spam_protection)
					balloon_alert(user, "bag full!")
					spam_protection = TRUE
					continue
	if(show_message)
		playsound(user, SFX_RUSTLE, 50, TRUE)
		if(!COOLDOWN_FINISHED(src, ore_bag_balloon_cooldown))
			return

		COOLDOWN_START(src, ore_bag_balloon_cooldown, ORE_BAG_BALOON_COOLDOWN)
		if (box)
			balloon_alert(user, "scoops ore into box")
			user.visible_message(
				span_notice("[user] offloads the ores beneath [user.p_them()] into [box]."),
				ignored_mobs = user
			)
		else
			balloon_alert(user, "scoops ore into bag")
			user.visible_message(
				span_notice("[user] scoops up the ores beneath [user.p_them()]."),
				ignored_mobs = user
			)

	spam_protection = FALSE

/obj/item/storage/bag/ore/cyborg
	name = "cyborg mining satchel"

/obj/item/storage/bag/ore/holding //miners, your messiah has arrived
	name = "mining satchel of holding"
	desc = "A revolution in convenience, this satchel allows for huge amounts of ore storage. It's been outfitted with anti-malfunction safety measures."
	icon_state = "satchel_bspace"
	storage_type = /datum/storage/bag/ore/holding

/obj/item/storage/bag/plants
	name = "plant bag"
	icon = 'icons/obj/service/hydroponics/equipment.dmi'
	icon_state = "plantbag"
	worn_icon_state = "plantbag"
	resistance_flags = FLAMMABLE
	storage_type = /datum/storage/bag/plants

/obj/item/storage/bag/plants/portaseeder
	name = "portable seed extractor"
	desc = "For the enterprising botanist on the go. Less efficient than the stationary model, it creates one seed per plant."
	icon_state = "portaseeder"

/obj/item/storage/bag/plants/portaseeder/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/storage/bag/plants/portaseeder/add_context(
	atom/source,
	list/context,
	obj/item/held_item,
	mob/living/user
)

	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Make seeds"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/storage/bag/plants/portaseeder/examine(mob/user)
	. = ..()
	. += span_notice("Ctrl-click to activate seed extraction.")

/obj/item/storage/bag/plants/portaseeder/item_ctrl_click(mob/user)
	for(var/obj/item/plant in contents)
		seedify(plant, 1)
	return CLICK_ACTION_SUCCESS

/obj/item/storage/bag/plants/cyborg
	name = "cyborg plant bag"

/obj/item/storage/bag/sheetsnatcher
	name = "sheet snatcher"
	desc = "A patented Nanotrasen storage system designed for any kind of mineral sheet."
	icon = 'icons/obj/mining.dmi'
	icon_state = "sheetsnatcher"
	worn_icon_state = "satchel"
	storage_type = /datum/storage/bag/sheet_snatcher

/obj/item/storage/bag/sheetsnatcher/borg
	name = "sheet snatcher 9000"
	desc = ""
	storage_type = /datum/storage/bag/sheet_snatcher/borg

/obj/item/storage/bag/sheetsnatcher/debug
	name = "sheet snatcher EXTREME EDITION"
	desc = "A Nanotrasen storage system designed which has been given post-market alterations to hold any type of sheet. Comes pre-populated with "
	color = "#ff3737" // I'm too lazy to make a unique sprite
	w_class = WEIGHT_CLASS_TINY
	storage_type = /datum/storage/bag/sheet_snatcher_debug

// Copy-pasted from the former /obj/item/storage/box/material, w/ small additions like rods, cardboard, plastic.
// "Only 20 uranium 'cause of radiation"
/obj/item/storage/bag/sheetsnatcher/debug/PopulateContents()
	// amount should be null if it should spawn with the type's default amount
	var/static/items_inside = list(
		/obj/item/stack/sheet/iron/fifty = null,
		/obj/item/stack/sheet/glass/fifty = null,
		/obj/item/stack/sheet/rglass/fifty = null,
		/obj/item/stack/sheet/plasmaglass/fifty = null,
		/obj/item/stack/sheet/titaniumglass/fifty = null,
		/obj/item/stack/sheet/plastitaniumglass/fifty = null,
		/obj/item/stack/sheet/plasteel/fifty = null,
		/obj/item/stack/sheet/mineral/titanium/fifty = null,
		/obj/item/stack/sheet/mineral/gold = 50,
		/obj/item/stack/sheet/mineral/silver = 50,
		/obj/item/stack/sheet/mineral/plasma = 50,
		/obj/item/stack/sheet/mineral/uranium = 20,
		/obj/item/stack/sheet/mineral/diamond = 50,
		/obj/item/stack/sheet/bluespace_crystal = 50,
		/obj/item/stack/sheet/mineral/bananium = 50,
		/obj/item/stack/sheet/mineral/wood/fifty = null,
		/obj/item/stack/sheet/plastic/fifty = null,
		/obj/item/stack/sheet/runed_metal/fifty = null,
		/obj/item/stack/rods/fifty = null,
		/obj/item/stack/sheet/mineral/plastitanium = 50,
		/obj/item/stack/sheet/mineral/abductor = 50,
		/obj/item/stack/sheet/cardboard/fifty = null,
	)
	for(var/obj/item/stack/stack_type as anything in items_inside)
		var/amt = items_inside[stack_type]
		new stack_type(src, amt, FALSE)

/obj/item/storage/bag/books
	name = "book bag"
	desc = "A bag for books."
	icon = 'icons/obj/service/library.dmi'
	icon_state = "bookbag"
	worn_icon_state = "bookbag"
	resistance_flags = FLAMMABLE
	storage_type = /datum/storage/bag/books

/obj/item/storage/bag/tray
	name = "serving tray"
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "tray"
	worn_icon_state = "tray"
	desc = "A metal tray to lay food on."
	force = 5
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*1.5)
	custom_price = PAYCHECK_CREW * 0.6
	storage_type = /datum/storage/bag/tray

/obj/item/storage/bag/tray/attack(mob/living/M, mob/living/user)
	. = ..()
	// Drop all the things. All of them.
	var/list/obj/item/oldContents = contents.Copy()
	atom_storage.remove_all(user)
	// Make each item scatter a bit
	for(var/obj/item/tray_item in oldContents)
		do_scatter(tray_item)

	if(prob(50))
		playsound(M, 'sound/items/trayhit/trayhit1.ogg', 50, TRUE)
	else
		playsound(M, 'sound/items/trayhit/trayhit2.ogg', 50, TRUE)

	if(ishuman(M))
		if(prob(10))
			M.Paralyze(40)
	update_appearance()

/obj/item/storage/bag/tray/proc/do_scatter(obj/item/tray_item)
	var/delay = rand(2,4)
	var/datum/move_loop/loop = GLOB.move_manager.move_rand(tray_item, list(NORTH,SOUTH,EAST,WEST), delay, timeout = rand(1, 2) * delay, flags = MOVEMENT_LOOP_START_FAST)
	//This does mean scattering is tied to the tray. Not sure how better to handle it
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(change_speed))

/obj/item/storage/bag/tray/proc/change_speed(datum/move_loop/source)
	SIGNAL_HANDLER
	var/new_delay = rand(2, 4)
	var/count = source.lifetime / source.delay
	source.lifetime = count * new_delay
	source.delay = new_delay

/obj/item/storage/bag/tray/update_overlays()
	. = ..()
	for(var/obj/item/I in contents)
		var/mutable_appearance/I_copy = new(I)
		I_copy.plane = FLOAT_PLANE
		I_copy.layer = FLOAT_LAYER
		. += I_copy

/obj/item/storage/bag/tray/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	update_appearance()

/obj/item/storage/bag/tray/Exited(atom/movable/gone, direction)
	. = ..()
	update_appearance()

/obj/item/storage/bag/tray/cafeteria
	name = "cafeteria tray"
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "foodtray"
	desc = "A cheap metal tray to pile today's meal onto."

/obj/item/storage/bag/chemistry
	name = "chemistry bag"
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "bag"
	worn_icon_state = "chembag"
	desc = "A bag for storing pills, patches, and bottles."
	resistance_flags = FLAMMABLE
	storage_type = /datum/storage/bag/chemistry

/obj/item/storage/bag/money
	name = "money bag"
	desc = "A bag for storing your profits."
	icon_state = "moneybag"
	worn_icon_state = "moneybag"
	force = 10
	throwforce = 0
	resistance_flags = FLAMMABLE
	max_integrity = 100
	w_class = WEIGHT_CLASS_BULKY
	storage_type = /datum/storage/bag/money

/obj/item/storage/bag/money/Initialize(mapload)
	. = ..()
	if(prob(20))
		icon_state = "moneybagalt"

/obj/item/storage/bag/money/vault/PopulateContents()
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/adamantine(src)

///Used in the dutchmen pirate shuttle.
/obj/item/storage/bag/money/dutchmen/PopulateContents()
	for(var/iteration in 1 to 9)
		new /obj/item/coin/silver/doubloon(src)
	for(var/iteration in 1 to 9)
		new /obj/item/coin/gold/doubloon(src)
	new /obj/item/coin/adamantine/doubloon(src)

/obj/item/storage/bag/bio
	name = "bio bag"
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "biobag"
	worn_icon_state = "biobag"
	desc = "A bag for the safe transportation and disposal of biowaste and other virulent materials."
	resistance_flags = FLAMMABLE
	storage_type = /datum/storage/bag/bio

/obj/item/storage/bag/xeno
	name = "science bag"
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "xenobag"
	worn_icon_state = "xenobag"
	desc = "A bag for the storage and transport of anomalous materials."
	resistance_flags = FLAMMABLE
	storage_type = /datum/storage/bag/xeno

/obj/item/storage/bag/construction
	name = "construction bag"
	icon = 'icons/obj/tools.dmi'
	icon_state = "construction_bag"
	worn_icon_state = "construction_bag"
	desc = "A bag for storing small construction components."
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_POCKETS
	resistance_flags = FLAMMABLE
	storage_type = /datum/storage/bag/construction

/obj/item/storage/bag/harpoon_quiver
	name = "harpoon quiver"
	desc = "A quiver for holding harpoons."
	icon = 'icons/obj/weapons/bows/quivers.dmi'
	icon_state = "quiver"
	inhand_icon_state = null
	worn_icon_state = "harpoon_quiver"
	storage_type = /datum/storage/bag/harpoon_quiver

/obj/item/storage/bag/harpoon_quiver/PopulateContents()
	for(var/i in 1 to 40)
		new /obj/item/ammo_casing/harpoon(src)

/obj/item/storage/bag/rebar_quiver
	name = "rebar quiver"
	icon = 'icons/obj/weapons/bows/quivers.dmi'
	icon_state = "rebar_quiver"
	worn_icon_state = "rebar_quiver"
	inhand_icon_state = "rebar_quiver"
	desc = "A oxygen tank cut in half, used for holding sharpened rods for the rebar crossbow."
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_SUITSTORE|ITEM_SLOT_NECK
	resistance_flags = FLAMMABLE
	storage_type = /datum/storage/bag/rebar_quiver

/obj/item/storage/bag/rebar_quiver/syndicate
	icon_state = "syndie_quiver_0"
	worn_icon_state = "syndie_quiver_0"
	inhand_icon_state = "holyquiver"
	desc = "A specialized quiver meant to hold any kind of bolts intended for use with the rebar crossbow. \
		Clearly a better design than a cut up oxygen tank..."
	slot_flags = ITEM_SLOT_NECK
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	actions_types = list(/datum/action/item_action/reload_rebar)
	action_slots = ALL
	storage_type = /datum/storage/bag/rebar_quiver/syndicate

/obj/item/storage/bag/rebar_quiver/syndicate/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/storage/bag/rebar_quiver/syndicate/PopulateContents()
	for(var/to_fill in 1 to 20)
		new /obj/item/ammo_casing/rebar/syndie(src)

/obj/item/storage/bag/rebar_quiver/syndicate/update_icon_state()
	. = ..()
	switch(contents.len)
		if(0)
			icon_state = "syndie_quiver_0"
		if(1 to 7)
			icon_state = "syndie_quiver_1"
		if(8 to 13)
			icon_state = "syndie_quiver_2"
		if(14 to 20)
			icon_state = "syndie_quiver_3"

/obj/item/storage/bag/rebar_quiver/syndicate/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/reload_rebar))
		reload_held_rebar(user)

/obj/item/storage/bag/rebar_quiver/syndicate/proc/reload_held_rebar(mob/user)
	if(!contents.len)
		user.balloon_alert(user, "no bolts left!")
		return
	var/obj/held_item = user.get_active_held_item()
	if(!held_item || !istype(held_item, /obj/item/gun/ballistic/rifle/rebarxbow))
		user.balloon_alert(user, "no held crossbow!")
		return
	var/obj/item/gun/ballistic/rifle/rebarxbow/held_crossbow = held_item
	if(held_crossbow.magazine.contents.len >= held_crossbow.magazine.max_ammo)
		user.balloon_alert(user, "no more room!")
		return
	if(!do_after(user, 1.2 SECONDS, user))
		return

	var/obj/item/ammo_casing/rebar/ammo_to_load = contents[1]
	held_crossbow.attackby(ammo_to_load, user)

/obj/item/storage/bag/quiver
	name = "quiver"
	desc = "Holds arrows for your bow. Good, because while pocketing arrows is possible, it surely can't be pleasant."
	icon = 'icons/obj/weapons/bows/quivers.dmi'
	icon_state = "quiver"
	inhand_icon_state = null
	worn_icon_state = "harpoon_quiver"
	storage_type = /datum/storage/bag/quiver

	/// type of arrow the quivel should hold
	var/arrow_path = /obj/item/ammo_casing/arrow

/obj/item/storage/bag/quiver/lesser
	storage_type = /datum/storage/bag/quiver/less

/obj/item/storage/bag/quiver/full/PopulateContents()
	. = ..()
	for(var/i in 1 to 10)
		new arrow_path(src)

/obj/item/storage/bag/quiver/holy
	name = "divine quiver"
	desc = "Holds arrows for your divine bow, where they wait to find their target."
	icon_state = "holyquiver"
	inhand_icon_state = "holyquiver"
	worn_icon_state = "holyquiver"
	arrow_path = /obj/item/ammo_casing/arrow/holy

/obj/item/storage/bag/quiver/holy/PopulateContents()
	. = ..()
	for(var/i in 1 to 10)
		new arrow_path(src)

/obj/item/storage/bag/quiver/endless
	name = "endless quiver"
	desc = "Holds arrows for your bow. A deep digital void is contained within."
	storage_type = /datum/storage/bag/quiver/endless

/obj/item/storage/bag/quiver/endless/PopulateContents()
	. = ..()
	new arrow_path(src)

#undef ORE_BAG_BALOON_COOLDOWN
