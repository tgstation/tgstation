/obj/effect/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/obj/objects.dmi'
	icon_state = "shards"

/obj/effect/decal/cleanable/ash
	name = "ashes"
	desc = "Ashes to ashes, dust to dust, and into space."
	gender = PLURAL
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	anchored = 1

/obj/effect/decal/cleanable/ash/attack_hand(mob/user as mob)
	user.visible_message("<span class='notice'>[user] wipes away \the [src].</span>")
	qdel(src)

/obj/effect/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/effects.dmi'
	icon_state = "dirt"
	mouse_opacity = 0

/obj/effect/decal/cleanable/flour
	name = "flour"
	desc = "It's still good. Four second rule!"
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/effects.dmi'
	icon_state = "flour"

/obj/effect/decal/cleanable/greenglow
	name = "glowing goo"
	desc = "Jeez. I hope that's not for lunch."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	luminosity = 1
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"

/obj/effect/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Somebody should remove that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb1"

/obj/effect/decal/cleanable/molten_item
	name = "gooey grey mass"
	desc = "It looks like a melted... something."
	density = 0
	anchored = 1
	layer = 3
	icon = 'icons/obj/chemical.dmi'
	icon_state = "molten"

/obj/effect/decal/cleanable/cobweb2
	name = "cobweb"
	desc = "Somebody should remove that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb2"

//Vomit (sorry)
/obj/effect/decal/cleanable/vomit
	name = "vomit"
	desc = "Gosh, how unpleasant."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "vomit_1"

	basecolor="#FFFF99"
	amount = 2
	random_icon_states = list("vomit_1", "vomit_2", "vomit_3", "vomit_4")
	transfers_dna = 1

/*
/obj/effect/decal/cleanable/vomit/Crossed(mob/living/carbon/human/perp)
	if (!istype(perp))
		return
	if(amount < 1)
		return

	if(perp.shoes)
		perp.shoes:track_blood = max(amount,perp.shoes:track_blood)		//Adding vomit to shoes

		if(!blood_overlays[perp.shoes.type])
			perp.shoes.generate_blood_overlay()
		if(perp.shoes.blood_overlay)
			overlays -= perp.shoes.blood_overlay
		else
			perp.shoes.blood_overlay = blood_overlays[perp.shoes.type]
		perp.shoes.blood_overlay.color = basecolor
		perp.shoes.overlays += perp.shoes.blood_overlay
		perp.shoes.blood_color=basecolor

		if(!perp.shoes.blood_DNA)
			perp.shoes.blood_DNA = list()
		perp.update_inv_shoes(1)
	else
		perp.track_blood = max(amount,perp.track_blood)				//Or feet
		if(!perp.feet_blood_DNA)
			perp.feet_blood_DNA = list()
		perp.feet_blood_color=basecolor

	amount--
*/

/obj/effect/decal/cleanable/tomato_smudge
	name = "tomato smudge"
	desc = "It's red."
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")

/obj/effect/decal/cleanable/egg_smudge
	name = "smashed egg"
	desc = "Seems like this one won't hatch."
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_egg1", "smashed_egg2", "smashed_egg3")

/obj/effect/decal/cleanable/pie_smudge //honk
	name = "smashed pie"
	desc = "It's pie cream from a cream pie."
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_pie")

/obj/effect/decal/cleanable/soot
	name = "soot"
	desc = "One hell of a party..."
	gender = PLURAL
	icon = 'icons/effects/tile_effects.dmi'
	icon_state = "tile_soot"
	anchored = 1
	layer=2

/obj/effect/decal/cleanable/soot/New()
	..()
	dir = pick(cardinal)

/obj/effect/decal/cleanable/lspaceclutter
	name = "clutter"
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/effects.dmi'
	icon_state = "lspaceclutter"