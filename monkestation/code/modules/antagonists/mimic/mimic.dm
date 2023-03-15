#define MIMIC_HEALTH_FLEE_AMOUNT 50
#define MIMIC_DISGUISE_COOLDOWN 5 SECONDS

#define REPLICATION_COST(mimic_count) (1 + round((mimic_count / 2)))

/mob/living/simple_animal/hostile/alien_mimic
	name = "mimic"
	real_name = "mimic"
	desc = "A morphing mass of black gooey tendrils."
	speak_emote = list("warbles")
	emote_hear = list("warbles")
	faction = list("aliens") //don't wanna have them attack eachother
	icon = 'monkestation/icons/mob/animal.dmi'
	icon_state = "mimic"
	icon_living = "mimic"
	icon_dead = "mimic_dead"
	move_to_delay = 0.5 SECONDS
	var/disguised_move_delay = 0.4 SECONDS
	var/undisguised_move_delay = 0.05 SECONDS
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	stat_attack = UNCONSCIOUS
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	sight = SEE_MOBS
	unsuitable_atmos_damage = 0 //They won't die in Space!
	minbodytemp = TCMB
	maxbodytemp = T0C + 40
	maxHealth = 125
	health = 125
	melee_damage = 7
	obj_damage = 30
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	wander = FALSE
	initial_language_holder = /datum/language_holder/mimic
	attacktext = "smothers"
	attack_sound = 'monkestation/sound/creatures/mimic/mimicattack.ogg'
	var/absorb_sound = 'monkestation/sound/creatures/mimic/mimicabsorb.ogg'
	var/split_sound = 'monkestation/sound/creatures/mimic/mimicsplit.ogg'

	var/playstyle_string = "<span class='big bold'>You are a mimic,</span></b> an alien that made it's way on to the station. \
							You can take the form of any item you can see by clicking on it. You can latch onto people by clicking on them, \
							which is instant when you're disguised. When you latch onto someone, they can't hurt you, but other people \
							can. After someone dies, you can absorb their body and reproduce to make more mimics.</b>"

	var/disguised = FALSE
	var/atom/movable/form = null
	var/disguise_time = 0

	//If this is currently reproducing
	var/splitting = FALSE
	//The target npc mimic's try to disguise as.
	var/atom/movable/ai_disg_target = null
	//attempts to reach a disguise target
	var/ai_disg_reach_attempts = 0

	var/datum/team/mimic/mimic_team

	var/has_organ = TRUE

	var/fleeing = FALSE
	mobchatspan = "blob"
	discovery_points = 2000

/mob/living/simple_animal/hostile/alien_mimic/examine(mob/user)
	. = ..()
	if(disguised)
		. += "<span class='warning'>It jitters a little bit...</span>"

/mob/living/simple_animal/hostile/alien_mimic/Destroy()
	mimic_team?.mimics -= src
	ai_disg_target = null
	. = ..()

/mob/living/simple_animal/hostile/alien_mimic/med_hud_set_health()
	if(disguised && !isliving(form))
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = null
		return //we hide medical hud while disguised
	..()

/mob/living/simple_animal/hostile/alien_mimic/med_hud_set_status()
	if(disguised && !isliving(form))
		var/image/holder = hud_list[STATUS_HUD]
		holder.icon_state = null
		return //we hide medical hud while disguised
	..()

/mob/living/simple_animal/hostile/alien_mimic/ClickOn(atom/target_item)
	if(allowed(target_item)) //Become Items
		if(disguise_time > world.time)
			to_chat(src, "<span class='warning'>You diguised too recently, wait a little longer!</span>")
			return
		if(disguised)
			restore()
		var/obj/item/item = target_item
		if(!item.anchored)
			disguise(item)
			return
	. = ..()

/mob/living/simple_animal/hostile/alien_mimic/proc/allowed(atom/movable/target_item)
	return isitem(target_item) && !istype(target_item, /obj/item/radio/intercom)

/mob/living/simple_animal/hostile/alien_mimic/proc/is_table(atom/possible_table)
	return istype(possible_table, /obj/structure/table) || istype(possible_table, /obj/structure/rack)

//Whether the AI should absorb a corpse when it gets the chance
/mob/living/simple_animal/hostile/alien_mimic/proc/should_heal()
	return health <= MIMIC_HEALTH_FLEE_AMOUNT

/mob/living/simple_animal/hostile/alien_mimic/proc/latch(mob/living/target)
	if(!istype(target))
		return
	if(target.has_buckled_mobs())
		target.unbuckle_all_mobs(force=TRUE)
	if(target.buckled)
		target.buckled.unbuckle_mob(target,TRUE)
	if(target)
		if(target.buckle_mob(src, TRUE))
			target.Knockdown(10 SECONDS)
			target.Stun(5 SECONDS)
			target.drop_all_held_items()
			layer = target.layer+0.01
			visible_message("<span class='warning'>[src] latches onto [target]!</span>")
			return TRUE
		else
			to_chat("<span class='warning'>You failed to latch onto the target!</span>")
	return FALSE

/mob/living/simple_animal/hostile/alien_mimic/proc/attempt_reproduce()
	if(disguised)
		to_chat(src,"<span class='warning'>You can't reproduce while disguised!</span>")
		return

	if(splitting) //prevent stacking a bunch
		return

	var/split_cost = REPLICATION_COST(mimic_team.mimics.len)

	if(mimic_team.people_absorbed >= split_cost)
		splitting = TRUE
		to_chat(src,"<span class='warning'>You start splitting yourself in two!</span>")
		playsound(get_turf(src), split_sound,100)
		if(do_mob(src, src, 5 SECONDS))
			splitting = FALSE
			if(mimic_team.people_absorbed < split_cost)
				return
			to_chat(src,"<span class='warning'>You make another mimic!</span>")
			var/mob/living/simple_animal/hostile/alien_mimic/split_mimic = new(loc)

			split_mimic.mimic_team = mimic_team
			mimic_team.mimics |= split_mimic

			split_mimic.ping_ghosts()
			mimic_team.people_absorbed -= split_cost
			return
		splitting = FALSE
		to_chat(src,"<span class='warning'>You fail to split!</span>")
		return
	to_chat(src,"<span class='warning'>You haven't absorbed enough people!</span>")

/mob/living/simple_animal/hostile/alien_mimic/attack_ghost(mob/user)
	if(QDELETED(src))
		return
	if(key)
		return
	if(stat == DEAD)
		return

	var/possess_ask = alert("Become a [name]? (Warning, You can no longer be cloned, and all past lives will be forgotten!)","Are you positive?","Yes","No")
	if(possess_ask == "No" || QDELETED(src))
		return

	if(suiciding) //clear suicide status if the old occupant suicided.
		set_suicide(FALSE)

	transfer_personality(user)

/mob/living/simple_animal/hostile/alien_mimic/proc/transfer_personality(mob/candidate)
	if(QDELETED(src))
		return
	if(key)
		to_chat(candidate, "<span class='warning'>This [name] was taken over before you could get to it!</span>")
		return FALSE

	toggle_ai(AI_OFF) //Turns the AI off so it doesn't move without player input
	SSmove_manager.stop_looping(src)

	ckey = candidate.ckey
	mind.assigned_role = "Mimic"
	var/datum/antagonist/mimic/mimic_datum = mind.add_antag_datum(/datum/antagonist/mimic,mimic_team)

	//Fixes when the datum has the team but not the mimic
	if(!mimic_team && mimic_datum.mimic_team)
		mimic_team = mimic_datum.mimic_team

	mimic_team.mimics |= src

	to_chat(src, playstyle_string)

	remove_from_spawner_menu()
	remove_from_dead_mob_list()
	add_to_alive_mob_list()
	set_stat(CONSCIOUS)

	return TRUE

/mob/living/simple_animal/hostile/alien_mimic/proc/ping_ghosts()
	set_playable()

/mob/living/simple_animal/hostile/alien_mimic/proc/disguise(atom/movable/target)
	if(splitting)
		to_chat(src,"<span class='warning'>You can't disguise while splitting!</span>")
		return
	if(isliving(buckled))
		to_chat(src,"<span class='warning'>You can't disguise while latched onto someone!</span>")
		return

	visible_message("<span class='warning'>[src] changes shape, becoming a copy of [target]!</span>", \
					"<span class='notice'>You assume the form of [target].</span>")

	ai_disg_target = null
	disguised = TRUE
	form = target
	desc = target.desc
	disguise_time = world.time + MIMIC_DISGUISE_COOLDOWN
	appearance = target.appearance
	if(length(target.vis_contents))
		add_overlay(target.vis_contents)
	alpha = max(alpha, 150)
	transform = initial(transform)
	pixel_y = initial(pixel_y)
	pixel_x = initial(pixel_x)
	density = target.density


	if(isliving(target))
		var/mob/living/living_target = target
		mobchatspan = living_target.mobchatspan
	else
		mobchatspan = initial(mobchatspan)

	set_varspeed(disguised_move_delay) //slower when disguised
	med_hud_set_health()
	med_hud_set_status()
	return

/mob/living/simple_animal/hostile/alien_mimic/proc/restore()
	if(!disguised)
		return
	disguised = FALSE
	form = null
	alpha = initial(alpha)
	color = initial(color)
	animate_movement = SLIDE_STEPS
	maptext = null
	density = initial(density)

	visible_message("<span class='warning'>A mimic jumps out of \the [src]!</span>", \
					"<span class='notice'>You reform to your normal body.</span>")

	name = initial(name)
	desc = initial(desc)
	icon = initial(icon)
	icon_state = initial(icon_state)

	disguise_time = world.time + MIMIC_DISGUISE_COOLDOWN

	cut_overlays()
	set_varspeed(undisguised_move_delay)
	med_hud_set_health()
	med_hud_set_status() //we are not an object

/mob/living/simple_animal/hostile/alien_mimic/Initialize(mapload)
	//1% chance for some silly names
	real_name = prob(99) ? "Mimic [rand(1,999)]" : pick("John Mimic","Not-A-Mimic","Goop Spider","Syndicate Infiltrator","Mimic Hater","Nar'sie Enthusiast")

	var/datum/action/innate/mimic_reproduce/replicate = new
	var/datum/action/innate/mimic_hivemind/hivemind = new
	replicate.Grant(src)
	hivemind.Grant(src)
	ADD_TRAIT(src, TRAIT_SHOCKIMMUNE, INNATE_TRAIT) //Needs this so breaking down a single door doesnt kill em
	set_varspeed(undisguised_move_delay)
	. = ..()

/mob/living/simple_animal/hostile/alien_mimic/Life()
	if(!has_organ) //incase someone uses a lazarus after stealing a mimic's organ
		if(health == maxHealth)
			to_chat(src,"<span class='userdanger'>You can't survive without any organs!</span>")
		adjustBruteLoss(20)
	if(isliving(buckled))
		var/mob/living/living_food = buckled
		if(living_food.stat == DEAD)
			resist_buckle()
	. = ..()

/mob/living/simple_animal/hostile/alien_mimic/attacked_by(obj/item/item, mob/living/target)
	if(src in target.buckled_mobs) //Can't attack if its Got ya
		to_chat(target,"<span class='userdanger'>You can't manage to hit \the [src] wrapped around you.</span>")
		return FALSE
	..()

/mob/living/simple_animal/hostile/alien_mimic/attackby(obj/item/item, mob/living/target)
	if(stat == DEAD && surgeries.len)
		if(target.a_intent == INTENT_HELP || target.a_intent == INTENT_DISARM)
			for(var/datum/surgery/current_surgery in surgeries)
				if(current_surgery.next_step(target,target.a_intent))
					return TRUE
	if(src in target.buckled_mobs) //Can't attack if its Got ya
		to_chat(target,"<span class='userdanger'>You can't manage to hit \the [src] wrapped around you.</span>")
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/alien_mimic/attack_hand(mob/living/target)
	if(stat == DEAD && surgeries.len)
		if(target.a_intent == INTENT_HELP || target.a_intent == INTENT_DISARM)
			for(var/datum/surgery/current_surgery in surgeries)
				if(current_surgery.next_step(target,target.a_intent))
					return TRUE
	if(src in target.buckled_mobs)
		return FALSE
	if(disguised)
		to_chat(target, "<span class='userdanger'>[src] latches onto you!</span>")
		visible_message("<span class='danger'>[src] latches onto [target]!</span>",\
				"<span class='userdanger'>You latch onto [target]!</span>", null, COMBAT_MESSAGE_RANGE)
		latch(target)
		restore()
		if(!mind) //If you click on it, trigger the AI (unless its controlled)
			toggle_ai(AI_ON)
	else
		..()

/mob/living/simple_animal/hostile/alien_mimic/death(gibbed)
	mimic_team?.mimics -= src
	if(buckled)
		buckled.unbuckle_mob(src,TRUE)
	if(disguised)
		visible_message("<span class='warning'>[src] explodes in a pile of black goo!</span>", \
						"<span class='userdanger'>You feel weak as your disguise start to dissolve.</span>")
		restore()
	..()

//AI can't track disguised mimics
/mob/living/simple_animal/hostile/alien_mimic/can_track(mob/living/user)
	if(disguised)
		return FALSE
	return ..()

/*
	AI stuff below here
*/
/mob/living/simple_animal/hostile/alien_mimic/CanAttack(atom/the_target)
	if(the_target == buckled)
		return TRUE //fixes it jumping off of people immediately
	if(iscarbon(the_target))
		var/mob/living/carbon/carbon_target = the_target
		if(carbon_target.stat == DEAD && should_heal() && !HAS_TRAIT(carbon_target, TRAIT_HUSK))
			return TRUE
	if(isliving(the_target))
		var/mob/living/living_target = the_target
		var/mob/living/simple_animal/hostile/alien_mimic/attacking_friend = locate() in living_target.buckled_mobs
		if(attacking_friend && attacking_friend != src)
			return FALSE
		var/faction_check = faction_check_mob(living_target)
		if((faction_check && !attack_same) || living_target.stat)
			return FALSE
	return TRUE

/mob/living/simple_animal/hostile/alien_mimic/adjustHealth(amount, updating_health, forced)
	if(amount > 0 && !mind) //if you take damage, run
		if(buckled)
			resist_buckle()
		if(!target)
			FindTarget()
		fleeing = TRUE
	..()

/mob/living/simple_animal/hostile/alien_mimic/AttackingTarget()
	if(target == src) //Remove your disguise
		restore()
		return

	if(!ismob(target)) //If you're attacking something or other
		if(disguised)
			restore()
		return ..()

	if(!isliving(target))
		return

	var/mob/living/victim = target

	if(iscyborg(target) || isAI(target)) //stinky sillicons with their no mounting rules
		victim.apply_damage(melee_damage, BRUTE, victim.get_bodypart(BODY_ZONE_CHEST)) //mimics still get the full damage, though it does feel a little dirty to deal the same damage twice
		return ..()

	if(buckled && victim == buckled) //If you're buckled to them
		victim.apply_damage(melee_damage, CLONE, victim.get_bodypart(BODY_ZONE_CHEST))
		return ..()

	if(!buckled) //Latch onto people
		if(iscarbon(victim) && victim.stat == DEAD && !HAS_TRAIT(victim, TRAIT_HUSK)) //Absorb someone to heal
			var/mob/living/carbon/carbon_victim = victim
			if(!carbon_victim.last_mind)
				to_chat(src, "<span class='warning'>They have no mind to gather information from!</span>")
				return
			if(NOHUSK in carbon_victim.dna.species.species_traits)
				to_chat(src, "<span class='warning'>You can't absorb this person!</span>")
				return
			visible_message("<span class='warning'>[src] starts absorbing [carbon_victim]!</span>", \
						"<span class='userdanger'>You start absorbing [carbon_victim].</span>")
			if(do_mob(src, carbon_victim, 10 SECONDS))
				if(HAS_TRAIT(carbon_victim, TRAIT_HUSK)) //Can't let em spam click em
					return
				playsound(get_turf(src), absorb_sound,100)
				visible_message("<span class='warning'>[src] absorbs [carbon_victim]!</span>", \
							"<span class='userdanger'>[carbon_victim]'s corpse decays as you absorb the nutrients from their body.</span>")
				carbon_victim.become_husk("burn") //Needs to be "burn" so rezadone and such an fix it, don't want it being an RR due to too many bodies for medbay.
				mimic_team?.people_absorbed++
				mimic_team?.total_people_absorbed++
				adjustHealth(-40)
			return
		if(disguised) //Insta latch if youre disguised
			if(victim.stat == DEAD)
				to_chat("<span class='warning'>You can't absorb a body while disguised!</span>")
				return
			latch(victim)
			restore()
			return
		else if(do_mob(src, target, 3 SECONDS)) //Latch after a bit if you arent
			latch(victim)
			return

/mob/living/simple_animal/hostile/alien_mimic/Aggro()
	if(mind)
		return
	if(disguised && get_dist(src,target)<=1) //Instantly latch onto them
		latch(target)
		restore()
		toggle_ai(AI_ON)

/mob/living/simple_animal/hostile/alien_mimic/MoveToTarget(list/possible_targets)
	if(fleeing)
		SSmove_manager.move_away(src, target, 15, move_to_delay)
		stop_automated_movement = 1
		if(!target || !CanAttack(target))
			LoseTarget()
			return FALSE
	else
		..()

/mob/living/simple_animal/hostile/alien_mimic/LoseTarget()
	if(fleeing)
		fleeing = FALSE
	..()

/mob/living/simple_animal/hostile/alien_mimic/ListTargets()
	var/atom/target_from = GET_TARGETS_FROM(src)
	if(!search_objects)
		. = list()
		for(var/atom/possible_target as() in dview(vision_range, get_turf(target_from), SEE_INVISIBLE_MINIMUM))
			if(ismob(possible_target) && possible_target != src && !ismimic(possible_target))
				var/mob/mob_target = possible_target
				if(mob_target.stat != DEAD)
					. += possible_target
	else
		. = oview(vision_range, target_from)

/mob/living/simple_animal/hostile/alien_mimic/get_stat_tab_status()
	var/list/tab_data = ..()
	tab_data["Replication Cost"] = GENERATE_STAT_TEXT("[REPLICATION_COST(mimic_team.mimics.len)]")
	tab_data["People Absorbed"] = GENERATE_STAT_TEXT("[mimic_team.people_absorbed]")
	return tab_data

/mob/living/simple_animal/hostile/alien_mimic/handle_automated_action()
	if(AIStatus == AI_OFF)
		return FALSE
	var/list/possible_targets = ListTargets() //we look around for potential targets and make it a list for later use.

	if(environment_smash)
		EscapeConfinement()

	if(AICanContinue(possible_targets))
		var/atom/target_from = GET_TARGETS_FROM(src)
		if(!QDELETED(target) && !target_from.Adjacent(target))
			DestroyPathToTarget()
		if(!MoveToTarget(possible_targets))     //if we lose our target
			if(AIShouldSleep(possible_targets))	// we try to acquire a new one
				toggle_ai(AI_IDLE)			// otherwise we go idle
	return TRUE

/mob/living/simple_animal/hostile/alien_mimic/AIShouldSleep(var/list/possible_targets)
	var/should_sleep = !FindTarget(possible_targets, 1)
	if(should_sleep) //Attempt to disguise
		if(!ai_disg_target)
			var/list/things = list()
			for(var/atom/thing as() in view(src))
				if(allowed(thing))
					things += thing
			if(things.len)
				var/atom/movable/picked_thing = pick(things)
				ai_disg_target = picked_thing
			else
				return TRUE //just give up if there's nothin
		if(Adjacent(ai_disg_target) || ai_disg_reach_attempts >= 10) //give it 10 tries before just turning into it
			//Get on any nearby tables after disguising
			var/list/tables = list()
			for(var/atom/possible_table as() in view(1,src))
				if(is_table(possible_table))
					tables += possible_table
			if(tables.len)
				var/atom/movable/chosen_table = pick(tables)
				Move(get_turf(chosen_table))
			ai_disg_reach_attempts = 0
			disguise(ai_disg_target)
		else
			if(buckled)
				resist_buckle()
			ai_disg_reach_attempts++
			Goto(ai_disg_target, move_to_delay, 1) //Go right next to it
			return FALSE
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/alien_mimic/consider_wakeup()
	var/list/target_list

	target_list = ListTargets()
	//Wait until they're alone
	if(target_list.len>1)
		return

	FindTarget(target_list, 1)
	if(iscarbon(target))
		var/mob/living/carbon/victim = target

		if(victim.stat == DEAD && should_heal() && !HAS_TRAIT(victim, TRAIT_HUSK)) //Heal if you're supposed to
			toggle_ai(AI_ON)
			restore()
			return

	var/target_dist = get_dist(target,src)
	//Only attack when they get close
	if(target_dist>1)
		return
	..()



/datum/action/innate/mimic_reproduce
	name = "Reproduce"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "separate"
	background_icon_state = "bg_alien"

/datum/action/innate/mimic_reproduce/Activate()
	var/mob/living/simple_animal/hostile/alien_mimic/mimic = owner
	mimic.attempt_reproduce()

/datum/action/innate/mimic_hivemind
	name = "Communicate"
	icon_icon = 'icons/mob/actions/actions_changeling.dmi' //I will try to make action sprites either before the merge or soon after it
	button_icon_state = "hivemind_channel"
	background_icon_state = "bg_alien"

/datum/action/innate/mimic_hivemind/Activate()
	if(!ismimic(usr))
		to_chat(usr, "<span class='warning'>You shouldn't have this ability!</span>")
		return
	var/input = stripped_input(usr, "Send a message to the hivemind.", "Communication", "")
	if(!input || !IsAvailable())
		return
	if(CHAT_FILTER_CHECK(input))
		to_chat(usr, "<span class='warning'>You cannot send a message that contains a word prohibited in IC chat!</span>")
		return
	hivemind_message(usr, input)

/datum/action/innate/mimic_hivemind/proc/hivemind_message(mob/living/user, message)
	var/my_message
	if(!message)
		return

	var/name_to_use
	var/mob/living/simple_animal/hostile/alien_mimic/mimic_user = user
	name_to_use = mimic_user.real_name

	my_message = "<span class='mimichivemindtitle'><b>Mimic Hivemind</b></span> <span class='mimichivemind'><b>[name_to_use]:</b> [message]</span>"
	for(var/player in GLOB.player_list)
		var/mob/recipient = player
		if(ismimic(recipient))
			to_chat(recipient, my_message)
		else if(recipient in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(recipient, user)
			to_chat(recipient, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="mimic hivemind")

#undef MIMIC_HEALTH_FLEE_AMOUNT
#undef MIMIC_DISGUISE_COOLDOWN
