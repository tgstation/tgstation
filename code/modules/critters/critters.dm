/obj/effect/critter/creature
	name = "creature"
	desc = "A sanity-destroying otherthing."
	icon = 'otherthing.dmi'
	icon_state = "otherthing"
	health = 80
	max_health = 80
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = 1
	atkcarbon = 1
	atksilicon = 1
	atkcritter = 1
	atkmech = 1
	atksame = 1
	firevuln = 1
	brutevuln = 1
	melee_damage_lower = 25
	melee_damage_upper = 50
	angertext = "runs"
	attacktext = "chomps"
	attack_sound = 'bite.ogg'


/obj/effect/critter/roach
	name = "cockroach"
	desc = "An unpleasant insect that lives in filthy places."
	icon_state = "roach"
	health = 5
	max_health = 5
	aggressive = 0
	defensive = 1
	wanderer = 1
	atkcarbon = 1
	atksilicon = 0
	attacktext = "bites"

	Die()
		..()
		del(src)


/obj/effect/critter/killertomato
	name = "killer tomato"
	desc = "Oh shit, you're really fucked now."
	icon_state = "killertomato"
	health = 15
	max_health = 15
	aggressive = 1
	defensive = 0
	wanderer = 1
	atkcarbon = 1
	atksilicon = 1
	firevuln = 2
	brutevuln = 2


	Harvest(var/obj/item/weapon/W, var/mob/living/user)
		if(..())
			var/success = 0
			if(istype(W, /obj/item/weapon/butch))
				new /obj/item/weapon/reagent_containers/food/snacks/tomatomeat(src)
				success = 1
			if(istype(W, /obj/item/weapon/kitchenknife))
				new /obj/item/weapon/reagent_containers/food/snacks/tomatomeat(src)
				new /obj/item/weapon/reagent_containers/food/snacks/tomatomeat(src)
				success = 1
			if(success)
				for(var/mob/O in viewers(src, null))
					O.show_message("\red [user.name] cuts apart the [src.name]!", 1)
				del(src)
				return 1
			return 0



/obj/effect/critter/spore
	name = "plasma spore"
	desc = "A barely intelligent colony of organisms. Very volatile."
	icon_state = "spore"
	density = 1
	health = 1
	max_health = 1
	aggressive = 0
	defensive = 0
	wanderer = 1
	atkcarbon = 0
	atksilicon = 0
	firevuln = 2
	brutevuln = 2


	Die()
		src.visible_message("<b>[src]</b> ruptures and explodes!")
		src.alive = 0
		var/turf/T = get_turf(src.loc)
		if(T)
			T.hotspot_expose(700,125)
			explosion(T, -1, -1, 2, 3)
		del src


	ex_act(severity)
		src.Die()


/obj/effect/critter/blob
	name = "blob"
	desc = "Some blob thing."
	icon_state = "blob"
	pass_flags = PASSBLOB
	health = 20
	max_health = 20
	aggressive = 1
	defensive = 0
	wanderer = 1
	atkcarbon = 1
	atksilicon = 1
	firevuln = 2
	brutevuln = 0.5
	melee_damage_lower = 2
	melee_damage_upper = 8
	angertext = "charges"
	attacktext = "hits"
	attack_sound = 'genhit1.ogg'

	Die()
		..()
		del(src)



/obj/effect/critter/spesscarp
	name = "Spess Carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon_state = "spesscarp"
	health = 100
	max_health = 100
	aggressive = 1
	aggression = 20
	defensive = 1
	wanderer = 1
	atkcarbon = 1
	atksilicon = 1
	atkcritter = 1
	atkmech = 1
	firevuln = 2
	brutevuln = 1
	melee_damage_lower = 5
	melee_damage_upper = 15
	angertext = "lunges"
	attacktext = "bites"
	attack_sound = 'bite.ogg'
	attack_speed = 10
	speed = 8
	chasespeed = 8
	var/stunchance = 10 // chance to tackle things down


//TEMPORARY
	New()
		..()
		spawn(0)
			del(src)
//TEMPORARY


	Harvest(var/obj/item/weapon/W, var/mob/living/user)
		if(..())
			var/success = 0
			if(istype(W, /obj/item/weapon/butch))
				new/obj/item/weapon/reagent_containers/food/snacks/carpmeat(src.loc)
				new/obj/item/weapon/reagent_containers/food/snacks/carpmeat(src.loc)
				success = 1
			if(istype(W, /obj/item/weapon/kitchenknife))
				new/obj/item/weapon/reagent_containers/food/snacks/carpmeat(src.loc)
				success = 1
			if(success)
				for(var/mob/O in viewers(src, null))
					O.show_message("\red [user.name] cuts apart the [src.name]!", 1)
				del(src)
				return 1
			return 0

	AfterAttack(var/mob/living/target)
		if(prob(stunchance))
			if(target.weakened <= 0)
				target.Weaken(rand(10, 15))
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[src]</B> knocks down [target]!", 1)
				playsound(loc, 'pierce.ogg', 25, 1, -1)



/obj/effect/critter/spesscarp/elite
	desc = "Oh shit, you're really fucked now. It has an evil gleam in its eye."
	health = 200
	max_health = 200
	melee_damage_lower = 20
	melee_damage_upper = 35
	stunchance = 15
	attack_speed = 7
//	opensdoors = 1 would give all access dono if want



/obj/effect/critter/walkingmushroom
	name = "Walking Mushroom"
	desc = "A...huge...mushroom...with legs!?"
	icon_state = "walkingmushroom"
	health = 15
	max_health = 15
	aggressive = 0
	defensive = 0
	wanderer = 1
	atkcarbon = 0
	atksilicon = 0
	firevuln = 2
	brutevuln = 1
	wanderspeed = 1


	Harvest(var/obj/item/weapon/W, var/mob/living/user)
		if(..())
			var/success = 0
			if(istype(W, /obj/item/weapon/butch))
				new /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice(src.loc)
				new /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice(src.loc)
				success = 1
			if(istype(W, /obj/item/weapon/kitchenknife))
				new /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice(src.loc)
				success = 1
			if(success)
				for(var/mob/O in viewers(src, null))
					O.show_message("\red [user.name] cuts apart the [src.name]!", 1)
				del(src)
				return 1
			return 0



/obj/effect/critter/lizard
	name = "Lizard"
	desc = "A cute tiny lizard."
	icon_state = "lizard"
	health = 5
	max_health = 5
	aggressive = 0
	defensive = 1
	wanderer = 1
	opensdoors = 0
	atkcarbon = 1
	atksilicon = 1
	attacktext = "bites"
