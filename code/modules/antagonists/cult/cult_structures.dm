// Cult buildings!
/obj/structure/destructible/cult
	icon = 'icons/obj/cult.dmi'
	break_sound = 'sound/hallucinations/veryfar_noise.ogg'
	density = TRUE
	anchored = TRUE
	light_power = 2
	debris = list(/obj/item/stack/sheet/runed_metal = 1)

/obj/structure/destructible/cult/examine_status(mob/user)
	if(IS_CULTIST(user) || isobserver(user))
		return span_cult("It's at <b>[round(atom_integrity * 100 / max_integrity)]%</b> stability.")
	return ..()

/obj/structure/destructible/cult/examine(mob/user)
	. = ..()
	. += span_notice("[src] is [anchored ? "secured to":"unsecured from"] the floor.")

/obj/structure/destructible/cult/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return
	update_appearance(UPDATE_ICON)

/obj/structure/destructible/cult/update_icon_state()
	icon_state = "[initial(icon_state)][anchored ? "" : "_off"]"
	return ..()

/obj/structure/destructible/cult/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(!isconstruct(user))
		return ..()

	var/mob/living/simple_animal/hostile/construct/healer = user
	if(!healer.can_repair)
		return ..()

	if(atom_integrity >= max_integrity)
		to_chat(user, span_cult("You cannot repair [src], as it's undamaged!"))
		return

	user.changeNext_move(CLICK_CD_MELEE)
	atom_integrity = min(max_integrity, atom_integrity + 5)
	Beam(user, icon_state = "sendbeam", time = 0.4 SECONDS)
	user.visible_message(
		span_danger("[user] repairs [src]."),
		span_cult("You repair [src], leaving it at <b>[round(atom_integrity * 100 / max_integrity)]%</b> stability.")
		)

/*
 * Proc for use with the concealing spell. Hides the building (makes it invisible).
 */
/obj/structure/destructible/cult/proc/conceal()
	set_density(FALSE)
	visible_message(span_danger("[src] fades away."))
	invisibility = INVISIBILITY_OBSERVER
	alpha = 100
	set_light_power(0)
	set_light_range(0)
	update_light()

/*
 * Proc for use with the concealing spell. Reveals the building (makes it visible).
 */
/obj/structure/destructible/cult/proc/reveal()
	set_density(initial(density))
	invisibility = 0
	visible_message(span_danger("[src] suddenly appears!"))
	alpha = initial(alpha)
	set_light_range(initial(light_range))
	set_light_power(initial(light_power))
	update_light()

// Cult buildings that dispense items to cultists.
/obj/structure/destructible/cult/item_dispenser
	/// Length of the cooldown between item dispenses.
	var/item_creation_cooldown = 5 MINUTES
	/// If provided, a bonus tip displayed to cultists on examined.
	var/cult_examine_tip
	/// The cooldown for when items can be dispensed.
	COOLDOWN_DECLARE(use_cooldown)

/obj/structure/destructible/cult/item_dispenser/examine(mob/user)
	. = ..()
	if(IS_CULTIST(user) || isobserver(user))
		if(cult_examine_tip)
			. += span_cult(cult_examine_tip)
		if(!COOLDOWN_FINISHED(src, use_cooldown))
			. += span_cultitalic("The magic in [src] is too weak, it will be ready to use again in <b>[DisplayTimeText(COOLDOWN_TIMELEFT(src, use_cooldown))]</b>.")

/obj/structure/destructible/cult/item_dispenser/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!isliving(user) || !IS_CULTIST(user))
		to_chat(user, span_warning("You're pretty sure you know exactly what this is used for and you can't seem to touch it."))
		return
	if(!anchored)
		to_chat(user, span_cultitalic("You need to anchor [src] to the floor first."))
		return
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		to_chat(user, span_cultitalic("The magic in [src] is too weak, it will be ready to use again in <b>[DisplayTimeText(COOLDOWN_TIMELEFT(src, use_cooldown))]</b>."))
		return

	var/list/spawned_items = get_items_to_spawn(user)
	if(!length(spawned_items))
		return
	if(QDELETED(src) || !anchored || !Adjacent(user) || !check_menu(user) || !COOLDOWN_FINISHED(src, use_cooldown))
		return

	COOLDOWN_START(src, use_cooldown, item_creation_cooldown)
	for(var/item_to_make in spawned_items)
		var/obj/item/made_item = new item_to_make(get_turf(src))
		succcess_message(user, made_item)

/*
 * Get all items that this cult building spawns when interacted with.
 * Override on a subtype basis to do things like open a radial
 * to give the user a list of options of items to chose from.
 *
 * Return a list: A list of typepaths to items that this building spawns when interacted with.
 */
/obj/structure/destructible/cult/item_dispenser/proc/get_items_to_spawn(mob/living/user)
	RETURN_TYPE(/list)
	CRASH("[type] - get_items_to_spawn() not implemented.")

/*
 * Gives feedback to [user] after creating a [spawned_item].
 * Override for unique feedback messages on item spawn.
 */
/obj/structure/destructible/cult/item_dispenser/proc/succcess_message(mob/living/user, obj/item/spawned_item)
	to_chat(user, span_cultitalic("[src] produces a [spawned_item.name]."))

/*
 * Simple proc intended for use in callbacks to determine if [user] can continue to use a radial menu.
 *
 * Returns TRUE if the user is a living mob that is a cultist and is not incapacitated.
 */
/obj/structure/destructible/cult/item_dispenser/proc/check_menu(mob/user)
	return isliving(user) && IS_CULTIST(user) && !user.incapacitated()

// Spooky looking door used in gateways. Or something.
/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = TRUE
	anchored = TRUE

/obj/effect/gateway/singularity_act()
	return

/obj/effect/gateway/singularity_pull()
	return
