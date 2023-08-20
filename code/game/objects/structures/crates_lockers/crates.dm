/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/storage/crates.dmi'
	icon_state = "crate"
	base_icon_state = "crate"
	req_access = null
	can_weld_shut = FALSE
	horizontal = TRUE
	allow_objects = TRUE
	allow_dense = TRUE
	dense_when_open = TRUE
	delivery_icon = "deliverycrate"
	open_sound = 'sound/machines/crate_open.ogg'
	close_sound = 'sound/machines/crate_close.ogg'
	open_sound_volume = 35
	close_sound_volume = 50
	drag_slowdown = 0
	door_anim_time = 0 // no animation
	pass_flags_self = PASSSTRUCTURE | LETPASSTHROW
	var/crate_climb_time = 20
	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest
	/// Where the Icons for lids are located.
	var/lid_icon = 'icons/obj/storage/crates.dmi'
	/// Icon state to use for lid to display when opened. Leave undefined if there isn't one.
	var/lid_icon_state
	/// Controls the X value of the lid, allowing left and right pixel movement.
	var/lid_x = 0
	/// Controls the Y value of the lid, allowing up and down pixel movement.
	var/lid_y = 0

/obj/structure/closet/crate/Initialize(mapload)
	AddElement(/datum/element/climbable, climb_time = crate_climb_time, climb_stun = 0) //add element in closed state before parent init opens it(if it does)
	. = ..()

	var/static/list/crate_paint_jobs
	if(isnull(crate_paint_jobs))
		crate_paint_jobs = list(
		"Internals" = list("icon_state" = "o2crate"),
		"Medical" = list("icon_state" = "medicalcrate"),
		"Radiation" = list("icon_state" = "radiation"),
		"Hydrophonics" = list("icon_state" = "hydrocrate"),
		"Science" = list("icon_state" = "scicrate"),
		"Solar" = list("icon_state" = "engi_e_crate"),
		"Engineering" = list("icon_state" = "engi_crate")
	)
	if(paint_jobs)
		paint_jobs = crate_paint_jobs

/obj/structure/closet/crate/Destroy()
	QDEL_NULL(manifest)
	return ..()

/obj/structure/closet/crate/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!istype(mover, /obj/structure/closet))
		var/obj/structure/closet/crate/locatedcrate = locate(/obj/structure/closet/crate) in get_turf(mover)
		if(locatedcrate) //you can walk on it like tables, if you're not in an open crate trying to move to a closed crate
			if(opened) //if we're open, allow entering regardless of located crate openness
				return TRUE
			if(!locatedcrate.opened) //otherwise, if the located crate is closed, allow entering
				return TRUE

/obj/structure/closet/crate/update_icon_state()
	icon_state = "[isnull(base_icon_state) ? initial(icon_state) : base_icon_state][opened ? "open" : ""]"
	return ..()

/obj/structure/closet/crate/closet_update_overlays(list/new_overlays)
	. = new_overlays
	if(manifest)
		. += "manifest"

	if(!opened)
		if(broken)
			. += "securecrateemag"
		else if(locked)
			. += "securecrater"
		else if(secure)
			. += "securecrateg"

	if(opened && lid_icon_state)
		var/mutable_appearance/lid = mutable_appearance(icon = lid_icon, icon_state = lid_icon_state)
		lid.pixel_x = lid_x
		lid.pixel_y = lid_y
		lid.layer = layer
		. += lid

/obj/structure/closet/crate/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(manifest)
		tear_manifest(user)

/obj/structure/closet/crate/after_open(mob/living/user, force)
	. = ..()
	RemoveElement(/datum/element/climbable, climb_time = crate_climb_time, climb_stun = 0)
	AddElement(/datum/element/climbable, climb_time = crate_climb_time * 0.5, climb_stun = 0)
	if(!QDELETED(manifest))
		playsound(src, 'sound/items/poster_ripped.ogg', 75, TRUE)
		manifest.forceMove(get_turf(src))
		manifest = null
		update_appearance()

/obj/structure/closet/crate/after_close(mob/living/user)
	. = ..()
	RemoveElement(/datum/element/climbable, climb_time = crate_climb_time * 0.5, climb_stun = 0)
	AddElement(/datum/element/climbable, climb_time = crate_climb_time, climb_stun = 0)

/obj/structure/closet/crate/proc/tear_manifest(mob/user)
	to_chat(user, span_notice("You tear the manifest off of [src]."))
	playsound(src, 'sound/items/poster_ripped.ogg', 75, TRUE)

	manifest.forceMove(loc)
	if(ishuman(user))
		user.put_in_hands(manifest)
	manifest = null
	update_appearance()

/obj/structure/closet/crate/preopen
	opened = TRUE
	icon_state = "crateopen"

/obj/structure/closet/crate/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon_state = "coffin"
	base_icon_state = "coffin"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	material_drop = /obj/item/stack/sheet/mineral/wood
	material_drop_amount = 5
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50
	can_install_electronics = FALSE
	paint_jobs = null

/obj/structure/closet/crate/maint

/obj/structure/closet/crate/maint/Initialize(mapload)
	..()

	var/static/list/possible_crates = RANDOM_CRATE_LOOT

	var/crate_path = pick_weight(possible_crates)
	var/obj/structure/closet/crate/random_crate = new crate_path(loc)
	random_crate.RegisterSignal(random_crate, COMSIG_CLOSET_POPULATE_CONTENTS, TYPE_PROC_REF(/obj/structure/closet/, populate_with_random_maint_loot))
	if (prob(50))
		random_crate.open(null, special_effects = FALSE) //crates spawned as immediatly opened don't need to animate into being opened

	return INITIALIZE_HINT_QDEL

/obj/structure/closet/proc/populate_with_random_maint_loot()
	SIGNAL_HANDLER

	for (var/i in 1 to rand(2,6))
		new /obj/effect/spawner/random/maintenance(src)

/obj/structure/closet/crate/trashcart //please make this a generic cart path later after things calm down a little
	desc = "A heavy, metal trashcart with wheels."
	name = "trash cart"
	icon_state = "trashcart"
	base_icon_state = "trashcart"
	can_install_electronics = FALSE
	paint_jobs = null

/obj/structure/closet/crate/trashcart/laundry
	name = "laundry cart"
	desc = "A large cart for hauling around large amounts of laundry."
	icon_state = "laundry"
	base_icon_state = "laundry"

/obj/structure/closet/crate/trashcart/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLUDGE, CELL_VIRUS_TABLE_GENERIC, rand(2,3), 15)
	AddElement(/datum/element/noisy_movement)

/obj/structure/closet/crate/trashcart/filled

/obj/structure/closet/crate/trashcart/filled/Initialize(mapload)
	. = ..()
	if(mapload)
		new /obj/effect/spawner/random/trash/grime(loc) //needs to be done before the trashcart is opened because it spawns things in a range outside of the trashcart

/obj/structure/closet/crate/trashcart/filled/PopulateContents()
	. = ..()
	for(var/i in 1 to rand(7,15))
		new /obj/effect/spawner/random/trash/garbage(src)
		if(prob(12))
			new /obj/item/storage/bag/trash/filled(src)

/obj/structure/closet/crate/internals
	desc = "An internals crate."
	name = "internals crate"
	icon_state = "o2crate"
	base_icon_state = "o2crate"

/obj/structure/closet/crate/medical
	desc = "A medical crate."
	name = "medical crate"
	icon_state = "medicalcrate"
	base_icon_state = "medicalcrate"

/obj/structure/closet/crate/freezer
	desc = "A freezer."
	name = "freezer"
	icon_state = "freezer"
	base_icon_state = "freezer"
	paint_jobs = null

/obj/structure/closet/crate/freezer/before_open(mob/living/user, force)
	. = ..()
	if(!.)
		return FALSE

	toggle_organ_decay(src)
	return TRUE

/obj/structure/closet/crate/freezer/after_close(mob/living/user)
	. = ..()
	toggle_organ_decay(src)

/obj/structure/closet/crate/freezer/Destroy()
	toggle_organ_decay(src)
	return ..()

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
	new /obj/item/bodypart/arm/left/robot/surplus(src)
	new /obj/item/bodypart/arm/left/robot/surplus(src)
	new /obj/item/bodypart/arm/right/robot/surplus(src)
	new /obj/item/bodypart/arm/right/robot/surplus(src)
	new /obj/item/bodypart/leg/left/robot/surplus(src)
	new /obj/item/bodypart/leg/left/robot/surplus(src)
	new /obj/item/bodypart/leg/right/robot/surplus(src)
	new /obj/item/bodypart/leg/right/robot/surplus(src)

/obj/structure/closet/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "radiation crate"
	icon_state = "radiation"
	base_icon_state = "radiation"

/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "hydrocrate"
	base_icon_state = "hydrocrate"

/obj/structure/closet/crate/engineering
	name = "engineering crate"
	icon_state = "engi_crate"
	base_icon_state = "engi_crate"

/obj/structure/closet/crate/engineering/electrical
	icon_state = "engi_e_crate"
	base_icon_state = "engi_e_crate"

/obj/structure/closet/crate/rcd
	desc = "A crate for the storage of an RCD."
	name = "\improper RCD crate"
	icon_state = "engi_crate"
	base_icon_state = "engi_crate"

/obj/structure/closet/crate/rcd/PopulateContents()
	..()
	for(var/i in 1 to 4)
		new /obj/item/rcd_ammo(src)
	new /obj/item/construction/rcd(src)

/obj/structure/closet/crate/science
	name = "science crate"
	desc = "A science crate."
	icon_state = "scicrate"
	base_icon_state = "scicrate"

/obj/structure/closet/crate/mod
	name = "MOD crate"
	icon_state = "scicrate"
	base_icon_state = "scicrate"

/obj/structure/closet/crate/mod/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/mod/core/standard(src)
	for(var/i in 1 to 2)
		new /obj/item/clothing/neck/link_scryer(src)

/obj/structure/closet/crate/solarpanel_small
	name = "budget solar panel crate"
	icon_state = "engi_e_crate"
	base_icon_state = "engi_e_crate"

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
	new /obj/item/storage/belt/champion(src)

/obj/structure/closet/crate/goldcrate/populate_contents_immediate()
	. = ..()

	for(var/i in 1 to 3)
		new /obj/item/stack/sheet/mineral/gold(src, 1, FALSE)

/obj/structure/closet/crate/silvercrate
	name = "silver crate"

/obj/structure/closet/crate/silvercrate/PopulateContents()
	..()
	for(var/i in 1 to 5)
		new /obj/item/coin/silver(src)

/obj/structure/closet/crate/decorations
	icon_state = "engi_crate"
	base_icon_state = "engi_crate"

/obj/structure/closet/crate/decorations/PopulateContents()
	. = ..()
	for(var/i in 1 to 4)
		new /obj/effect/spawner/random/decoration/generic(src)
