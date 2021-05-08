/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	req_access = null
	can_weld_shut = FALSE
	horizontal = TRUE
	allow_objects = TRUE
	allow_dense = TRUE
	dense_when_open = TRUE
	climbable = TRUE
	climb_time = 10 //real fast, because let's be honest stepping into or onto a crate is easy
	climb_stun = 0 //climbing onto crates isn't hard, guys
	delivery_icon = "deliverycrate"
	open_sound = 'sound/machines/crate_open.ogg'
	close_sound = 'sound/machines/crate_close.ogg'
	open_sound_volume = 35
	close_sound_volume = 50
	drag_slowdown = 0
	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest

/obj/structure/closet/crate/Initialize()
	. = ..()
	if(icon_state == "[initial(icon_state)]open")
		opened = TRUE
	update_icon()

/obj/structure/closet/crate/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!istype(mover, /obj/structure/closet))
		var/obj/structure/closet/crate/locatedcrate = locate(/obj/structure/closet/crate) in get_turf(mover)
		if(locatedcrate) //you can walk on it like tables, if you're not in an open crate trying to move to a closed crate
			if(opened) //if we're open, allow entering regardless of located crate openness
				return TRUE
			if(!locatedcrate.opened) //otherwise, if the located crate is closed, allow entering
				return TRUE

/obj/structure/closet/crate/update_icon_state()
	icon_state = "[initial(icon_state)][opened ? "open" : ""]"

/obj/structure/closet/crate/closet_update_overlays(list/new_overlays)
	. = new_overlays
	if(manifest)
		. += "manifest"

/obj/structure/closet/crate/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(manifest)
		tear_manifest(user)

/obj/structure/closet/crate/open(mob/living/user, force = FALSE)
	. = ..()
	if(. && manifest)
		to_chat(user, "<span class='notice'>The manifest is torn off [src].</span>")
		playsound(src, 'sound/items/poster_ripped.ogg', 75, TRUE)
		manifest.forceMove(get_turf(src))
		manifest = null
		update_icon()

/obj/structure/closet/crate/proc/tear_manifest(mob/user)
	to_chat(user, "<span class='notice'>You tear the manifest off of [src].</span>")
	playsound(src, 'sound/items/poster_ripped.ogg', 75, TRUE)

	manifest.forceMove(loc)
	if(ishuman(user))
		user.put_in_hands(manifest)
	manifest = null
	update_icon()

/obj/structure/closet/crate/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon_state = "coffin"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	material_drop = /obj/item/stack/sheet/mineral/wood
	material_drop_amount = 5
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50

/obj/structure/closet/crate/maint

/obj/structure/closet/crate/maint/PopulateContents()
	. = ..()
	for(var/i in 1 to rand(2,6))
		new /obj/effect/spawner/lootdrop/maintenance(src)

/obj/structure/closet/crate/cart/maint

/obj/structure/closet/crate/cart/maint/PopulateContents()
	. = ..()
	for(var/i in 1 to rand(2,6))
		new /obj/effect/spawner/lootdrop/maintenance(src)

/obj/structure/closet/crate/cart/trashcart/Initialize()
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLUDGE, CELL_VIRUS_TABLE_GENERIC, rand(2,3), 15)

/obj/structure/closet/crate/cart/trashcart/filled

/obj/structure/closet/crate/cart/trashcart/filled/PopulateContents()
	. = ..()
	for(var/i in 1 to rand(7,15))
		new /obj/effect/spawner/lootdrop/garbage_spawner(src)
		if(prob(12))
			new	/obj/item/storage/bag/trash/filled(src)
	new /obj/effect/spawner/scatter/grime(loc)

/obj/structure/closet/crate/internals
	desc = "An internals crate."
	name = "internals crate"
	icon_state = "o2crate"

/obj/structure/closet/crate/cart
	desc = "A heavy, metal cart with wheels."
	name = "cart"
	icon_state = "cart"

/obj/structure/closet/crate/cart/Moved()
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, TRUE)

/obj/structure/closet/crate/cart/trashcart
	desc = "A heavy, metal trashcart with wheels."
	name = "trash cart"
	icon_state = "trashcart"

/obj/structure/closet/crate/cart/laundry
	name = "laundry cart"
	desc = "A large cart for hauling around large amounts of laundry."
	icon_state = "laundry"

/obj/structure/closet/crate/cart/medical
	name = "medical cart"
	desc = "A cart for the quick movement of medical supplies."
	icon_state = "medcart"

/obj/structure/closet/crate/cart/mech
	name = "mech cart"
	desc = "A large cart for hauling around lthose giant mech parts."
	icon_state = "mechcart"

/obj/structure/closet/crate/cart/forensic
	name = "forensic cart"
	desc = "Bring out your dead! Bring out your dead!"
	icon_state = "forensiccart"

/obj/structure/closet/crate/medical
	desc = "A medical crate."
	name = "medical crate"
	icon_state = "medicalcrate"

/obj/structure/closet/crate/freezer
	desc = "A freezer."
	name = "freezer"
	icon_state = "freezer"

//Snowflake organ freezer code
//Order is important, since we check source, we need to do the check whenever we have all the organs in the crate

/obj/structure/closet/crate/freezer/open(mob/living/user, force = FALSE)
	recursive_organ_check(src)
	..()

/obj/structure/closet/crate/freezer/close()
	..()
	recursive_organ_check(src)

/obj/structure/closet/crate/freezer/Destroy()
	recursive_organ_check(src)
	..()

/obj/structure/closet/crate/freezer/Initialize()
	. = ..()
	recursive_organ_check(src)



/obj/structure/closet/crate/freezer/blood
	name = "blood freezer"
	desc = "A freezer containing packs of blood."

/obj/structure/closet/crate/freezer/blood/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/blood(src)
	new /obj/item/reagent_containers/blood(src)
	new /obj/item/reagent_containers/blood/a_minus(src)
	new /obj/item/reagent_containers/blood/b_minus(src)
	new /obj/item/reagent_containers/blood/b_plus(src)
	new /obj/item/reagent_containers/blood/o_minus(src)
	new /obj/item/reagent_containers/blood/o_plus(src)
	new /obj/item/reagent_containers/blood/lizard(src)
	new /obj/item/reagent_containers/blood/ethereal(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/blood/random(src)

/obj/structure/closet/crate/freezer/surplus_limbs
	name = "surplus prosthetic limbs"
	desc = "A crate containing an assortment of cheap prosthetic limbs."

/obj/structure/closet/crate/freezer/surplus_limbs/PopulateContents()
	. = ..()
	new /obj/item/bodypart/l_arm/robot/surplus(src)
	new /obj/item/bodypart/l_arm/robot/surplus(src)
	new /obj/item/bodypart/r_arm/robot/surplus(src)
	new /obj/item/bodypart/r_arm/robot/surplus(src)
	new /obj/item/bodypart/l_leg/robot/surplus(src)
	new /obj/item/bodypart/l_leg/robot/surplus(src)
	new /obj/item/bodypart/r_leg/robot/surplus(src)
	new /obj/item/bodypart/r_leg/robot/surplus(src)

/obj/structure/closet/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "radiation crate"
	icon_state = "radiation"

/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "hydrocrate"

/obj/structure/closet/crate/engineering
	name = "engineering crate"
	icon_state = "engi_crate"

/obj/structure/closet/crate/engineering/electrical
	icon_state = "engi_e_crate"

/obj/structure/closet/crate/rcd
	desc = "A crate for the storage of an RCD."
	name = "\improper RCD crate"
	icon_state = "engi_crate"

/obj/structure/closet/crate/rcd/PopulateContents()
	..()
	for(var/i in 1 to 4)
		new /obj/item/rcd_ammo(src)
	new /obj/item/construction/rcd(src)

/obj/structure/closet/crate/science
	name = "science crate"
	desc = "A science crate."
	icon_state = "scicrate"

/obj/structure/closet/crate/solarpanel_small
	name = "budget solar panel crate"
	icon_state = "engi_e_crate"

/obj/structure/closet/crate/solarpanel_small/PopulateContents()
	..()
	for(var/i in 1 to 13)
		new /obj/item/solar_assembly(src)
	new /obj/item/circuitboard/computer/solar_control(src)
	new /obj/item/paper/guides/jobs/engi/solars(src)
	new /obj/item/electronics/tracker(src)

/obj/structure/closet/crate/goldcrate
	name = "gold crate"

/obj/structure/closet/crate/goldcrate/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/stack/sheet/mineral/gold(src, 1, FALSE)
	new /obj/item/storage/belt/champion(src)

/obj/structure/closet/crate/silvercrate
	name = "silver crate"

/obj/structure/closet/crate/silvercrate/PopulateContents()
	..()
	for(var/i in 1 to 5)
		new /obj/item/coin/silver(src)


///////////////////////////////////////////////////////////////
/// Resource cache crates used for resource related events. ///
///				  Coded By Melbert. Thanks Mel!				///
///////////////////////////////////////////////////////////////

/obj/structure/closet/crate/resource_cache
	name = "resource cache"
	desc = "A steel crate filled to the brim with resources."
	/// Assoc list of resources to amounts
	var/list/obj/item/stack/resources = list()
	/// Whether bonus mats will get added to the crate on spawn.
	var/bonus_mats = TRUE

/obj/structure/closet/crate/resource_cache/PopulateContents()
	. = ..()
	// Add in our resources from the assoc list of resources
	resources = string_assoc_list(resources)
	for(var/contents in resources)
		var/amount = resources[contents]
		new contents(src, amount)

	// A chance to add in some extra metal or glass
	if(bonus_mats)
		switch(rand(1, 200))
			if(1 to 9)
				new /obj/item/stack/sheet/metal(src, 10)
			if(10 to 24)
				new /obj/item/stack/sheet/metal(src, 25)
			if(15 to 34)
				new /obj/item/stack/sheet/glass(src, 10)
			if(35 to 49)
				new /obj/item/stack/sheet/glass(src, 25)
			if(50 to 59)
				new /obj/item/stack/sheet/mineral/gold(src, 8)
			if(60 to 69)
				new /obj/item/stack/sheet/mineral/silver(src, 12)

/// Special crates are specialized and can have rare materials
/obj/structure/closet/crate/resource_cache/special
	desc = "A steel crate filled to the brim with resources. You don't really recognize the branding."
	icon_state = "securecrate"

/// Syndicate crates can have syndie contraband hidden away, and contain syndie building mats
/obj/structure/closet/crate/resource_cache/syndicate
	name = "syndicate resource cache"
	desc = "A steel crate filled to the brim with resources. This one is from the syndicate."
	icon_state = "secgearcrate"
	// The max amount of TC we can spend hidden contraband
	var/contraband_value = 8

/obj/structure/closet/crate/resource_cache/syndicate/PopulateContents()
	. = ..()
	if(bonus_mats && prob(4))
		contraband_value += rand(-4, 4)
		message_admins("A [name] at [ADMIN_VERBOSEJMP(loc)] was populated with contraband syndicate items (tc value = [contraband_value]).")
		log_game("A [name] at [loc_name(loc)] was populated with contraband syndicate items (tc value = [contraband_value]).")
		var/list/uplink_items = get_uplink_items(SSticker.mode)
		while(contraband_value)
			var/category = pick(uplink_items)
			var/item = pick(uplink_items[category])
			var/datum/uplink_item/I = uplink_items[category][item]
			if(!I.surplus || prob(100 - I.surplus))
				continue
			if(contraband_value < I.cost)
				continue
			contraband_value -= I.cost
			new I.item(src)

/// Centcom crates have usual advanced building mats found on NT stations
/obj/structure/closet/crate/resource_cache/centcom
	name = "nanotrasen resource cache"
	desc = "A steel crate filled to the brim with resources. This one is from centcom."
	icon_state = "plasmacrate"

/// Normal crates just have normal resources
/obj/structure/closet/crate/resource_cache/normal

/// Basic building mats (metal and glass)
//---
/obj/structure/closet/crate/resource_cache/normal/metals
	icon_state = "engi_crate"
	resources = list(/obj/item/stack/sheet/metal = 50, \
					/obj/item/stack/sheet/glass = 50)

/obj/structure/closet/crate/resource_cache/normal/metals/low
	resources = list(/obj/item/stack/sheet/metal = 30, \
					/obj/item/stack/sheet/glass = 25)

/obj/structure/closet/crate/resource_cache/normal/metals/high
	resources = list(/obj/item/stack/sheet/metal = 120, \
					/obj/item/stack/sheet/glass = 100)
//---

/// Rare metals (silver and gold)
//---
/obj/structure/closet/crate/resource_cache/normal/rare_metals
	icon_state = "engi_secure_crate"
	resources = list(/obj/item/stack/sheet/mineral/gold = 20, \
					/obj/item/stack/sheet/mineral/silver = 25, \
					/obj/item/stack/sheet/mineral/titanium = 30 )

/obj/structure/closet/crate/resource_cache/normal/rare_metals/low
	resources = list(/obj/item/stack/sheet/mineral/gold = 10, \
					/obj/item/stack/sheet/mineral/silver = 12, \
					/obj/item/stack/sheet/mineral/titanium = 20 )

/obj/structure/closet/crate/resource_cache/normal/rare_metals/high
	resources = list(/obj/item/stack/sheet/mineral/gold = 30, \
					/obj/item/stack/sheet/mineral/silver = 40, \
					/obj/item/stack/sheet/mineral/titanium = 50 )
//---

/// Rare gems (diamonds, bluespace crystals)
//---
/obj/structure/closet/crate/resource_cache/normal/rare_gems
	icon_state = "engi_secure_crate"
	resources = list(/obj/item/stack/sheet/mineral/diamond = 10, \
					/obj/item/stack/sheet/bluespace_crystal = 8)

/obj/structure/closet/crate/resource_cache/normal/rare_gems/low
	resources = list(/obj/item/stack/sheet/mineral/diamond = 6, \
					/obj/item/stack/sheet/bluespace_crystal = 5)

/obj/structure/closet/crate/resource_cache/normal/rare_gems/high
	resources = list(/obj/item/stack/sheet/mineral/diamond = 12, \
					/obj/item/stack/sheet/bluespace_crystal = 10)
//---

/// Hazardous resources (plasma and uranium)
//---
/obj/structure/closet/crate/resource_cache/normal/hazardous_metals
	icon_state = "radiation"
	resources = list(/obj/item/stack/sheet/mineral/uranium = 15, \
					/obj/item/stack/sheet/mineral/plasma = 30)

/obj/structure/closet/crate/resource_cache/normal/hazardous_metals/low
	resources = list(/obj/item/stack/sheet/mineral/uranium = 5, \
					/obj/item/stack/sheet/mineral/plasma = 15)

/obj/structure/closet/crate/resource_cache/normal/hazardous_metals/high
	resources = list(/obj/item/stack/sheet/mineral/uranium = 20, \
					/obj/item/stack/sheet/mineral/plasma = 40)
//---

/// Basic materials (cardboard, metal, plastic, wood, glass)
//---
/obj/structure/closet/crate/resource_cache/normal/basic_materials
	resources = list(/obj/item/stack/sheet/cardboard = 20, \
					/obj/item/stack/sheet/metal = 80, \
					/obj/item/stack/sheet/glass = 25)

/obj/structure/closet/crate/resource_cache/normal/poor_materials
	resources = list(/obj/item/stack/sheet/cardboard = 80, \
					/obj/item/stack/sheet/mineral/wood = 50, \
					/obj/item/stack/sheet/plastic = 20, \
					/obj/item/stack/sheet/metal = 30)
//---

/// Weird crates (Random stuff)
//---
/obj/structure/closet/crate/resource_cache/special/weird_materials_cult
	icon_state = "weaponcrate"
	resources = list(/obj/item/stack/sheet/runed_metal = 20, \
					/obj/item/stack/sheet/metal = 30, \
					/obj/item/stack/sheet/glass = 30)

/obj/structure/closet/crate/resource_cache/special/weird_materials_aliens
	icon_state = "weaponcrate"
	resources = list(/obj/item/stack/sheet/mineral/abductor = 25, \
					/obj/item/stack/sheet/metal = 30, \
					/obj/item/stack/sheet/glass = 30)

/obj/structure/closet/crate/resource_cache/special/many_metals
	bonus_mats = FALSE
	resources = list(/obj/item/stack/sheet/metal = 30, \
					/obj/item/stack/sheet/glass = 25, \
					/obj/item/stack/sheet/mineral/gold = 10, \
					/obj/item/stack/sheet/mineral/silver = 12, \
					/obj/item/stack/sheet/mineral/titanium = 15 )

/obj/structure/closet/crate/resource_cache/special/many_rare_mats
	bonus_mats = FALSE
	resources = list(/obj/item/stack/sheet/mineral/gold = 12, \
					/obj/item/stack/sheet/mineral/silver = 12, \
					/obj/item/stack/sheet/mineral/titanium = 10, \
					/obj/item/stack/sheet/mineral/uranium = 10, \
					/obj/item/stack/sheet/mineral/plasma = 15)

/obj/structure/closet/crate/resource_cache/special/diamonds
	bonus_mats = FALSE
	resources = list(/obj/item/stack/sheet/mineral/diamond = 12)

/obj/structure/closet/crate/resource_cache/special/bananium
	bonus_mats = FALSE
	resources = list(/obj/item/stack/sheet/mineral/bananium = 10)

/obj/structure/closet/crate/resource_cache/lizard_things
	name = "\improper lizard empire trade goods"
	desc = "A rough hide crate. This one was made by the Lizard Empire, and contains various trade goods of their people."
	icon_state = "necrocrate"
	resources = list(/obj/item/stack/sheet/sinew = 5, \
					/obj/item/stack/sheet/animalhide/goliath_hide = 5, \
					/obj/item/stack/sheet/bone = 10)

/obj/structure/closet/crate/resource_cache/magic_things
	name = "\improper crate of insquisition contraband"
	desc = "A coarse wooden crate, with a broken seal of thick wax over the lid. Maybe opening this is a bad idea?"
	icon_state = "wooden"
	bonus_mats = FALSE
	resources = list(/obj/item/stack/sheet/mineral/mythril = 2, \
					/obj/item/stack/sheet/mineral/adamantine = 4, \
					/obj/item/stack/sheet/mineral/runite = 12, \
					/obj/item/stack/sheet/runed_metal = 20 )

// Yes, this crate can have literally any stack item.
// No, it's blacklisted from the events that use it for a reason.
/obj/structure/closet/crate/resource_cache/random_materials
	desc = "A steel crate. This one seems like trouble."

/obj/structure/closet/crate/resource_cache/random_materials/Initialize()
	for(var/i in 1 to rand(2, 4))
		resources += list(pick(subtypesof(/obj/item/stack)) = round(rand(1, 50),5))
	. = ..()

//---

/// Syndie stuff (Random stuff)
//---
/obj/structure/closet/crate/resource_cache/syndicate/building_mats
	resources = list(/obj/item/stack/sheet/mineral/plastitanium = 50, \
					/obj/item/stack/sheet/plastitaniumglass = 30)
//---

/// Centcom stuff (Random stuff)
//---
/obj/structure/closet/crate/resource_cache/centcom/building_mats
	resources = list(/obj/item/stack/sheet/plasteel = 50, \
					/obj/item/stack/sheet/plasmarglass = 30)
//---
// -- End resource caches. --
