//////////////////////////////////////////////
//////////     SLIME CROSSBREEDS    //////////
//////////////////////////////////////////////
// A system of combining two extract types. //
// Performed by feeding a slime 10 of an    //
// extract color.                           //
//////////////////////////////////////////////
/*==========================================*\
To add a crossbreed:
	The file name is automatically selected
	by the crossbreeding effect, which uses
	the format slimecross/[modifier]/[color].

	If a crossbreed doesn't exist, don't
	worry. If no file is found at that
	location, it will simple display that
	the crossbreed was too unstable.

	As a result, do not feel the need to
	try to add all of the crossbred
	effects at once, if you're here and
	trying to make a new slime type. Just
	get your slimetype in the codebase and
	get around to the crossbreeds eventually!
\*==========================================*/

/obj/item/slimecross //The base type for crossbred extracts. Mostly here for posterity, and to set base case things.
	name = "crossbred slime extract"
	desc = "An extremely potent slime extract, formed through crossbreeding."
	icon = 'icons/obj/science/slimecrossing.dmi'
	icon_state = "base"
	var/colour = "null"
	var/effect = "null"
	var/effect_desc = "null"
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 6

/obj/item/slimecross/examine(mob/user)
	. = ..()
	if(effect_desc)
		. += span_notice("[effect_desc]")

/obj/item/slimecross/Initialize(mapload)
	. = ..()
	name = effect + " " + colour + " extract"
	var/itemcolor = COLOR_WHITE
	switch(colour)
		if(SLIME_TYPE_ORANGE)
			itemcolor = "#FFA500"
		if(SLIME_TYPE_PURPLE)
			itemcolor = "#B19CD9"
		if(SLIME_TYPE_BLUE)
			itemcolor = "#ADD8E6"
		if(SLIME_TYPE_METAL)
			itemcolor = "#7E7E7E"
		if(SLIME_TYPE_YELLOW)
			itemcolor = COLOR_YELLOW
		if(SLIME_TYPE_DARK_PURPLE)
			itemcolor = COLOR_DARK_PURPLE
		if(SLIME_TYPE_DARK_BLUE)
			itemcolor = COLOR_BLUE
		if(SLIME_TYPE_SILVER)
			itemcolor = "#D3D3D3"
		if(SLIME_TYPE_BLUESPACE)
			itemcolor = COLOR_LIME
		if(SLIME_TYPE_SEPIA)
			itemcolor = "#704214"
		if(SLIME_TYPE_CERULEAN)
			itemcolor = "#2956B2"
		if(SLIME_TYPE_PYRITE)
			itemcolor = "#FAFAD2"
		if(SLIME_TYPE_RED)
			itemcolor = COLOR_RED
		if(SLIME_TYPE_GREEN)
			itemcolor = COLOR_VIBRANT_LIME
		if(SLIME_TYPE_PINK)
			itemcolor = "#FF69B4"
		if(SLIME_TYPE_GOLD)
			itemcolor = COLOR_GOLD
		if(SLIME_TYPE_OIL)
			itemcolor = "#505050"
		if(SLIME_TYPE_BLACK)
			itemcolor = COLOR_BLACK
		if(SLIME_TYPE_LIGHT_PINK)
			itemcolor = "#FFB6C1"
		if(SLIME_TYPE_ADAMANTINE)
			itemcolor = "#008B8B"
	add_atom_colour(itemcolor, FIXED_COLOUR_PRIORITY)

/obj/item/slimecrossbeaker //To be used as a result for extract reactions that make chemicals.
	name = "result extract"
	desc = "You shouldn't see this."
	icon = 'icons/obj/science/slimecrossing.dmi'
	icon_state = "base"
	var/del_on_empty = TRUE
	var/list/list_reagents

/obj/item/slimecrossbeaker/Initialize(mapload)
	. = ..()
	create_reagents(50, INJECTABLE | DRAWABLE | SEALED_CONTAINER)
	if(list_reagents)
		for(var/reagent in list_reagents)
			reagents.add_reagent(reagent, list_reagents[reagent])
	if(del_on_empty)
		START_PROCESSING(SSobj,src)

/obj/item/slimecrossbeaker/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/obj/item/slimecrossbeaker/process()
	if(!reagents.total_volume)
		visible_message(span_notice("[src] has been drained completely, and melts away."))
		qdel(src)

/obj/item/slimecrossbeaker/bloodpack //Pack of 50u blood. Deletes on empty.
	name = "blood extract"
	desc = "A sphere of liquid blood, somehow managing to stay together."
	color = COLOR_RED
	list_reagents = list(/datum/reagent/blood = 50)

/obj/item/slimecrossbeaker/pax //5u synthpax.
	name = "peace-inducing extract"
	desc = "A small blob of synthetic pax."
	color = "#FFCCCC"
	list_reagents = list(/datum/reagent/pax/peaceborg = 5)

/obj/item/slimecrossbeaker/omnizine //15u omnizine.
	name = "healing extract"
	desc = "A gelatinous extract of pure omnizine."
	color = COLOR_MAGENTA
	list_reagents = list(/datum/reagent/medicine/omnizine = 15)

/obj/item/slimecrossbeaker/autoinjector //As with the above, but automatically injects whomever it is used on with contents.
	var/ignore_flags = FALSE
	var/self_use_only = FALSE

/obj/item/slimecrossbeaker/autoinjector/Initialize(mapload)
	. = ..()
	reagents.flags = DRAWABLE // Cannot be refilled, since it's basically an autoinjector!

/obj/item/slimecrossbeaker/autoinjector/attack(mob/living/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return
	if(!iscarbon(M))
		return
	if(self_use_only && M != user)
		to_chat(user, span_warning("This can only be used on yourself."))
		return
	if(reagents.total_volume && (ignore_flags || M.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE)))
		reagents.trans_to(M, reagents.total_volume, transferred_by = user)
		if(user != M)
			to_chat(M, span_warning("[user] presses [src] against you!"))
			to_chat(user, span_notice("You press [src] against [M], injecting [M.p_them()]."))
		else
			to_chat(user, span_notice("You press [src] against yourself, and it flattens against you!"))
	else
		to_chat(user, span_warning("There's no place to stick [src]!"))

/obj/item/slimecrossbeaker/autoinjector/regenpack
	ignore_flags = TRUE //It is, after all, intended to heal.
	name = "mending solution"
	desc = "A strange glob of sweet-smelling semifluid, which seems to stick to skin rather easily."
	color = COLOR_MAGENTA
	list_reagents = list(/datum/reagent/medicine/regen_jelly = 20)

/obj/item/slimecrossbeaker/autoinjector/slimejelly //Primarily for slimepeople, but you do you.
	self_use_only = TRUE
	ignore_flags = TRUE
	name = "slime jelly bubble"
	desc = "A sphere of slime jelly. It seems to stick to your skin, but avoids other surfaces."
	color = COLOR_VIBRANT_LIME
	list_reagents = list(/datum/reagent/toxin/slimejelly = 50)

/obj/item/slimecrossbeaker/autoinjector/peaceandlove
	name = "peaceful distillation"
	desc = "A light pink gooey sphere. Simply touching it makes you a little dizzy."
	color = "#DDAAAA"
	list_reagents = list(/datum/reagent/pax/peaceborg = 10, /datum/reagent/drug/space_drugs = 15) //Peace, dudes

/obj/item/slimecrossbeaker/autoinjector/peaceandlove/Initialize(mapload)
	. = ..()
	reagents.flags = NONE // It won't be *that* easy to get your hands on pax.

/obj/item/slimecrossbeaker/autoinjector/slimestimulant
	name = "invigorating gel"
	desc = "A bubbling purple mixture, designed to heal and boost movement."
	color = COLOR_MAGENTA
	list_reagents = list(/datum/reagent/medicine/regen_jelly = 30, /datum/reagent/drug/methamphetamine = 9)
