/obj/machinery/wish_granter/attack_hand(mob/living/carbon/user)
	if(charges <= 0)
		to_chat(user, "The Wish Granter lies silent.")
		return

	else if(!ishuman(user))
		to_chat(user, "You feel a dark stirring inside of the Wish Granter, something you want nothing of. Your instincts are better than any man's.")
		return

	else if (!insisting)
		to_chat(user, "Your first touch makes the Wish Granter stir, listening to you.  Are you really sure you want to do this?")
		insisting++

	else
		if(is_special_character(user))
			to_chat(user, "You speak.  [pick("I want power","Humanity is corrupt, mankind must be destroyed", "I want to rule the world","I want immortality")].  The Wish Granter answers.")
			to_chat(user, "Your head pounds for a moment, before your vision clears. The Wish Granter, sensing the darkness in your heart, has given you limitless power, and it's all yours!")
			user.dna.add_mutation(HULK)
			user.dna.add_mutation(XRAY)
			user.dna.add_mutation(COLDRES)
			user.dna.add_mutation(TK)
			user.next_move_modifier *= 0.5	//half the delay between attacks!
			to_chat(user, "Things around you feel slower!")
			charges--
			insisting = FALSE
			to_chat(user, "You have a very great feeling about this!")
		else
			to_chat(user, "The Wish Granter awaits your wish.")
			var/wish = input("You want...","Wish") as null|anything in list("Power","Wealth","The Station To Disappear","To Kill","Nothing")
			switch(wish)
				if("Power")	//Gives infinite power in exchange for infinite power going off in your face!
					if(charges <= 0)
						return
					to_chat(user, "<B>Your wish is granted, but at a terrible cost...</B>")
					to_chat(user, "The Wish Granter punishes you for your selfishness, warping itself into a delaminating supermatter shard!")
					var/obj/item/stock_parts/cell/infinite/powah = new /obj/item/stock_parts/cell/infinite(get_turf(user))
					if(user.put_in_hands(powah))
						to_chat(user, "[powah] materializes into your hands!")
					else
						to_chat(user, "[powah] materializes onto the floor.")
					var/obj/machinery/power/supermatter_crystal/powerwish = new /obj/machinery/power/supermatter_crystal(loc)
					powerwish.damage = 700	//right at the emergency threshold
					powerwish.produces_gas = FALSE
					charges--
					insisting = FALSE
					if(!charges)
						qdel(src)
				if("Wealth")	//Gives 1 million space bucks in exchange for being turned into gold!
					if(charges <= 0)
						return
					to_chat(user, "<B>Your wish is granted, but at a cost...</B>")
					to_chat(user, "The Wish Granter punishes you for your selfishness, warping your body to match the greed in your heart.")
					new /obj/structure/closet/crate/trashcart/moneywish(loc)
					new /obj/structure/closet/crate/trashcart/moneywish(loc)
					user.set_species(/datum/species/golem/gold)
					charges--
					insisting = FALSE
					if(!charges)
						qdel(src)
				if("The Station To Disappear")	//teleports you to the station and makes you blind, making the station disappear for you!
					if(charges <= 0)
						return
					to_chat(user, "<B>Your wish is 'granted', but at a terrible cost...</B>")
					to_chat(user, "The Wish Granter punishes you for your selfishness, claiming your soul and warping your eyes to match the darkness in your heart.")
					user.dna.add_mutation(BLINDMUT)
					user.adjust_eye_damage(100)
					var/list/destinations = list()
					for(var/obj/item/beacon/B in GLOB.teleportbeacons)
						var/turf/T = get_turf(B)
						if(is_station_level(T.z))
							destinations += B
					var/chosen_beacon = pick(destinations)
					var/obj/effect/portal/jaunt_tunnel/J = new (get_turf(src), src, 100, null, FALSE, get_turf(chosen_beacon))
					try_move_adjacent(J)
					playsound(src,'sound/effects/sparks4.ogg',50,1)
					charges--
					insisting = FALSE
					if(!charges)
						qdel(src)
				if("To Kill")	//Makes you kill things in exchange for rewards!
					if(charges <= 0)
						return
					to_chat(user, "<B>Your wish is granted, but at a terrible cost...</B>")
					to_chat(user, "The Wish Granter punishes you for your wickedness, warping itself into a dastardly creature for you to kill! ...but it almost seems to reward you for this.")
					var/obj/item/melee/transforming/energy/sword/cx/killreward = new /obj/item/melee/transforming/energy/sword/cx(get_turf(user))
					if(user.put_in_hands(killreward))
						to_chat(user, "[killreward] materializes into your hands!")
					else
						to_chat(user, "[killreward] materializes onto the floor.")
					user.next_move_modifier *= 0.8	//20% less delay between attacks!
					to_chat(user, "Things around you feel slightly slower!")
					var/mob/living/simple_animal/hostile/venus_human_trap/killwish = new /mob/living/simple_animal/hostile/venus_human_trap(loc)
					killwish.maxHealth = 1500
					killwish.health = killwish.maxHealth
					killwish.grasp_range = 6
					killwish.melee_damage_upper = 30
					killwish.grasp_chance = 50
					killwish.loot = list(/obj/item/twohanded/hypereutactic)
					charges--
					insisting = FALSE
					if(!charges)
						qdel(src)
				if("Nothing")	//Makes the wish granter disappear
					if(charges <= 0)
						return
					to_chat(user, "<B>The Wish Granter vanishes from sight!</B>")
					to_chat(user, "You feel as if you just narrowly avoided a terrible fate...")
					charges--
					insisting = FALSE
					qdel(src)

//ITEMS THAT IT USES

/obj/structure/closet/crate/trashcart/moneywish
	desc = "A heavy, metal trashcart with wheels. Filled with cash."
	name = "loaded trash cart"

/obj/structure/closet/crate/trashcart/moneywish/PopulateContents()	//25*20*1000=500,000
	for(var/i = 0, i < 25, i++)
		var/obj/item/stack/spacecash/c1000/lodsamoney = new /obj/item/stack/spacecash/c1000(src)
		lodsamoney.amount = lodsamoney.max_amount
