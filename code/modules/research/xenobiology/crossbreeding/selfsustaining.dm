/*
Self-sustaining extracts:
	Produces 4 extracts that do not need reagents.
*/
/obj/item/slimecross/selfsustaining
	name = "self-sustaining extract"
	effect = "self-sustaining"
	icon_state = "selfsustaining"
	var/extract_type = /obj/item/slime_extract
	var/auto_color

/obj/item/autoslime
	name = "autoslime"
	desc = "It resembles a normal slime extract, but seems filled with a strange, multi-colored fluid."
	var/obj/item/slime_extract/extract

//Just divides into the actual item.
/obj/item/slimecross/selfsustaining/Initialize()
	..()
	visible_message("<span class='warning'>The [src] shudders, and splits into four smaller extracts.</span>")
	for(var/i = 0, i < 4, i++)
		var/obj/item/autoslime/A = new /obj/item/autoslime(src.loc)
		var/obj/item/slime_extract/X = new extract_type(A)
		A.extract = X
		A.icon = icon
		A.icon_state = icon_state
		A.color = auto_color
		A.name = "self-sustaining " + colour
	return INITIALIZE_HINT_QDEL

/obj/item/autoslime/Initialize()
	return ..()

/obj/item/autoslime/attack_self(mob/user)
	var/reagentselect = input(user, "Choose the reagent the extract will produce.", "Self-sustaining Reaction") as null|anything in extract.activate_reagents
	var/amount = 5
	var/secondary

	if ((user.get_active_held_item() != src || user.stat || user.restrained()))
		return
	if(!reagentselect)
		return
	if(reagentselect == "lesser plasma")
		amount = 4
		reagentselect = "plasma"
	if(reagentselect == "holy water and uranium")
		reagentselect = "holywater"
		secondary = "uranium"
	extract.forceMove(user.drop_location())
	qdel(src)
	user.put_in_active_hand(extract)
	extract.reagents.add_reagent(reagentselect,amount)
	if(secondary)
		extract.reagents.add_reagent(secondary,amount)

//Different types.

/obj/item/slimecross/selfsustaining/grey
	extract_type = /obj/item/slime_extract/grey
	colour = "grey"

/obj/item/slimecross/selfsustaining/orange
	extract_type = /obj/item/slime_extract/orange
	colour = "orange"
	auto_color = "#FFA500"

/obj/item/slimecross/selfsustaining/purple
	extract_type = /obj/item/slime_extract/purple
	colour = "purple"
	auto_color = "#B19CD9"

/obj/item/slimecross/selfsustaining/blue
	extract_type = /obj/item/slime_extract/blue
	colour = "blue"
	auto_color = "#ADD8E6"

/obj/item/slimecross/selfsustaining/metal
	extract_type = /obj/item/slime_extract/metal
	colour = "metal"
	auto_color = "#7E7E7E"

/obj/item/slimecross/selfsustaining/yellow
	extract_type = /obj/item/slime_extract/yellow
	colour = "yellow"
	auto_color = "#FFFF00"

/obj/item/slimecross/selfsustaining/darkpurple
	extract_type = /obj/item/slime_extract/darkpurple
	colour = "dark purple"
	auto_color = "#551A8B"

/obj/item/slimecross/selfsustaining/darkblue
	extract_type = /obj/item/slime_extract/darkblue
	colour = "dark blue"
	auto_color = "#0000FF"

/obj/item/slimecross/selfsustaining/silver
	extract_type = /obj/item/slime_extract/silver
	colour = "silver"
	auto_color = "#D3D3D3"

/obj/item/slimecross/selfsustaining/bluespace
	extract_type = /obj/item/slime_extract/bluespace
	colour = "bluespace"
	auto_color = "#32CD32"

/obj/item/slimecross/selfsustaining/sepia
	extract_type = /obj/item/slime_extract/sepia
	colour = "sepia"
	auto_color = "#704214"

/obj/item/slimecross/selfsustaining/cerulean
	extract_type = /obj/item/slime_extract/cerulean
	colour = "cerulean"
	auto_color = "#2956B2"

/obj/item/slimecross/selfsustaining/pyrite
	extract_type = /obj/item/slime_extract/pyrite
	colour = "pyrite"
	auto_color = "#FAFAD2"

/obj/item/slimecross/selfsustaining/red
	extract_type = /obj/item/slime_extract/red
	colour = "red"
	auto_color = "#FF0000"

/obj/item/slimecross/selfsustaining/green
	extract_type = /obj/item/slime_extract/green
	colour = "green"
	auto_color = "#00FF00"

/obj/item/slimecross/selfsustaining/pink
	extract_type = /obj/item/slime_extract/pink
	colour = "pink"
	auto_color = "#FF69B4"

/obj/item/slimecross/selfsustaining/gold
	extract_type = /obj/item/slime_extract/gold
	colour = "gold"
	auto_color = "#FFD700"

/obj/item/slimecross/selfsustaining/oil
	extract_type = /obj/item/slime_extract/oil
	colour = "oil"
	auto_color = "#505050"

/obj/item/slimecross/selfsustaining/black
	extract_type = /obj/item/slime_extract/black
	colour = "black"
	auto_color = "#000000"

/obj/item/slimecross/selfsustaining/lightpink
	extract_type = /obj/item/slime_extract/lightpink
	colour = "light pink"
	auto_color = "#FFB6C1"

/obj/item/slimecross/selfsustaining/adamantine
	extract_type = /obj/item/slime_extract/adamantine
	colour = "adamantine"
	auto_color = "#008B8B"

/obj/item/slimecross/selfsustaining/rainbow
	extract_type = /obj/item/slime_extract/rainbow
	colour = "rainbow"
