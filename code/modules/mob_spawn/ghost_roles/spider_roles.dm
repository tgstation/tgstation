/obj/structure/spider/eggcluster
	name = "egg cluster"
	desc = "There's something alive in there, and sooner or later it's going to find its way out."
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

/obj/structure/spider/eggcluster/examine_more(mob/user)
	. = ..()

	if(istype(user, /mob/living/basic/spider/giant/midwife))
		switch(spawner.amount_grown)
			if(0 to 24)
				. += span_info("These eggs look shrunken and dormant.")
			if(25 to 49)
				. += span_info("These eggs have begun to move, pulsating, gestating...")
			if(50 to 74)
				. += span_info("These eggs are rippling, unseen life stirring beneath its skin.")
			if(75 to 99)
				. += span_info("These eggs swell with unseen life. They are almost ready to burst.")
			if(100 to INFINITY)
				. += span_info("These eggs are plump, teeming with life. Any moment now...")

/obj/structure/spider/eggcluster/enriched
	name = "enriched egg cluster"
	color = rgb(148, 0, 211)

/obj/structure/spider/eggcluster/bloody
	icon = 'icons/mob/simple/meteor_heart.dmi'
	icon_state = "eggs"
	name = "bloody egg cluster"

/obj/structure/spider/eggcluster/midwife
	name = "midwife egg cluster"

/obj/effect/mob_spawn/ghost_role/spider
	name = "egg cluster"
	desc = "They seem to pulse slightly with an inner life."
	icon = 'icons/effects/effects.dmi'
	icon_state = "eggs"
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	show_flavor = FALSE
	you_are_text = "You are a spider."
	flavour_text = "For the hive! Choose a spider and fulfill your role to take over the station... if that is within your directives, of course."
	important_text = "Follow your directives at all costs."
	faction = list(FACTION_SPIDER)
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
	/// Which antag datum do we grant?
	var/granted_datum = /datum/antagonist/spider
	/// The types of spiders that the spawner can produce
	var/list/potentialspawns = list(
		/mob/living/basic/spider/growing/spiderling/nurse,
		/mob/living/basic/spider/growing/spiderling/hunter,
		/mob/living/basic/spider/growing/spiderling/ambush,
		/mob/living/basic/spider/growing/spiderling/tangle,
		/mob/living/basic/spider/growing/spiderling/guard,
		/mob/living/basic/spider/growing/spiderling/scout,
	)
	/// Do we flash the byond window when this particular egg type is available?
	var/flash_window = FALSE

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

/obj/effect/mob_spawn/ghost_role/spider/process(seconds_per_tick)
	amount_grown += rand(5, 15) * seconds_per_tick
	if(amount_grown >= 100 && !ready)
		ready = TRUE
		notify_ghosts("[src] is ready to hatch!", null, enter_link = "<a href=?src=[REF(src)];activate=1>(Click to play)</a>", source = src, action = NOTIFY_ORBIT, ignore_key = POLL_IGNORE_SPIDER, flashwindow = flash_window)
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

/obj/effect/mob_spawn/ghost_role/spider/special(mob/living/basic/spider/spawned_mob, mob/mob_possessor)
	. = ..()
	if (isspider(spawned_mob))
		spawned_mob.directive = directive
	egg.spawner = null
	QDEL_NULL(egg)
	var/datum/antagonist/spider/spider_antag = new granted_datum(directive)
	spawned_mob.mind.add_antag_datum(spider_antag)

/obj/effect/mob_spawn/ghost_role/spider/enriched
	name = "enriched egg cluster"
	color = rgb(148, 0, 211)
	you_are_text = "You are an enriched spider."
	cluster_type = /obj/structure/spider/eggcluster/enriched
	potentialspawns = list(
		/mob/living/basic/spider/growing/spiderling/tarantula,
		/mob/living/basic/spider/growing/spiderling/viper,
		/mob/living/basic/spider/growing/spiderling/midwife,
	)
	flash_window = TRUE

/obj/effect/mob_spawn/ghost_role/spider/bloody
	name = "bloody egg cluster"
	icon = 'icons/mob/simple/meteor_heart.dmi'
	icon_state = "eggs"
	you_are_text = "You are a flesh spider."
	flavour_text = "An abomination of nature set upon the station by changelings. Your only goal is to kill, terrorize, and survive."
	faction = list()
	directive = null
	cluster_type = /obj/structure/spider/eggcluster/bloody
	potentialspawns = list(
		/mob/living/basic/flesh_spider,
	)
	flash_window = TRUE
	granted_datum = /datum/antagonist/spider/flesh

/obj/effect/mob_spawn/ghost_role/spider/midwife
	name = "midwife egg cluster"
	you_are_text = "You are a midwife spider."
	flavour_text = "The crux of the spider horde. You have the ability to reproduce and create more spiders, and turn victims into special spider eggs."
	directive = "Ensure the survival of the spider species and overtake whatever structure you find yourself in."
	cluster_type = /obj/structure/spider/eggcluster/midwife
	potentialspawns = list(
		/mob/living/basic/spider/giant/midwife, // We don't want the event to end instantly because of a 2 hp spiderling dying
	)
	flash_window = TRUE

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
	var/chosen_spider = length(potentialspawns) > 1 ? get_radial_choice(user) : potentialspawns[1]
	if(QDELETED(src) || QDELETED(user) || isnull(chosen_spider))
		return FALSE
	mob_type = chosen_spider
	return ..()

/// Pick a spider type from a radial menu
/obj/effect/mob_spawn/ghost_role/spider/proc/get_radial_choice(mob/user)
	var/list/spider_list = list()
	var/list/display_spiders = list()
	for(var/choice in potentialspawns)
		var/mob/living/basic/spider/growing/spiderling/chosen_spiderling = choice
		var/mob/living/basic/spider/growing/young/young_spider = initial(chosen_spiderling.grow_as)
		var/mob/living/basic/spider/giant/spider = initial(young_spider.grow_as) // God this is so stupid
		spider_list[initial(spider.name)] = chosen_spiderling

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
	return spider_list[chosen_spider]
