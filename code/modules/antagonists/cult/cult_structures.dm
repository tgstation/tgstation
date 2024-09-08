// Cult buildings!
/obj/structure/destructible/cult
	icon = 'icons/obj/antags/cult/structures.dmi'
	break_sound = 'sound/hallucinations/veryfar_noise.ogg'
	density = TRUE
	anchored = TRUE
	light_power = 2
	debris = list(/obj/item/stack/sheet/runed_metal = 1)
	/// Length of the cooldown between uses.
	var/use_cooldown_duration = 5 MINUTES
	/// If provided, a bonus tip displayed to cultists on examined.
	var/cult_examine_tip
	/// The cooldown for when items can be dispensed.
	COOLDOWN_DECLARE(use_cooldown)
	/// Assigned cult team, set when cultistism is checked.
	var/datum/team/cult/cult_team

/obj/structure/destructible/cult/Destroy()
	cult_team = null
	return ..()

/obj/structure/destructible/cult/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_CONSTRUCTED, PROC_REF(on_constructed))

/obj/structure/destructible/cult/proc/on_constructed(datum/source, mob/builder)
	SIGNAL_HANDLER
	var/datum/antagonist/cult/cultist = builder.mind?.has_antag_datum(/datum/antagonist/cult, TRUE)
	cult_team = cultist?.get_team()

/// Tries to find a cultist. If it succeeds, it also takes advantage of the moment to define the structure's cult team if it's not set yet.
/obj/structure/destructible/cult/proc/is_cultist_check(mob/fool)

	if(!IS_CULTIST(fool))
		return FALSE

	if(isnull(cult_team))
		var/datum/antagonist/cult/cultist = fool.mind?.has_antag_datum(/datum/antagonist/cult, TRUE)
		cult_team = cultist?.get_team()

	return TRUE

/obj/structure/destructible/cult/examine_status(mob/user)
	if(is_cultist_check(user) || isobserver(user))
		return span_cult("It's at <b>[round(atom_integrity * 100 / max_integrity)]%</b> stability.")
	return ..()

/obj/structure/destructible/cult/examine(mob/user)
	. = ..()
	. += span_notice("[src] is [anchored ? "secured to":"unsecured from"] the floor.")
	if(is_cultist_check(user) || isobserver(user))
		if(cult_examine_tip)
			. += span_cult(cult_examine_tip)
		if(!COOLDOWN_FINISHED(src, use_cooldown_duration))
			. += span_cult_italic("The magic in [src] is too weak, it will be ready to use again in <b>[DisplayTimeText(COOLDOWN_TIMELEFT(src, use_cooldown_duration))]</b>.")

/obj/structure/destructible/cult/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return
	update_appearance(UPDATE_ICON)

/obj/structure/destructible/cult/update_icon_state()
	icon_state = "[initial(icon_state)][anchored ? "" : "_off"]"
	return ..()

/*
 * Proc for use with the concealing spell. Hides the building (makes it invisible).
 */
/obj/structure/destructible/cult/proc/conceal()
	set_density(FALSE)
	visible_message(span_danger("[src] fades away."))
	SetInvisibility(INVISIBILITY_OBSERVER, id=type)
	alpha = 100
	set_light_power(0)
	set_light_range(0)
	update_light()

/*
 * Proc for use with the concealing spell. Reveals the building (makes it visible).
 */
/obj/structure/destructible/cult/proc/reveal()
	set_density(initial(density))
	RemoveInvisibility(type)
	visible_message(span_danger("[src] suddenly appears!"))
	alpha = initial(alpha)
	set_light_range(initial(light_range))
	set_light_power(initial(light_power))
	update_light()

// Cult buildings that dispense items to cultists.
/obj/structure/destructible/cult/item_dispenser
	/// An associated list of options this structure can make. See setup_options() for format.
	var/list/options
	/// The dispenser will create this item and then delete itself if it is rust converted.
	var/obj/mansus_conversion_path = /obj/item/skub

/obj/structure/destructible/cult/item_dispenser/Initialize(mapload)
	. = ..()
	setup_options()

/obj/structure/destructible/cult/item_dispenser/rust_heretic_act()
	visible_message(span_notice("[src] crumbles to dust. In its midst, you spot \a [initial(mansus_conversion_path.name)]."))
	var/turf/turfy = get_turf(src)
	new mansus_conversion_path(turfy)
	turfy.rust_heretic_act()
	return ..()

/obj/structure/destructible/cult/item_dispenser/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!isliving(user) || !is_cultist_check(user))
		to_chat(user, span_warning("You're pretty sure you know exactly what this is used for and you can't seem to touch it."))
		return
	if(!anchored)
		to_chat(user, span_cult_italic("You need to anchor [src] to the floor first."))
		return
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		to_chat(user, span_cult_italic("The magic in [src] is too weak, it will be ready to use again in <b>[DisplayTimeText(COOLDOWN_TIMELEFT(src, use_cooldown))]</b>."))
		return

	setup_options()

	var/list/spawned_items = get_items_to_spawn(user)
	if(!length(spawned_items))
		return
	if(QDELETED(src) || !anchored || !Adjacent(user) || !check_menu(user) || !COOLDOWN_FINISHED(src, use_cooldown))
		return

	COOLDOWN_START(src, use_cooldown, use_cooldown_duration)
	for(var/item_to_make in spawned_items)
		var/obj/item/made_item = new item_to_make(get_turf(src))
		ADD_TRAIT(made_item, TRAIT_CONTRABAND, INNATE_TRAIT)
		succcess_message(user, made_item)


/*
 * Set up and populate our list of options.
 * Overriden by subtypes.
 *
 * The list of options is a associated list of format:
 *   item_name = list(
 *     preview = image(),
 *     output = list(paths),
 *   )
 */
/obj/structure/destructible/cult/item_dispenser/proc/setup_options()
	return

/*
 * Extra options, currently used for items unlocked after sacrificing a heretic.
 *
 * The list of options is a associated list of format:
 *   item_name = list(
 *     preview = image(),
 *     output = list(paths),
 *   )
 */
/obj/structure/destructible/cult/item_dispenser/proc/extra_options()
	return

/*
 * Get all items that this cult building will spawn when interacted with.
 * Opens a radial menu for the user and shows them the list of options, which they can choose from.
 *
 * Return a list: A list of typepaths to items that this building will spawn, chosen by the user.
 */
/obj/structure/destructible/cult/item_dispenser/proc/get_items_to_spawn(mob/living/user)
	if(!LAZYLEN(options))
		CRASH("[type] did not set any options via setup_options!")

	var/list/choices = list()
	for(var/item in options)
		choices[item] = options[item][PREVIEW_IMAGE]

	var/picked_choice = show_radial_menu(
		user,
		src,
		choices,
		custom_check = CALLBACK(src, PROC_REF(check_menu), user),
		require_near = TRUE,
		tooltips = TRUE,
		)

	if(!picked_choice)
		return

	return options[picked_choice][OUTPUT_ITEMS]

/*
 * Gives feedback to [user] after creating a [spawned_item].
 * Override for unique feedback messages on item spawn.
 */
/obj/structure/destructible/cult/item_dispenser/proc/succcess_message(mob/living/user, obj/item/spawned_item)
	to_chat(user, span_cult_italic("[src] produces a [spawned_item.name]."))

/*
 * Simple proc intended for use in callbacks to determine if [user] can continue to use a radial menu.
 *
 * Returns TRUE if the user is a living mob that is a cultist and is not incapacitated.
 */
/obj/structure/destructible/cult/item_dispenser/proc/check_menu(mob/user)
	return isliving(user) && is_cultist_check(user) && !user.incapacitated

// Spooky looking door used in gateways. Or something.
/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back."
	icon = 'icons/obj/antags/cult/structures.dmi'
	icon_state = "hole"
	density = TRUE
	anchored = TRUE

/obj/effect/gateway/singularity_act()
	return

/obj/effect/gateway/singularity_pull()
	return
