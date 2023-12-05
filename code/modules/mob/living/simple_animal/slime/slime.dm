#define SLIME_CARES_ABOUT(to_check) (to_check && (to_check == Target || to_check == Leader || (to_check in Friends)))
/mob/living/simple_animal/slime
	name = "grey baby slime (123)"
	icon = 'icons/mob/simple/slimes.dmi'
	icon_state = "grey baby slime"
	pass_flags = PASSTABLE | PASSGRILLE
	gender = NEUTER
	faction = list(FACTION_SLIME, FACTION_NEUTRAL)

	harm_intent_damage = 5
	icon_living = "grey baby slime"
	icon_dead = "grey baby slime dead"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomp on"
	emote_see = list("jiggles", "bounces in place")
	speak_emote = list("blorbles")
	bubble_icon = "slime"
	initial_language_holder = /datum/language_holder/slime

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	maxHealth = 150
	health = 150
	mob_biotypes = MOB_SLIME
	melee_damage_lower = 5
	melee_damage_upper = 25

	verb_say = "blorbles"
	verb_ask = "inquisitively blorbles"
	verb_exclaim = "loudly blorbles"
	verb_yell = "loudly blorbles"

	// canstun and canknockdown don't affect slimes because they ignore stun and knockdown variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANUNCONSCIOUS|CANPUSH

	footstep_type = FOOTSTEP_MOB_SLIME

	//Physiology

	///Is the slime an adult slime?
	var/is_adult = TRUE

	///The number of /obj/item/slime_extract's the slime has left inside
	var/cores = 1
	///Chance of mutating, should be between 25 and 35
	var/mutation_chance = 30
	///1-10 controls how much electricity they are generating
	var/powerlevel = 0
	///Controls how long the slime has been overfed, if 10, grows or reproduces
	var/amount_grown = 0

	///Has a mutator been used on the slime? Only one is allowed
	var/mutator_used = FALSE
	///Is the slime forced into being immobile, despite the gases present?
	var/force_stasis = FALSE

	//The datum that handles the slime colour's core and possible mutations
	var/datum/slime_type/slime_type

	//CORE-CROSSING CODE

	///What cross core modification is being used.
	var/crossbreed_modification
	///How many extracts of the modtype have been applied.
	var/applied_crossbreed_amount = 0

	//AI related traits

	///The current mood of the slime, set randomly or through emotes (if sentient).
	var/current_mood

	///Determines if the AI loop is activated
	var/slime_ai_processing = FALSE
	///Attack cooldown
	var/is_attack_on_cooldown = FALSE
	///If a slime has been hit with a freeze gun, or wrestled/attacked off a human, they become disciplined and don't attack anymore for a while
	var/discipline_stacks = 0
	///Stored the world time when the slime's stun wears off
	var/stunned_until = 0

	///Is the slime docile?
	var/docile = FALSE

	///Used to understand when someone is talking to it
	var/slime_id = 0
	///AI variable - tells the slime to hunt this down
	var/mob/living/Target = null
	///AI variable - tells the slime to follow this person
	var/mob/living/Leader = null

	///Determines if it's been attacked recently. Can be any number, is a cooloff-ish variable
	var/attacked_stacks = 0
	///If set to 1, the slime will attack and eat anything it comes in contact with
	var/rabid = FALSE
	///AI variable, cooloff-ish for how long it's going to stay in one place
	var/holding_still = 0
	///AI variable, cooloff-ish for how long it's going to follow its target
	var/target_patience = 0
	///A list of friends; they are not considered targets for feeding; passed down after splitting
	var/list/Friends = list()
	///Last phrase said near it and person who said it
	var/list/speech_buffer = list()

/mob/living/simple_animal/slime/Initialize(mapload, new_type=/datum/slime_type/grey, new_is_adult=FALSE)
	var/datum/action/innate/slime/feed/feeding_action = new
	feeding_action.Grant(src)

	is_adult = new_is_adult

	if(is_adult)
		var/datum/action/innate/slime/reproduce/reproduce_action = new
		reproduce_action.Grant(src)
		health = 200
		maxHealth = 200
	else
		var/datum/action/innate/slime/evolve/evolve_action = new
		evolve_action.Grant(src)
	set_slime_type(new_type)
	. = ..()
	set_nutrition(700)

	AddElement(/datum/element/soft_landing)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLIME, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	ADD_TRAIT(src, TRAIT_CANT_RIDE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/slime/Destroy()
	for (var/A in actions)
		var/datum/action/AC = A
		AC.Remove(src)
	set_target(null)
	set_leader(null)
	clear_friends()
	return ..()

///Random slime subtype
/mob/living/simple_animal/slime/random/Initialize(mapload, new_colour, new_is_adult)
	. = ..(mapload, pick(subtypesof(/datum/slime_type)), prob(50))

///Friendly docile subtype
/mob/living/simple_animal/slime/pet
	docile = TRUE

/mob/living/simple_animal/slime/proc/set_slime_type(new_type)
	slime_type = new new_type
	update_name()
	regenerate_icons()

/mob/living/simple_animal/slime/update_name()
	///Checks if the slime has a generic name, in the format of baby/adult slime (123)
	var/static/regex/slime_name_regex = new("\\w+ (baby|adult) slime \\(\\d+\\)")
	if(slime_name_regex.Find(name))
		slime_id = rand(1, 1000)
		name = "[slime_type.colour] [is_adult ? "adult" : "baby"] slime ([slime_id])"
		real_name = name
	return ..()

///randomizes the colour of a slime
/mob/living/simple_animal/slime/proc/random_colour()
	set_slime_type(pick(subtypesof(/datum/slime_type)))

/mob/living/simple_animal/slime/regenerate_icons()
	cut_overlays()
	var/icon_text = "[slime_type.colour] [is_adult ? "adult" : "baby"] slime"
	icon_dead = "[icon_text] dead"
	if(stat != DEAD)
		icon_state = icon_text
		if(current_mood && !stat)
			add_overlay("aslime-[current_mood]")
	else
		icon_state = icon_dead
	..()

/mob/living/simple_animal/slime/updatehealth()
	. = ..()
	var/mod = 0
	if(!HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))
		var/health_deficiency = (maxHealth - health)
		if(health_deficiency >= 45)
			mod += (health_deficiency / 25)
		if(health <= 0)
			mod += 2
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_healthmod, multiplicative_slowdown = mod)

/mob/living/simple_animal/slime/adjust_bodytemperature()
	. = ..()
	var/mod = 0
	if(bodytemperature >= 330.23) // 135 F or 57.08 C
		mod = -1 // slimes become supercharged at high temperatures
	else if(bodytemperature < 283.222)
		mod = ((283.222 - bodytemperature) / 10) * 1.75
	if(mod)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_tempmod, multiplicative_slowdown = mod)

/mob/living/simple_animal/slime/ObjBump(obj/O)
	if(!client && powerlevel > 0)
		var/probab = 10
		switch(powerlevel)
			if(1 to 2)
				probab = 20
			if(3 to 4)
				probab = 30
			if(5 to 6)
				probab = 40
			if(7 to 8)
				probab = 60
			if(9)
				probab = 70
			if(10)
				probab = 95
		if(prob(probab))
			if(istype(O, /obj/structure/window) || istype(O, /obj/structure/grille))
				if(nutrition <= get_hunger_nutrition() && !is_attack_on_cooldown)
					if (is_adult || prob(5))
						O.attack_slime(src)
						is_attack_on_cooldown = TRUE
						addtimer(VARSET_CALLBACK(src, is_attack_on_cooldown, FALSE), 4.5 SECONDS)

/mob/living/simple_animal/slime/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return 2

/mob/living/simple_animal/slime/get_status_tab_items()
	. = ..()
	if(!docile)
		. += "Nutrition: [nutrition]/[get_max_nutrition()]"
	if(amount_grown >= SLIME_EVOLUTION_THRESHOLD)
		if(is_adult)
			. += "You can reproduce!"
		else
			. += "You can evolve!"

	switch(stat)
		if(HARD_CRIT, UNCONSCIOUS)
			. += "You are knocked out by high levels of BZ!"
		else
			. += "Power Level: [powerlevel]"


/mob/living/simple_animal/slime/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	if(!forced)
		amount = -abs(amount)
	return ..() //Heals them

/mob/living/simple_animal/slime/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	powerlevel = 0 // oh no, the power!

/mob/living/simple_animal/slime/MouseDrop(atom/movable/target_atom as mob|obj)
	if(isliving(target_atom) && target_atom != src && usr == src)
		var/mob/living/Food = target_atom
		if(can_feed_on(Food))
			start_feeding(Food)
	return ..()

/mob/living/simple_animal/slime/doUnEquip(obj/item/unequipped_item, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	return

/mob/living/simple_animal/slime/start_pulling(atom/movable/moveable_atom, state, force = move_force, supress_message = FALSE)
	return

/mob/living/simple_animal/slime/attack_ui(slot, params)
	return

/mob/living/simple_animal/slime/attack_slime(mob/living/simple_animal/slime/attacking_slime, list/modifiers)
	if(..()) //successful slime attack
		if(attacking_slime == src)
			return
		if(buckled)
			stop_feeding(silent = TRUE)
			visible_message(span_danger("[attacking_slime] pulls [src] off!"), \
				span_danger("You pull [src] off!"))
			return
		attacked_stacks += 5
		if(nutrition >= 100) //steal some nutrition. negval handled in life()
			adjust_nutrition(-(50 + (40 * attacking_slime.is_adult)))
			attacking_slime.add_nutrition(50 + (40 * attacking_slime.is_adult))
		if(health > 0)
			attacking_slime.adjustBruteLoss(-10 + (-10 * attacking_slime.is_adult))
			attacking_slime.updatehealth()

/mob/living/simple_animal/slime/attack_animal(mob/living/simple_animal/user, list/modifiers)
	. = ..()
	if(.)
		attacked_stacks += 10

/mob/living/simple_animal/slime/attack_paw(mob/living/carbon/human/user, list/modifiers)
	if(..()) //successful monkey bite.
		attacked_stacks += 10

/mob/living/simple_animal/slime/attack_larva(mob/living/carbon/alien/larva/L, list/modifiers)
	if(..()) //successful larva bite.
		attacked_stacks += 10

/mob/living/simple_animal/slime/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	discipline_slime(user)

/mob/living/simple_animal/slime/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(buckled)
		user.do_attack_animation(src, ATTACK_EFFECT_DISARM)
		if(buckled == user)
			if(prob(60))
				user.visible_message(span_warning("[user] attempts to wrestle \the [name] off!"), \
					span_danger("You attempt to wrestle \the [name] off!"))
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)

			else
				user.visible_message(span_warning("[user] manages to wrestle \the [name] off!"), \
					span_notice("You manage to wrestle \the [name] off!"))
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

				discipline_slime(user)

		else
			if(prob(30))
				buckled.visible_message(span_warning("[user] attempts to wrestle \the [name] off of [buckled]!"), \
					span_warning("[user] attempts to wrestle \the [name] off of you!"))
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)

			else
				buckled.visible_message(span_warning("[user] manages to wrestle \the [name] off of [buckled]!"), \
					span_notice("[user] manage to wrestle \the [name] off of you!"))
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

				discipline_slime(user)
	else
		if(stat == DEAD && surgeries.len)
			if(!user.combat_mode || LAZYACCESS(modifiers, RIGHT_CLICK))
				for(var/datum/surgery/operations as anything in surgeries)
					if(operations.next_step(user, modifiers))
						return TRUE
		if(..()) //successful attack
			attacked_stacks += 10

/mob/living/simple_animal/slime/attack_alien(mob/living/carbon/alien/adult/user, list/modifiers)
	if(..()) //if harm or disarm intent.
		attacked_stacks += 10
		discipline_slime(user)


/mob/living/simple_animal/slime/attackby(obj/item/attacking_item, mob/living/user, params)
	if(stat == DEAD && surgeries.len)
		var/list/modifiers = params2list(params)
		if(!user.combat_mode || (LAZYACCESS(modifiers, RIGHT_CLICK)))
			for(var/datum/surgery/operations as anything in surgeries)
				if(operations.next_step(user, modifiers))
					return TRUE
	if(istype(attacking_item, /obj/item/stack/sheet/mineral/plasma) && !stat) //Let's you feed slimes plasma.
		add_friendship(user, 1)
		to_chat(user, span_notice("You feed the slime the plasma. It chirps happily."))
		var/obj/item/stack/sheet/mineral/plasma/sheet = attacking_item
		sheet.use(1)
		return
	if(attacking_item.force > 0)
		attacked_stacks += 10
		if(prob(25))
			user.do_attack_animation(src)
			user.changeNext_move(CLICK_CD_MELEE)
			to_chat(user, span_danger("[attacking_item] passes right through [src]!"))
			return
		if(discipline_stacks && prob(50)) // wow, buddy, why am I getting attacked??
			discipline_stacks = 0
	if(attacking_item.force >= 3)
		var/force_effect = 2 * attacking_item.force
		if(is_adult)
			force_effect = round(attacking_item.force/2)
		if(prob(10 + force_effect))
			discipline_slime(user)

	if(!istype(attacking_item, /obj/item/storage/bag/xeno))
		return ..()

	var/obj/item/storage/xeno_bag = attacking_item
	if(!crossbreed_modification)
		to_chat(user, span_warning("The slime is not currently being mutated."))
		return
	var/has_output = FALSE //Have we outputted text?
	var/has_found = FALSE //Have we found an extract to be added?
	for(var/obj/item/slime_extract/extract in xeno_bag.contents)
		if(extract.crossbreed_modification == crossbreed_modification)
			xeno_bag.atom_storage.attempt_remove(extract, get_turf(src), silent = TRUE)
			qdel(extract)
			applied_crossbreed_amount++
			has_found = TRUE
		if(applied_crossbreed_amount >= SLIME_EXTRACT_CROSSING_REQUIRED)
			to_chat(user, span_notice("You feed the slime as many of the extracts from the bag as you can, and it mutates!"))
			playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)
			spawn_corecross()
			has_output = TRUE
			break

	if(has_output)
		return

	if(!has_found)
		to_chat(user, span_warning("There are no extracts in the bag that this slime will accept!"))
	else
		to_chat(user, span_notice("You feed the slime some extracts from the bag."))
		playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)
	return


///Spawns a crossed slimecore item
/mob/living/simple_animal/slime/proc/spawn_corecross()
	var/static/list/crossbreeds = subtypesof(/obj/item/slimecross)
	visible_message(span_danger("[src] shudders, its mutated core consuming the rest of its body!"))
	playsound(src, 'sound/magic/smoke.ogg', 50, TRUE)
	var/selected_crossbreed_path
	for(var/crossbreed_path in crossbreeds)
		var/obj/item/slimecross/cross_item = crossbreed_path
		if(initial(cross_item.colour) == slime_type.colour && initial(cross_item.effect) == crossbreed_modification)
			selected_crossbreed_path = cross_item
			break
	if(selected_crossbreed_path)
		new selected_crossbreed_path(loc)
	else
		visible_message(span_warning("The mutated core shudders, and collapses into a puddle, unable to maintain its form."))
	qdel(src)

/mob/living/simple_animal/slime/proc/apply_water()
	adjustBruteLoss(rand(15,20))
	if(client)
		return

	if(Target) // Like cats
		set_target(null)
		++discipline_stacks
	return

/mob/living/simple_animal/slime/examine(mob/user)
	. = list("<span class='info'>This is [icon2html(src, user)] \a <EM>[src]</EM>!")
	if (stat == DEAD)
		. += span_deadsay("It is limp and unresponsive.")
	else
		if (stat == UNCONSCIOUS || stat == HARD_CRIT) // Slime stasis
			. += span_deadsay("It appears to be alive but unresponsive.")
		if (getBruteLoss())
			. += "<span class='warning'>"
			if (getBruteLoss() < 40)
				. += "It has some punctures in its flesh!"
			else
				. += "<B>It has severe punctures and tears in its flesh!</B>"
			. += "</span>\n"

		switch(powerlevel)
			if(2 to 3)
				. += "It is flickering gently with a little electrical activity."

			if(4 to 5)
				. += "It is glowing gently with moderate levels of electrical activity."

			if(6 to 9)
				. += span_warning("It is glowing brightly with high levels of electrical activity.")

			if(10)
				. += span_warning("<B>It is radiating with massive levels of electrical activity!</B>")

	. += "</span>"

///Makes a slime not attack people for a while
/mob/living/simple_animal/slime/proc/discipline_slime(mob/user)
	if(stat)
		return

	if(prob(80) && !client)
		discipline_stacks++

		if(!is_adult && discipline_stacks == 1) //if the slime is a baby and has not been overly disciplined, it will give up its grudge
			attacked_stacks = 0

	set_target(null)
	if(buckled)
		stop_feeding(silent = TRUE) //we unbuckle the slime from the mob it latched onto.

	stunned_until = world.time + rand(2 SECONDS, 6 SECONDS)

	Stun(3)
	if(user)
		step_away(src,user,15)

	addtimer(CALLBACK(src, PROC_REF(slime_move), user), 0.3 SECONDS)

///Makes a slime move away, used for a timed callback
/mob/living/simple_animal/slime/proc/slime_move(mob/user)
	if(user)
		step_away(src,user,15)

/mob/living/simple_animal/slime/get_mob_buckling_height(mob/seat)
	if(..())
		return 3

///Sets the slime's current attack target
/mob/living/simple_animal/slime/proc/set_target(new_target)
	var/old_target = Target
	Target = new_target
	if(old_target && !SLIME_CARES_ABOUT(old_target))
		UnregisterSignal(old_target, COMSIG_QDELETING)
	if(Target)
		RegisterSignal(Target, COMSIG_QDELETING, PROC_REF(clear_memories_of), override = TRUE)

///Sets the person the slime is following around
/mob/living/simple_animal/slime/proc/set_leader(new_leader)
	var/old_leader = Leader
	Leader = new_leader
	if(old_leader && !SLIME_CARES_ABOUT(old_leader))
		UnregisterSignal(old_leader, COMSIG_QDELETING)
	if(Leader)
		RegisterSignal(Leader, COMSIG_QDELETING, PROC_REF(clear_memories_of), override = TRUE)

///Alters the friendship value of the target
/mob/living/simple_animal/slime/proc/add_friendship(new_friend, amount = 1)
	if(!Friends[new_friend])
		Friends[new_friend] = 0
	Friends[new_friend] += amount
	if(new_friend)
		RegisterSignal(new_friend, COMSIG_QDELETING, PROC_REF(clear_memories_of), override = TRUE)

///Sets the friendship value of the target
/mob/living/simple_animal/slime/proc/set_friendship(new_friend, amount = 1)
	Friends[new_friend] = amount
	if(new_friend)
		RegisterSignal(new_friend, COMSIG_QDELETING, PROC_REF(clear_memories_of), override = TRUE)

///Removes someone from the friendlist
/mob/living/simple_animal/slime/proc/remove_friend(friend)
	Friends -= friend
	if(friend && !SLIME_CARES_ABOUT(friend))
		UnregisterSignal(friend, COMSIG_QDELETING)

///Adds someone to the friend list
/mob/living/simple_animal/slime/proc/set_friends(new_buds)
	clear_friends()
	for(var/mob/friend as anything in new_buds)
		set_friendship(friend, new_buds[friend])

///Removes everyone from the friend list
/mob/living/simple_animal/slime/proc/clear_friends()
	for(var/mob/friend as anything in Friends)
		remove_friend(friend)

///The passed source will be no longer be the slime's target, leader, or one of its friends
/mob/living/simple_animal/slime/proc/clear_memories_of(datum/source)
	SIGNAL_HANDLER
	if(source == Target)
		set_target(null)
	if(source == Leader)
		set_leader(null)
	remove_friend(source)

#undef SLIME_CARES_ABOUT
