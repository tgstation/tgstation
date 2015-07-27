
#define SKINTYPE_MONKEY 1
#define SKINTYPE_ALIEN 2
#define SKINTYPE_BEAR 3

#define MEATTYPE_MONKEY 1
#define MEATTYPE_ALIEN 2
#define MEATTYPE_BEAR 3

//////Kitchen Spike

/obj/structure/kitchenspike
	name = "meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals"
	density = 1
	anchored = 1
	var/meat = 0
	var/occupied = 0
	var/meattype = null
	var/skin = 0
	var/skintype = null

/obj/structure/kitchenspike/attack_paw(mob/user)
	return src.attack_hand(usr)

/obj/structure/kitchenspike/attackby(obj/item/weapon/grab/G, mob/user, params)
	if(!istype(G, /obj/item/weapon/grab))
		return
	if(istype(G.affecting, /mob/living/carbon/monkey))
		if(src.occupied == 0)
			src.icon_state = "spikebloody"
			src.occupied = 1
			src.meat = 5
			src.meattype = MEATTYPE_MONKEY
			src.skin = 1
			src.skintype = SKINTYPE_MONKEY
			for(var/mob/O in viewers(src, null))
				O.show_message(text("<span class='danger'>[user] has forced [G.affecting] onto the spike, killing them instantly!</span>"))
			qdel(G.affecting)
			qdel(G)

		else
			user << "<span class='danger'>The spike already has something on it, finish collecting its meat first!</span>"
	else if(istype(G.affecting, /mob/living/carbon/alien))
		if(src.occupied == 0)
			src.icon_state = "spikebloodygreen"
			src.occupied = 1
			src.meat = 5
			src.meattype = MEATTYPE_ALIEN
			src.skin = 1
			src.skintype = SKINTYPE_ALIEN
			for(var/mob/O in viewers(src, null))
				O.show_message(text("<span class='danger'>[user] has forced [G.affecting] onto the spike, killing them instantly!</span>"))
			qdel(G.affecting)
			qdel(G)
		else
			user << "<span class='danger'>The spike already has something on it, finish collecting its meat first!</span>"
	else if(istype(G.affecting, /mob/living/simple_animal/hostile/bear))
		if(src.occupied == 0)
			src.icon_state = "spikebloodybearz"
			src.occupied = 1
			src.meat = 5
			src.meattype = MEATTYPE_BEAR
			src.skin = 1
			src.skintype = SKINTYPE_BEAR
			for(var/mob/O in viewers(src, null))
				O.show_message(text("<span class='danger'>[user] has forced [G.affecting] onto the spike, killing them instantly!</span>"))
			qdel(G.affecting)
			qdel(G)
		else
			user << "<span class='danger'>The spike already has something on it, finish collecting its meat first!</span>"
	else
		user << "<span class='danger'>They are too big for the spike, try something smaller!</span>"
		return

///obj/structure/kitchenspike/MouseDrop_T(var/atom/movable/C, mob/user)
//	if(istype(C, /obj/mob/carbon/monkey)
//	else if(istype(C, /obj/mob/carbon/alien) && !istype(C, /mob/living/carbon/alien/larva/slime))
//	else if(istype(C, /obj/livestock/spesscarp

/obj/structure/kitchenspike/attack_hand(mob/user)
	if(..())
		return
	if(src.occupied)
		if(src.meattype == MEATTYPE_MONKEY && src.skintype == SKINTYPE_MONKEY)
			if(src.skin >= 1)
				src.skin--
				new /obj/item/stack/sheet/animalhide/monkey(src.loc)
				user << "<span class='notice'>You remove the hide from the monkey.</span>"
			else if(src.meat > 1)
				src.meat--
				new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/monkey(src.loc )
				usr << "<span class='notice'>You remove some meat from the monkey.</span>"
			else if(src.meat == 1)
				src.meat--
				new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/monkey(src.loc)
				usr << "<span class='notice'>You remove the last piece of meat from the monkey.</span>"
				src.icon_state = "spike"
				src.occupied = 0
		else if(src.meattype == MEATTYPE_ALIEN && src.skintype == SKINTYPE_ALIEN)
			if(src.skin >= 1)
				src.skin--
				new /obj/item/stack/sheet/animalhide/xeno(src.loc)
				user << "<span class='notice'>You remove the hide from the alien.</span>"
			else if(src.meat > 1)
				src.meat--
				new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/xeno(src.loc )
				usr << "<span class='notice'>You remove some meat from the alien.</span>"
			else if(src.meat == 1)
				src.meat--
				new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/xeno(src.loc)
				usr << "<span class='notice'>You remove the last piece of meat from the alien.</span>"
				src.icon_state = "spike"
				src.occupied = 0
		else if(src.meattype == MEATTYPE_BEAR && src.skintype == SKINTYPE_BEAR)
			if(src.skin >= 1)
				src.skin--
				new /obj/item/clothing/head/bearpelt(src.loc)
				user << "<span class='notice'>You remove the hide from the bear.</span>"
			else if(src.meat > 1)
				src.meat--
				new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/bear(src.loc )
				usr << "<span class='notice'>You remove some meat from the bear.</span>"
			else if(src.meat == 1)
				src.meat--
				new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/bear(src.loc)
				usr << "<span class='notice'>You remove the last piece of meat from the bear.</span>"
				src.icon_state = "spike"
				src.occupied = 0


#undef SKINTYPE_MONKEY
#undef SKINTYPE_ALIEN
#undef SKINTYPE_BEAR

#undef MEATTYPE_MONKEY
#undef MEATTYPE_ALIEN
#undef MEATTYPE_BEAR