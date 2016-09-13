/obj/structure/flora/ash
	gender = PLURAL
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER //sporangiums up don't shoot
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "l_mushroom"
	name = "large mushrooms"
	desc = "A number of large mushrooms, covered in a faint layer of ash and what can only be spores."
	var/harvested_name = "shortened mushrooms"
	var/harvested_desc = "Some quickly regrowing mushrooms, formerly known to be quite large."
	var/needs_sharp_harvest = TRUE
	var/harvest = /obj/item/ash_flora/shavings
	var/harvest_amount_low = 1
	var/harvest_amount_high = 3
	var/harvest_time = 60
	var/harvest_message_low = "You pick a mushroom, but fail to collect many shavings from its cap."
	var/harvest_message_med = "You pick a mushroom, carefully collecting the shavings from its cap."
	var/harvest_message_high = "You harvest and collect shavings from several mushroom caps."
	var/harvested = FALSE
	var/base_icon
	var/regrowth_time_low = 4800
	var/regrowth_time_high = 8400

/obj/structure/flora/ash/New()
	..()
	base_icon = "[icon_state][rand(1, 4)]"
	icon_state = base_icon
	if(prob(15))
		harvest(null, TRUE)

/obj/structure/flora/ash/proc/harvest(user, no_drop)
	if(harvested)
		return 0
	if(!no_drop)
		var/rand_harvested = rand(harvest_amount_low, harvest_amount_high)
		if(rand_harvested)
			if(user)
				var/msg = harvest_message_med
				if(rand_harvested == harvest_amount_low)
					msg = harvest_message_low
				else if(rand_harvested == harvest_amount_high)
					msg = harvest_message_high
				user << "<span class='notice'>[msg]</span>"
			for(var/i in 1 to rand_harvested)
				new harvest(get_turf(src))
	icon_state = "[base_icon]p"
	name = harvested_name
	desc = harvested_desc
	harvested = TRUE
	addtimer(src, "regrow", rand(regrowth_time_low, regrowth_time_high))
	return 1

/obj/structure/flora/ash/proc/regrow()
	icon_state = base_icon
	name = initial(name)
	desc = initial(desc)
	harvested = FALSE

/obj/structure/flora/ash/attackby(obj/item/weapon/W, mob/user, params)
	if(!harvested && needs_sharp_harvest && W.sharpness)
		user.visible_message("<span class='notice'>[user] starts to harvest from [src] with [W].</span>","<span class='notice'>You begin to harvest from [src] with [W].</span>")
		if(do_after(user, harvest_time, target = src))
			harvest(user)
	else
		return ..()

/obj/structure/flora/ash/attack_hand(mob/user)
	if(!harvested && !needs_sharp_harvest)
		user.visible_message("<span class='notice'>[user] starts to harvest from [src].</span>","<span class='notice'>You begin to harvest from [src].</span>")
		if(do_after(user, harvest_time, target = src))
			harvest(user)
	else
		..()

/obj/structure/flora/ash/leaf_shroom
	icon_state = "s_mushroom"
	name = "leafy mushrooms"
	desc = "A number of mushrooms, each of which surrounds a greenish sporangium with a number of leaf-like structures."
	harvested_name = "leafless mushrooms"
	harvested_desc = "A bunch of formerly-leafed mushrooms, with their sporangiums exposed. Scandalous?"
	harvest = /obj/item/ash_flora/mushroom_leaf
	needs_sharp_harvest = FALSE
	harvest_amount_high = 4
	harvest_time = 20
	harvest_message_low = "You pluck a single, suitable leaf."
	harvest_message_med = "You pluck a number of leaves, leaving a few unsuitable ones."
	harvest_message_high = "You pluck quite a lot of suitable leaves."
	regrowth_time_low = 2400
	regrowth_time_high = 6000

/obj/structure/flora/ash/cap_shroom
	icon_state = "r_mushroom"
	name = "tall mushrooms"
	desc = "Several mushrooms, the larger of which have a ring of conks at the midpoint of their stems."
	harvested_name = "small mushrooms"
	harvested_desc = "Several small mushrooms near the stumps of what likely were larger mushrooms."
	harvest = /obj/item/ash_flora/mushroom_cap
	harvest_amount_high = 4
	harvest_time = 50
	harvest_message_low = "You slice the cap off of a mushroom."
	harvest_message_med = "You slice off a few conks from the larger mushrooms."
	harvest_message_high = "You slice off a number of caps and conks from these mushrooms."
	regrowth_time_low = 3000
	regrowth_time_high = 5400

/obj/structure/flora/ash/stem_shroom
	icon_state = "t_mushroom"
	name = "numerous mushrooms"
	desc = "A large number of mushrooms, some of which have long, fleshy stems."
	harvested_name = "tiny mushrooms"
	harvested_desc = "A few tiny mushrooms around larger stumps. You can already see them growing back."
	harvest = /obj/item/ash_flora/mushroom_stem
	harvest_amount_high = 4
	harvest_time = 40
	harvest_message_low = "You pick and slice the cap off of a mushroom, leaving the stem."
	harvest_message_med = "You pick and decapitate several mushrooms for their stems."
	harvest_message_high = "You acquire a number of stems from these mushrooms."
	regrowth_time_low = 3000
	regrowth_time_high = 6000

/obj/structure/flora/ash/cacti
	icon_state = "cactus"
	name = "fruiting cacti"
	desc = "Several prickly cacti, brimming with ripe fruit and covered in a thin layer of ash."
	harvested_name = "cacti"
	harvested_desc = "A bunch of prickly cacti. You can see fruits slowly growing beneath the covering of ash."
	harvest = /obj/item/ash_flora/cactus_fruit
	needs_sharp_harvest = FALSE
	harvest_amount_high = 2
	harvest_time = 10
	harvest_message_low = "You pick a cactus fruit."
	harvest_message_med = "You pick several cactus fruit." //shouldn't show up, because you can't get more than two
	harvest_message_high = "You pick a pair of cactus fruit."
	regrowth_time_low = 4800
	regrowth_time_high = 7200

/obj/structure/flora/ash/cacti/Crossed(mob/AM)
	if(ishuman(AM) && has_gravity(loc) && prob(70))
		var/mob/living/carbon/human/H = AM
		if(!H.shoes && !H.lying) //ouch, my feet.
			var/picked_def_zone = pick("l_leg", "r_leg")
			var/obj/item/bodypart/O = H.get_bodypart(picked_def_zone)
			if(!istype(O) || (PIERCEIMMUNE in H.dna.species.specflags))
				return
			H.apply_damage(rand(3, 6), BRUTE, picked_def_zone)
			H.Weaken(2)
			H.visible_message("<span class='danger'>[H] steps on a cactus!</span>", \
				"<span class='userdanger'>You step on a cactus!</span>")

/obj/item/ash_flora
	name = "mushroom shavings"
	desc = "Some shavings from a tall mushroom. With enough, might serve as a bowl."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "mushroom_shavings"
	w_class = 1
	burn_state = FLAMMABLE
	burntime = 30
	var/prepared = FALSE
	var/prepared_type = /obj/item/ash_flora/shavings
	var/standard_prep = TRUE

/obj/item/ash_flora/New()
	..()
	pixel_x = rand(-4, 4)
	pixel_y = rand(-4, 4)

/obj/item/ash_flora/attackby(obj/item/weapon/W, mob/user, params)
	if(!standard_prep || !W.sharpness || !prepare(user))
		return ..()

/obj/item/ash_flora/proc/prepare(mob/user)
	if(!prepared)
		prepared = TRUE
		user << "<span class='notice'>You prepare [src].</span>"
		var/obj/item/ash_flora/A = new prepared_type(get_turf(src))
		if(user.is_holding(src))
			user.unEquip(src, TRUE)
			user.put_in_hands(A)
		qdel(src)
		. = 1

/obj/item/ash_flora/shavings //for actual crafting
	prepared = TRUE

/obj/item/ash_flora/mushroom_leaf
	name = "mushroom leaf"
	desc = "A leaflike structure from a mushroom. You should probably wash the ash off."
	icon_state = "mushroom_leaf"
	standard_prep = FALSE
	prepared_type = /obj/item/ash_flora/mushroom_leaf/prepared

/obj/item/ash_flora/mushroom_leaf/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag && (istype(target, /turf/open/floor/plating/ashplanet/wateryrock) || istype(target, /obj/structure/sink)))
		prepare(user)

/obj/item/ash_flora/mushroom_leaf/prepared
	name = "washed mushroom leaf"
	desc = "A greenish leaflike structure from a mushroom. Kind of like lettuce?"
	icon_state = "mushroom_leaf_p"
	prepared = TRUE

/obj/item/ash_flora/mushroom_cap
	name = "mushroom cap"
	desc = "A mushroom cap. Possibly delicious, at least if you cut it up a bit first."
	icon_state = "mushroom_cap"
	prepared_type = /obj/item/ash_flora/mushroom_cap/prepared

/obj/item/ash_flora/mushroom_cap/prepared
	name = "sliced mushroom cap"
	desc = "A sliced-up mushroom cap, revealing pale yellow innards. It smells faintly salty."
	icon_state = "mushroom_cap_p"
	prepared = TRUE

/obj/item/ash_flora/mushroom_stem
	name = "mushroom stem"
	desc = "A mushroom stem. Slice it up, throw it in a stew."
	icon_state = "mushroom_stem"
	prepared_type = /obj/item/ash_flora/mushroom_stem/prepared

/obj/item/ash_flora/mushroom_stem/prepared
	name = "sliced mushroom stem"
	desc = "A mushroom stem, cut in half to reveal orange flesh. Smells almost like potatos, but with a sour undertone."
	icon_state = "mushroom_stem_p"
	prepared = TRUE

/obj/item/ash_flora/cactus_fruit
	name = "cactus fruit"
	desc = "A cactus fruit covered in a thick, reddish skin. And some ash."
	icon_state = "cactus_fruit"
	prepared_type = /obj/item/ash_flora/cactus_fruit/prepared

/obj/item/ash_flora/cactus_fruit/prepared
	name = "peeled cactus fruit"
	desc = "A cactus fruit with the skin and ash carefully scraped off, revealing a faintly sweet-smelling yellow center."
	icon_state = "cactus_fruit_p"
	prepared = TRUE

/obj/item/mushroom_bowl
	name = "mushroom bowl"
	desc = "A bowl made out of mushrooms. Not food, though it might have contained some at some point."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "mushroom_bowl"
	w_class = 2
	burn_state = FLAMMABLE
	burntime = 40

//what you can craft with these things
/datum/crafting_recipe/mushroom_bowl
	name = "Mushroom Bowl"
	result = /obj/item/mushroom_bowl
	reqs = list(/obj/item/ash_flora/shavings = 5)
	time = 30
	//category = CAT_PRIMAL //uncomment once ashplanet exists and this wouldn't just take up space fnr
