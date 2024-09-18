//Water source, use the type water_source for unlimited water sources like classic sinks.
/obj/structure/water_source
	name = "Water Source"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face. This one seems to be infinite!"
	anchored = TRUE
	///Boolean on whether something is currently being washed, preventing multiple people from cleaning at once.
	var/busy = FALSE
	///The reagent that is dispensed from this source, by default it's water.
	var/datum/reagent/dispensedreagent = /datum/reagent/water

/obj/structure/water_source/Initialize(mapload)
	. = ..()
	create_reagents(INFINITY, NO_REACT)
	reagents.add_reagent(dispensedreagent, INFINITY)

/obj/structure/water_source/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!iscarbon(user))
		return
	if(!Adjacent(user))
		return

	if(busy)
		to_chat(user, span_warning("Someone's already washing here!"))
		return
	var/selected_area = user.parse_zone_with_bodypart(user.zone_selected)
	var/washing_face = FALSE
	if(selected_area in list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_EYES))
		washing_face = TRUE
	user.visible_message(
		span_notice("[user] starts washing [user.p_their()] [washing_face ? "face" : "hands"]..."),
		span_notice("You start washing your [washing_face ? "face" : "hands"]..."))
	busy = TRUE

	if(!do_after(user, 4 SECONDS, target = src))
		busy = FALSE
		return

	busy = FALSE

	if(washing_face)
		SEND_SIGNAL(user, COMSIG_COMPONENT_CLEAN_FACE_ACT, CLEAN_WASH)
	else if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(!human_user.wash_hands(CLEAN_WASH))
			to_chat(user, span_warning("Your hands are covered by something!"))
			return
	else
		user.wash(CLEAN_WASH)

	user.visible_message(
		span_notice("[user] washes [user.p_their()] [washing_face ? "face" : "hands"] using [src]."),
		span_notice("You wash your [washing_face ? "face" : "hands"] using [src]."),
	)

/obj/structure/water_source/attackby(obj/item/attacking_item, mob/living/user, params)
	if(busy)
		to_chat(user, span_warning("Someone's already washing here!"))
		return

	if(attacking_item.item_flags & ABSTRACT) //Abstract items like grabs won't wash. No-drop items will though because it's still technically an item in your hand.
		return

	if(is_reagent_container(attacking_item))
		var/obj/item/reagent_containers/container = attacking_item
		if(container.is_refillable())
			if(!container.reagents.holder_full())
				container.reagents.add_reagent(dispensedreagent, min(container.volume - container.reagents.total_volume, container.amount_per_transfer_from_this))
				to_chat(user, span_notice("You fill [container] from [src]."))
				return TRUE
			to_chat(user, span_notice("\The [container] is full."))
			return FALSE

	if(istype(attacking_item, /obj/item/melee/baton/security))
		var/obj/item/melee/baton/security/baton = attacking_item
		if(baton.cell?.charge && baton.active)
			flick("baton_active", src)
			user.Paralyze(baton.knockdown_time)
			user.set_stutter(baton.knockdown_time)
			baton.cell.use(baton.cell_hit_cost)
			user.visible_message(
				span_warning("[user] shocks [user.p_them()]self while attempting to wash the active [baton.name]!"),
				span_userdanger("You unwisely attempt to wash [baton] while it's still on."))
			playsound(src, baton.on_stun_sound, 50, TRUE)
			return

	if(istype(attacking_item, /obj/item/mop))
		attacking_item.reagents.add_reagent(dispensedreagent, 5)
		to_chat(user, span_notice("You wet [attacking_item] in [src]."))
		playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
		return

	if(istype(attacking_item, /obj/item/stack/medical/gauze))
		var/obj/item/stack/medical/gauze/G = attacking_item
		new /obj/item/reagent_containers/cup/rag(loc)
		to_chat(user, span_notice("You tear off a strip of gauze and make a rag."))
		G.use(1)
		return

	if(istype(attacking_item, /obj/item/stack/sheet/cloth))
		var/obj/item/stack/sheet/cloth/cloth = attacking_item
		new /obj/item/reagent_containers/cup/rag(loc)
		to_chat(user, span_notice("You tear off a strip of cloth and make a rag."))
		cloth.use(1)
		return

	if(istype(attacking_item, /obj/item/stack/ore/glass))
		new /obj/item/stack/sheet/sandblock(loc)
		to_chat(user, span_notice("You wet the sand and form it into a block."))
		attacking_item.use(1)
		return

	if(!user.combat_mode || (attacking_item.item_flags & NOBLUDGEON))
		to_chat(user, span_notice("You start washing [attacking_item]..."))
		busy = TRUE
		if(!do_after(user, 4 SECONDS, target = src))
			busy = FALSE
			return TRUE
		busy = FALSE
		attacking_item.wash(CLEAN_WASH)
		reagents.expose(attacking_item, TOUCH, 5 / max(reagents.total_volume, 5))
		user.visible_message(
			span_notice("[user] washes [attacking_item] using [src]."),
			span_notice("You wash [attacking_item] using [src]."))
		return TRUE

	return ..()

/obj/structure/water_source/puddle //splishy splashy ^_^
	name = "puddle"
	desc = "A puddle used for washing one's hands and face."
	icon_state = "puddle"
	base_icon_state = "puddle"
	resistance_flags = UNACIDABLE

/obj/structure/water_source/puddle/Initialize(mapload)
	. = ..()
	register_context()

/obj/structure/water_source/puddle/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_RMB] = "Scoop Tadpoles"

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/water_source/puddle/attack_hand(mob/user, list/modifiers)
	icon_state = "[base_icon_state]-splash"
	. = ..()
	icon_state = base_icon_state

/obj/structure/water_source/puddle/attackby(obj/item/attacking_item, mob/user, params)
	icon_state = "[base_icon_state]-splash"
	. = ..()
	icon_state = base_icon_state

/obj/structure/water_source/puddle/attack_hand_secondary(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	icon_state = "[base_icon_state]-splash"
	balloon_alert(user, "scooping tadpoles...")
	if(do_after(user, 5 SECONDS, src))
		playsound(loc, 'sound/effects/slosh.ogg', 15, TRUE)
		balloon_alert(user, "got a tadpole")
		var/obj/item/fish/tadpole/tadpole = new(loc)
		tadpole.randomize_size_and_weight()
		user.put_in_hands(tadpole)
	icon_state = base_icon_state
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
