/obj/effect/temp_visual/offered_item_effect
	duration = OFFER_EFFECT_DURATION
	var/time_out_time = OFFER_EFFECT_DURATION - 1 SECONDS
	var/fade_time = 0.5 SECONDS
	var/datum/offer_effects/offer_effects = /datum/offer_effects
	vis_flags = VIS_INHERIT_LAYER|VIS_INHERIT_PLANE|VIS_UNDERLAY
	mouse_opacity = MOUSE_OPACITY_ICON
	var/fading_out = FALSE

/obj/effect/temp_visual/offered_item_effect/proc/fade_out()
	offer_effects.fade_out()
	fading_out = TRUE

/obj/effect/temp_visual/offered_item_effect/Initialize(mapload, obj/item/offered_thing, mob/living/offerer, mob/living/offered_to)
	. = ..()
	icon = offered_thing.icon
	icon_state = offered_thing.icon_state
	appearance = offered_thing.appearance
	transform = matrix() * 0

	if(offered_thing.offer_effects)
		offer_effects = offered_thing.offer_effects

	offer_effects = new offer_effects(src)

	offer_effects?.on_creation(src, offered_thing, offerer, offered_to)

	offerer.vis_contents += src
	offerer.contents += src

	alpha = 200

/obj/effect/temp_visual/offered_item_effect/Destroy()
	. = ..()

	QDEL_NULL(offer_effects)


/obj/effect/temp_visual/offered_item_effect/proc/on_drop()
	SIGNAL_HANDLER

	offer_effects.on_drop()

/obj/effect/temp_visual/offered_item_effect/proc/handover(obj/handed_thing, mob/living/taker, mob/living/offerer)
	SIGNAL_HANDLER

	offer_effects.on_handover(taker)

/obj/effect/temp_visual/offered_item_effect/proc/someone_moved(mob/mover)
	SIGNAL_HANDLER

	offer_effects.someone_moved()

/obj/effect/temp_visual/offered_item_effect/proc/calculate_offset(mob/living/offerer, mob/living/offered_to)
	if(QDELETED(src))
		return

	offer_effects.calculate_offset(offerer, offered_to)

/obj/effect/temp_visual/offered_item_effect/attack_hand(mob/living/user)
	. = ..()

	var/mob/living/offerer = offer_effects.offerer
	var/obj/offered_item = offer_effects.offered_item

	if(fading_out)
		return

	if(user == offerer)
		offerer.cancel_offering_item()
		return

	if(user.combat_mode == TRUE)
		offerer.attack_hand(arglist(args))
		user.changeNext_move(CLICK_CD_MELEE)
		return

	offer_effects.try_accept(user, offered_item)

/obj/effect/temp_visual/offered_item_effect/attackby(obj/item/I, mob/living/user, params)
	. = ..()

	if(I == offer_effects.offered_item)
		user.cancel_offering_item()
		return

	if(offer_effects?.attackby(user, I))
		return

	offer_effects.attackby(arglist(args))

