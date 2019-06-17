/mob/living/simple_animal/hostile/retaliate/goose
	name = "goose"
	desc = "It's loose"
	icon_state = "goose" // sprites by cogwerks from goonstation, used with permission
	icon_living = "goose"
	icon_dead = "goose_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_chance = 0
	turns_per_move = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 2)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"
	emote_taunt = list("hisses")
	taunt_chance = 30
	speed = 0
	maxHealth = 25
	health = 25
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "pecks"
	attack_sound = "goose"
	speak_emote = list("honks")
	faction = list("neutral")
	attack_same = TRUE
	gold_core_spawnable = HOSTILE_SPAWN
	var/random_retaliate = TRUE
	var/icon_vomit_start = "vomit_start"
	var/icon_vomit = "vomit"
	var/icon_vomit_end = "vomit_end"

/mob/living/simple_animal/hostile/retaliate/goose/handle_automated_movement()
	. = ..()
	if(prob(5) && random_retaliate == TRUE)
		Retaliate()

/mob/living/simple_animal/hostile/retaliate/goose/vomit //https://cdn.discordapp.com/attachments/429431032228610058/585549032177401857/vomitgoose.png
	name = "Birdboat"
	real_name = "Birdboat"
	desc = "It's a sick-looking goose, probably ate too much maintenance trash. Best not to move it around too much."
	gender = MALE
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	gold_core_spawnable = NO_SPAWN
	random_retaliate = FALSE
	var/vomiting = FALSE
	var/vomitCoefficient = 1
	var/vomitTimeBonus = 0
	var/datum/action/cooldown/vomit/goosevomit

/mob/living/simple_animal/hostile/retaliate/goose/vomit/Initialize()
	. = ..()
	goosevomit = new()
	goosevomit.Grant(src)

/mob/living/simple_animal/hostile/retaliate/goose/vomit/Destroy()
	QDEL_NULL(goosevomit)
	return ..()

/mob/living/simple_animal/hostile/retaliate/goose/vomit/examine(user)
	..()
	to_chat(user, "<span class='notice'>Somehow, it still looks hungry.</span>")

/mob/living/simple_animal/hostile/retaliate/goose/vomit/attacked_by(obj/item/O, mob/user)
	feed(O)

/mob/living/simple_animal/hostile/retaliate/goose/vomit/proc/feed(obj/item/O)
	if(istype(O, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/tasty = O
		if (tasty.foodtype & GROSS)
			visible_message("<span class='notice'>[src] hungrily gobbles up \the [tasty]!</span>")
			tasty.forceMove(src)
			playsound(src,'sound/items/eatfood.ogg', 70, 1)
			vomitCoefficient ++
			vomitTimeBonus += 5
		else
			visible_message("<span class='notice'>[src] refuses to eat \the [tasty].</span>")

/mob/living/simple_animal/hostile/retaliate/goose/vomit/proc/vomit()
	var/turf/T = get_turf(src)
	var/obj/item/reagent_containers/food/consumed = locate() in contents //Barf out a single food item from our guts
	if (prob(50) && consumed)
		barf_food(consumed)
	else
		playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1) //yes getting the turf twice is necessary fuck off
		T.add_vomit_floor(src)
		
/mob/living/simple_animal/hostile/retaliate/goose/vomit/proc/barf_food(var/atom/A)
	if(istype(A, /obj/item/reagent_containers/food))
		var/turf/T = get_turf(src)
		var/obj/item/reagent_containers/food/consumed = A
		consumed.forceMove(T)
		var/destination = get_edge_target_turf(T, pick(GLOB.alldirs)) //Pick a random direction to toss them in
		consumed.throw_at(destination, 1, 2) //Thow the food at a random tile 1 spot away
		var/turf/T = get_turf(consumed)
		T.add_vomit_floor(src)
		playsound(get_turf(consumed), 'sound/effects/splat.ogg', 50, 1) //yes getting the turf twice is necessary fuck off

/mob/living/simple_animal/hostile/retaliate/goose/vomit/proc/vomit_start(duration)
	flick("vomit_start",src)
	vomiting = TRUE
	icon_state = "vomit"
	vomit()
	addtimer(CALLBACK(src, .proc/vomit_end), duration)

/mob/living/simple_animal/hostile/retaliate/goose/vomit/proc/vomit_end()
	for (var/obj/item/consumed in contents) //Get rid of any food left in the poor thing
		barf_food(consumed)
	flick("vomit_end",src)
	vomiting = FALSE
	icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/retaliate/goose/vomit/Moved(oldLoc, dir)
	. = ..()
	if(vomiting)
		vomit() // its supposed to keep vomiting if you move
		return
	for (var/atom/tasty in get_turf(src))
		feed(tasty)
	if(prob(vomitCoefficient * 0.5))	
		vomit_start(vomitTimeBonus + 25)
		vomitCoefficient = 1
		vomitTimeBonus = 0

/datum/action/cooldown/vomit
	name = "Vomit"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "vomit"
	icon_icon = 'icons/mob/animal.dmi'
	cooldown_time = 250

/datum/action/cooldown/vomit/Trigger()
	if(!..())
		return FALSE
	if(!istype(owner, /mob/living/simple_animal/hostile/retaliate/goose/vomit))
		return FALSE
	var/mob/living/simple_animal/hostile/retaliate/goose/vomit/vomit = owner
	if(!vomit.vomiting)
		vomit.vomit_start(25)
	return TRUE