/obj/item/airlock_painter
	name = "airlock painter"
	desc = "An advanced autopainter preprogrammed with several paintjobs for airlocks. Use it on an airlock during or after construction to change the paintjob."
	desc_controls = "Alt-Click to remove the ink cartridge."
	icon = 'icons/obj/devices/tool.dmi'
	icon_state = "paint_sprayer"
	inhand_icon_state = "paint_sprayer"
	worn_icon_state = "painter"
	w_class = WEIGHT_CLASS_SMALL

	custom_materials = list(/datum/material/iron= SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/glass= SMALL_MATERIAL_AMOUNT * 0.5)

	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	usesound = 'sound/effects/spray2.ogg'

	/// The ink cartridge to pull charges from.
	var/obj/item/toner/ink = null
	/// The type path to instantiate for the ink cartridge the device initially comes with, eg. /obj/item/toner
	var/initial_ink_type = /obj/item/toner
	/// Associate list of all paint jobs the airlock painter can apply. The key is the name of the airlock the user will see. The value is the type path of the airlock
	var/list/available_paint_jobs = list(
		"Public" = /obj/machinery/door/airlock/public,
		"Engineering" = /obj/machinery/door/airlock/engineering,
		"Atmospherics" = /obj/machinery/door/airlock/atmos,
		"Security" = /obj/machinery/door/airlock/security,
		"Command" = /obj/machinery/door/airlock/command,
		"Medical" = /obj/machinery/door/airlock/medical,
		"Virology" = /obj/machinery/door/airlock/virology,
		"Research" = /obj/machinery/door/airlock/research,
		"Hydroponics" = /obj/machinery/door/airlock/hydroponics,
		"Freezer" = /obj/machinery/door/airlock/freezer,
		"Science" = /obj/machinery/door/airlock/science,
		"Mining" = /obj/machinery/door/airlock/mining,
		"Maintenance" = /obj/machinery/door/airlock/maintenance,
		"External" = /obj/machinery/door/airlock/external,
		"External Maintenance"= /obj/machinery/door/airlock/maintenance/external,
		"Standard" = /obj/machinery/door/airlock
	)

/obj/item/airlock_painter/Initialize(mapload)
	. = ..()
	ink = new initial_ink_type(src)

/obj/item/airlock_painter/Destroy(force)
	QDEL_NULL(ink)
	return ..()

//This proc doesn't just check if the painter can be used, but also uses it.
//Only call this if you are certain that the painter will be used right after this check!
/obj/item/airlock_painter/proc/use_paint(mob/user)
	if(can_use(user))
		ink.charges--
		playsound(src.loc, 'sound/effects/spray2.ogg', 50, TRUE)
		return TRUE
	else
		return FALSE

//This proc only checks if the painter can be used.
//Call this if you don't want the painter to be used right after this check, for example
//because you're expecting user input.
/obj/item/airlock_painter/proc/can_use(mob/user)
	if(!ink)
		balloon_alert(user, "no cartridge!")
		return FALSE
	else if(ink.charges < 1)
		balloon_alert(user, "out of ink!")
		return FALSE
	else
		return TRUE

/obj/item/airlock_painter/suicide_act(mob/living/user)
	var/obj/item/organ/lungs/L = user.get_organ_slot(ORGAN_SLOT_LUNGS)

	if(can_use(user) && L)
		user.visible_message(span_suicide("[user] is inhaling toner from [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		use(user)

		// Once you've inhaled the toner, you throw up your lungs
		// and then die.

		// Find out if there is an open turf in front of us,
		// and if not, pick the turf we are standing on.
		var/turf/T = get_step(get_turf(src), user.dir)
		if(!isopenturf(T))
			T = get_turf(src)

		// they managed to lose their lungs between then and
		// now. Good job.
		if(!L)
			return OXYLOSS

		L.Remove(user)

		// make some colorful reagent, and apply it to the lungs
		L.create_reagents(10)
		L.reagents.add_reagent(/datum/reagent/colorful_reagent, 10)
		L.reagents.expose(L, TOUCH, 1)

		// TODO maybe add some colorful vomit?

		user.visible_message(span_suicide("[user] vomits out [user.p_their()] [L]!"))
		playsound(user.loc, 'sound/effects/splat.ogg', 50, TRUE)

		L.forceMove(T)

		return (TOXLOSS|OXYLOSS)
	else if(can_use(user) && !L)
		user.visible_message(span_suicide("[user] is spraying toner on [user.p_them()]self from [src]! It looks like [user.p_theyre()] trying to commit suicide."))
		user.reagents.add_reagent(/datum/reagent/colorful_reagent, 1)
		user.reagents.expose(user, TOUCH, 1)
		return TOXLOSS

	else
		user.visible_message(span_suicide("[user] is trying to inhale toner from [src]! It might be a suicide attempt if [src] had any toner."))
		return SHAME


/obj/item/airlock_painter/examine(mob/user)
	. = ..()
	if(!ink)
		. += span_notice("It doesn't have a toner cartridge installed.")
		return
	var/ink_level = "high"
	if(ink.charges < 1)
		ink_level = "empty"
	else if((ink.charges/ink.max_charges) <= 0.25) //25%
		ink_level = "low"
	else if((ink.charges/ink.max_charges) > 1) //Over 100% (admin var edit)
		ink_level = "dangerously high"
	. += span_notice("Its ink levels look [ink_level].")

/obj/item/airlock_painter/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(W, /obj/item/toner))
		if(ink)
			to_chat(user, span_warning("[src] already contains \a [ink]!"))
			return
		if(!user.transferItemToLoc(W, src))
			return
		to_chat(user, span_notice("You install [W] into [src]."))
		ink = W
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	else
		return ..()

/obj/item/airlock_painter/click_alt(mob/user)
	if(!ink)
		return CLICK_ACTION_BLOCKING

	playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	ink.forceMove(user.drop_location())
	user.put_in_hands(ink)
	to_chat(user, span_notice("You remove [ink] from [src]."))
	ink = null
	return CLICK_ACTION_SUCCESS
