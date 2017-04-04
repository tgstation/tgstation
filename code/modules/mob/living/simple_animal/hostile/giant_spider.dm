
#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

/mob/living/simple_animal/hostile/poison
	var/poison_per_bite = 5
	var/poison_type = "toxin"

/mob/living/simple_animal/hostile/poison/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			L.reagents.add_reagent(poison_type, poison_per_bite)



//basic spider mob, these generally guard nests
/mob/living/simple_animal/hostile/poison/giant_spider
	name = "giant spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has deep red eyes."
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	speak_emote = list("chitters")
	emote_hear = list("chitters")
	speak_chance = 5
	turns_per_move = 5
	see_in_dark = 10
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab/spider = 2, /obj/item/weapon/reagent_containers/food/snacks/spiderleg = 8)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 200
	health = 200
	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 20
	faction = list("spiders")
	var/busy = 0
	pass_flags = PASSTABLE
	move_to_delay = 6
	ventcrawler = VENTCRAWLER_ALWAYS
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	unique_name = 1
	gold_core_spawnable = 1
	see_invisible = SEE_INVISIBLE_MINIMUM
	see_in_dark = 4
	var/playable_spider = FALSE

/mob/living/simple_animal/hostile/poison/giant_spider/Topic(href, href_list)
	if(href_list["activate"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost) && playable_spider)
			humanize_spider(ghost)

/mob/living/simple_animal/hostile/poison/giant_spider/attack_ghost(mob/user)
	if(!humanize_spider(user))
		return ..()

/mob/living/simple_animal/hostile/poison/giant_spider/proc/humanize_spider(mob/user)
	if(key || !playable_spider)//Someone is in it or the fun police are shutting it down
		return 0
	var/spider_ask = alert("Become a spider?", "Are you australian?", "Yes", "No")
	if(spider_ask == "No" || !src || QDELETED(src))
		return 1
	if(key)
		to_chat(user, "<span class='notice'>Someone else already took this spider.</span>")
		return 1
	key = user.key
	return 1

//nursemaids - these create webs and eggs
/mob/living/simple_animal/hostile/poison/giant_spider/nurse
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	gender = FEMALE
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab/spider = 2, /obj/item/weapon/reagent_containers/food/snacks/spiderleg = 8, /obj/item/weapon/reagent_containers/food/snacks/spidereggs = 4)
	maxHealth = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 10
	poison_per_bite = 3
	var/atom/movable/cocoon_target
	var/fed = 0

//hunters have the most poison and move the fastest, so they can find prey
/mob/living/simple_animal/hostile/poison/giant_spider/hunter
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	maxHealth = 120
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	poison_per_bite = 5
	move_to_delay = 5

/mob/living/simple_animal/hostile/poison/giant_spider/handle_automated_action()
	if(!..()) //AIStatus is off
		return 0
	if(AIStatus == AI_IDLE)
		//1% chance to skitter madly away
		if(!busy && prob(1))
			stop_automated_movement = 1
			Goto(pick(urange(20, src, 1)), move_to_delay)
			spawn(50)
				stop_automated_movement = 0
				walk(src,0)
		return 1

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/proc/GiveUp(C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(cocoon_target == C && get_dist(src,cocoon_target) > 1)
				cocoon_target = null
			busy = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/handle_automated_action()
	if(..())
		var/list/can_see = view(src, 10)
		if(!busy && prob(30))	//30% chance to stop wandering and do something
			//first, check for potential food nearby to cocoon
			for(var/mob/living/C in can_see)
				if(C.stat && !istype(C,/mob/living/simple_animal/hostile/poison/giant_spider) && !C.anchored)
					cocoon_target = C
					busy = MOVING_TO_TARGET
					Goto(C, move_to_delay)
					//give up if we can't reach them after 10 seconds
					GiveUp(C)
					return

			//second, spin a sticky spiderweb on this tile
			var/obj/structure/spider/stickyweb/W = locate() in get_turf(src)
			if(!W)
				Web()
			else
				//third, lay an egg cluster there
				if(fed)
					LayEggs()
				else
					//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
					for(var/obj/O in can_see)

						if(O.anchored)
							continue

						if(istype(O, /obj/item) || istype(O, /obj/structure) || istype(O, /obj/machinery))
							cocoon_target = O
							busy = MOVING_TO_TARGET
							stop_automated_movement = 1
							Goto(O, move_to_delay)
							//give up if we can't reach them after 10 seconds
							GiveUp(O)

		else if(busy == MOVING_TO_TARGET && cocoon_target)
			if(get_dist(src, cocoon_target) <= 1)
				Wrap()

	else
		busy = 0
		stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/giant_spider/verb/Web()
	set name = "Lay Web"
	set category = "Spider"
	set desc = "Spread a sticky web to slow down prey."

	var/T = src.loc

	if(stat == DEAD)
		return
	if(busy != SPINNING_WEB)
		busy = SPINNING_WEB
		src.visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance.</span>")
		stop_automated_movement = 1
		if(do_after(src, 40, target = T))
			if(busy == SPINNING_WEB && src.loc == T)
				new /obj/structure/spider/stickyweb(T)
		busy = 0
		stop_automated_movement = 0


/mob/living/simple_animal/hostile/poison/giant_spider/nurse/verb/Wrap()
	set name = "Wrap"
	set category = "Spider"
	set desc = "Wrap up prey to feast upon and objects for safe keeping."

	if(stat == DEAD)
		return
	if(!cocoon_target)
		var/list/choices = list()
		for(var/mob/living/L in view(1,src))
			if(L == src || L.anchored)
				continue
			if(Adjacent(L))
				choices += L
		for(var/obj/O in src.loc)
			if(O.anchored)
				continue
			if(Adjacent(O))
				choices += O
		cocoon_target = input(src,"What do you wish to cocoon?") in null|choices

	if(stat != DEAD && cocoon_target && busy != SPINNING_COCOON)
		if(cocoon_target.anchored)
			cocoon_target = null
			return
		busy = SPINNING_COCOON
		src.visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance around \the [cocoon_target].</span>")
		stop_automated_movement = 1
		walk(src,0)
		if(do_after(src, 50, target = src))
			if(busy == SPINNING_COCOON)
				if(cocoon_target && isturf(cocoon_target.loc) && get_dist(src,cocoon_target) <= 1)
					var/obj/structure/spider/cocoon/C = new(cocoon_target.loc)
					var/large_cocoon = 0
					C.pixel_x = cocoon_target.pixel_x
					C.pixel_y = cocoon_target.pixel_y
					for(var/obj/item/I in C.loc)
						I.forceMove(C)
					for(var/obj/structure/S in C.loc)
						if(!S.anchored)
							S.forceMove(C)
							large_cocoon = 1
					for(var/obj/machinery/M in C.loc)
						if(!M.anchored)
							M.forceMove(C)
							large_cocoon = 1
					for(var/mob/living/L in C.loc)
						if(istype(L, /mob/living/simple_animal/hostile/poison/giant_spider))
							continue
						large_cocoon = 1
						L.forceMove(C)
						C.pixel_x = L.pixel_x
						C.pixel_y = L.pixel_y
						fed++
						visible_message("<span class='danger'>\the [src] sticks a proboscis into \the [L] and sucks a viscous substance out.</span>")
						break

					if(large_cocoon)
						C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
		cocoon_target = null
		busy = 0
		stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/verb/LayEggs()
	set name = "Lay Eggs"
	set category = "Spider"
	set desc = "Lay a clutch of eggs, but you must wrap a creature for feeding first."

	var/obj/structure/spider/eggcluster/E = locate() in get_turf(src)
	if(stat == DEAD)
		return
	if(E)
		to_chat(src, "<span class='warning'>There is already a cluster of eggs here!</span>")
	else if(!fed)
		to_chat(src, "<span class='warning'>You are too hungry to do this!</span>")
	else if(busy != LAYING_EGGS)
		busy = LAYING_EGGS
		src.visible_message("<span class='notice'>\the [src] begins to lay a cluster of eggs.</span>")
		stop_automated_movement = 1
		if(do_after(src, 50, target = src.loc))
			if(busy == LAYING_EGGS)
				E = locate() in get_turf(src)
				if(!E)
					var/obj/structure/spider/eggcluster/C = new /obj/structure/spider/eggcluster(src.loc)
					if(ckey)
						C.player_spiders = 1
					C.poison_type = poison_type
					C.poison_per_bite = poison_per_bite
					C.faction = faction.Copy()
					fed--
		busy = 0
		stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/giant_spider/handle_temperature_damage()
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(20)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(20)

#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON
