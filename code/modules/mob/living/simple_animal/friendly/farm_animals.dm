//goat
/mob/living/simple_animal/hostile/retaliate/goat
	name = "goat"
	desc = "Not known for their pleasant disposition."
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"
	speak = list("EHEHEHEHEH","eh?")
	speak_emote = list("brays")
	emote_hear = list("brays")
	emote_see = list("shakes its head", "stamps a foot", "glares around")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/slab
	meat_amount = 4
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	faction = list("neutral")
	attack_same = 1
	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 40
	melee_damage_lower = 1
	melee_damage_upper = 2
	environment_smash = 0
	stop_automated_movement_when_pulled = 1
	var/datum/reagents/udder = null

/mob/living/simple_animal/hostile/retaliate/goat/New()
	udder = new(50)
	udder.my_atom = src
	..()

/mob/living/simple_animal/hostile/retaliate/goat/Life()
	. = ..()
	if(.)
		//chance to go crazy and start wacking stuff
		if(!enemies.len && prob(1))
			Retaliate()

		if(enemies.len && prob(10))
			enemies = list()
			LoseTarget()
			src.visible_message("<span class='notice'>[src] calms down.</span>")

	if(stat == CONSCIOUS)
		if(udder && prob(5))
			udder.add_reagent("milk", rand(5, 10))

		if(locate(/obj/effect/spacevine) in loc)
			var/obj/effect/spacevine/SV = locate(/obj/effect/spacevine) in loc
			SV.eat(src)

		if(!pulledby)
			for(var/direction in shuffle(list(1,2,4,8,5,6,9,10)))
				var/step = get_step(src, direction)
				if(step)
					if(locate(/obj/effect/spacevine) in step)
						Move(step, get_dir(src, step))

/mob/living/simple_animal/hostile/retaliate/goat/Retaliate()
	..()
	src.visible_message("<span class='danger'>[src] gets an evil-looking gleam in \his eye.</span>")

/mob/living/simple_animal/hostile/retaliate/goat/Move()
	..()
	if(!stat)
		if(locate(/obj/effect/spacevine) in loc)
			var/obj/effect/spacevine/SV = locate(/obj/effect/spacevine) in loc
			SV.eat(src)


/mob/living/simple_animal/hostile/retaliate/goat/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(stat == CONSCIOUS && istype(O, /obj/item/weapon/reagent_containers/glass))
		user.visible_message("<span class='notice'>[user] milks [src] using \the [O].</span>")
		var/obj/item/weapon/reagent_containers/glass/G = O
		var/transfered = udder.trans_id_to(G, "milk", rand(5,10))
		if(G.reagents.total_volume >= G.volume)
			user << "<span class='danger'>[O] is full.</span>"
		if(!transfered)
			user << "<span class='danger'>The udder is dry. Wait a bit longer...</span>"
	else
		..()
//cow
/mob/living/simple_animal/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	speak = list("moo?","moo","MOOOOOO")
	speak_emote = list("moos","moos hauntingly")
	emote_hear = list("brays")
	emote_see = list("shakes its head")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/slab
	meat_amount = 6
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 50
	var/datum/reagents/udder = null

/mob/living/simple_animal/cow/New()
	udder = new(50)
	udder.my_atom = src
	..()

/mob/living/simple_animal/cow/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(stat == CONSCIOUS && istype(O, /obj/item/weapon/reagent_containers/glass))
		user.visible_message("<span class='notice'>[user] milks [src] using \the [O].</span>")
		var/obj/item/weapon/reagent_containers/glass/G = O
		var/transfered = udder.trans_id_to(G, "milk", rand(5,10))
		if(G.reagents.total_volume >= G.volume)
			user << "<span class='danger'>[O] is full.</span>"
		if(!transfered)
			user << "<span class='danger'>The udder is dry. Wait a bit longer...</span>"
	else
		..()

/mob/living/simple_animal/cow/Life()
	. = ..()
	if(stat == CONSCIOUS)
		if(udder && prob(5))
			udder.add_reagent("milk", rand(5, 10))

/mob/living/simple_animal/cow/attack_hand(mob/living/carbon/M as mob)
	if(!stat && M.a_intent == "disarm" && icon_state != icon_dead)
		M.visible_message("<span class='warning'>[M] tips over [src].</span>","<span class='notice'>You tip over [src].</span>")
		Weaken(30)
		icon_state = icon_dead
		spawn(rand(20,50))
			if(!stat && M)
				icon_state = icon_living
				var/list/responses = list(	"[src] looks at you imploringly.",
											"[src] looks at you pleadingly",
											"[src] looks at you with a resigned expression.",
											"[src] seems resigned to its fate.")
				M << pick(responses)
	else
		..()

/mob/living/simple_animal/chick
	name = "\improper chick"
	desc = "Adorable! They make such a racket though."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	speak = list("Cherp.","Cherp?","Chirrup.","Cheep!")
	speak_emote = list("cheeps")
	emote_hear = list("cheeps")
	emote_see = list("pecks at the ground","flaps its tiny wings")
	density = 0
	speak_chance = 2
	turns_per_move = 2
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/slab
	meat_amount = 1
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 1
	ventcrawler = 2
	var/amount_grown = 0
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY

/mob/living/simple_animal/chick/New()
	..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)

/mob/living/simple_animal/chick/Life()
	. =..()
	if(!.)
		return
	if(!stat && !ckey)
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			new /mob/living/simple_animal/chicken(src.loc)
			qdel(src)

var/const/MAX_CHICKENS = 50
var/global/chicken_count = 0

/mob/living/simple_animal/chicken
	name = "\improper chicken"
	desc = "Hopefully the eggs are good this season."
	icon_state = "chicken"
	icon_living = "chicken"
	icon_dead = "chicken_dead"
	speak = list("Cluck!","BWAAAAARK BWAK BWAK BWAK!","Bwaak bwak.")
	speak_emote = list("clucks","croons")
	emote_hear = list("clucks")
	emote_see = list("pecks at the ground","flaps its wings viciously")
	density = 0
	speak_chance = 2
	turns_per_move = 3
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/slab
	var/egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg
	var/food_type = /obj/item/weapon/reagent_containers/food/snacks/grown/wheat
	meat_amount = 2
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 10
	ventcrawler = 2
	var/eggsleft = 0
	var/eggsFertile = TRUE
	var/body_color
	var/icon_prefix = "chicken"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	var/list/feedMessages = list("It clucks happily.","It clucks happily.")
	var/list/layMessage = list("lays an egg.","squats down and croons.","begins making a huge racket.","begins clucking raucously.")
	var/list/validColors = list("brown","black","white")

/mob/living/simple_animal/chicken/New()
	..()
	if(!body_color)
		body_color = pick(validColors)
	icon_state = "[icon_prefix]_[body_color]"
	icon_living = "[icon_prefix]_[body_color]"
	icon_dead = "[icon_prefix]_[body_color]_dead"
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)
	chicken_count += 1

/mob/living/simple_animal/chicken/death(gibbed)
	..(gibbed)
	chicken_count -= 1

/mob/living/simple_animal/chicken/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(istype(O, food_type)) //feedin' dem chickens
		if(!stat && eggsleft < 8)
			var/feedmsg = "<span class='notice'>[user] feeds [O] to [name]! [pick(feedMessages)]"
			user.visible_message(feedmsg)
			user.drop_item()
			qdel(O)
			eggsleft += rand(1, 4)
			//world << eggsleft
		else
			user << "<span class='notice'>[name] doesn't seem hungry!</span>"
	else
		..()

/mob/living/simple_animal/chicken/Life()
	. =..()
	if(!.)
		return
	if(!stat && prob(3) && eggsleft > 0)
		visible_message("[src] [pick(layMessage)]")
		eggsleft--
		var/obj/item/E = new egg_type(get_turf(src))
		E.pixel_x = rand(-6,6)
		E.pixel_y = rand(-6,6)
		if(eggsFertile)
			if(chicken_count < MAX_CHICKENS && prob(25))
				SSobj.processing |= E

/obj/item/weapon/reagent_containers/food/snacks/egg/var/amount_grown = 0
/obj/item/weapon/reagent_containers/food/snacks/egg/process()
	if(isturf(loc))
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			visible_message("[src] hatches with a quiet cracking sound.")
			new /mob/living/simple_animal/chick(get_turf(src))
			SSobj.processing.Remove(src)
			qdel(src)
	else
		SSobj.processing.Remove(src)
