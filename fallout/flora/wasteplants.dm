/obj/structure/flora/wasteplant
	name = "wasteland plant"
	desc = "It's a wasteland plant."
	icon = 'fallout/icons/flora/wastelandflora.dmi'
	anchored = 1
	density = 0
	var/has_prod = TRUE
	var/obj/item/reagent_containers/food/snacks/grown/produce = null //If only we used ACTUAL plants

/obj/structure/flora/wasteplant/Initialize()
	. = ..()
	update_icon()

/obj/structure/flora/wasteplant/attack_hand(mob/user)
	if(has_prod)
		user.put_in_hands(new produce)
		to_chat(user, "<span class='notice'>You take [produce.name] from [src].</span>")
		has_prod = FALSE
		update_icon() //Won't update due to proc otherwise
		addtimer(CALLBACK(src, .proc/regrow), 10 MINUTES)
	else
		to_chat(user, "<span class='warning'>Seems to be nothing on this plant.</span>")
	update_icon()

/obj/structure/flora/wasteplant/proc/regrow()
	has_prod = TRUE
	update_icon()

/obj/structure/flora/wasteplant/update_icon()
	if(has_prod)
		icon_state = "[initial(icon_state)]"
	else
		icon_state = "[initial(icon_state)]_no"

/obj/structure/flora/wasteplant/wild_broc
	name = "wild broc flower"
	icon_state = "wild_broc"
	desc = "A tall stalk bearing a vibrant, orange flower famed for its healing properties."
	produce = /obj/item/reagent_containers/food/snacks/grown/broc

/obj/structure/flora/wasteplant/wild_xander
	name = "wild xander roots"
	icon_state = "wild_xander"
	desc = "A hardy, onion-like root with mild healing properties."
	produce = /obj/item/reagent_containers/food/snacks/grown/xander

/obj/structure/flora/wasteplant/wild_feracactus
	name = "wild barrel cactus"
	icon_state = "wild_feracactus"
	desc = "A squat, spherical cactus blooming with a toxic fruit."
	produce = /obj/item/reagent_containers/food/snacks/grown/feracactus

/obj/structure/flora/wasteplant/wild_mutfruit
	name = "wild mutfruit sapling"
	icon_state = "wild_mutfruit"
	desc = "This irradiated sapling offers a fruit that is highly nutritious and hydrating."
	produce = /obj/item/reagent_containers/food/snacks/grown/mutfruit

/obj/structure/flora/wasteplant/wild_fungus
	name = "cave fungi"
	icon_state = "wild_fungus"
	desc = "This edible strain of fungus grows in dark places and is said to have anti-toxic properties."
	produce = /obj/item/reagent_containers/food/snacks/grown/fungus

/obj/structure/flora/wasteplant/wild_agave
	name = "wild agave"
	icon_state = "wild_agave"
	desc = "The juice of this fleshy plant soothes burns, but it also removes nutrients from the body."
	produce = /obj/item/reagent_containers/food/snacks/grown/agave

//Fallout 13 general flora directory

/obj/structure/flora/grass/wasteland
	icon = 'fallout/icons/flora/flora.dmi'
	desc = "Some dry, virtually dead grass."
	icon_state = "tall_grass_1"

/obj/structure/flora/grass/wasteland/New()
	..()
	icon_state = "tall_grass_[rand(1,8)]"

/obj/structure/flora/grass/wasteland/attackby(obj/item/W, mob/user, params) //we dont use /weapon any more
	if(W.sharpness && W.force > 0 && !(NODECONSTRUCT_1 in flags_1))
		to_chat(user, "You begin to harvest [src]...")
		if(do_after(user, 100/W.force, target = user))
			to_chat(user, "<span class='notice'>You've collected [src]</span>")
			var/obj/item/stack/sheet/hay/H = user.get_inactive_held_item()
			if(istype(H))
				H.add(1)
			else
				new /obj/item/stack/sheet/hay/(get_turf(src))
			qdel(src)
			return 1
	else
		. = ..()

/obj/structure/flora/tree/wasteland
	name = "dead tree"
	desc = "It's a tree. Useful for combustion and/or construction."
	icon = 'fallout/icons/flora/trees.dmi'
	icon_state = "deadtree_1"
	log_amount = 4
	obj_integrity = 100
	max_integrity = 100

/obj/structure/flora/tree/wasteland/New()
	icon_state = "deadtree_[rand(1,6)]"
	..()

/obj/structure/flora/tree/joshua
	name = "joshua tree"
	desc = "A tree named by mormons, who said it's branches mimiced the biblical Joshua, raising his hands in prayer."
	icon = 'fallout/icons/flora/trees.dmi'
	log_amount = 3
	icon_state = "joshua_1"

/obj/structure/flora/tree/joshua/Initialize()
	. = ..()
	icon_state = "joshua_[rand(1,4)]"

/obj/structure/flora/tree/cactus
	name = "cactus"
	desc = "It's a giant cowboy hat! It's waving hello! It wants you to hug it!"
	icon = 'fallout/icons/flora/trees.dmi'
	icon_state = "cactus"
	log_amount = 2
