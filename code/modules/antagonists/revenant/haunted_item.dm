/// Makes our item SUPER spooky!
/// Adds the haunted element and some other bonuses
/datum/component/haunted_item
	/// Our throwforce before being haunted
	var/pre_haunt_throwforce
	/// Optional message displayed when we're despawned / dehaunted
	var/despawn_message
	/// List of types that, if they hit our item, we will instantly stop the haunting
	var/list/types_which_dispell_us
	/// List of traits which allow items outside of types_which_dispell_us to also work on us
	var/list/traits_which_dispell_us

/datum/component/haunted_item/Initialize(
	// What color should the haunted item be glowing? By default the color's white (passed into the haunted element).
	haunt_color,
	// How long should the haunt last? If null, it will last forever / until removed.
	haunt_duration,
	// How far should the haunted item look for targets when it's created? If null, it won't aggro anyone by default.
	aggro_radius,
	// Optional, what message should the item show when the haunt happens (when the component is applied)?
	spawn_message,
	// Optional, what message should the item show when the haunt ends (clear_haunting is called)?
	despawn_message,
	// How much throwforce does the haunted item get? Keep in mind it attacks by throwing itself
	throw_force_bonus = 3,
	// What's the max amount of throwforce that we should consider going to
	throw_force_max = 15,
	// See the types_which_dispell_us list. By default / if null, this will become the default static list.
	list/types_which_dispell_us,
	// List of traits which allow items outside of types_which_dispell_us to also work on us
	// By default / if null will default to TRAIT_NULLROD_ITEM
	list/traits_which_dispell_us,
)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/haunted_item = parent
	if(istype(haunted_item.ai_controller, /datum/ai_controller/haunted)) // already spooky
		return COMPONENT_INCOMPATIBLE

	haunted_item.make_haunted(MAGIC_TRAIT, haunt_color)
	if(isnull(haunted_item.ai_controller)) // failed to make spooky! don't go on
		return COMPONENT_INCOMPATIBLE

	if(!isnull(haunt_duration))
		addtimer(CALLBACK(src, PROC_REF(clear_haunting)), haunt_duration)

	if(!isnull(spawn_message))
		haunted_item.visible_message(spawn_message)

	if(!isnull(aggro_radius))
		// We were given an aggro radius, we'll start attacking people nearby
		for(var/mob/living/victim in view(aggro_radius, haunted_item))
			if(victim.stat != CONSCIOUS)
				continue
			if(victim.mob_biotypes & MOB_SPIRIT)
				continue
			if(victim.invisibility >= INVISIBILITY_REVENANT)
				continue
			// This gives all mobs in view "5" haunt level
			// For reference picking one up gives "2"
			haunted_item.ai_controller.add_blackboard_key_assoc(BB_TO_HAUNT_LIST, victim, 5)

	if(haunted_item.throwforce < throw_force_max)
		pre_haunt_throwforce = haunted_item.throwforce
		haunted_item.throwforce = min(haunted_item.throwforce + throw_force_bonus, throw_force_max)

	var/static/list/default_dispell_types = list(/obj/item/nullrod, /obj/item/book/bible)
	var/static/list/default_dispell_traits = list(TRAIT_NULLROD_ITEM)
	src.types_which_dispell_us = types_which_dispell_us || default_dispell_types
	src.traits_which_dispell_us = traits_which_dispell_us || default_dispell_traits
	src.despawn_message = despawn_message

/datum/component/haunted_item/Destroy(force)
	var/obj/item/haunted_item = parent
	// Handle these two specifically in Destroy() instead of clear_haunting(),
	// because we want to make sure they always get dealt with no matter how the component is removed
	if(!isnull(pre_haunt_throwforce))
		haunted_item.throwforce = pre_haunt_throwforce
	haunted_item.remove_haunted(MAGIC_TRAIT)
	return ..()

/datum/component/haunted_item/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_hit_by_holy_tool))

/datum/component/haunted_item/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)

/// Removes the haunting, showing any despawn message we have and qdeling our component
/datum/component/haunted_item/proc/clear_haunting()
	var/obj/item/haunted_item = parent

	if(!isnull(despawn_message))
		haunted_item.visible_message(despawn_message)

	qdel(src)

/// Signal proc for [COMSIG_ATOM_ATTACKBY], when we get smacked by holy stuff we should stop being ghostly.
/datum/component/haunted_item/proc/on_hit_by_holy_tool(obj/item/source, obj/item/attacking_item, mob/living/attacker, params)
	SIGNAL_HANDLER

	if(!is_type_in_list(attacking_item, types_which_dispell_us))
		var/has_trait = FALSE
		for(var/dispell_trait in traits_which_dispell_us)
			if(HAS_TRAIT(attacking_item, dispell_trait))
				has_trait = TRUE
				break

		if(!has_trait)
			return

	attacker.visible_message(span_warning("[attacker] dispells the ghostly energy from [source]!"), span_warning("You dispel the ghostly energy from [source]!"))
	clear_haunting()
	return COMPONENT_NO_AFTERATTACK

/**
 * Takes a given area and chance, applying the haunted_item component to objects in the area.
 *
 * Takes an epicenter, and within the range around it, runs a haunt_chance percent chance of
 * applying the haunted_item component to nearby objects.
 *
 * * epicenter - The center of the outburst area.
 * * range - The range of the outburst, centered around the epicenter.
 * * haunt_chance - The percent chance that an object caught in the epicenter will be haunted.
 * * duration - How long the haunting will remain for.
 */

/proc/haunt_outburst(epicenter, range, haunt_chance, duration = 1 MINUTES)
	for(var/obj/item/object_to_possess in range(range, epicenter))
		if(!prob(haunt_chance))
			continue
		object_to_possess.AddComponent(/datum/component/haunted_item, \
			haunt_color = "#52336e", \
			haunt_duration = duration, \
			aggro_radius = range, \
			spawn_message = span_revenwarning("[object_to_possess] slowly rises upward, hanging menacingly in the air..."), \
			despawn_message = span_revenwarning("[object_to_possess] settles to the floor, lifeless and unmoving."), \
		)
