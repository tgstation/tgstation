/// parent type for all other stickers. do not spawn directly
/obj/item/sticker
	name = "sticker"
	desc = "A sticker with some strong adhesive on the back, sticks to stuff!"
	item_flags = NOBLUDGEON | XENOMORPH_HOLDABLE //funny
	resistance_flags = FLAMMABLE
	icon = 'icons/obj/stickers.dmi'
	w_class = WEIGHT_CLASS_TINY
	throw_range = 3
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	///The overlay we apply to things we stick to
	var/mutable_appearance/sticker_overlay
	///A list of icon_states to pick an icon_state on Initialize, provided it is not null.
	var/list/icon_states
	///The thing we are attached to
	var/atom/attached
	///The turf our COMSIG_TURF_EXPOSE is registered to, so we can unregister it later.
	var/turf/signal_turf
	/// If the sticker should be disincluded from normal sticker boxes.
	var/contraband = FALSE

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
	var/list/parameters = params2list(params)
	if(!LAZYACCESS(parameters, ICON_X) || !LAZYACCESS(parameters, ICON_Y))
		return
	var/divided_size = world.icon_size / 2
	var/px = text2num(LAZYACCESS(parameters, ICON_X)) - divided_size
	var/py = text2num(LAZYACCESS(parameters, ICON_Y)) - divided_size
	. |= AFTERATTACK_PROCESSED_ITEM
	user.do_attack_animation(target)
	stick(target,user,px,py)
	return .

///Sticks this sticker to the target, with the pixel offsets being px and py.
/obj/item/sticker/proc/stick(atom/target, mob/living/user, px,py)
	sticker_overlay = mutable_appearance(icon, icon_state , layer = target.layer + 1, appearance_flags = RESET_COLOR | PIXEL_SCALE)
	sticker_overlay.pixel_x = px
	sticker_overlay.pixel_y = py
	target.add_overlay(sticker_overlay)
	attached = target
	if(isliving(target) && user)
		var/mob/living/victim = target
		if(victim.client)
			user.log_message("stuck [src] to [key_name(victim)]", LOG_ATTACK)
			victim.log_message("had [src] stuck to them by [key_name(user)]", LOG_ATTACK)
	register_signals(user)
	moveToNullspace()

///Makes this sticker move from nullspace and cut the overlay from the object it is attached to, silent for no visible message.
/obj/item/sticker/proc/peel(datum/source)
	SIGNAL_HANDLER
	if(!attached)
		return
	attached.cut_overlay(sticker_overlay)
	sticker_overlay = null
	forceMove(attached.drop_location())
	pixel_y = rand(-4,1)
	pixel_x = rand(-3,3)
	unregister_signals()
	attached = null

///Registers signals to the object it is attached to
/obj/item/sticker/proc/register_signals(mob/living/user)
	if(isturf(attached))
		//register signals on the users turf instead because we can assume they are on flooring sticking it to a wall so it should burn (otherwise it would fruitlessly check wall temperature)
		signal_turf = (user && isclosedturf(attached)) ? get_turf(user) : attached
		RegisterSignal(signal_turf, COMSIG_TURF_EXPOSE, PROC_REF(on_turf_expose))
	RegisterSignal(attached, COMSIG_LIVING_IGNITED, PROC_REF(on_ignite))
	RegisterSignal(attached, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(peel))
	RegisterSignal(attached, COMSIG_PARENT_QDELETING, PROC_REF(on_attached_qdel))

//Unregisters signals from the object it is attached to
/obj/item/sticker/proc/unregister_signals(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(attached, list(COMSIG_COMPONENT_CLEAN_ACT, COMSIG_LIVING_IGNITED, COMSIG_PARENT_QDELETING))
	if(signal_turf)
		UnregisterSignal(signal_turf, COMSIG_TURF_EXPOSE)
		signal_turf = null

/obj/item/sticker/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!. && prob(50))
		stick(hit_atom,rand(-7,7),rand(-7,7))
		attached.balloon_alert_to_viewers("the sticker lands on its sticky side!")

///Signal handler for COMSIG_TURF_EXPOSE, deletes this sticker if the temperature is above 100C and it is flammable
/obj/item/sticker/proc/on_turf_expose(datum/source, datum/gas_mixture/air, exposed_temperature)
	SIGNAL_HANDLER
	if(!(resistance_flags & FLAMMABLE) || exposed_temperature <= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		return
	peel()
	qdel(src)

///Signal handler for COMSIG_LIVING_IGNITED, deletes this sticker, if it is flammable
/obj/item/sticker/proc/on_ignite(datum/source)
	SIGNAL_HANDLER
	if(!(resistance_flags & FLAMMABLE))
		return
	peel()
	qdel(src)

/// Signal handler for COMSIG_PARENT_QDELETING, deletes this sticker if the attached object is deleted
/obj/item/sticker/proc/on_attached_qdel(datum/source)
	SIGNAL_HANDLER
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

/obj/item/sticker/rev
	name = "blue R sticker"
	desc = "A sticker of FUCK THE SYSTEM, the galaxy's premiere hardcore punk band."
	icon_state = "revhead"

/obj/item/sticker/pslime
	name = "slime plushie sticker"
	icon_state = "pslime"

/obj/item/sticker/pliz
	name = "lizard plushie sticker"
	icon_state = "plizard"

/obj/item/sticker/pbee
	name = "bee plushie sticker"
	icon_state = "pbee"

/obj/item/sticker/psnake
	name = "snake plushie sticker"
	icon_state = "psnake"

/obj/item/sticker/robot
	name = "bot sticker"
	icon_state = "tile"
	icon_states = list("tile","medbot","clean")

/obj/item/sticker/toolbox
	name = "toolbox sticker"
	icon_state = "toolbox"

/obj/item/sticker/clown
	name = "clown sticker"
	icon_state = "honkman"

/obj/item/sticker/mime
	name = "mime sticker"
	icon_state = "silentman"

/obj/item/sticker/assistant
	name = "assistant sticker"
	icon_state = "tider"

/obj/item/sticker/syndicate
	name = "syndicate sticker"
	icon_state = "synd"
	contraband = TRUE

/obj/item/sticker/syndicate/c4
	name = "C-4 sticker"
	icon_state = "c4"

/obj/item/sticker/syndicate/bomb
	name = "syndicate bomb sticker"
	icon_state = "sbomb"

/obj/item/sticker/syndicate/apc
	name = "broken APC sticker"
	icon_state = "milf"

/obj/item/sticker/syndicate/larva
	name = "larva sticker"
	icon_state = "larva"

/obj/item/sticker/syndicate/cult
	name = "bloody paper sticker"
	icon_state = "cult"

/obj/item/sticker/syndicate/flash
	name = "flash sticker"
	icon_state = "flash"

/obj/item/sticker/syndicate/op
	name = "operative sticker"
	icon_state = "newcop"

/obj/item/sticker/syndicate/trap
	name = "bear trap sticker"
	icon_state = "trap"
