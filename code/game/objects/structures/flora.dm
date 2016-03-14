//trees
/obj/structure/flora/tree
	name = "tree"
	anchored = 1
	density = 1

	layer = FLY_LAYER
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_1"

	pixel_x = -16

	var/health = 100
	var/maxHealth = 100

	var/height = 6 //How many logs are spawned


	var/falling_dir = 0 //Direction in which spawned logs are thrown.

	var/const/randomize_on_creation = 1
	var/const/log_type = /obj/item/weapon/grown/log/tree

/obj/structure/flora/tree/New()
	..()

	if(randomize_on_creation)
		health = rand(60, 200)
		maxHealth = health

		height = rand(3, 8)

		icon_state = pick(
		"tree_1",
		"tree_2",
		"tree_3",
		"tree_4",
		"tree_5",
		"tree_6",
		)

/obj/structure/flora/tree/examine(mob/user)
	.=..()

	//Tell user about the height. Note that normally height ranges from 3 to 8 (with a 5% chance of having 6 to 15 instead)
	to_chat(user, "<span class='info'>It appears to be about [height*3] feet tall.</span>")
	switch(health / maxHealth)
		if(1.0)
			//It's healthy
		if(0.9 to 0.6)
			to_chat(user, "<span class='info'>It's been partially cut down.</span>")
		if(0.6 to 0.2)
			to_chat(user, "<span class='notice'>It's almost cut down, [falling_dir ? "and it's leaning towards the [dir2text(falling_dir)]." : "but it still stands upright."]</span>")
		if(0.2 to 0)
			to_chat(user, "<span class='danger'>It's going to fall down any minute now!</span>")

/obj/structure/flora/tree/attackby(obj/item/W, mob/living/user)
	..()

	if(istype(W, /obj/item/weapon))
		if(W.is_sharp() >= 1.2) //As sharp as a knife
			if(W.w_class >= 2) //Big enough to use to cut down trees
				health -= (user.get_strength() * W.force)
			else
				to_chat(user, "<span class='info'>\The [W] doesn't appear to be big enough to cut into \the [src]. Try something bigger.</span>")
		else
			to_chat(user, "<span class='info'>\The [W] doesn't appear to be sharp enough to cut into \the [src]. Try something sharper.</span>")

	update_health()

	return 1

/obj/structure/flora/tree/proc/fall_down()
	if(!falling_dir)
		falling_dir = pick(cardinal)

	var/turf/our_turf = get_turf(src) //Turf at which this tree is located
	var/turf/current_turf = get_turf(src) //Turf in which to spawn a log. Updated in the loop

	qdel(src)

	spawn()
		while(height > 0)
			if(!current_turf) break //If the turf in which to spawn a log doesn't exist, stop the thing

			var/obj/item/I = new log_type(our_turf) //Spawn a log and throw it at the "current_turf"
			I.throw_at(current_turf, 10, 10)

			current_turf = get_step(current_turf, falling_dir)

			height--

			sleep(1)

/obj/structure/flora/tree/proc/update_health()
	if(health < 40 && !falling_dir)
		falling_dir = pick(cardinal)
		visible_message("<span class='danger'>\The [src] starts leaning to the [dir2text(falling_dir)]!</span>",
			drugged_message = "<span class='sinister'>\The [src] is coming to life, man.</span>")

	if(health <= 0)
		fall_down()

/obj/structure/flora/tree/ex_act(severity)
	switch(severity)
		if(1) //Epicentre
			return qdel(src)
		if(2) //Major devastation
			height -= rand(1,4) //Some logs are lost
			fall_down()
		if(3) //Minor devastation (IED)
			health -= rand(10,30)
			update_health()

/obj/structure/flora/tree/pine
	name = "pine tree"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"

/obj/structure/flora/tree/pine/New()
	..()
	icon_state = "pine_[rand(1, 3)]"

/obj/structure/flora/tree/pine/xmas
	name = "xmas tree"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_c"

/obj/structure/flora/tree/pine/xmas/New()
	..()
	icon_state = "pine_c"

/obj/structure/flora/tree/dead
	name = "dead tree"
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_1"

/obj/structure/flora/tree/dead/New()
	..()
	icon_state = "tree_[rand(1, 6)]"

/obj/structure/flora/tree_stump
	name = "tree stump"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_stump"

//grass
/obj/structure/flora/grass
	name = "grass"
	icon = 'icons/obj/flora/snowflora.dmi'
	anchored = 1

/obj/structure/flora/grass/brown
	icon_state = "snowgrass1bb"

/obj/structure/flora/grass/brown/New()
	..()
	icon_state = "snowgrass[rand(1, 3)]bb"


/obj/structure/flora/grass/green
	icon_state = "snowgrass1gb"

/obj/structure/flora/grass/green/New()
	..()
	icon_state = "snowgrass[rand(1, 3)]gb"

/obj/structure/flora/grass/both
	icon_state = "snowgrassall1"

/obj/structure/flora/grass/both/New()
	..()
	icon_state = "snowgrassall[rand(1, 3)]"


//bushes
/obj/structure/flora/bush
	name = "bush"
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowbush1"
	anchored = 1

/obj/structure/flora/bush/New()
	..()
	icon_state = "snowbush[rand(1, 6)]"

/obj/structure/flora/pottedplant
	name = "potted plant"
	desc = "Oh, no. Not again."
	icon = 'icons/obj/plants.dmi'
	icon_state = "plant-26"
	layer = FLY_LAYER

/obj/structure/flora/pottedplant/Destroy()
	for(var/I in contents)
		qdel(I)

	return ..()

/obj/structure/flora/pottedplant/attackby(var/obj/item/I, var/mob/user)
	if(!I)
		return
	if(I.w_class > 2)
		to_chat(user, "That item is too big.")
		return
	if(contents.len)
		to_chat(user, "There is already something in the pot.")
	else
		if(user.drop_item(I, src))
			user.visible_message("<span class='notice'>[user] stuffs something into the pot.</span>", "You stuff \the [I] into the [src].")

/obj/structure/flora/pottedplant/attack_hand(mob/user)
	if(contents.len)
		var/obj/item/I = contents[1]
		user.visible_message("<span class='notice'>[user] retrieves something from the pot.</span>", "You retrieve \the [I] from the [src].")
		I.forceMove(loc)
		user.put_in_active_hand(I)
	else
		to_chat(user, "You root around in the roots.")

// /vg/
/obj/structure/flora/pottedplant/random/New()
	..()
	icon_state = "plant-[rand(1,26)]"

//newbushes

/obj/structure/flora/ausbushes
	name = "bush"
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "firstbush_1"
	anchored = 1

/obj/structure/flora/ausbushes/New()
	..()
	icon_state = "firstbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/reedbush
	icon_state = "reedbush_1"

/obj/structure/flora/ausbushes/reedbush/New()
	..()
	icon_state = "reedbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/leafybush
	icon_state = "leafybush_1"

/obj/structure/flora/ausbushes/leafybush/New()
	..()
	icon_state = "leafybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/palebush
	icon_state = "palebush_1"

/obj/structure/flora/ausbushes/palebush/New()
	..()
	icon_state = "palebush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/stalkybush
	icon_state = "stalkybush_1"

/obj/structure/flora/ausbushes/stalkybush/New()
	..()
	icon_state = "stalkybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/grassybush
	icon_state = "grassybush_1"

/obj/structure/flora/ausbushes/grassybush/New()
	..()
	icon_state = "grassybush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/fernybush
	icon_state = "fernybush_1"

/obj/structure/flora/ausbushes/fernybush/New()
	..()
	icon_state = "fernybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/sunnybush
	icon_state = "sunnybush_1"

/obj/structure/flora/ausbushes/sunnybush/New()
	..()
	icon_state = "sunnybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/genericbush
	icon_state = "genericbush_1"

/obj/structure/flora/ausbushes/genericbush/New()
	..()
	icon_state = "genericbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/pointybush
	icon_state = "pointybush_1"

/obj/structure/flora/ausbushes/pointybush/New()
	..()
	icon_state = "pointybush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/lavendergrass
	icon_state = "lavendergrass_1"

/obj/structure/flora/ausbushes/lavendergrass/New()
	..()
	icon_state = "lavendergrass_[rand(1, 4)]"

/obj/structure/flora/ausbushes/ywflowers
	icon_state = "ywflowers_1"

/obj/structure/flora/ausbushes/ywflowers/New()
	..()
	icon_state = "ywflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/brflowers
	icon_state = "brflowers_1"

/obj/structure/flora/ausbushes/brflowers/New()
	..()
	icon_state = "brflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/ppflowers
	icon_state = "ppflowers_1"

/obj/structure/flora/ausbushes/ppflowers/New()
	..()
	icon_state = "ppflowers_[rand(1, 4)]"

/obj/structure/flora/ausbushes/sparsegrass
	icon_state = "sparsegrass_1"

/obj/structure/flora/ausbushes/sparsegrass/New()
	..()
	icon_state = "sparsegrass_[rand(1, 3)]"

/obj/structure/flora/ausbushes/fullgrass
	icon_state = "fullgrass_1"

/obj/structure/flora/ausbushes/fullgrass/New()
	..()
	icon_state = "fullgrass_[rand(1, 3)]"

//a rock is flora according to where the icon file is
//and now these defines
/obj/structure/flora/rock
	name = "rock"
	desc = "a rock"
	icon_state = "rock1"
	icon = 'icons/obj/flora/rocks.dmi'
	anchored = 1

/obj/structure/flora/rock/New()
	..()
	icon_state = "rock[rand(1,5)]"

/obj/structure/flora/rock/pile
	name = "rocks"
	desc = "some rocks"
	icon_state = "rockpile1"

/obj/structure/flora/rock/pile/New()
	..()
	icon_state = "rockpile[rand(1,5)]"
