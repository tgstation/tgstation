#define SPIDER_IDLE 0
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
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/spider = 2, /obj/item/reagent_containers/food/snacks/spiderleg = 8)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 200
	health = 200
	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 20
	faction = list("spiders")
	var/busy = SPIDER_IDLE
	pass_flags = PASSTABLE
	move_to_delay = 6
	ventcrawler = VENTCRAWLER_ALWAYS
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	unique_name = 1
	gold_core_spawnable = 1
	see_in_dark = 4
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	var/playable_spider = FALSE
	var/datum/action/innate/lay_web/lay_web
	var/directive = "" //Message passed down to children, to relay the creator's orders

/mob/living/simple_animal/hostile/poison/giant_spider/Initialize()
	. = ..()
	lay_web = new
	lay_web.Grant(src)

/mob/living/simple_animal/hostile/poison/giant_spider/Destroy()
	if(lay_web)
		lay_web.Remove(src)
		QDEL_NULL(lay_web)
	return ..()

/mob/living/simple_animal/hostile/poison/giant_spider/Topic(href, href_list)
	if(href_list["activate"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost) && playable_spider)
			humanize_spider(ghost)

/mob/living/simple_animal/hostile/poison/giant_spider/Login()
	..()
	if(directive)
		to_chat(src, "<span class='notice'>Your mother left you a directive! Follow it at all costs.</span>")
		to_chat(src, "<span class='notice'><b>[directive]</b></span>")

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
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/spider = 2, /obj/item/reagent_containers/food/snacks/spiderleg = 8, /obj/item/reagent_containers/food/snacks/spidereggs = 4)
	maxHealth = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 10
	poison_per_bite = 3
	var/atom/movable/cocoon_target
	var/fed = 0
	var/datum/action/innate/wrap/wrap
	var/datum/action/innate/lay_eggs/lay_eggs
	var/datum/action/innate/set_directive/set_directive
	var/static/list/consumed_mobs = list() //the tags of mobs that have been consumed by nurse spiders to lay eggs

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/Initialize()
	. = ..()
	lay_web = new
	lay_web.Grant(src)
	wrap = new
	wrap.Grant(src)
	lay_eggs = new
	lay_eggs.Grant(src)
	set_directive = new
	set_directive.Grant(src)

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/Destroy()
	if(lay_web)
		lay_web.Remove(src)
		QDEL_NULL(lay_web)
	if(wrap)
		wrap.Remove(src)
		QDEL_NULL(wrap)
	if(lay_eggs)
		lay_eggs.Remove(src)
		QDEL_NULL(lay_eggs)
	if(set_directive)
		set_directive.Remove(src)
		QDEL_NULL(set_directive)
	return ..()

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

/mob/living/simple_animal/hostile/poison/giant_spider/ice //spiders dont usually like tempatures of 140 kelvin who knew
	name = "giant ice spider"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	color = rgb(114,228,250)
	gold_core_spawnable = 0

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/ice
	name = "giant ice spider"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	color = rgb(114,228,250)
	gold_core_spawnable = 0

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/ice
	name = "giant ice spider"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	color = rgb(114,228,250)
	gold_core_spawnable = 0

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
			busy = FALSE
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/handle_automated_action()
	if(..())
		var/list/can_see = view(src, 10)
		if(!busy && prob(30))	//30% chance to stop wandering and do something
			//first, check for potential food nearby to cocoon
			for(var/mob/living/C in can_see)
				if(C.stat && !istype(C, /mob/living/simple_animal/hostile/poison/giant_spider) && !C.anchored)
					cocoon_target = C
					busy = MOVING_TO_TARGET
					Goto(C, move_to_delay)
					//give up if we can't reach them after 10 seconds
					GiveUp(C)
					return

			//second, spin a sticky spiderweb on this tile
			var/obj/structure/spider/stickyweb/W = locate() in get_turf(src)
			if(!W)
				lay_web.Activate()
			else
				//third, lay an egg cluster there
				if(fed)
					lay_eggs.Activate()
				else
					//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
					for(var/obj/O in can_see)

						if(O.anchored)
							continue

						if(isitem(O) || istype(O, /obj/structure) || istype(O, /obj/machinery))
							cocoon_target = O
							busy = MOVING_TO_TARGET
							stop_automated_movement = 1
							Goto(O, move_to_delay)
							//give up if we can't reach them after 10 seconds
							GiveUp(O)

		else if(busy == MOVING_TO_TARGET && cocoon_target)
			if(get_dist(src, cocoon_target) <= 1)
				wrap.Activate()

	else
		busy = SPIDER_IDLE
		stop_automated_movement = FALSE

/datum/action/innate/lay_web
	name = "Spin Web"
	desc = "Spin a web to slow down potential prey."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_web"
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/lay_web/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider/nurse))
		return
	var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/S = owner

	if(!isturf(S.loc))
		return
	var/turf/T = get_turf(S)

	var/obj/structure/spider/stickyweb/W = locate() in T
	if(W)
		to_chat(S, "<span class='warning'>There's already a web here!</span>")
		return

	if(S.busy != SPINNING_WEB)
		S.busy = SPINNING_WEB
		S.visible_message("<span class='notice'>[S] begins to secrete a sticky substance.</span>","<span class='notice'>You begin to lay a web.</span>")
		S.stop_automated_movement = TRUE
		if(do_after(S, 40, target = T))
			if(S.busy == SPINNING_WEB && S.loc == T)
				new /obj/structure/spider/stickyweb(T)
		S.busy = SPIDER_IDLE
		S.stop_automated_movement = FALSE
	else
		to_chat(S, "<span class='warning'>You're already spinning a web!</span>")

/datum/action/innate/wrap
	name = "Wrap"
	desc = "Wrap something or someone in a cocoon. If it's a living being, you'll also consume them, allowing you to lay eggs."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "wrap"
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/wrap/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider/nurse))
		return
	var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/S = owner

	if(!S.cocoon_target)
		var/list/choices = list()
		for(var/mob/living/L in view(1,S))
			if(L == S || L.anchored)
				continue
			if(istype(L, /mob/living/simple_animal/hostile/poison/giant_spider))
				continue
			if(S.Adjacent(L))
				choices += L
		for(var/obj/O in S.loc)
			if(O.anchored)
				continue
			if(S.Adjacent(O))
				choices += O
		var/temp_input = input(S,"What do you wish to cocoon?") in null|choices
		if(temp_input && !S.cocoon_target)
			S.cocoon_target = temp_input

	if(S.stat != DEAD && S.cocoon_target && S.Adjacent(S.cocoon_target) && !S.cocoon_target.anchored)
		if(S.busy == SPINNING_COCOON)
			return //we're already doing this, don't cancel out or anything
		S.busy = SPINNING_COCOON
		S.visible_message("<span class='notice'>[S] begins to secrete a sticky substance around [S.cocoon_target].</span>","<span class='notice'>You begin wrapping [S.cocoon_target] into a cocoon.</span>")
		S.stop_automated_movement = TRUE
		walk(S,0)
		if(do_after(S, 50, target = S.cocoon_target))
			if(S.busy == SPINNING_COCOON)
				var/obj/structure/spider/cocoon/C = new(S.cocoon_target.loc)
				if(isliving(S.cocoon_target))
					var/mob/living/L = S.cocoon_target
					if(L.blood_volume && (L.stat != DEAD || !S.consumed_mobs[L.tag])) //if they're not dead, you can consume them anyway
						S.consumed_mobs[L.tag] = TRUE
						S.fed++
						S.lay_eggs.UpdateButtonIcon(TRUE)
						S.visible_message("<span class='danger'>[src] sticks a proboscis into [L] and sucks a viscous substance out.</span>","<span class='notice'>You suck the nutriment out of [L], feeding you enough to lay a cluster of eggs.</span>")
						L.death() //you just ate them, they're dead.
					else
						to_chat(S, "<span class='warning'>[L] cannot sate your hunger!</span>")
				S.cocoon_target.forceMove(C)

				if(S.cocoon_target.density || ismob(S.cocoon_target))
					C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
	S.cocoon_target = null
	S.busy = SPIDER_IDLE
	S.stop_automated_movement = FALSE

/datum/action/innate/lay_eggs
	name = "Lay Eggs"
	desc = "Lay a cluster of eggs, which will soon grow into more spiders. You must wrap a living being to do this."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_eggs"
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/lay_eggs/IsAvailable()
	if(..())
		if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider/nurse))
			return 0
		var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/S = owner
		if(S.fed)
			return 1
		return 0

/datum/action/innate/lay_eggs/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider/nurse))
		return
	var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/S = owner

	var/obj/structure/spider/eggcluster/E = locate() in get_turf(S)
	if(E)
		to_chat(S, "<span class='warning'>There is already a cluster of eggs here!</span>")
	else if(!S.fed)
		to_chat(S, "<span class='warning'>You are too hungry to do this!</span>")
	else if(S.busy != LAYING_EGGS)
		S.busy = LAYING_EGGS
		S.visible_message("<span class='notice'>[S] begins to lay a cluster of eggs.</span>","<span class='notice'>You begin to lay a cluster of eggs.</span>")
		S.stop_automated_movement = TRUE
		if(do_after(S, 50, target = get_turf(S)))
			if(S.busy == LAYING_EGGS)
				E = locate() in get_turf(S)
				if(!E || !isturf(S.loc))
					var/obj/structure/spider/eggcluster/C = new /obj/structure/spider/eggcluster(get_turf(S))
					if(S.ckey)
						C.player_spiders = TRUE
					C.directive = S.directive
					C.poison_type = S.poison_type
					C.poison_per_bite = S.poison_per_bite
					C.faction = S.faction.Copy()
					S.fed--
					UpdateButtonIcon(TRUE)
		S.busy = SPIDER_IDLE
		S.stop_automated_movement = FALSE

/datum/action/innate/set_directive
	name = "Set Directive"
	desc = "Set a directive for your children to follow."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "directive"
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/set_directive/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider/nurse))
		return
	var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/S = owner
	S.directive = stripped_input(S, "Enter the new directive", "Create directive", "[S.directive]", MAX_MESSAGE_LEN)

/mob/living/simple_animal/hostile/poison/giant_spider/handle_temperature_damage()
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(20)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(20)

#undef SPIDER_IDLE
#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON
