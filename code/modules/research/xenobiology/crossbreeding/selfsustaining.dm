/obj/item/slimecross/selfsustaining
	name = "self-sustaining extract"
	var/extract_type = /obj/item/slime_extract
	var/list/activatereagents = list()

/obj/item/autoslime
	name = "autoslime"
	desc = "It resembles a normal slime extract, but seems filled with a strange, multi-colored fluid."
	var/obj/item/slime_extract/extract
	var/list/activatereagents = list()

//Just divides into the actual item.
/obj/item/slimecross/selfsustaining/Initialize()
	. = ..()
	src.visible_message("<span class='warning'>The [src] shudders, and splits into four smaller extracts.</span>")
	for(var/i = 0, i < 4, i++)
		var/obj/item/autoslime/A = new /obj/item/autoslime(src.loc)
		var/obj/item/slime_extract/X = new extract_type(A)
		A.extract = X
		A.activatereagents = activatereagents
	qdel(src)


/obj/item/autoslime/Initialize()
	name = "self-sustaining " + extract.name
	..()

/obj/item/autoslime/attack_self(mob/user)
	var/reagentselect = input(user, "Choose the reagent the extract will produce.", "Self-sustaining Reaction") as null|anything in activatereagents
	var/amount = 5
	var/secondary

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
	activatereagents = list("blood","plasma","water")
	colour = "grey"

/obj/item/slimecross/selfsustaining/orange
	extract_type = /obj/item/slime_extract/orange
	activatereagents = list("blood","plasma","water")
	colour = "orange"

/obj/item/slimecross/selfsustaining/purple
	extract_type = /obj/item/slime_extract/purple
	activatereagents = list("blood","plasma")
	colour = "purple"

/obj/item/slimecross/selfsustaining/blue
	extract_type = /obj/item/slime_extract/blue
	activatereagents = list("blood","plasma","water")
	colour = "blue"

/obj/item/slimecross/selfsustaining/metal
	extract_type = /obj/item/slime_extract/metal
	activatereagents = list("plasma","water")
	colour = "metal"

/obj/item/slimecross/selfsustaining/yellow
	extract_type = /obj/item/slime_extract/yellow
	activatereagents = list("blood","plasma","water")
	colour = "yellow"

/obj/item/slimecross/selfsustaining/darkpurple
	extract_type = /obj/item/slime_extract/darkpurple
	activatereagents = list("plasma")
	colour = "dark purple"

/obj/item/slimecross/selfsustaining/darkblue
	extract_type = /obj/item/slime_extract/darkblue
	activatereagents = list("plasma","water")
	colour = "dark blue"

/obj/item/slimecross/selfsustaining/silver
	extract_type = /obj/item/slime_extract/silver
	activatereagents = list("plasma","water")
	colour = "silver"

/obj/item/slimecross/selfsustaining/bluespace
	extract_type = /obj/item/slime_extract/bluespace
	activatereagents = list("blood","plasma")
	colour = "bluespace"

/obj/item/slimecross/selfsustaining/sepia
	extract_type = /obj/item/slime_extract/sepia
	activatereagents = list("blood","plasma","water")
	colour = "sepia"

/obj/item/slimecross/selfsustaining/cerulean
	extract_type = /obj/item/slime_extract/cerulean
	activatereagents = list("blood","plasma")
	colour = "cerulean"

/obj/item/slimecross/selfsustaining/pyrite
	extract_type = /obj/item/slime_extract/pyrite
	activatereagents = list("blood","plasma")
	colour = "pyrite"

/obj/item/slimecross/selfsustaining/red
	extract_type = /obj/item/slime_extract/red
	activatereagents = list("blood","plasma","water")
	colour = "red"

/obj/item/slimecross/selfsustaining/green
	extract_type = /obj/item/slime_extract/green
	activatereagents = list("blood","plasma","radium")
	colour = "green"

/obj/item/slimecross/selfsustaining/pink
	extract_type = /obj/item/slime_extract/pink
	activatereagents = list("blood","plasma")
	colour = "pink"

/obj/item/slimecross/selfsustaining/gold
	extract_type = /obj/item/slime_extract/gold
	activatereagents = list("blood","plasma","water")
	colour = "gold"

/obj/item/slimecross/selfsustaining/oil
	extract_type = /obj/item/slime_extract/oil
	activatereagents = list("blood","plasma")
	colour = "oil"

/obj/item/slimecross/selfsustaining/black
	extract_type = /obj/item/slime_extract/black
	activatereagents = list("plasma")
	colour = "black"

/obj/item/slimecross/selfsustaining/lightpink
	extract_type = /obj/item/slime_extract/lightpink
	activatereagents = list("plasma")
	colour = "light pink"

/obj/item/slimecross/selfsustaining/adamantine
	extract_type = /obj/item/slime_extract/adamantine
	activatereagents = list("plasma")
	colour = "adamantine"

/obj/item/slimecross/selfsustaining/rainbow
	extract_type = /obj/item/slime_extract/rainbow
	activatereagents = list("blood","lesser plasma","plasma","holy water and uranium")
	colour = "rainbow"