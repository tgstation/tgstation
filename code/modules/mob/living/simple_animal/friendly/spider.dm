/mob/living/simple_animal/spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon_state = "spiderling"
	icon_living = "spiderling"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	maxHealth = 3
	health = 3
	speed = 0
	turns_per_move = 1
	harm_intent_damage = 1
	friendly = "nudges"
	response_help = "shoos"
	response_disarm = "brushes aside"
	response_harm = "squashes"
	speak_emote = list("chitters")
	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	gold_core_spawnable = FRIENDLY_SPAWN
	verb_say = "chitters"
	verb_ask = "chitters inquisitively"
	verb_exclaim = "chitters intensely"
	verb_yell = "chitters intensely"
	faction = list("spiders")
	del_on_death = TRUE
	loot = list(/obj/item/reagent_containers/food/snacks/spiderling)

	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent
	var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent
	var/travelling_in_vent = 0

/mob/living/simple_animal/spiderling/Initialize()
	. = ..()
	pixel_x = rand(6,-6)
	pixel_y = rand(6,-6)
	AddComponent(/datum/component/swarming)

/mob/living/simple_animal/spiderling/proc/start_enter_vent()
	var/list/vents = list()
	var/datum/pipeline/entry_vent_parent = entry_vent.parents[1]
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in entry_vent_parent.other_atmosmch)
		vents.Add(temp_vent)
	if(!vents.len)
		entry_vent = null
		return
	exit_vent = pick(vents)
	if(prob(50))
		visible_message("<span class='warning'>[src] scrambles into the ventilation ducts!</span>", \
						"<span class='warning'>You hear something scampering through the ventilation ducts.</span>")
	addtimer(CALLBACK(src, .proc/enter_vent), rand(20,60))

/mob/living/simple_animal/spiderling/proc/enter_vent()
	travelling_in_vent = TRUE
	forceMove(entry_vent)
	var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
	addtimer(CALLBACK(src, .proc/travel_vent), travel_time)

/mob/living/simple_animal/spiderling/proc/travel_vent()
	if(!exit_vent || exit_vent.welded)
		forceMove(entry_vent)
		entry_vent = null
		travelling_in_vent = FALSE
		return
	if(prob(50))
		exit_vent.audible_message("<span class='warning'>You hear something scampering through the ventilation ducts.</span>")
	forceMove(exit_vent)
	addtimer(CALLBACK(src, .proc/exit_vent), rand(20,60))

/mob/living/simple_animal/spiderling/proc/exit_vent()
	if(!exit_vent || exit_vent.welded)
		forceMove(entry_vent)
		entry_vent = null
		travelling_in_vent = FALSE
		return
	forceMove(get_turf(exit_vent))
	travelling_in_vent = FALSE
	entry_vent = null
	exit_vent = null
	var/area/new_area = get_area(src)
	if(new_area)
		new_area.Entered(src)

/mob/living/simple_animal/spiderling/handle_automated_movement()
	if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			start_enter_vent()
	//=================

	else if(prob(10))
		//ventcrawl!
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/v in view(7,src))
			if(!v.welded)
				entry_vent = v
				walk_to(src, entry_vent, 1)
				break
	else
		..()

//eventually grows into a giant spider
/mob/living/simple_animal/spiderling/giant
	var/grow_as = null
	var/amount_grown = 0
	var/player_controlled = FALSE
	var/grown_poison_type = "toxin"
	var/grown_poison_per_bite = 5
	var/directive = "" //Message from the mother
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/spiderling/giant/Life()
	..()
	if(isturf(loc))
		amount_grown += rand(0,2)
		if(amount_grown >= 100)
			if(!grow_as)
				if(prob(3))
					grow_as = pick(/mob/living/simple_animal/hostile/poison/giant_spider/tarantula, /mob/living/simple_animal/hostile/poison/giant_spider/hunter/viper, /mob/living/simple_animal/hostile/poison/giant_spider/nurse/midwife)
				else
					grow_as = pick(/mob/living/simple_animal/hostile/poison/giant_spider, /mob/living/simple_animal/hostile/poison/giant_spider/hunter, /mob/living/simple_animal/hostile/poison/giant_spider/nurse)
			var/mob/living/simple_animal/hostile/poison/giant_spider/S = new grow_as(src.loc)
			S.poison_per_bite = grown_poison_per_bite
			S.poison_type = grown_poison_type
			S.faction = faction.Copy()
			S.directive = directive
			if(player_controlled)
				S.playable_spider = TRUE
				notify_ghosts("Spider [S.name] can be controlled", null, enter_link="<a href=?src=[REF(S)];activate=1>(Click to play)</a>", source=S, action=NOTIFY_ATTACK)
			qdel(src)

/mob/living/simple_animal/spiderling/giant/hunter
	grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/hunter

/mob/living/simple_animal/spiderling/giant/nurse
	grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/nurse

/mob/living/simple_animal/spiderling/giant/midwife
	grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/nurse/midwife

/mob/living/simple_animal/spiderling/giant/viper
	grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/hunter/viper

/mob/living/simple_animal/spiderling/giant/tarantula
	grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/tarantula