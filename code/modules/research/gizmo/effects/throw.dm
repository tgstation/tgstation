/datum/gizmo_effect/throw_self/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	holder.throw_at(get_edge_target_turf(holder, pick(GLOB.alldirs)), 50, 1)

/datum/gizmo_effect/thrower
	/// Weighted list of items we can throw
	var/list/throwables = list(
		/obj/item/knife/kitchen = 1,
		/obj/item/shard = 1,

	)
	/// Path of item to throw
	var/throwing_path

/datum/gizmo_effect/thrower/New()
	. = ..()
	throwing_path = pick_weight(throwables)

/datum/gizmo_effect/thrower/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	var/obj/item/item = new throwing_path (get_turf(holder))

	var/list/targets = list()
	for(var/mob/living/victims in oview(5, holder))
		targets += victims

	if(!targets.len)
		targets += get_edge_target_turf(holder, GLOB.alldirs)
	item.throw_at(pick(targets), 20, 3)
	modify(item)

/// Do some extra modifications if need be
/datum/gizmo_effect/thrower/proc/modify(obj/item/item)
	return

/datum/gizmo_effect/ominous/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	holder.audible_message(span_hear("You hear an ominous hum."))

/datum/gizmo_effect/thrower/grenade
	throwables = list(
		/obj/item/grenade/iedcasing = 3,
		/obj/item/grenade/chem_grenade/cleaner = 2,
		/obj/item/grenade/smokebomb = 2,
		/obj/item/grenade/syndieminibomb/concussion = 1,
		/obj/item/grenade/frag = 1,
		/obj/item/grenade/chem_grenade/teargas = 1,
		/obj/item/grenade/chem_grenade/facid = 1,
		/obj/item/grenade/chem_grenade/clf3 = 1,
	)

/datum/gizmo_effect/thrower/grenade/modify(obj/item/item)
	var/obj/item/grenade/regret = item
	regret.arm_grenade()
