/obj/item/airlock_painter
	name = "airlock painter"
	desc = "An advanced autopainter preprogrammed with several paintjobs for airlocks. Use it on an airlock during or after construction to change the paintjob."
	icon = 'icons/obj/objects.dmi'
	icon_state = "paint sprayer"
	item_state = "paint sprayer"

	w_class = WEIGHT_CLASS_SMALL

	custom_materials = list(/datum/material/iron=50, /datum/material/glass=50)

	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	usesound = 'sound/effects/spray2.ogg'

	var/obj/item/toner/ink = null

/obj/item/airlock_painter/Initialize()
	. = ..()
	ink = new /obj/item/toner(src)

//This proc doesn't just check if the painter can be used, but also uses it.
//Only call this if you are certain that the painter will be used right after this check!
/obj/item/airlock_painter/proc/use_paint(mob/user)
	if(can_use(user))
		ink.charges--
		playsound(src.loc, 'sound/effects/spray2.ogg', 50, TRUE)
		return 1
	else
		return 0

//This proc only checks if the painter can be used.
//Call this if you don't want the painter to be used right after this check, for example
//because you're expecting user input.
/obj/item/airlock_painter/proc/can_use(mob/user)
	if(!ink)
		to_chat(user, "<span class='warning'>There is no toner cartridge installed in [src]!</span>")
		return 0
	else if(ink.charges < 1)
		to_chat(user, "<span class='warning'>[src] is out of ink!</span>")
		return 0
	else
		return 1

/obj/item/airlock_painter/suicide_act(mob/user)
	var/obj/item/organ/lungs/L = user.getorganslot(ORGAN_SLOT_LUNGS)

	if(can_use(user) && L)
		user.visible_message("<span class='suicide'>[user] is inhaling toner from [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
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
		L.reagents.reaction(L, TOUCH, 1)

		// TODO maybe add some colorful vomit?

		user.visible_message("<span class='suicide'>[user] vomits out [user.p_their()] [L]!</span>")
		playsound(user.loc, 'sound/effects/splat.ogg', 50, TRUE)

		L.forceMove(T)

		return (TOXLOSS|OXYLOSS)
	else if(can_use(user) && !L)
		user.visible_message("<span class='suicide'>[user] is spraying toner on [user.p_them()]self from [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
		user.reagents.add_reagent(/datum/reagent/colorful_reagent, 1)
		user.reagents.reaction(user, TOUCH, 1)
		return TOXLOSS

	else
		user.visible_message("<span class='suicide'>[user] is trying to inhale toner from [src]! It might be a suicide attempt if [src] had any toner.</span>")
		return SHAME


/obj/item/airlock_painter/examine(mob/user)
	. = ..()
	if(!ink)
		. += "<span class='notice'>It doesn't have a toner cartridge installed.</span>"
		return
	var/ink_level = "high"
	if(ink.charges < 1)
		ink_level = "empty"
	else if((ink.charges/ink.max_charges) <= 0.25) //25%
		ink_level = "low"
	else if((ink.charges/ink.max_charges) > 1) //Over 100% (admin var edit)
		ink_level = "dangerously high"
	. += "<span class='notice'>Its ink levels look [ink_level].</span>"


/obj/item/airlock_painter/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/toner))
		if(ink)
			to_chat(user, "<span class='warning'>[src] already contains \a [ink]!</span>")
			return
		if(!user.transferItemToLoc(W, src))
			return
		to_chat(user, "<span class='notice'>You install [W] into [src].</span>")
		ink = W
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	else
		return ..()

/obj/item/airlock_painter/attack_self(mob/user)
	if(ink)
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		ink.forceMove(user.drop_location())
		user.put_in_hands(ink)
		to_chat(user, "<span class='notice'>You remove [ink] from [src].</span>")
		ink = null

/obj/item/airlock_painter/decal
	name = "decal painter"
	desc = "An airlock painter, reprogramed to use a different style of paint in order to apply decals for floor tiles as well, in addition to repainting doors. Decals break when the floor tiles are removed."
	icon = 'icons/obj/objects.dmi'
	icon_state = "decal_sprayer"
	item_state = "decalsprayer"
	custom_materials = list(/datum/material/iron=2000, /datum/material/glass=500)
	var/stored_dir = 2
	var/stored_color = ""
	var/stored_decal = "warningline"
	var/stored_decal_total = "warningline"

/obj/item/airlock_painter/decal/afterattack(atom/target, mob/user, proximity)
	. = ..()
	var/turf/open/floor/F = target
	if(!proximity)
		to_chat(user, "<span class='notice'>You need to get closer!</span>")
		return
	if(use_paint(user) && isturf(F))
		F.AddComponent(/datum/component/decal, 'icons/turf/decals.dmi', stored_decal_total, stored_dir, CLEAN_STRONG, color, null, null, alpha)

/obj/item/airlock_painter/decal/attack_self(mob/user)
	ui_interact(user)
	if((ink) && (ink.charges >= 1))
		to_chat(user, "<span class='notice'>[src] beeps to prevent you from removing the toner until out of charges.</span>")
		return
	. = ..()

/obj/item/airlock_painter/decal/Initialize()
	. = ..()
	ink = new /obj/item/toner/large(src)

/obj/item/airlock_painter/decal/proc/update_decal_path()
	stored_decal_total = "[stored_decal][stored_color]"
	return

/obj/item/airlock_painter/decal/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "decal_painter", name, 500, 500, master_ui, state)
		ui.open()

/obj/item/airlock_painter/decal/ui_data(mob/user)
	var/list/data = list()
	data["decal_direction"] = stored_dir
	data["decal_color"] = stored_color
	data["decal_style"] = stored_decal
	return data

/obj/item/airlock_painter/decal/ui_act(action,active)
	if(..())
		return
	switch(action)
		//Decal Designs
		if("lines")
			stored_decal = "warningline"
		if("lines corner")
			stored_decal = "warninglinecorner"
		if("caution")
			stored_decal = "caution"
		if("arrow")
			stored_decal = "arrows"
		if("stand clear")
			stored_decal = "stand_clear"
		if("box")
			stored_decal = "box"
		if("box corners")
			stored_decal = "box_corners"
		if("delivery")
			stored_decal = "delivery"
		if("full stripes")
			stored_decal = "warn_full"
		//Direction for the Decal
		if("north")
			stored_dir = 1
		if("south")
			stored_dir = 2
		if("east")
			stored_dir = 4
		if("west")
			stored_dir = 8
		//Decal colors
		if("yellow")
			stored_color = ""
		if("red")
			stored_color = "_red"
		if("white")
			stored_color = "_white"
	. = TRUE
	update_decal_path()

/obj/item/airlock_painter/decal/debug
	name = "extreme decal painter"

/obj/item/airlock_painter/decal/debug/Initialize()
	. = ..()
	ink = new /obj/item/toner/extreme(src)
