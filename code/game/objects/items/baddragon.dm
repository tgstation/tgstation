//Buckle up, this is about to get really gay, really fast
//Be glad it's not in the "toys.dm", this way you can just tick the file out

//part of this was lifted from the baseball bat item. Seemed logical.

/obj/item/weapon/dragondildo
	name = "Dragon Dildo"
	desc = "An illegal item produced by the Bad Dragon Syndicate group. Outlawed in all NT regulated space regions. Possession of one is punished by execution."
	icon = 'icons/obj/baddragon.dmi'
	icon_state = "blue_raspberry_m"
	origin_tech = "syndicate=1" //might have to comment this out later. Let's see what happens though.
	slot_flags = SLOT_BELT
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 4
	w_class = 2
	embed_chance = 80 //this is going to get annoying fast, but goddamn
	var/lubbed = 0 //yes, this is happening
	var/procedure = 0
	var/size = 0 //0 for "not generated", 1 for small, 2 for medium, 3 for large

//generate random dildo
/obj/item/weapon/dragondildo/New()
	if(!size)
		if(prob(25))
			qdel(src) //so the placement is a bit more random and people have to actively search for them
		if(prob(75))
			size = 1
		else
			size = 2
		//pick the flavour
	var/model = pick("blue_raspberry_",
						"dragon_grapes_",
						"dragon_strawberry_",
						"dragon_watermellon_",
						"trex_fruitpunch_",
						"trex_pumpkin_",
						"trex_razelberry_",
						"trex_watermelon_",
						"shark_blueberry_",
						"shark_bubblegum_",
						"shark_chillipepper_",
						"shark_wildberry_")
	switch(model)
		if("blue_raspberry_")
			name = "Dragon Dildo: Raspberry"
		if("dragon_grapes_")
			name = "Dragon Dildo: Grape"
		if("dragon_strawberry_")
			name = "Dragon Dildo: Strawberry"
		if("dragon_watermellon_")
			name = "Dragon Dildo: Watermellon"
		if("trex_fruitpunch_")
			name = "T-Rex Dildo: Fruitpunch"
		if("trex_pumpkin_")
			name = "T-Rex Dildo: Pumpkin"
		if("trex_razelberry_")
			name = "T-Rex Dildo: Razelberry"
		if("trex_watermelon_")
			name = "T-Rex Dildo: Watermelon"
		if("shark_blueberry_")
			name = "Shark Dildo: Blue Berry"
		if("shark_bubblegum_")
			name = "Shark Dildo: Bubblegum"
		if("shark_chillipepper_")
			name = "Shark Dildo: Chillipepper"
		if("shark_wildberry_")
			name = "Shark Dildo: Wildberry"
	switch(size)
		if(1)
			model += "s"
			name = "Small " + name
		if(2)
			model += "m"
			name = "Medium " + name
		if(3)
			model += "l"
			name = "Large " + name
	icon_state = model
	//stat changes
	force = 5*size
	throwforce = force

//funtimes
/obj/item/weapon/dragondildo/attack(mob/living/carbon/human/M, mob/user)
	if(in_use)
		return
	if(M.w_uniform)//jumpsuit check
		user << "<span class='warning'>You must remove his jumpsuit!</span>"
		return
	if(!user.a_intent == "help")
		..()
		return
	else

		var/obj/item/organ/limb/chest/C = locate(/obj/item/organ/limb/chest) in M.organs //technically, if you don't have a chest, you don't have a butt either. Real reason: we can only embed things in limbs, not internal organs.
		if(!C)
			user << "<span class='warning'>He has nowhere to insert this!</span>"
			return
		procedure = 1
		user.visible_message("<span class='danger'>[user] begins pushing [src.name] inside [M.name]!</span>", \
					"<span class='userdanger'>You begin to push [src.name] inside [M.name]!</span>")
		if(do_after(user, (24*size)/(1+lubbed), target = M))
			user.drop_item()
			C.embedded_objects |= src
			loc = M
			if(!lubbed)
				src.add_blood(M)//eew
			M.apply_damage((20*size)/(1+lubbed),BRUTE,"groin")
			lubbed = 0
			M.emote("scream")
			user.visible_message("<span class='danger'>[user] inserts [src.name] inside [M.name]!</span>", \
					"<span class='userdanger'>You insert [src.name] inside [M.name]!</span>")
		procedure = 0

//spawners, assign "gen_size" to a fixed number, or leave 0 for random Small or Medium one's.
/obj/item/weapon/dragondildo/spawner
	var/gen_size = 0
	name = "dragon dildo spawner"

/obj/item/weapon/dragondildo/spawner/New()
	var/obj/item/weapon/dragondildo/new_gen = new /obj/item/weapon/dragondildo(src.loc)
	new_gen.size = gen_size
	qdel(src)