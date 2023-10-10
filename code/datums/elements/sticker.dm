#define MAX_ALLOWED_STICKERS 12

/datum/element/sticker
	///The typepath for our attached sticker component
	var/stick_type = /datum/component/attached_sticker
	///If TRUE, our attached_sticker can be washed off
	var/washable = TRUE

/datum/element/sticker/Attach(datum/target, sticker_type, cleanable=TRUE)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
	if(sticker_type)
		stick_type = sticker_type
	washable = cleanable

/datum/element/sticker/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ITEM_AFTERATTACK, COMSIG_MOVABLE_IMPACT))

/datum/element/sticker/proc/on_afterattack(obj/item/source, atom/target, mob/living/user, prox, params)
	SIGNAL_HANDLER
	if(!prox)
		return
	if(!isatom(target))
		return
	var/list/parameters = params2list(params)
	if(!LAZYACCESS(parameters, ICON_X) || !LAZYACCESS(parameters, ICON_Y))
		return
	var/divided_size = world.icon_size / 2
	var/px = text2num(LAZYACCESS(parameters, ICON_X)) - divided_size
	var/py = text2num(LAZYACCESS(parameters, ICON_Y)) - divided_size

	user.do_attack_animation(target)
	if(do_stick(source, target, user, px, py))
		target.balloon_alert_to_viewers("sticker sticked")

///Add our stick_type to the target with px and py as pixel x and pixel y respectively
/datum/element/sticker/proc/do_stick(obj/item/source, atom/target, mob/living/user, px, py)
	if(COUNT_TRAIT_SOURCES(target, TRAIT_STICKERED) >= MAX_ALLOWED_STICKERS)
		source.balloon_alert_to_viewers("sticker won't stick!")
		return FALSE
	target.AddComponent(stick_type, px, py, source, user, washable)
	return TRUE

/datum/element/sticker/proc/on_throw_impact(obj/item/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(prob(50) && do_stick(source, hit_atom, null, rand(-7,7), rand(-7,7)))
		hit_atom.balloon_alert_to_viewers("sticker landed on sticky side!")

#undef MAX_ALLOWED_STICKERS
