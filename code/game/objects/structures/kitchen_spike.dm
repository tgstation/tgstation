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
	buckle_lying = 0
	can_buckle = 1
	var/meat = 0
	var/occupied = 0
	var/meattype = null
	var/skin = 0
	var/skintype = null

	var/global/list/allowed_types = list( //ugh I know it's a whitelist but it's not as god-awful and hacky as before. at least this way it's sustainable. i don't think there's even a better way than this.
		/mob/living/carbon/monkey,
		/mob/living/carbon/alien,
		/mob/living/simple_animal/hostile/bear,
		/mob/living/simple_animal/pet/dog/corgi,
	)

	var/global/list/meatlist = list(
		"monkey"	= MEATTYPE_MONKEY,
		"alien"		= MEATTYPE_ALIEN,
		"bear"		= MEATTYPE_BEAR,
		"corgi"		= MEATTYPE_CORGI,
	)
	var/global/list/skinlist = list(
		"monkey"	= SKINTYPE_MONKEY,
		"alien"		= SKINTYPE_ALIEN,
		"bear"		= SKINTYPE_BEAR,
		"corgi"		= SKINTYPE_CORGI,
	)

/obj/structure/kitchenspike/attack_paw(mob/user)
	return src.attack_hand(usr)

/obj/structure/kitchenspike/proc/is_mob_allowed(var/obj/item/weapon/grab/G)
	for(var/I in allowed_types)
		if(istype(G.affecting, I))
			return I
	return 0

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
		return
	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		var/allowed_type = is_mob_allowed(G)
		if(allowed_type)
			if(!occupied)
				occupied = 1
				meat = 5
				skin = 1

				var/list/affecting_path = text2list("[allowed_type]", "/")		//we want a specific part of the type path for this: the last part of the path in allowed_types
				var/affecting_type = affecting_path[affecting_path.len]			//ex. 1 if affecting.type is /mob/living/carbon/monkey, this will set affecting_type to "monkey"
																				//ex. 2 if affecting.type is /mob/living/carbon/alien/humanoid/queen, this will set affecting_type to "alien"

				//set these vars to the appropriate values based on type
				icon_state = "spikebloody[affecting_type]"
				meattype = meatlist["[affecting_type]"]
				skintype = skinlist["[affecting_type]"]

				var/mob/living/O = G.affecting
				O.visible_message(text("<span class='danger'>[user] has forced [G.affecting] onto the spike, killing them instantly!</span>"))
				qdel(G.affecting)
				qdel(G)
			else
				user << "<span class='danger'>The spike already has something on it; finish collecting its meat first!</span>"
			return
		if(istype(G.affecting, /mob/living/carbon/human))
			if(!occupied)
				if(do_mob(user, src, 50))
					if(occupied) //to prevent spam/queing up attacks
						return
					if(G.affecting.buckled)
						return
					var/mob/living/carbon/human/H = G.affecting
					playsound(src.loc, "sound/effects/splat.ogg", 25, 1)
					H.visible_message("<span class='danger'>[user] slams [G.affecting] onto the meat spike!</span>", "<span class='userdanger'>[user] slams you onto the meat spike!</span>", "<span class='italics'>You hear a squishy wet noise.</span>")
					H.loc = src.loc
					H.emote("scream")
					var/turf/pos = get_turf(H)
					pos.add_blood_floor(H)
					H.adjustBruteLoss(30)
					var/matrix/m120 = matrix()
					m120.Turn(180)
					animate(H, transform = m120, time = 3)
					H.pixel_y = H.get_standard_pixel_y_offset(180)
					occupied = TRUE
					H.buckled = src
					H.dir = 2
					buckled_mob = H
					return
		user << "<span class='danger'>You can't use that on the spike!</span>"
		return
	..()

/obj/structure/kitchenspike/user_buckle_mob(mob/living/M, mob/living/user) //Don't want them getting put on the rack other than by spiking
	return

/obj/structure/kitchenspike/user_unbuckle_mob(mob/living/carbon/human/user)
	if(buckled_mob && buckled_mob.buckled == src)
		var/mob/living/M = buckled_mob
		if(M != user)
			M.visible_message(\
				"[user.name] tries to pull [M.name] free of the [src]!",\
				"<span class='notice'>[user.name] is trying to pull you off the [src], opening up fresh wounds!</span>",\
				"<span class='italics'>You hear a squishy wet noise.</span>")
			M.adjustBruteLoss(20)
			if(!do_after(M, 300, target = src))
				if(M && M.buckled)
					M.visible_message(\
					"[user.name] fails to free [M.name]!",\
					"<span class='notice'>[user.name] fails to pull you off of the [src].</span>")
				return

		else
			M.visible_message(\
			"<span class='warning'>[M.name] struggles to break free from the [src]!</span>",\
			"<span class='notice'>You struggle to break free from the [src], exacerbating your wounds! (Stay still for two minutes.)</span>",\
			"<span class='italics'>You hear a wet squishing noise..</span>")
			M.adjustBruteLoss(30)
			if(!do_after(M, 1200, target = src))
				if(M && M.buckled)
					M << "<span class='warning'>You fail to free yourself!</span>"
				return
		if(!M.buckled)
			return
		var/mob/living/carbon/human/L = buckled_mob
		var/matrix/m120 = matrix()
		m120.Turn(360)
		animate(L, transform = m120, time = 3)
		L.pixel_y = L.get_standard_pixel_y_offset(360)
		M.adjustBruteLoss(20)
		src.visible_message(text("<span class='danger'>[M] falls free of the [src]!</span>"))
		unbuckle_mob()
		L.emote("scream")
		L.AdjustWeakened(10)
		occupied = 0

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
		icon_state = "spike"
		occupied = 0


#undef SKINTYPE_MONKEY
#undef SKINTYPE_ALIEN
#undef SKINTYPE_BEAR
#undef SKINTYPE_CORGI

#undef MEATTYPE_MONKEY
#undef MEATTYPE_ALIEN
#undef MEATTYPE_BEAR
#undef MEATTYPE_CORGI