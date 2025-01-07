// the different states of the mystery box
/// Closed, can't interact
#define MYSTERY_BOX_COOLING_DOWN 0
/// Closed, ready to be interacted with
#define MYSTERY_BOX_STANDBY 1
/// The box is choosing the prize
#define MYSTERY_BOX_CHOOSING 2
/// The box is presenting the prize, for someone to claim it
#define MYSTERY_BOX_PRESENTING 3

// delays for the different stages of the box's state, the visuals, and the audio
/// How long the box takes to decide what the prize is
#define MBOX_DURATION_CHOOSING (5 SECONDS)
/// How long the box takes to start expiring the offer, though it's still valid until MBOX_DURATION_EXPIRING finishes. Timed to the sound clips
#define MBOX_DURATION_PRESENTING (3.5 SECONDS)
/// How long the box takes to start lowering the prize back into itself. When this finishes, the prize is gone
#define MBOX_DURATION_EXPIRING (4.5 SECONDS)
/// How long after the box closes until it can go again
#define MBOX_DURATION_STANDBY (2.7 SECONDS)

GLOBAL_LIST_INIT(mystery_box_guns, list(
	/obj/item/gun/energy/recharge/ebow/large,
	/obj/item/gun/energy/e_gun,
	/obj/item/gun/energy/e_gun/nuclear,
	/obj/item/gun/energy/laser,
	/obj/item/gun/energy/laser/hellgun,
	/obj/item/gun/energy/laser/captain,
	/obj/item/gun/energy/laser/scatter,
	/obj/item/gun/energy/temperature,
	/obj/item/gun/ballistic/revolver/c38/detective,
	/obj/item/gun/ballistic/revolver/mateba,
	/obj/item/gun/ballistic/automatic/pistol/deagle/camo,
	/obj/item/gun/ballistic/automatic/pistol/suppressed,
	/obj/item/gun/energy/pulse/carbine/taserless,
	/obj/item/gun/energy/pulse/pistol/taserless,
	/obj/item/gun/ballistic/shotgun/lethal,
	/obj/item/gun/ballistic/shotgun/automatic/combat,
	/obj/item/gun/ballistic/shotgun/bulldog/unrestricted,
	/obj/item/gun/ballistic/rifle/boltaction,
	/obj/item/gun/ballistic/automatic/ar,
	/obj/item/gun/ballistic/automatic/proto/unrestricted,
	/obj/item/gun/ballistic/automatic/c20r/unrestricted,
	/obj/item/gun/ballistic/automatic/l6_saw/unrestricted,
	/obj/item/gun/ballistic/automatic/m90/unrestricted,
	/obj/item/gun/ballistic/automatic/tommygun,
	/obj/item/gun/ballistic/automatic/wt550,
	/obj/item/gun/ballistic/automatic/smartgun,
	/obj/item/gun/ballistic/rifle/sniper_rifle,
	/obj/item/gun/ballistic/rifle/boltaction,
))

GLOBAL_LIST_INIT(mystery_box_extended, list(
	/obj/item/clothing/gloves/tackler/combat,
	/obj/item/clothing/gloves/race,
	/obj/item/clothing/gloves/rapid,
	/obj/item/shield/riot/flash,
	/obj/item/grenade/stingbang/mega,
	/obj/item/storage/belt/sabre,
	/obj/item/knife/combat,
	/obj/item/melee/baton/security/loaded,
	/obj/item/reagent_containers/hypospray/combat,
	/obj/item/defibrillator/compact/combat/loaded/nanotrasen,
	/obj/item/melee/energy/sword/saber,
	/obj/item/spear,
	/obj/item/circular_saw,
))

GLOBAL_LIST_INIT(mystery_magic, list(
	/obj/item/gun/magic/wand/arcane_barrage,
	/obj/item/gun/magic/wand/arcane_barrage/blood,
	/obj/item/gun/magic/wand/fireball,
	/obj/item/gun/magic/wand/resurrection,
	/obj/item/gun/magic/wand/teleport,
	/obj/item/gun/magic/wand/door,
	/obj/item/gun/magic/wand/nothing,
	/obj/item/storage/belt/wands/full,
	/obj/item/gun/magic/staff/healing,
	/obj/item/gun/magic/staff/chaos,
	/obj/item/gun/magic/staff/door,
	/obj/item/gun/magic/staff/honk,
	/obj/item/gun/magic/staff/spellblade,
	/obj/item/gun/magic/staff/flying,
	/obj/item/gun/magic/staff/babel,
	/obj/item/singularityhammer,
	/obj/item/runic_vendor_scepter,
))

GLOBAL_LIST_INIT(mystery_fishing, list(
	/obj/item/storage/toolbox/fishing/master,
	/obj/item/storage/box/fish_revival_kit,
	/obj/item/circuitboard/machine/fishing_portal_generator/emagged,
	/obj/item/fishing_rod/telescopic/master,
	/obj/item/bait_can/super_baits,
	/obj/item/storage/fish_case/tiziran,
	/obj/item/storage/fish_case/syndicate,
	/obj/item/claymore/cutlass/old,
	/obj/item/gun/energy/laser/retro/old,
	/obj/item/gun/energy/laser/musket,
	/obj/item/gun/energy/disabler/smoothbore,
	/obj/item/gun/ballistic/rifle/boltaction/surplus,
	/obj/item/food/rationpack,
	/obj/item/food/canned/squid_ink,
	/obj/item/reagent_containers/cup/glass/bottle/rum/aged,
	/obj/item/storage/bag/money/dutchmen,
	/obj/item/language_manual/piratespeak,
	/obj/item/clothing/head/costume/pirate/armored,
	/obj/item/clothing/suit/costume/pirate/armored,
	/obj/structure/cannon/mystery_box,
	/obj/item/stack/cannonball/trashball/four,
	/obj/item/stack/cannonball/four,
))

/obj/structure/mystery_box
	name = "mystery box"
	desc = "A wooden crate that seems equally magical and mysterious, capable of granting the user all kinds of different pieces of gear."
	icon = 'icons/obj/storage/crates.dmi'
	icon_state = "wooden"
	pixel_y = -4
	anchored = TRUE
	density = TRUE
	max_integrity = 99999
	damage_deflection = 100

	var/crate_open_sound = 'sound/machines/crate/crate_open.ogg'
	var/crate_close_sound = 'sound/machines/crate/crate_close.ogg'
	var/open_sound = 'sound/effects/mysterybox/mbox_full.ogg'
	var/grant_sound = 'sound/effects/mysterybox/mbox_end.ogg'
	/// Should we play sounds?
	var/play_sounds = TRUE
	/// The box's current state, and whether it can be interacted with in different ways
	var/box_state = MYSTERY_BOX_STANDBY
	/// The object that represents the rapidly changing item that will be granted upon being claimed. Is not, itself, an item.
	var/obj/mystery_box_item/presented_item
	/// What type of mystery box item should we generate?
	var/box_item = /obj/mystery_box_item
	/// A timer for how long it takes for the box to start its expire animation
	var/box_expire_timer
	/// A timer for how long it takes for the box to close itself
	var/box_close_timer
	/// Every type that's a child of this that has an icon, icon_state, and isn't ABSTRACT is fair game. More granularity to come
	var/selectable_base_type = /obj/item
	/// The instantiated list that contains all of the valid items that can be chosen from. Generated in [/obj/structure/mystery_box/proc/generate_valid_types]
	var/list/valid_types
	/// If the prize is a ballistic gun with an external magazine, should we grant the user a spare mag?
	var/grant_extra_mag = TRUE
	/// Stores the current sound channel we're using so we can cut off our own sounds as needed. Randomized after each roll
	var/current_sound_channel
	/// How many time can it still be used?
	var/uses_left = INFINITY
	/// A list of weakrefs to mind datums of people that opened it and how many times.
	var/list/datum/weakref/minds_that_opened_us
	/// Does this box open on attack_hand?
	var/open_on_attackhand = TRUE
	/// Does this box expire?
	var/expires = TRUE

/obj/structure/mystery_box/Initialize(mapload)
	. = ..()
	generate_valid_types()

/obj/structure/mystery_box/Destroy()
	QDEL_NULL(presented_item)
	if(current_sound_channel)
		SSsounds.free_sound_channel(current_sound_channel)
	minds_that_opened_us = null
	return ..()

/obj/structure/mystery_box/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	switch(box_state)
		if(MYSTERY_BOX_STANDBY)
			if(open_on_attackhand)
				activate(user)

		if(MYSTERY_BOX_PRESENTING)
			if(presented_item.claimable)
				grant_weapon(user)

/obj/structure/mystery_box/update_icon_state()
	icon_state = "[initial(icon_state)][box_state > MYSTERY_BOX_STANDBY ? "open" : ""]"
	return ..()

/// This proc is used to define what item types valid_types is filled with
/obj/structure/mystery_box/proc/generate_valid_types()
	valid_types = list()

	for(var/iter_path in typesof(selectable_base_type))
		if(!ispath(iter_path, /obj/item))
			continue
		var/obj/item/iter_item = iter_path
		if((initial(iter_item.item_flags) & ABSTRACT) || !initial(iter_item.icon_state) || !initial(iter_item.inhand_icon_state))
			continue
		valid_types += iter_path

/// The box has been activated, play the sound and spawn the prop item
/obj/structure/mystery_box/proc/activate(mob/living/user)
	box_state = MYSTERY_BOX_CHOOSING
	update_icon_state()
	presented_item = new box_item(loc)
	presented_item.start_animation(src)
	if(play_sounds)
		current_sound_channel = SSsounds.reserve_sound_channel(src)
		playsound(src, open_sound, 70, FALSE, channel = current_sound_channel, falloff_exponent = 10)
		playsound(src, crate_open_sound, 80)
	if(user.mind)
		LAZYINITLIST(minds_that_opened_us)
		var/datum/weakref/ref = WEAKREF(user.mind)
		minds_that_opened_us[ref] += 1
	uses_left--

/// The box has finished choosing, mark it as available for grabbing
/obj/structure/mystery_box/proc/present_weapon()
	visible_message(span_notice("[src] presents [presented_item]!"), vision_distance = COMBAT_MESSAGE_RANGE)
	box_state = MYSTERY_BOX_PRESENTING
	if(expires)
		box_expire_timer = addtimer(CALLBACK(src, PROC_REF(start_expire_offer)), MBOX_DURATION_PRESENTING, TIMER_STOPPABLE)

/// The prize is still claimable, but the animation will show it start to recede back into the box
/obj/structure/mystery_box/proc/start_expire_offer()
	presented_item.expire_animation()
	box_close_timer = addtimer(CALLBACK(src, PROC_REF(close_box)), MBOX_DURATION_EXPIRING, TIMER_STOPPABLE)

/// The box is closed, whether because the prize fully expired, or it was claimed. Start resetting all of the state stuff
/obj/structure/mystery_box/proc/close_box()
	box_state = MYSTERY_BOX_COOLING_DOWN
	update_icon_state()
	QDEL_NULL(presented_item)
	deltimer(box_close_timer)
	deltimer(box_expire_timer)
	if(play_sounds)
		playsound(src, crate_close_sound, 100)
	box_close_timer = null
	box_expire_timer = null
	addtimer(CALLBACK(src, PROC_REF(ready_again)), MBOX_DURATION_STANDBY)
	if(uses_left <= 0)
		visible_message("[src] breaks down.")
		deconstruct(disassembled = FALSE)

/// The cooldown between activations has finished, shake to show that
/obj/structure/mystery_box/proc/ready_again()
	if(play_sounds)
		SSsounds.free_sound_channel(current_sound_channel)
		current_sound_channel = null
	box_state = MYSTERY_BOX_STANDBY
	Shake(3, 0, 0.5 SECONDS)

/// Someone attacked the box with an empty hand, spawn the shown prize and give it to them, then close the box
/obj/structure/mystery_box/proc/grant_weapon(mob/living/user)
	var/atom/movable/instantiated_weapon = new presented_item.selected_path(loc)
	user.visible_message(span_notice("[user] takes [presented_item] from [src]."), span_notice("You take [presented_item] from [src]."), vision_distance = COMBAT_MESSAGE_RANGE)
	if(play_sounds)
		playsound(src, grant_sound, 70, FALSE, channel = current_sound_channel, falloff_exponent = 10)
	close_box()

	if(!isitem(instantiated_weapon))
		return
	user.put_in_hands(instantiated_weapon)

	if(!isgun(instantiated_weapon))
		return
	// handle pins + possibly extra ammo
	var/obj/item/gun/instantiated_gun = instantiated_weapon
	instantiated_gun.unlock()
	if(!grant_extra_mag || !istype(instantiated_gun, /obj/item/gun/ballistic))
		return
	var/obj/item/gun/ballistic/instantiated_ballistic = instantiated_gun
	if(!instantiated_ballistic.internal_magazine)
		var/obj/item/ammo_box/magazine/extra_mag = new instantiated_ballistic.spawn_magazine_type(loc)
		user.put_in_hands(extra_mag)

/obj/item/baton_key
	name = "baton key"
	desc = "Thank you for purchasing a Baton Case Key! You can get crates from the Torment Nexus in Security. No refunds. All sales final. Uncrate responsibly."
	icon = 'icons/obj/weapons/baton.dmi'
	icon_state = "casecard(tm)"
	var/being_used = FALSE // no opening multiple crates at once for you, thief

/obj/structure/mystery_box/baton_crate
	name = "baton crate"
	desc = "Only opens with a Baton Case Key from Cargo. Buy one today for 249 credits for a chance at an incredibly rare and unique Baton! \
	Fun for all ages in sectors of space where gambling regulations are unenforced!"
	icon_state = "case"
	box_item = /obj/mystery_box_item/baton_crate
	open_on_attackhand = FALSE
	expires = FALSE
	anchored = FALSE
	max_integrity = 250
	damage_deflection = 15
	play_sounds = FALSE

/obj/structure/mystery_box/baton_crate/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(istype(attacking_item, /obj/item/baton_key))
		var/obj/item/baton_key/key = attacking_item
		if(key.being_used)
			return
		key.being_used = TRUE
		playsound(src, 'sound/effects/doorcreaky.ogg', 80, FALSE, -1)
		Shake(3, 0, 0.5 SECONDS)
		if(do_after(user, 3.75 SECONDS, src))
			qdel(attacking_item)
			anchored = TRUE
			Shake(3, 0, 0.5 SECONDS)
			playsound(src, 'sound/effects/mysterybox/baton_crate_open.ogg', 80, FALSE, -1)
			activate(user)
		else
			Shake(3, 0, 0.5 SECONDS)
			key.being_used = FALSE

/obj/structure/mystery_box/baton_crate/grant_weapon(mob/living/user)
	user.visible_message(span_notice("[user] takes [presented_item] from [src]."), span_notice("You take [presented_item] from [src]."), vision_distance = COMBAT_MESSAGE_RANGE)
	user.put_in_hands(presented_item.selected_item_final)
	QDEL_NULL(presented_item)
	visible_message("[src] breaks down.")
	deconstruct(disassembled = FALSE)

/obj/structure/mystery_box/baton_crate/generate_valid_types()
	valid_types = subtypesof(/datum/baton_model)

/obj/structure/mystery_box/guns
	desc = "A wooden crate that seems equally magical and mysterious, capable of granting the user all kinds of different pieces of gear. This one seems focused on firearms."

/obj/structure/mystery_box/guns/generate_valid_types()
	valid_types = GLOB.summoned_guns

/obj/structure/mystery_box/tdome
	desc = "A wooden crate that seems equally magical and mysterious, capable of granting the user all kinds of different pieces of gear. This one has an extended array of weaponry."

/obj/structure/mystery_box/tdome/generate_valid_types()
	valid_types = GLOB.mystery_box_guns + GLOB.mystery_box_extended

/obj/structure/mystery_box/wands
	desc = "A wooden crate that seems equally magical and mysterious, capable of granting the user all kinds of different magical items."

/obj/structure/mystery_box/wands/generate_valid_types()
	valid_types = GLOB.mystery_magic

///A fishing and pirate-themed mystery box, rarely found by fishing in the ocean, then another cannot be caught for the next 30 minutes.
/obj/structure/mystery_box/fishing
	name = "treasure chest"
	desc = "A piratey coffer equally magical and mysterious, capable of granting different pieces of gear to whoever opens it."
	icon_state = "treasure"
	uses_left = 18
	max_integrity = 100
	damage_deflection = 30
	grant_extra_mag = FALSE
	anchored = FALSE

/obj/structure/mystery_box/handle_deconstruct(disassembled)
	new /obj/item/stack/sheet/mineral/wood(drop_location(), 2)
	return ..()

/obj/structure/mystery_box/fishing/generate_valid_types()
	valid_types = GLOB.mystery_fishing

/obj/structure/mystery_box/fishing/activate(mob/living/user)
	if(user.mind && minds_that_opened_us?[WEAKREF(user.mind)] >= 3)
		to_chat(user, span_warning("[src] refuses to open to you anymore. Perhaps you should present it to someone else..."))
		return
	return ..()

/// This represents the item that comes out of the box and is constantly changing before the box finishes deciding. Can probably be just an /atom or /movable.
/obj/mystery_box_item
	name = "???"
	desc = "Who knows what it'll be??"
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "revolver"
	pixel_y = -8
	uses_integrity = FALSE

	/// The currently selected item. Constantly changes while choosing, determines what is spawned if the prize is claimed, and its current icon
	var/selected_path = /obj/item/gun/ballistic/revolver/c38/detective
	/// The box that spawned this
	var/obj/structure/mystery_box/parent_box
	/// Whether this prize is currently claimable
	var/claimable = FALSE
	/// What color are the hype lights?
	var/hype_light_color = COLOR_VIVID_YELLOW
	/// What item did we select?
	var/selected_item_final
	/// Do we spawn rays when we're opening?
	var/spawn_rays = TRUE
	/// What's the duration of the choosing time?
	var/choosing_duration = MBOX_DURATION_CHOOSING


/obj/mystery_box_item/Initialize(mapload)
	. = ..()
	var/matrix/starting = matrix()
	starting.Scale(0.5,0.5)
	transform = starting
	if(spawn_rays)
		add_filter("weapon_rays", 3, list("type" = "rays", "size" = 28, "color" = hype_light_color))

/obj/mystery_box_item/Destroy(force)
	parent_box = null
	return ..()

// this way, clicking on the prize will work the same as clicking on the box
/obj/mystery_box_item/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(claimable)
		parent_box.grant_weapon(user)

/// Start pushing the prize up
/obj/mystery_box_item/proc/start_animation(atom/parent)
	parent_box = parent
	loop_icon_changes()

/// Keep changing the icon and selected path
/obj/mystery_box_item/proc/loop_icon_changes()
	var/change_delay = 0.2 // the running count of the delay
	var/change_delay_delta = 0.2 // How much to increment the delay per step so the changing slows down
	var/change_counter = 0 // The running count of the running count

	var/matrix/starting = matrix()
	animate(src, pixel_y = 6, transform = starting, time = choosing_duration, easing = QUAD_EASING | EASE_OUT)

	while((change_counter + change_delay_delta + change_delay) < choosing_duration)
		change_delay += change_delay_delta
		change_counter += change_delay
		selected_path = pick(parent_box.valid_types)
		addtimer(CALLBACK(src, PROC_REF(update_random_icon), selected_path), change_counter)

	addtimer(CALLBACK(src, PROC_REF(present_item)), choosing_duration + change_delay_delta)

/// animate() isn't up to the task for queueing up icon changes, so this is the proc we call with timers to update our icon
/obj/mystery_box_item/proc/update_random_icon(new_item_type)
	var/atom/movable/new_item = new_item_type
	icon = new_item::icon
	icon_state = new_item::icon_state

/obj/mystery_box_item/proc/present_item()
	var/atom/movable/selected_item = selected_path
	add_filter("ready_outline", 2, list("type" = "outline", "color" = hype_light_color, "size" = 0.2))
	name = selected_item::name
	parent_box.present_weapon()
	claimable = TRUE

/// Sink back into the box
/obj/mystery_box_item/proc/expire_animation()
	var/matrix/shrink_back = matrix()
	shrink_back.Scale(0.5,0.5)
	animate(src, pixel_y = -8, transform = shrink_back, time = MBOX_DURATION_EXPIRING)

/obj/mystery_box_item/baton_crate
	name = "Mystery Baton"
	desc = "Ninety-nine percent of unboxers quit before they win a factory new donut sturambit."
	hype_light_color = COLOR_SECURITY_RED
	icon = 'icons/obj/weapons/baton.dmi'
	icon_state = "stunbaton"
	choosing_duration = 9.6 SECONDS
	spawn_rays = FALSE
	var/datum/baton_model/baton_model
	var/list/possible_models = list()

/obj/mystery_box_item/baton_crate/Initialize(mapload)
	. = ..()
	if(!length(possible_models))
		for(var/datum/baton_model/model as anything in subtypesof(/datum/baton_model))
			possible_models += list(initial(model.type) = initial(model.rarity))

/obj/mystery_box_item/baton_crate/update_random_icon(new_item_type)
	baton_model = pick_weight(possible_models)
	var/icon/possible_baton = icon('icons/obj/weapons/baton.dmi', initial(baton_model.icon_state))
	possible_baton.Blend("#000000", ICON_MULTIPLY)
	icon = possible_baton
	icon_state = ""
	playsound(src, 'sound/effects/mysterybox/baton_crate_scroll.ogg', 80, FALSE, -1)

/obj/mystery_box_item/baton_crate/present_item()
	var/obj/item/melee/baton/security/skin/selected_item = new /obj/item/melee/baton/security/skin(src, baton_model)
	name = selected_item.name
	desc = selected_item.desc
	icon = selected_item.icon
	icon_state = "stunbaton"
	selected_item_final = selected_item
	var/highest_rarity_found
	if(selected_item.chosen_model.rarity_hex == "baton_common" || selected_item.chosen_skin.rarity_hex == "baton_common")
		highest_rarity_found = "baton_common"
	if(selected_item.chosen_model.rarity_hex == "baton_uncommon" || selected_item.chosen_skin.rarity_hex == "baton_uncommon")
		highest_rarity_found = "baton_uncommon"
	if(selected_item.chosen_model.rarity_hex == "baton_rare" || selected_item.chosen_skin.rarity_hex == "baton_rare")
		highest_rarity_found = "baton_rare"
	if(selected_item.chosen_model.rarity_hex == "baton_mythical" || selected_item.chosen_skin.rarity_hex == "baton_mythical")
		highest_rarity_found = "baton_mythical"
	if(selected_item.chosen_model.rarity_hex == "baton_legendary" || selected_item.chosen_skin.rarity_hex == "baton_legendary")
		highest_rarity_found = "baton_legendary"
	if(selected_item.chosen_model.rarity_hex == "baton_ancient" || selected_item.chosen_skin.rarity_hex == "baton_ancient")
		highest_rarity_found = "baton_ancient"
	switch(highest_rarity_found)
		if("baton_common")
			playsound(src, 'sound/effects/mysterybox/common.ogg', 80, FALSE, -1) // too lame for hype rays
		if("baton_uncommon")
			playsound(src, 'sound/effects/mysterybox/uncommon.ogg', 80, FALSE, -1)
			add_filter("weapon_rays", 3, list("type" = "rays", "size" = 14, "color" = "#6597e2"))
			add_filter("ready_outline", 2, list("type" = "outline", "color" = "#6597e2", "size" = 0.2))
		if("baton_rare")
			playsound(src, 'sound/effects/mysterybox/rare.ogg', 80, FALSE, -1)
			add_filter("weapon_rays", 3, list("type" = "rays", "size" = 14, "color" = "#4b69ce"))
			add_filter("ready_outline", 2, list("type" = "outline", "color" = "#4b69ce", "size" = 0.2))
		if("baton_mythical")
			playsound(src, 'sound/effects/mysterybox/mythical.ogg', 80, FALSE, -1)
			add_filter("weapon_rays", 3, list("type" = "rays", "size" = 28, "color" = "#8847ff"))
			add_filter("ready_outline", 2, list("type" = "outline", "color" = "#8847ff", "size" = 0.2))
		if("baton_legendary")
			playsound(src, 'sound/effects/mysterybox/legendary.ogg', 80, FALSE, -1)
			add_filter("weapon_rays", 3, list("type" = "rays", "size" = 28, "color" = "#d42de6"))
			add_filter("ready_outline", 2, list("type" = "outline", "color" = hype_light_color, "size" = 0.2))
		if("baton_ancient")
			playsound(src, 'sound/effects/mysterybox/ancient.ogg', 80, FALSE, -1)
			add_filter("weapon_rays", 3, list("type" = "rays", "size" = 42, "color" = "#eb4c4c"))
			add_filter("ready_outline", 2, list("type" = "outline", "color" = "#eb4c4c", "size" = 0.2))
	parent_box.present_weapon()
	claimable = TRUE

#undef MYSTERY_BOX_COOLING_DOWN
#undef MYSTERY_BOX_STANDBY
#undef MYSTERY_BOX_CHOOSING
#undef MYSTERY_BOX_PRESENTING
#undef MBOX_DURATION_CHOOSING
#undef MBOX_DURATION_PRESENTING
#undef MBOX_DURATION_EXPIRING
#undef MBOX_DURATION_STANDBY
