/**
 * Bitrunning tech disks which let you load items or programs into the vdom on first avatar generation.
 * For the record: Balance shouldn't be a primary concern.
 * You can make the custom cheese spells you've always wanted.
 * Just make it fun and engaging, it's PvE content.
 */
/obj/item/bitrunning_disk
	name = "generic bitrunning program"
	desc = "A disk containing source code."
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	base_icon_state = "datadisk"
	icon_state = "datadisk0"
	/// Name of the choice made
	var/choice_made

/obj/item/bitrunning_disk/Initialize(mapload)
	. = ..()

	icon_state = "[base_icon_state][rand(0, 7)]"
	update_icon()

/obj/item/bitrunning_disk/examine(mob/user)
	. = ..()
	. += span_infoplain("This disk must be carried on your person into a netpod to be used.")

	if(isnull(choice_made))
		. += span_notice("To make a selection, toggle the disk in hand.")
		return

	. += span_info("It has been used to select: <b>[choice_made]</b>.")
	. += span_notice("It cannot make another selection.")

/obj/item/bitrunning_disk/ability
	desc = "A disk containing source code. It can be used to preload abilities into the virtual domain. Duplicate abilities will be ignored."
	/// The selected ability that this grants
	var/datum/action/granted_action
	/// The list of actions that this can grant
	var/list/datum/action/selectable_actions = list()

/obj/item/bitrunning_disk/ability/attack_self(mob/user, modifiers)
	. = ..()

	if(choice_made)
		return

	var/names = list()
	for(var/datum/action/thing as anything in selectable_actions)
		names += initial(thing.name)

	var/choice = tgui_input_list(user, message = "Select an ability",  title = "Bitrunning Program", items = names)
	if(isnull(choice) || !user.is_holding(src))
		return

	for(var/datum/action/thing as anything in selectable_actions)
		if(initial(thing.name) == choice)
			granted_action = thing

	if(isnull(granted_action))
		return

	balloon_alert(user, "selected")
	playsound(user, 'sound/items/click.ogg', 50, TRUE)
	choice_made = choice

/// Tier 1 programs. Simple, funny, or helpful.
/obj/item/bitrunning_disk/ability/tier1
	name = "bitrunning program: basic"
	selectable_actions = list(
		/datum/action/cooldown/spell/conjure/cheese,
		/datum/action/cooldown/spell/basic_heal,
	)

/// Tier 2 programs. More complex, powerful, or useful.
/obj/item/bitrunning_disk/ability/tier2
	name = "bitrunning program: complex"
	selectable_actions = list(
		/datum/action/cooldown/spell/pointed/projectile/fireball,
		/datum/action/cooldown/spell/pointed/projectile/lightningbolt,
		/datum/action/cooldown/spell/forcewall,
	)

/// Tier 3 abilities. Very powerful, game breaking.
/obj/item/bitrunning_disk/ability/tier3
	name = "bitrunning program: elite"
	selectable_actions = list(
		/datum/action/cooldown/spell/shapeshift/dragon,
		/datum/action/cooldown/spell/shapeshift/polar_bear,
	)

/obj/item/bitrunning_disk/item
	desc = "A disk containing source code. It can be used to preload items into the virtual domain."
	/// The selected item that this grants
	var/obj/granted_item
	/// The list of actions that this can grant
	var/list/obj/selectable_items = list()

/obj/item/bitrunning_disk/item/attack_self(mob/user, modifiers)
	. = ..()

	if(choice_made)
		return

	var/names = list()
	for(var/obj/thing as anything in selectable_items)
		names += initial(thing.name)

	var/choice = tgui_input_list(user, message = "Select an ability",  title = "Bitrunning Program", items = names)
	if(isnull(choice) || !user.is_holding(src))
		return

	for(var/obj/thing as anything in selectable_items)
		if(initial(thing.name) == choice)
			granted_item = thing

	balloon_alert(user, "selected")
	playsound(user, 'sound/items/click.ogg', 50, TRUE)
	choice_made = choice

/// Tier 1 items. Simple, funny, or helpful.
/obj/item/bitrunning_disk/item/tier1
	name = "bitrunning gear: simple"
	selectable_items = list(
		/obj/item/pizzabox/infinite,
		/obj/item/gun/medbeam,
		/obj/item/grenade/c4,
	)

/// Tier 2 items. More complex, powerful, or useful.
/obj/item/bitrunning_disk/item/tier2
	name = "bitrunning gear: complex"
	selectable_items = list(
		/obj/item/reagent_containers/hypospray/medipen/survival/luxury,
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/clothing/suit/armor/vest,
	)

/// Tier 3 items. Very powerful, game breaking.
/obj/item/bitrunning_disk/item/tier3
	name = "bitrunning gear: advanced"
	selectable_items = list(
		/obj/item/gun/energy/e_gun/nuclear,
		/obj/item/dualsaber/green,
		/obj/item/grenade/syndieminibomb,
	)

///proto-kinetic accelerator mods, to be applied to pka's given inside domains
/obj/item/bitrunning_disk/item/pka_mods
	name = "bitrunning gear: proto-kinetic accelerator mods"
	selectable_items = list(
		/obj/item/borg/upgrade/modkit/range,
		/obj/item/borg/upgrade/modkit/damage,
		/obj/item/borg/upgrade/modkit/cooldown,
		/obj/item/borg/upgrade/modkit/aoe/mobs,
		/obj/item/borg/upgrade/modkit/human_passthrough,
	)

/obj/item/bitrunning_disk/item/pka_mods/premium
	name = "bitrunning gear: premium proto-kinetic accelerator mods"
	selectable_items = list(
		/obj/item/borg/upgrade/modkit/cooldown/repeater,
		/obj/item/borg/upgrade/modkit/lifesteal,
		/obj/item/borg/upgrade/modkit/resonator_blasts,
		/obj/item/borg/upgrade/modkit/bounty,
		/obj/item/borg/upgrade/modkit/indoors,
	)

///proto-kinetic crusher trophies, to be applied to pkc's given inside domains
/obj/item/bitrunning_disk/item/pkc_mods
	name = "bitrunning gear: proto-kinetic crusher mods"
	selectable_items = list(
		/obj/item/crusher_trophy/watcher_wing,
		/obj/item/crusher_trophy/blaster_tubes/magma_wing,
		/obj/item/crusher_trophy/legion_skull,
		/obj/item/crusher_trophy/wolf_ear,
	)

/obj/item/bitrunning_disk/item/pkc_mods/premium
	name = "bitrunning gear: premium proto-kinetic crusher mods"
	selectable_items = list(
		/obj/item/crusher_trophy/watcher_wing/ice_wing,
		/obj/item/crusher_trophy/blaster_tubes,
		/obj/item/crusher_trophy/miner_eye,
		/obj/item/crusher_trophy/tail_spike,
		/obj/item/crusher_trophy/demon_claws,
		/obj/item/crusher_trophy/vortex_talisman,
		/obj/item/crusher_trophy/ice_demon_cube,
	)
