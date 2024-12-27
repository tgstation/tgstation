/*
Self-sustaining extracts:
	Produces 4 extracts that do not need reagents.
*/
/obj/item/slimecross/selfsustaining
	name = "self-sustaining extract"
	effect = "self-sustaining"
	icon_state = "selfsustaining"
	var/extract_type = /obj/item/slime_extract

/obj/item/autoslime
	name = "autoslime"
	desc = "It resembles a normal slime extract, but seems filled with a strange, multi-colored fluid."
	var/obj/item/slime_extract/extract
	var/effect_desc = "A self-sustaining slime extract. When used, lets you choose which reaction you want."

//Just divides into the actual item.
/obj/item/slimecross/selfsustaining/Initialize(mapload)
	..()
	visible_message(span_warning("The [src] shudders, and splits into four smaller extracts."))
	for(var/i in 1 to 4)
		var/obj/item/autoslime/A = new /obj/item/autoslime(src.loc)
		var/obj/item/slime_extract/X = new extract_type(A)
		A.extract = X
		A.icon = icon
		A.icon_state = icon_state
		A.color = color
		A.name = "self-sustaining " + colour + " extract"
	return INITIALIZE_HINT_QDEL

/obj/item/autoslime/Initialize(mapload)
	return ..()

/obj/item/autoslime/attack_self(mob/user)
	var/reagentselect = tgui_input_list(user, "Reagent the extract will produce.", "Self-sustaining Reaction", sort_list(extract.activate_reagents, GLOBAL_PROC_REF(cmp_typepaths_asc)))
	if(isnull(reagentselect))
		return
	var/amount = 5
	var/secondary

	if (user.get_active_held_item() != src || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(!reagentselect)
		return
	if(reagentselect == "lesser plasma")
		amount = 4
		reagentselect = /datum/reagent/toxin/plasma
	if(reagentselect == "holy water and uranium")
		reagentselect = /datum/reagent/water/holywater
		secondary = /datum/reagent/uranium
	extract.forceMove(user.drop_location())
	qdel(src)
	user.put_in_active_hand(extract)
	extract.reagents.add_reagent(reagentselect,amount)
	if(secondary)
		extract.reagents.add_reagent(secondary,amount)

/obj/item/autoslime/examine(mob/user)
	. = ..()
	if(effect_desc)
		. += span_notice("[effect_desc]")

//Different types.

/obj/item/slimecross/selfsustaining/grey
	extract_type = /obj/item/slime_extract/grey
	colour = SLIME_TYPE_GREY

/obj/item/slimecross/selfsustaining/orange
	extract_type = /obj/item/slime_extract/orange
	colour = SLIME_TYPE_ORANGE

/obj/item/slimecross/selfsustaining/purple
	extract_type = /obj/item/slime_extract/purple
	colour = SLIME_TYPE_PURPLE

/obj/item/slimecross/selfsustaining/blue
	extract_type = /obj/item/slime_extract/blue
	colour = SLIME_TYPE_BLUE

/obj/item/slimecross/selfsustaining/metal
	extract_type = /obj/item/slime_extract/metal
	colour = SLIME_TYPE_METAL

/obj/item/slimecross/selfsustaining/yellow
	extract_type = /obj/item/slime_extract/yellow
	colour = SLIME_TYPE_YELLOW

/obj/item/slimecross/selfsustaining/darkpurple
	extract_type = /obj/item/slime_extract/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE

/obj/item/slimecross/selfsustaining/darkblue
	extract_type = /obj/item/slime_extract/darkblue
	colour = SLIME_TYPE_DARK_BLUE

/obj/item/slimecross/selfsustaining/silver
	extract_type = /obj/item/slime_extract/silver
	colour = SLIME_TYPE_SILVER

/obj/item/slimecross/selfsustaining/bluespace
	extract_type = /obj/item/slime_extract/bluespace
	colour = SLIME_TYPE_BLUESPACE

/obj/item/slimecross/selfsustaining/sepia
	extract_type = /obj/item/slime_extract/sepia
	colour = SLIME_TYPE_SEPIA

/obj/item/slimecross/selfsustaining/cerulean
	extract_type = /obj/item/slime_extract/cerulean
	colour = SLIME_TYPE_CERULEAN

/obj/item/slimecross/selfsustaining/pyrite
	extract_type = /obj/item/slime_extract/pyrite
	colour = SLIME_TYPE_PYRITE

/obj/item/slimecross/selfsustaining/red
	extract_type = /obj/item/slime_extract/red
	colour = SLIME_TYPE_RED

/obj/item/slimecross/selfsustaining/green
	extract_type = /obj/item/slime_extract/green
	colour = SLIME_TYPE_GREEN

/obj/item/slimecross/selfsustaining/pink
	extract_type = /obj/item/slime_extract/pink
	colour = SLIME_TYPE_PINK

/obj/item/slimecross/selfsustaining/gold
	extract_type = /obj/item/slime_extract/gold
	colour = SLIME_TYPE_GOLD

/obj/item/slimecross/selfsustaining/oil
	extract_type = /obj/item/slime_extract/oil
	colour = SLIME_TYPE_OIL

/obj/item/slimecross/selfsustaining/black
	extract_type = /obj/item/slime_extract/black
	colour = SLIME_TYPE_BLACK

/obj/item/slimecross/selfsustaining/lightpink
	extract_type = /obj/item/slime_extract/lightpink
	colour = SLIME_TYPE_LIGHT_PINK

/obj/item/slimecross/selfsustaining/adamantine
	extract_type = /obj/item/slime_extract/adamantine
	colour = SLIME_TYPE_ADAMANTINE

/obj/item/slimecross/selfsustaining/rainbow
	extract_type = /obj/item/slime_extract/rainbow
	colour = SLIME_TYPE_RAINBOW
