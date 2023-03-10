/obj/item/sticker
	name = "sticker"
	desc = "A sticker with some strong adhesive on the back, sticks to stuff!"
	item_flags = NOBLUDGEON | XENOMORPH_HOLDABLE //funny
	resistance_flags = FLAMMABLE
	icon = 'icons/obj/stickers.dmi'
	w_class = WEIGHT_CLASS_TINY
	throw_range = 3
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	var/mutable_appearance/sticker_overlay
	var/list/icon_states
	var/atom/attached

/obj/item/sticker/Initialize(mapload)
	. = ..()
	if(icon_states)
		icon_state = pick(icon_states)
	pixel_y = rand(-3,3)
	pixel_x = rand(-3,3)

/obj/item/sticker/afterattack(atom/target, mob/living/user, prox, params)
	. = ..()
	if(!prox)
		return
	if(!isliving(target) && !isobj(target) && !isturf(target))
		return
	user.visible_message(span_notice("[user] sticks [src] to [target]!"),span_notice("You stick [src] to [target]!"))
	var/list/parameters = params2list(params)
	var/py = text2num(parameters["icon-y"]) - 16
	var/px = text2num(parameters["icon-x"]) - 16
	. |= AFTERATTACK_PROCESSED_ITEM
	stick(target,px,py)

/obj/item/sticker/proc/stick(atom/target,px,py)
	sticker_overlay = mutable_appearance(icon, icon_state , layer = target.layer + 1, appearance_flags = RESET_COLOR | PIXEL_SCALE)
	sticker_overlay.pixel_x = px
	sticker_overlay.pixel_y = py
	target.add_overlay(sticker_overlay)
	attached = target
	register_signals()
	moveToNullspace()

/obj/item/sticker/proc/peel(datum/source, silent=FALSE)
	SIGNAL_HANDLER
	if(!attached)
		return
	attached.cut_overlay(sticker_overlay)
	sticker_overlay = null
	forceMove(isturf(attached) ? attached : attached.loc)
	if(!silent)
		attached.visible_message(span_notice("[src] falls off [attached]."))
	pixel_y = rand(-3,3)
	pixel_x = rand(-3,3)
	unregister_signals()
	attached = null

/obj/item/sticker/proc/register_signals()
	RegisterSignal(attached, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(peel))
	if(isturf(attached))
		RegisterSignal(attached, COMSIG_TURF_EXPOSE, PROC_REF(on_turf_expose))
	RegisterSignal(attached, COMSIG_LIVING_IGNITED, PROC_REF(on_ignite))
	RegisterSignal(attached, COMSIG_PARENT_QDELETING, PROC_REF(unregister_signals))

/obj/item/sticker/proc/unregister_signals(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(attached,list(COMSIG_COMPONENT_CLEAN_ACT,COMSIG_PARENT_QDELETING, COMSIG_LIVING_IGNITED, COMSIG_TURF_EXPOSE))

/obj/item/sticker/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!. && prob(50))
		stick(hit_atom,rand(-7,7),rand(-7,7))
		attached.visible_message(span_notice("[src] lands on [attached] with its sticky side!"))

/obj/item/sticker/proc/on_turf_expose(datum/source, datum/gas_mixture/air, exposed_temperature)
	SIGNAL_HANDLER
	if((resistance_flags & FLAMMABLE) && exposed_temperature >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		peel(silent=TRUE)
		qdel(src)

/obj/item/sticker/proc/on_ignite(datum/source)
	SIGNAL_HANDLER
	if(resistance_flags & FLAMMABLE)
		peel(silent=TRUE)
		qdel(src)

/obj/item/sticker/smile
	name = "smiley sticker"
	icon_state = "smile"

/obj/item/sticker/frown
	name = "frowny sticker"
	icon_state = "frown"

/obj/item/sticker/left_arrow
	name = "left arrow sticker"
	icon_state = "larrow"

/obj/item/sticker/right_arrow
	name = "right arrow sticker"
	icon_state = "rarrow"

/obj/item/sticker/star
	name = "star sticker"
	icon_state = "star1"
	icon_states = list("star1","star2")

/obj/item/sticker/heart
	name = "heart sticker"
	icon_state = "heart"

/obj/item/sticker/googly
	name = "googly eye sticker"
	icon_state = "googly1"
	icon_states = list("googly1","googly2")
