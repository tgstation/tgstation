/obj/structure/flora
	resistance_flags = FLAMMABLE
	obj_integrity = 150
	max_integrity = 150
	anchored = 1

//trees
/obj/structure/flora/tree
	name = "tree"
	density = 1
	pixel_x = -16
	layer = FLY_LAYER
	var/cut = FALSE
	var/log_amount = 10

/obj/structure/flora/tree/attackby(obj/item/weapon/W, mob/user, params)
	if(!cut && log_amount && (!(NODECONSTRUCT in flags)))
		if(W.sharpness && W.force > 0)
			if(W.hitsound)
				playsound(get_turf(src), W.hitsound, 100, 0, 0)
			user.visible_message("<span class='notice'>[user] begins to cut down [src] with [W].</span>","<span class='notice'>You begin to cut down [src] with [W].</span>", "You hear the sound of sawing.")
			if(do_after(user, 1000/W.force, target = user)) //5 seconds with 20 force, 8 seconds with a hatchet, 20 seconds with a shard.
				if(cut)
					return
				user.visible_message("<span class='notice'>[user] fells [src] with the [W].</span>","<span class='notice'>You fell [src] with the [W].</span>", "You hear the sound of a tree falling.")
				playsound(get_turf(src), 'sound/effects/meteorimpact.ogg', 100 , 0, 0)
				icon = 'icons/obj/flora/pinetrees.dmi'
				icon_state = "tree_stump"
				density = 0
				pixel_x = -16
				name += " stump"
				cut = TRUE
				for(var/i=1 to log_amount)
					new /obj/item/weapon/grown/log/tree(get_turf(src))

	else
		return ..()




/obj/structure/flora/tree/pine
	name = "pine tree"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"

/obj/structure/flora/tree/pine/Initialize()
	icon_state = "pine_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/tree/pine/xmas
	name = "xmas tree"
	icon_state = "pine_c"

/obj/structure/flora/tree/pine/xmas/Initialize()
	. = ..()
	icon_state = "pine_c"

/obj/structure/flora/tree/dead
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_1"

/obj/structure/flora/tree/palm
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"

/obj/structure/flora/tree/palm/Initialize()
	. = ..()
	icon_state = pick("palm1","palm2")
	pixel_x = 0

/obj/structure/festivus
	name = "festivus pole"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "festivus_pole"
	desc = "During last year's Feats of Strength the Research Director was able to suplex this passing immobile rod into a planter."

/obj/structure/flora/tree/dead/Initialize()
	icon_state = "tree_[rand(1, 6)]"
	. = ..()

/obj/structure/flora/tree/jungle
	name = "tree"
	icon_state = "tree"
	desc = "It's seriously hampering your view of the jungle."
	icon = 'icons/obj/flora/jungletrees.dmi'
	pixel_x = -48
	pixel_y = -20

/obj/structure/flora/tree/jungle/Initialize()
	icon_state = "[icon_state][rand(1, 6)]"
	. = ..()

//grass
/obj/structure/flora/grass
	name = "grass"
	icon = 'icons/obj/flora/snowflora.dmi'
	gender = PLURAL	//"this is grass" not "this is a grass"

/obj/structure/flora/grass/brown
	icon_state = "snowgrass1bb"

/obj/structure/flora/grass/brown/Initialize()
	icon_state = "snowgrass[rand(1, 3)]bb"
	. = ..()


/obj/structure/flora/grass/green
	icon_state = "snowgrass1gb"

/obj/structure/flora/grass/green/Initialize()
	icon_state = "snowgrass[rand(1, 3)]gb"
	. = ..()

/obj/structure/flora/grass/both
	icon_state = "snowgrassall1"

/obj/structure/flora/grass/both/Initialize()
	icon_state = "snowgrassall[rand(1, 3)]"
	. = ..()


//bushes
/obj/structure/flora/bush
	name = "bush"
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowbush1"
	anchored = 1

/obj/structure/flora/bush/Initialize()
	icon_state = "snowbush[rand(1, 6)]"
	. = ..()

//newbushes

/obj/structure/flora/ausbushes
	name = "bush"
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "firstbush_1"

/obj/structure/flora/ausbushes/Initialize()
	if(icon_state == "firstbush_1")
		icon_state = "firstbush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/reedbush
	icon_state = "reedbush_1"

/obj/structure/flora/ausbushes/reedbush/Initialize()
	icon_state = "reedbush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/leafybush
	icon_state = "leafybush_1"

/obj/structure/flora/ausbushes/leafybush/Initialize()
	icon_state = "leafybush_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/palebush
	icon_state = "palebush_1"

/obj/structure/flora/ausbushes/palebush/Initialize()
	icon_state = "palebush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/stalkybush
	icon_state = "stalkybush_1"

/obj/structure/flora/ausbushes/stalkybush/Initialize()
	icon_state = "stalkybush_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/grassybush
	icon_state = "grassybush_1"

/obj/structure/flora/ausbushes/grassybush/Initialize()
	icon_state = "grassybush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/fernybush
	icon_state = "fernybush_1"

/obj/structure/flora/ausbushes/fernybush/Initialize()
	icon_state = "fernybush_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/sunnybush
	icon_state = "sunnybush_1"

/obj/structure/flora/ausbushes/sunnybush/Initialize()
	icon_state = "sunnybush_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/genericbush
	icon_state = "genericbush_1"

/obj/structure/flora/ausbushes/genericbush/Initialize()
	icon_state = "genericbush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/pointybush
	icon_state = "pointybush_1"

/obj/structure/flora/ausbushes/pointybush/Initialize()
	icon_state = "pointybush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/lavendergrass
	icon_state = "lavendergrass_1"

/obj/structure/flora/ausbushes/lavendergrass/Initialize()
	icon_state = "lavendergrass_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/ywflowers
	icon_state = "ywflowers_1"

/obj/structure/flora/ausbushes/ywflowers/Initialize()
	icon_state = "ywflowers_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/brflowers
	icon_state = "brflowers_1"

/obj/structure/flora/ausbushes/brflowers/Initialize()
	icon_state = "brflowers_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/ppflowers
	icon_state = "ppflowers_1"

/obj/structure/flora/ausbushes/ppflowers/Initialize()
	icon_state = "ppflowers_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/sparsegrass
	icon_state = "sparsegrass_1"

/obj/structure/flora/ausbushes/sparsegrass/Initialize()
	icon_state = "sparsegrass_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/fullgrass
	icon_state = "fullgrass_1"

/obj/structure/flora/ausbushes/fullgrass/Initialize()
	icon_state = "fullgrass_[rand(1, 3)]"
	. = ..()

/obj/item/weapon/twohanded/required/kirbyplants
	name = "potted plant"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "plant-01"
	layer = ABOVE_MOB_LAYER
	w_class = WEIGHT_CLASS_HUGE
	force = 10
	throwforce = 13
	throw_speed = 2
	throw_range = 4

/obj/item/weapon/twohanded/required/kirbyplants/equipped(mob/living/user)
	var/image/I = image(icon = 'icons/obj/flora/plants.dmi' , icon_state = src.icon_state, loc = user)
	I.override = 1
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "sneaking_mission", I)
	..()

/obj/item/weapon/twohanded/required/kirbyplants/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("sneaking_mission")

/obj/item/weapon/twohanded/required/kirbyplants/random
	var/list/static/states

/obj/item/weapon/twohanded/required/kirbyplants/random/Initialize()
	. = ..()
	if(!states)
		generate_states()
	icon_state = pick(states)

/obj/item/weapon/twohanded/required/kirbyplants/random/proc/generate_states()
	states = list()
	for(var/i in 1 to 25)
		var/number
		if(i < 10)
			number = "0[i]"
		else
			number = "[i]"
		states += "plant-[number]"
	states += "applebush"


/obj/item/weapon/twohanded/required/kirbyplants/dead
	name = "RD's potted plant"
	desc = "A gift from the botanical staff, presented after the RD's reassignment. There's a tag on it that says \"Y'all come back now, y'hear?\"\nIt doesn't look very healthy..."
	icon_state = "plant-25"


//a rock is flora according to where the icon file is
//and now these defines

/obj/structure/flora/rock
	icon_state = "basalt"
	desc = "A volcanic rock"
	icon = 'icons/obj/flora/rocks.dmi'
	resistance_flags = FIRE_PROOF
	density = 1

/obj/structure/flora/rock/Initialize()
	. = ..()
	icon_state = "[icon_state][rand(1,3)]"

/obj/structure/flora/rock/pile
	icon_state = "lavarocks"
	desc = "A pile of rocks"

/obj/structure/flora/rock/pile/Initialize()
	. = ..()
	icon_state = "[icon_state][rand(1,3)]"

//Jungle grass

/obj/structure/flora/grass/jungle
	name = "jungle grass"
	desc = "Thick alien flora."
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_state = "grassa"


/obj/structure/flora/grass/jungle/Initialize()
	icon_state = "[icon_state][rand(1, 5)]"
	. = ..()

/obj/structure/flora/grass/jungle/b
	icon_state = "grassb"

//Jungle rocks

/obj/structure/flora/rock/jungle
	icon_state = "pile of rocks"
	desc = "A pile of rocks."
	icon_state = "rock"
	icon = 'icons/obj/flora/jungleflora.dmi'
	density = FALSE

/obj/structure/flora/rock/jungle/Initialize()
	. = ..()
	icon_state = "[initial(icon_state)][rand(1,5)]"


//Jungle bushes

/obj/structure/flora/junglebush
	name = "bush"
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_state = "busha"

/obj/structure/flora/junglebush/Initialize()
	icon_state = "[icon_state][rand(1, 3)]"
	. = ..()

/obj/structure/flora/junglebush/b
	icon_state = "bushb"

/obj/structure/flora/junglebush/c
	icon_state = "bushc"

/obj/structure/flora/junglebush/large
	icon_state = "bush"
	icon = 'icons/obj/flora/largejungleflora.dmi'
	pixel_x = -16
	pixel_y = -12
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/flora/rock/pile/largejungle
	name = "rocks"
	icon_state = "rocks"
	icon = 'icons/obj/flora/largejungleflora.dmi'
	density = FALSE
	pixel_x = -16
	pixel_y = -16

/obj/structure/flora/rock/pile/largejungle/Initialize()
	. = ..()
	icon_state = "[initial(icon_state)][rand(1,3)]"
