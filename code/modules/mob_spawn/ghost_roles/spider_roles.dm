/obj/structure/spider/eggcluster
	name = "egg cluster"
	desc = "They seem to pulse slightly with an inner life."
	icon_state = "eggs"
	/// Mob spawner handling the actual spawn of the spider
	var/obj/effect/mob_spawn/ghost_role/spider/spawner

/obj/structure/spider/eggcluster/Initialize(mapload)
	pixel_x = base_pixel_x + rand(3,-3)
	pixel_y = base_pixel_y + rand(3,-3)
	return ..()

/obj/structure/spider/eggcluster/Destroy()
	if(spawner)
		QDEL_NULL(spawner)
	return ..()

/obj/structure/spider/eggcluster/attack_ghost(mob/user)
	if(spawner)
		spawner.attack_ghost(user)
	return ..()

/obj/structure/spider/eggcluster/enriched
	name = "enriched egg cluster"
	color = rgb(148, 0, 211)

/obj/structure/spider/eggcluster/bloody
	name = "bloody egg cluster"
	color = rgb(255, 0, 0)

/obj/structure/spider/eggcluster/midwife
	name = "midwife egg cluster"

/obj/effect/mob_spawn/ghost_role/spider
	name = "egg cluster"
	desc = "They seem to pulse slightly with an inner life."
	mob_name = "\improper spider"
	icon = 'icons/effects/effects.dmi'
	icon_state = "eggs"
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	show_flavor = FALSE
	you_are_text = "You are a spider."
	flavour_text = "For the hive! Choose a spider and fulfill your role to take over the station... if that is within your directives, of course."
	important_text = "Follow your directives at all costs."
	faction = list("spiders")
	spawner_job_path = /datum/job/spider
	role_ban = ROLE_ALIEN
	prompt_ghost = FALSE
	/// Prevents spawning from this mob_spawn until TRUE, set by the egg growing
	var/ready = FALSE
	/// The amount the egg cluster has grown.  Is able to produce a spider when it hits 100.
	var/amount_grown = 0
	/// The mother's directive at the time the egg was produced.  Passed onto the child.
	var/directive = ""
	///	Type of the cluster that the spawner spawns
	var/cluster_type = /obj/structure/spider/eggcluster
	/// Physical structure housing the spawner
	var/obj/structure/spider/eggcluster/egg
	/// The types of spiders that the spawner can produce
	var/list/potentialspawns = list(
		/mob/living/simple_animal/hostile/giant_spider,
		/mob/living/simple_animal/hostile/giant_spider/hunter,
		/mob/living/simple_animal/hostile/giant_spider/nurse,
	)

/obj/effect/mob_spawn/ghost_role/spider/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	potentialspawns = string_list(potentialspawns)
	egg = new cluster_type(get_turf(loc))
	egg.spawner = src
	forceMove(egg)

/obj/effect/mob_spawn/ghost_role/spider/Destroy()
	egg = null
	return ..()

/obj/effect/mob_spawn/ghost_role/spider/process(delta_time)
	amount_grown += rand(0, 1) * delta_time
	if(amount_grown >= 100 && !ready)
		ready = TRUE
		notify_ghosts("[src] is ready to hatch!", null, enter_link = "<a href=?src=[REF(src)];activate=1>(Click to play)</a>", source = src, action = NOTIFY_ORBIT, ignore_key = POLL_IGNORE_SPIDER)
		STOP_PROCESSING(SSobj, src)

/obj/effect/mob_spawn/ghost_role/spider/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["activate"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)
			attack_ghost(ghost)

/obj/effect/mob_spawn/ghost_role/spider/allow_spawn(mob/user, silent = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!ready)
		if(!silent)
			to_chat(user, span_warning("\The [src] is not ready to hatch yet!"))
		return FALSE

/obj/effect/mob_spawn/ghost_role/spider/special(mob/living/simple_animal/hostile/giant_spider/spawned_mob, mob/mob_possessor)
	spawned_mob.directive = directive
	egg.spawner = null
	QDEL_NULL(egg)
	return ..()

/obj/effect/mob_spawn/ghost_role/spider/enriched
	name = "enriched egg cluster"
	color = rgb(148, 0, 211)
	you_are_text = "You are an enriched spider."
	cluster_type = /obj/structure/spider/eggcluster/enriched
	potentialspawns = list(
		/mob/living/simple_animal/hostile/giant_spider/tarantula,
		/mob/living/simple_animal/hostile/giant_spider/viper,
		/mob/living/simple_animal/hostile/giant_spider/midwife,
	)

/obj/effect/mob_spawn/ghost_role/spider/bloody
	name = "bloody egg cluster"
	color = rgb(255, 0, 0)
	you_are_text = "You are a bloody spider."
	flavour_text = "An abomination of nature set upon the station by changelings. Your only goal is to kill, terrorize, and survive."
	directive = "You are the spawn of a vicious changeling. You have no ambitions except to wreak havoc and ensure your own survival. You are aggressive to all living beings outside of your species, including changelings."
	cluster_type = /obj/structure/spider/eggcluster/bloody
	potentialspawns = list(
		/mob/living/simple_animal/hostile/giant_spider/hunter/flesh,
	)

/obj/effect/mob_spawn/ghost_role/spider/midwife
	name = "midwife egg cluster"
	you_are_text = "You are a midwife spider."
	flavour_text = "The crux of the spider horde. You have the ability to reproduce and create more spiders, and turn victims into special spider eggs."
	directive = "Ensure the survival of the spider species and overtake whatever structure you find yourself in."
	cluster_type = /obj/structure/spider/eggcluster/midwife
	potentialspawns = list(
		/mob/living/simple_animal/hostile/giant_spider/midwife,
	)

/**
 * Makes a ghost into a spider based on the type of egg cluster.
 *
 * Allows a ghost to get a prompt to use the egg cluster to become a spider.
 *
 * Arguments:
 * * user - The ghost attempting to become a spider
 * * newname - If set, renames the mob to this name
 */
/obj/effect/mob_spawn/ghost_role/spider/create(mob/user, newname)
	var/list/spider_list = list()
	var/list/display_spiders = list()
	for(var/choice in potentialspawns)
		var/mob/living/simple_animal/hostile/giant_spider/spider = choice
		spider_list[initial(spider.name)] = choice

		var/datum/radial_menu_choice/option = new
		option.image = image(icon = initial(spider.icon), icon_state = initial(spider.icon_state))

		var/datum/reagent/spider_poison = initial(spider.poison_type)
		var/spider_description = initial(spider.menu_description)
		if(initial(spider.poison_per_bite))
			spider_description += " [initial(spider_poison.name)] injection of [initial(spider.poison_per_bite)]u per bite."
		else
			spider_description += " Does not inject [initial(spider_poison.name)]."
		option.info = span_boldnotice(spider_description)

		display_spiders[initial(spider.name)] = option
	sort_list(display_spiders)
	var/chosen_spider = show_radial_menu(user, egg, display_spiders, radius = 38)
	chosen_spider = spider_list[chosen_spider]
	if(QDELETED(src) || QDELETED(user) || !chosen_spider)
		return FALSE
	mob_type = chosen_spider
	mob_name = "[mob_name] ([rand(1, 1000)])"
	return ..()
