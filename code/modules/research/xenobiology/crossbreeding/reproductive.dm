/*
Reproductive extracts:
	When fed three monkey cubes, produces between
	1 and 4 normal slime extracts of the same colour.
*/
/obj/item/slimecross/reproductive
	name = "reproductive extract"
	desc = "It pulses with a strange hunger."
	icon_state = "reproductive"
	effect = "reproductive"
	var/extract_type = /obj/item/slime_extract/
	var/cubes_eaten = 0
	var/last_produce = 0
	var/cooldown = 30 // 3 seconds.

/obj/item/slimecross/reproductive/attackby(obj/item/O, mob/user)
	if((last_produce + cooldown) > world.time)
		to_chat(user, "<span class='warning'>[src] is still digesting!</span>")
		return
	if(istype(O, /obj/item/storage/bag/bio))
		var/obj/item/storage/P = O
		var/obj/item/reagent_containers/food/snacks/monkeycube/M
		for(var/obj/item/X in P.contents)
			M = X
			if(M && istype(M))
				break
		if(M && istype(M))
			P.remove_from_storage(M, get_turf(src))
			attackby(M,user)
		else
			to_chat(user, "<span class='warning'>There are no monkey cubes in the bio bag!</span>")
	if(istype(O,/obj/item/reagent_containers/food/snacks/monkeycube))
		qdel(O)
		cubes_eaten++
		to_chat(user, "<span class='notice'>You feed [O] to [src], and it pulses gently.</span>")
		playsound(src, 'sound/items/eatfood.ogg', 20, 1)
	if(cubes_eaten >= 3)
		var/cores = rand(1,4)
		visible_message("<span class='notice'>[src] briefly swells to a massive size, and expels [cores] extract[cores > 1 ? "s":""]!</span>")
		playsound(src, 'sound/effects/splat.ogg', 40, 1)
		last_produce = world.time
		for(var/i = 0, i < cores, i++)
			new extract_type(get_turf(loc))
		cubes_eaten = 0

/obj/item/slimecross/reproductive/grey
	extract_type = /obj/item/slime_extract/grey
	colour = "grey"

/obj/item/slimecross/reproductive/orange
	extract_type = /obj/item/slime_extract/orange
	colour = "orange"

/obj/item/slimecross/reproductive/purple
	extract_type = /obj/item/slime_extract/purple
	colour = "purple"

/obj/item/slimecross/reproductive/blue
	extract_type = /obj/item/slime_extract/blue
	colour = "blue"

/obj/item/slimecross/reproductive/metal
	extract_type = /obj/item/slime_extract/metal
	colour = "metal"

/obj/item/slimecross/reproductive/yellow
	extract_type = /obj/item/slime_extract/yellow
	colour = "yellow"

/obj/item/slimecross/reproductive/darkpurple
	extract_type = /obj/item/slime_extract/darkpurple
	colour = "dark purple"

/obj/item/slimecross/reproductive/darkblue
	extract_type = /obj/item/slime_extract/darkblue
	colour = "dark blue"

/obj/item/slimecross/reproductive/silver
	extract_type = /obj/item/slime_extract/silver
	colour = "silver"

/obj/item/slimecross/reproductive/bluespace
	extract_type = /obj/item/slime_extract/bluespace
	colour = "bluespace"

/obj/item/slimecross/reproductive/sepia
	extract_type = /obj/item/slime_extract/sepia
	colour = "sepia"

/obj/item/slimecross/reproductive/cerulean
	extract_type = /obj/item/slime_extract/cerulean
	colour = "cerulean"

/obj/item/slimecross/reproductive/pyrite
	extract_type = /obj/item/slime_extract/pyrite
	colour = "pyrite"

/obj/item/slimecross/reproductive/red
	extract_type = /obj/item/slime_extract/red
	colour = "red"

/obj/item/slimecross/reproductive/green
	extract_type = /obj/item/slime_extract/green
	colour = "green"

/obj/item/slimecross/reproductive/pink
	extract_type = /obj/item/slime_extract/pink
	colour = "pink"

/obj/item/slimecross/reproductive/gold
	extract_type = /obj/item/slime_extract/gold
	colour = "gold"

/obj/item/slimecross/reproductive/oil
	extract_type = /obj/item/slime_extract/oil
	colour = "oil"

/obj/item/slimecross/reproductive/black
	extract_type = /obj/item/slime_extract/black
	colour = "black"

/obj/item/slimecross/reproductive/lightpink
	extract_type = /obj/item/slime_extract/lightpink
	colour = "light pink"

/obj/item/slimecross/reproductive/adamantine
	extract_type = /obj/item/slime_extract/adamantine
	colour = "adamantine"

/obj/item/slimecross/reproductive/rainbow
	extract_type = /obj/item/slime_extract/rainbow
	colour = "rainbow"
