
/obj/structure/netchair
	name = "net chair"
	desc = "A link to the netverse. It has an assortment of cables to connect to a virtual domain."

	anchored = TRUE
	buckle_lying = 0 //you sit in a chair, not lay
	can_buckle = TRUE
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair"
	integrity_failure = 0.1
	layer = OBJ_LAYER
	max_integrity = 250
	resistance_flags = NONE
	/// The person sitting in this chair.
	var/datum/weakref/voidrunner
	/// The selected outfit for the gamer chair.
	var/datum/outfit/netsuit = /datum/outfit/job/miner
	/// Static list of outfits to select from
	var/static/list/cached_outfits

/obj/structure/netchair/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_BUCKLE, PROC_REF(on_buckle))

/obj/structure/netchair/attack_hand(mob/living/user, list/modifiers)
	if(ishuman(user) && !user.combat_mode)
		ui_interact(user)
	else
		return ..()

/obj/structure/netchair/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NetChair")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/structure/netchair/ui_data()
	var/list/data = list()

	data["netsuit"] = netsuit
	return data

/obj/structure/netchair/ui_static_data()
	var/list/data = list()

	if(!cached_outfits)
		cached_outfits += make_outfit_collection("Jobs", subtypesof(/datum/outfit/job))

	data["collections"] = cached_outfits

	return data

/obj/structure/netchair/ui_act(action, params)
	. = ..()
	if(.)
		return TRUE
	switch(action)
		if("select_outfit")
			var/datum/outfit/new_suit = resolve_outfit(params["outfit"])
			if(new_suit)
				netsuit = new_suit
				return TRUE

	return FALSE

/// Creates a list of outfit entries for the UI.
/obj/structure/netchair/proc/make_outfit_collection(identifier, list/outfit_list)
	var/list/collection = list(
		"name" = identifier,
		"outfits" = list()
	)

	for(var/path as anything in outfit_list)
		var/datum/outfit/outfit = path
		collection["outfits"] += list(list("path" = path, "name" = initial(outfit.name)))

	return list(collection)

/// On buckled, checks if mob is alive and human, then enters the matrix.
/obj/structure/netchair/proc/on_buckle(datum/source, mob/living/mob_to_buckle, _force)
	SIGNAL_HANDLER

	if(!istype(mob_to_buckle) || !ishuman(mob_to_buckle) || mob_to_buckle.stat == DEAD)
		return FALSE

	enter_matrix(mob_to_buckle)

/// Creates a new z-level, an avatar, then transfers the mind to the avatar.
/obj/structure/netchair/proc/enter_matrix(mob/living/carbon/human/neo)
	set waitfor = FALSE
	balloon_alert(neo, "Generating virtual domain...")

	var/datum/map_template/virtual_domain/gondola/new_level = new()
	var/datum/space_level/loaded = new_level.load_new_z()
	if(!loaded)
		log_game("The virtual domain z-level failed to load.")
		message_admins("The virtual domain z-level failed to load. Hackers won't be teleported to the netverse.")
		CRASH("Failed to initialize virtual domain z-level!")

	var/turf/destination = pick(get_area_turfs(/area/station/holodeck/rec_center, loaded.z_value))
	if(QDELETED(destination) || QDELETED(neo) || neo.stat == DEAD || !neo.mind)
		return

	var/obj/structure/hololadder/wayout = new(destination, src)
	var/mob/living/carbon/human/avatar = new(wayout)
	avatar.equipOutfit(netsuit, visualsOnly = TRUE)

	voidrunner = WEAKREF(neo)
	neo.mind.transfer_to(avatar, TRUE)

	if(!destination || !do_teleport(avatar, destination, asoundin = 'sound/magic/repulse.ogg', asoundout = 'sound/magic/blind.ogg', no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC, forced = TRUE))
		CRASH("Failed to teleport the hacker to the netverse.")


/obj/structure/netchair/proc/resolve_outfit(text)

	var/path = text2path(text)
	if(ispath(path, /datum/outfit))
		return path

	return FALSE
