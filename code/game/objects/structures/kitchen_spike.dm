
#define SKINTYPE_MONKEY	/obj/item/stack/sheet/animalhide/monkey
#define SKINTYPE_ALIEN	/obj/item/stack/sheet/animalhide/xeno
#define SKINTYPE_BEAR	/obj/item/clothing/head/bearpelt
#define SKINTYPE_CORGI	/obj/item/stack/sheet/animalhide/corgi

#define MEATTYPE_MONKEY	/obj/item/weapon/reagent_containers/food/snacks/meat/slab/monkey
#define MEATTYPE_ALIEN	/obj/item/weapon/reagent_containers/food/snacks/meat/slab/xeno
#define MEATTYPE_BEAR	/obj/item/weapon/reagent_containers/food/snacks/meat/slab/bear
#define MEATTYPE_CORGI	/obj/item/weapon/reagent_containers/food/snacks/meat/slab/corgi

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
	if(occupied)
		if(meat >= 1)
			new meattype(src.loc)
			meat--
			if(meat > 1)
				usr << "<span class='notice'>You remove some meat from [src].</span>"
			return
	if(src.skin >=1)
		new skintype(src.loc)
		skin--
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