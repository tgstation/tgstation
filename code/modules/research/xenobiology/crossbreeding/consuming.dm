/*
Consuming extracts:
	Holds potentially infinite normal extracts.
	Allows easy feeding of extracts to slimes.
*/
/obj/item/slimecross/consuming
	name = "consuming extract"
	desc = "It hungers... for <i>more</i>." //My slimecross has finally decided to eat... my extract!
	var/stored = 0
	var/extract_type = /obj/item/slime_extract

/obj/item/slimecross/consuming/examine(mob/user)
	..()
	if(stored > 0)
		to_chat(user, "You see [stored] pearl[stored > 1 ? "s":""] of drained extracts floating inside.")
	if(stored == 0)
		to_chat(user, "The extract is empty.")

/obj/item/slimecross/consuming/attack_self(mob/user)
	if(stored > 0)
		stored--
		var/obj/item/slime_extract/X = new extract_type(user.drop_location())
		user.put_in_inactive_hand(X)
		to_chat(user, "<span class='notice'>The [src] unhappily releases one of its consumed extracts as it is squeezed.</span>")
	else
		to_chat(user,"<span class='warning'>The [src] is empty!</span>")

/obj/item/slimecross/consuming/attackby(obj/item/O, mob/user)
	if(istype(O,extract_type))
		qdel(O)
		stored++
		to_chat(user,"<span class='warning'>The [src] splits in half like an opening mouth and swallows the extract!</span>")
	else
		to_chat(user,"<span class='warning'>You can only feed the [src] [colour] extracts!</span>")

/obj/item/slimecross/consuming/afterattack(turf/target, mob/user, proximity)
	if(!proximity)
		return
	if(!istype(target))
		return
	var/foundsome = FALSE
	for(var/obj/item/slime_extract/X in target.contents)
		if(istype(X,extract_type))
			foundsome = TRUE
			qdel(X)
			stored++

	if(foundsome)
		to_chat(user,"<span class='warning'>The [src] eagerly consumes all of the [colour] extracts!</span>")

/obj/item/slimecross/consuming/attack(mob/living/simple_animal/slime/M, mob/user)
	if(stored > 0)
		var/obj/item/slime_extract/X = new extract_type(user.drop_location())
		X.attack(M,user)
		if(!QDELETED(X))
			qdel(X)
		else
			stored--

/obj/item/slimecross/consuming/grey
	extract_type = /obj/item/slime_extract/grey
	colour = "grey"

/obj/item/slimecross/consuming/orange
	extract_type = /obj/item/slime_extract/orange
	colour = "orange"

/obj/item/slimecross/consuming/purple
	extract_type = /obj/item/slime_extract/purple
	colour = "purple"

/obj/item/slimecross/consuming/blue
	extract_type = /obj/item/slime_extract/blue
	colour = "blue"

/obj/item/slimecross/consuming/metal
	extract_type = /obj/item/slime_extract/metal
	colour = "metal"

/obj/item/slimecross/consuming/yellow
	extract_type = /obj/item/slime_extract/yellow
	colour = "yellow"

/obj/item/slimecross/consuming/darkpurple
	extract_type = /obj/item/slime_extract/darkpurple
	colour = "dark purple"

/obj/item/slimecross/consuming/darkblue
	extract_type = /obj/item/slime_extract/darkblue
	colour = "dark blue"

/obj/item/slimecross/consuming/silver
	extract_type = /obj/item/slime_extract/silver
	colour = "silver"

/obj/item/slimecross/consuming/bluespace
	extract_type = /obj/item/slime_extract/bluespace
	colour = "bluespace"

/obj/item/slimecross/consuming/sepia
	extract_type = /obj/item/slime_extract/sepia
	colour = "sepia"

/obj/item/slimecross/consuming/cerulean
	extract_type = /obj/item/slime_extract/cerulean
	colour = "cerulean"

/obj/item/slimecross/consuming/pyrite
	extract_type = /obj/item/slime_extract/pyrite
	colour = "pyrite"

/obj/item/slimecross/consuming/red
	extract_type = /obj/item/slime_extract/red
	colour = "red"

/obj/item/slimecross/consuming/green
	extract_type = /obj/item/slime_extract/green
	colour = "green"

/obj/item/slimecross/consuming/pink
	extract_type = /obj/item/slime_extract/pink
	colour = "pink"

/obj/item/slimecross/consuming/gold
	extract_type = /obj/item/slime_extract/gold
	colour = "gold"

/obj/item/slimecross/consuming/oil
	extract_type = /obj/item/slime_extract/oil
	colour = "oil"

/obj/item/slimecross/consuming/black
	extract_type = /obj/item/slime_extract/black
	colour = "black"

/obj/item/slimecross/consuming/lightpink
	extract_type = /obj/item/slime_extract/lightpink
	colour = "light pink"

/obj/item/slimecross/consuming/adamantine
	extract_type = /obj/item/slime_extract/adamantine
	colour = "adamantine"

/obj/item/slimecross/consuming/rainbow
	extract_type = /obj/item/slime_extract/rainbow
	colour = "rainbow"
