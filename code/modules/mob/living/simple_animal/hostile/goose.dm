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
	desc = "It's a sick-looking goose. Probably ate too much maintenance trash."
	gender = MALE
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	gold_core_spawnable = NO_SPAWN
	random_retaliate = FALSE
	var/vomiting = FALSE
	var/datum/action/cooldown/vomit/goosevomit

/mob/living/simple_animal/hostile/retaliate/goose/vomit/Initialize()
	. = ..()
	goosevomit = new()
	goosevomit.Grant(src)

/mob/living/simple_animal/hostile/retaliate/goose/vomit/Destroy()
	QDEL_NULL(goosevomit)
	return ..()

/mob/living/simple_animal/hostile/retaliate/goose/vomit/proc/vomit()
	var/turf/T = get_turf(src)
	playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1) //yes getting the turf twice is necessary fuck off
	T.add_vomit_floor(src)

/mob/living/simple_animal/hostile/retaliate/goose/vomit/proc/vomit_start(duration)
	flick("vomit_start",src)
	vomiting = TRUE
	icon_state = "vomit"
	vomit()
	addtimer(CALLBACK(src, .proc/vomit_end), duration)

/mob/living/simple_animal/hostile/retaliate/goose/vomit/proc/vomit_end()
	flick("vomit_end",src)
	vomiting = FALSE
	icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/retaliate/goose/vomit/Moved(oldLoc, dir)
	. = ..()
	if(vomiting)
		vomit() // its supposed to keep vomiting if you move
		return
	if(prob(0.5))
		vomit_start(25)

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