/obj/structure/tripwire
	name = "stretching"
	desc = "A wire stretched for several meters. The end of the wire is tied to something..."
	icon_state = "zipline_hook" // Я кстати говорил какой у меня большой хуй? Он ещё кста влезает в рот кодеров сс220)))
	icon = 'icons/effects/beam.dmi' // Ну а хули спрайт есть можно и использовать
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = TRUE
	resistance_flags = FLAMMABLE
	max_integrity = 25
	integrity_failure = 0.5
	var/obj/item/grenade/stretching
	var/mob/owner

/obj/structure/tripwire/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(check_anus_wycc_for_stretchability),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/tripwire/proc/activate()
	if(stretching)
		stretching.detonate(owner)
		stretching.forceMove(get_turf(stretching))
		to_chat(owner, span_userdanger("We hit the [src] and activate the [stretching.name]!"))
		qdel(src)

/obj/structure/tripwire/proc/check_anus_wycc_for_stretchability(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(ismob(AM))
		var/mob/MM = AM
		if(MM.movement_type & FLYING)
			return
		if(ismouse(MM))
			return
		if(ishuman(AM))
			var/mob/living/carbon/human/H
			if(H.move_intent == MOVE_INTENT_WALK)
				to_chat(AM, span_notice("Carefully step over the [src]."))
				return
	activate()

/obj/structure/tripwire/attack_hand(mob/user)
	activate()

/obj/structure/tripwire/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/wirecutters) && !(resistance_flags & INDESTRUCTIBLE))
		if(do_after(user, 30, target = src))
			W.play_tool_sound(src)
			if(prob(80) && user.mind.antag_datums == null && user != owner)
				to_chat(user, span_userdanger("Accidentally cutting the wire incorrectly!"))
				activate()
				return
			if(stretching)
				stretching.forceMove(get_turf(stretching))
			qdel(src)
	..()

/obj/structure/tripwire/CheckParts(list/parts_list)
	stretching = locate() in parts_list
	if(!stretching)
		qdel(src)
		return
	return ..()

/datum/crafting_recipe/tripwire
	name = "stretch"
	time = 5 SECONDS
	result = /obj/structure/tripwire
	reqs = list(/obj/item/stack/cable_coil = 30,
				/obj/item/grenade = 1)
	parts = list(/obj/item/grenade = 1)
	time = 5 SECONDS
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/tripwire/on_craft_completion(mob/user, atom/result)
	. = ..()
	var/obj/structure/tripwire/TW = result
	TW.owner = user
	message_admins("[ADMIN_LOOKUPFLW(user)] поставил растяжку[ADMIN_COORDJMP(result)]")
	log_game("[key_name(user)] поставил растяжку[COORD(result)]")
