/*
Stabilized extracts:
	Provides a passive buff to the holder.
*/

//To add: Create an effect in crossbreeding/_status_effects.dm with the name "/datum/status_effect/stabilized/[color]"
//Status effect will automatically be applied while held, and lost on drop.

/obj/item/slimecross/stabilized
	name = "stabilized extract"
	desc = "It seems inert, but anything it touches glows softly..."
	effect = "stabilized"
	icon_state = "stabilized"
	var/datum/status_effect/linked_effect
	var/mob/living/owner

/obj/item/slimecross/stabilized/Initialize()
	..()
	START_PROCESSING(SSobj,src)

/obj/item/slimecross/stabilized/Destroy()
	STOP_PROCESSING(SSobj,src)
	qdel(linked_effect)
	return ..()

/obj/item/slimecross/stabilized/process()
	var/humanfound = null
	if(ishuman(loc))
		humanfound = loc
	if(ishuman(loc.loc)) //Check if in backpack.
		humanfound = (loc.loc)
	if(!humanfound)
		return
	var/mob/living/carbon/human/H = humanfound
	var/effectpath = /datum/status_effect/stabilized
	var/static/list/effects = subtypesof(/datum/status_effect/stabilized)
	for(var/X in effects)
		var/datum/status_effect/stabilized/S = X
		if(initial(S.colour) == colour)
			effectpath = S
			break
	if(!H.has_status_effect(effectpath))
		var/datum/status_effect/stabilized/S = H.apply_status_effect(effectpath)
		owner = H
		S.linked_extract = src
		STOP_PROCESSING(SSobj,src)

//Colors and subtypes:
/obj/item/slimecross/stabilized/grey
	colour = "grey"

/obj/item/slimecross/stabilized/orange
	colour = "orange"

/obj/item/slimecross/stabilized/purple
	colour = "purple"

/obj/item/slimecross/stabilized/blue
	colour = "blue"

/obj/item/slimecross/stabilized/metal
	colour = "metal"

/obj/item/slimecross/stabilized/yellow
	colour = "yellow"

/obj/item/slimecross/stabilized/darkpurple
	colour = "dark purple"

/obj/item/slimecross/stabilized/darkblue
	colour = "dark blue"

/obj/item/slimecross/stabilized/silver
	colour = "silver"

/obj/item/slimecross/stabilized/bluespace
	colour = "bluespace"

/obj/item/slimecross/stabilized/sepia
	colour = "sepia"

/obj/item/slimecross/stabilized/cerulean
	colour = "cerulean"

/obj/item/slimecross/stabilized/pyrite
	colour = "pyrite"

/obj/item/slimecross/stabilized/red
	colour = "red"

/obj/item/slimecross/stabilized/green
	colour = "green"

/obj/item/slimecross/stabilized/pink
	colour = "pink"

/obj/item/slimecross/stabilized/gold
	colour = "gold"

/obj/item/slimecross/stabilized/oil
	colour = "oil"

/obj/item/slimecross/stabilized/black
	colour = "black"

/obj/item/slimecross/stabilized/lightpink
	colour = "light pink"

/obj/item/slimecross/stabilized/adamantine
	colour = "adamantine"

/obj/item/slimecross/stabilized/rainbow
	colour = "rainbow"
	var/obj/item/slimecross/regenerative/regencore

/obj/item/slimecross/stabilized/rainbow/attackby(obj/item/O, mob/user)
	var/obj/item/slimecross/regenerative/regen = O
	if(istype(O) && !regencore)
		to_chat(user, "<span class='notice'>You place the [O] in the [src], prepping the extract for automatic application!</span>")
		regencore = regen
		regen.forceMove(src)
		return
	return ..()