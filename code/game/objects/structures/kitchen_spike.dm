
#define SKINTYPE_MONKEY 1
#define SKINTYPE_ALIEN 2
#define SKINTYPE_BEAR 3
#define SKINTYPE_CORGI 4

#define MEATTYPE_MONKEY 1
#define MEATTYPE_ALIEN 2
#define MEATTYPE_BEAR 3
#define MEATTYPE_CORGI 4

//////Kitchen Spike

/obj/structure/kitchenspike_frame
	name = "meatspike frame"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spikeframe"
	desc = "The frame of a meat spike."
	density = 1
	anchored = 0

/obj/structure/kitchenspike_frame/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(default_unfasten_wrench(user, I))
		return
	else if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if(R.get_amount() >= 4)
			R.use(4)
			user << "<span class='notice'>You add spikes to the frame.</span>"
			var/obj/F = new /obj/structure/kitchenspike(src.loc,)
			transfer_fingerprints_to(F)
			qdel(src)

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

/obj/structure/kitchenspike/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/crowbar))
		if(!src.occupied)
			playsound(loc, 'sound/items/Crowbar.ogg', 100, 1)
			if(do_after(user, 20, target = src))
				user << "<span class='notice'>You pry the spikes out of the frame.</span>"
				new /obj/item/stack/rods(loc, 4)
				var/obj/F = new /obj/structure/kitchenspike_frame(src.loc,)
				transfer_fingerprints_to(F)
				qdel(src)
		else
			user << "<span class='notice'>You can't do that while something's on the spike!</span>"
	else if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		if(istype(G.affecting, /mob/living/carbon/monkey) || istype (G.affecting, /mob/living/carbon/alien) || istype (G.affecting, /mob/living/simple_animal/hostile/bear) || istype (G.affecting, /mob/living/simple_animal/pet/dog/corgi))
			if(!src.occupied)
				src.occupied = 1
				src.meat = 5
				src.skin = 1
				if(istype(G.affecting, /mob/living/carbon/monkey))
					src.meattype = MEATTYPE_MONKEY
					src.skintype = SKINTYPE_MONKEY
					src.icon_state = "spikebloody"
				if(istype(G.affecting, /mob/living/carbon/alien))
					src.icon_state = "spikebloodygreen"
					src.meattype = MEATTYPE_ALIEN
					src.skintype = SKINTYPE_ALIEN
				if(istype(G.affecting, /mob/living/simple_animal/hostile/bear))
					src.icon_state = "spikebloodybearz"
					src.meattype = MEATTYPE_BEAR
					src.skintype = SKINTYPE_BEAR
				if(istype(G.affecting, /mob/living/simple_animal/pet/dog/corgi))
					src.icon_state = "spikecorgi"
					src.meattype = MEATTYPE_CORGI
					src.skintype = SKINTYPE_CORGI
					var/mob/living/O = G.affecting
					O.show_message(text("<span class='danger'>[user] has forced [G.affecting] onto the spike, killing them instantly!</span>"))
				qdel(G.affecting)
				qdel(G)
			else
				user << "<span class='danger'>The spike already has something on it, finish collecting its meat first!</span>"
		else if(istype(G.affecting, /mob/living/carbon/human))
			user.changeNext_move(CLICK_CD_MELEE)
			playsound(src.loc, "sound/effects/splat.ogg", 25, 1)
			var/mob/living/carbon/human/H = G.affecting
			H.visible_message("<span class='danger'>[user] slams [G.affecting] into the meat spike!</span>", "<span class='userdanger'>[user] slams you into the meat spike!</span>", "<span class='italics'>You hear a squishy wet noise.</span>")
			H.adjustBruteLoss(20)
		else
			user << "<span class='danger'>You can't use that on the spike!</span>"
			return
	else
		..()

///obj/structure/kitchenspike/MouseDrop_T(var/atom/movable/C, mob/user)
//	if(istype(C, /obj/mob/carbon/monkey)
//	else if(istype(C, /obj/mob/carbon/alien) && !istype(C, /mob/living/carbon/alien/larva/slime))
//	else if(istype(C, /obj/livestock/spesscarp

/obj/structure/kitchenspike/attack_hand(mob/user)
	if(..())
		return
	if(src.occupied)
		if (src.meat > 1)
			switch(src.meattype)
				if(MEATTYPE_MONKEY)
					new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/monkey(src.loc )
				if(MEATTYPE_ALIEN)
					new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/xeno(src.loc )
				if(MEATTYPE_BEAR)
					new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/bear(src.loc )
				if(MEATTYPE_CORGI)
					new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/corgi(src.loc )
			src.meat--
			usr << "<span class='notice'>You remove some meat from [src].</span>"
		else if (src.meat == 1)
			switch(src.meattype)
				if(MEATTYPE_MONKEY)
					new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/monkey(src.loc)
				if(MEATTYPE_ALIEN)
					new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/xeno(src.loc)
				if(MEATTYPE_BEAR)
					new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/bear(src.loc)
				if(MEATTYPE_CORGI)
					new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/corgi(src.loc)
			src.meat--
		else if(src.skin >=1)
			switch(src.skintype)
				if(SKINTYPE_MONKEY)
					new /obj/item/stack/sheet/animalhide/monkey(src.loc)
				if(SKINTYPE_ALIEN)
					new /obj/item/stack/sheet/animalhide/xeno(src.loc)
				if(SKINTYPE_BEAR)
					new /obj/item/clothing/head/bearpelt(src.loc)
				if(SKINTYPE_CORGI)
					new	/obj/item/stack/sheet/animalhide/corgi(src.loc)
			src.skin--
			usr << "<span class='notice'>You remove the hide from [src].</span>"
			src.icon_state = "spike"
			src.occupied = 0


#undef SKINTYPE_MONKEY
#undef SKINTYPE_ALIEN
#undef SKINTYPE_BEAR
#undef SKINTYPE_CORGI

#undef MEATTYPE_MONKEY
#undef MEATTYPE_ALIEN
#undef MEATTYPE_BEAR
#undef MEATTYPE_CORGI