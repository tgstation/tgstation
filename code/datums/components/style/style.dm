#define STYLE_DULL 1
#define STYLE_COOL 2
#define STYLE_BRUTAL 3
#define STYLE_ABSOLUTE 4
#define STYLE_SPACED 5

#define ACTION_KILL "KILL"
#define ACTION_MINOR_KILL "MINOR KILL"
#define ACTION_MAJOR_KILL "MAJOR KILL"
#define ACTION_DISRESPECT "DISRESPECT"
#define ACTION_MELEED "MELEE'D"
#define ACTION_ROCK_MINED "ROCK MINED"
#define ACTION_ORE_MINED "ORE MINED"
#define ACTION_TRAPPER "TRAPPER"
#define ACTION_PARRIED "PARRIED"
#define ACTION_PROJECTILE_BOOST "PROJECTILE BOOST"
#define ACTION_GIBTONITE_HIT "GIBTONITE HIT"
#define ACTION_GIBTONITE_BOOM "GIBTONITE BOOM"
#define ACTION_GIBTONITE_DEFUSED "GIBTONITE DEFUSED"
#define ACTION_MARK_DETONATED "MARK DETONATED"
#define ACTION_GEYSER_MARKED "GEYSER MARKED"

/datum/component/style
	/// Amount of style we have.
	var/style_points = -1
	/// Our style point multiplier.
	var/point_multiplier = 1
	/// The current rank we have.
	var/rank = STYLE_DULL
	/// The last point affecting actions we've done
	var/list/actions = list()
	/// The style meter shown on screen.
	var/atom/movable/screen/style_meter_background/meter
	/// The image of the style meter.
	var/atom/movable/screen/style_meter/meter_image
	/// The timer for meter updating
	var/timerid
	/// Highest score attained by this component, to avoid as much overhead when considering to award a high score to the client
	var/high_score = 0
	/// Weakref to the added projectile parry component
	var/datum/weakref/projectile_parry
	/// What rank, minimum, the user needs to be to hotswap items
	var/hotswap_rank = STYLE_BRUTAL
	/// If this is multitooled, making it make funny noises on the user's rank going up
	var/multitooled = FALSE
	/// A static list of lists of all the possible sounds to play when multitooled, in numerical order
	var/static/list/rankup_sounds = list(
		list(
			'sound/items/style/combo_dull1.ogg',
			'sound/items/style/combo_dull2.ogg',
			'sound/items/style/combo_dull3.ogg',
		),
		list(
			'sound/items/style/combo_cool1.ogg',
			'sound/items/style/combo_cool2.ogg',
			'sound/items/style/combo_cool3.ogg',
		),
		list(
			'sound/items/style/combo_brutal1.ogg',
			'sound/items/style/combo_brutal2.ogg',
			'sound/items/style/combo_brutal3.ogg',
		),
		list(
			'sound/items/style/combo_absolute1.ogg',
			'sound/items/style/combo_absolute2.ogg',
			'sound/items/style/combo_absolute3.ogg',
		),
		list(
			'sound/items/style/combo_spaced1.ogg',
			'sound/items/style/combo_spaced2.ogg',
		),
	)


/datum/component/style/Initialize(multitooled = FALSE)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/mob_parent = parent

	meter = new()
	meter_image = new()
	meter.vis_contents += meter_image
	meter_image.add_filter("meter_mask", 1, list(type = "alpha", icon = icon('icons/hud/style_meter.dmi', "style_meter"), flags = MASK_INVERSE))
	meter.update_appearance()
	meter_image.update_appearance()

	update_screen()

	if(mob_parent.hud_used)
		mob_parent.hud_used.static_inventory += meter
		mob_parent.hud_used.show_hud(mob_parent.hud_used.hud_version)

	START_PROCESSING(SSdcs, src)

	if(multitooled)
		src.multitooled = multitooled

/datum/component/style/RegisterWithParent()
	RegisterSignal(parent, COMSIG_USER_ITEM_INTERACTION, PROC_REF(hotswap))
	RegisterSignal(parent, COMSIG_MOB_MINED, PROC_REF(on_mine))
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_take_damage))
	RegisterSignal(parent, COMSIG_MOB_EMOTED("flip"), PROC_REF(on_flip))
	RegisterSignal(parent, COMSIG_MOB_EMOTED("spin"), PROC_REF(on_spin))
	RegisterSignal(parent, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_attack))
	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_punch))
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH, PROC_REF(on_death))
	RegisterSignal(parent, COMSIG_LIVING_RESONATOR_BURST, PROC_REF(on_resonator_burst))
	RegisterSignal(parent, COMSIG_LIVING_PROJECTILE_PARRIED, PROC_REF(on_projectile_parry))
	RegisterSignal(parent, COMSIG_LIVING_DEFUSED_GIBTONITE, PROC_REF(on_gibtonite_defuse))
	RegisterSignal(parent, COMSIG_LIVING_CRUSHER_DETONATE, PROC_REF(on_crusher_detonate))
	RegisterSignal(parent, COMSIG_LIVING_DISCOVERED_GEYSER, PROC_REF(on_geyser_discover))

	projectile_parry = WEAKREF(parent.AddComponent(\
		/datum/component/projectile_parry,\
		list(\
			/obj/projectile/colossus,\
			/obj/projectile/temp/watcher,\
			/obj/projectile/kinetic,\
			/obj/projectile/bileworm_acid,\
			/obj/projectile/herald,\
			/obj/projectile/kiss,\
			)\
		)
	)


/datum/component/style/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_USER_ITEM_INTERACTION)
	UnregisterSignal(parent, COMSIG_MOB_MINED)
	UnregisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE)
	UnregisterSignal(parent, list(COMSIG_MOB_EMOTED("flip"), COMSIG_MOB_EMOTED("spin")))
	UnregisterSignal(parent, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_LIVING_UNARMED_ATTACK))
	UnregisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH)
	UnregisterSignal(parent, COMSIG_LIVING_RESONATOR_BURST)
	UnregisterSignal(parent, COMSIG_LIVING_PROJECTILE_PARRIED)
	UnregisterSignal(parent, COMSIG_LIVING_DEFUSED_GIBTONITE)
	UnregisterSignal(parent, COMSIG_LIVING_CRUSHER_DETONATE)
	UnregisterSignal(parent, COMSIG_LIVING_DISCOVERED_GEYSER)

	if(projectile_parry)
		qdel(projectile_parry.resolve())


/datum/component/style/Destroy(force)
	STOP_PROCESSING(SSdcs, src)
	var/mob/mob_parent = parent
	if(mob_parent.hud_used)
		mob_parent.hud_used.static_inventory -= meter
		mob_parent.hud_used.show_hud(mob_parent.hud_used.hud_version)
	return ..()


/datum/component/style/process(seconds_per_tick)
	point_multiplier = round(max(point_multiplier - 0.2 * seconds_per_tick, 1), 0.1)
	change_points(-5 * seconds_per_tick * ROUND_UP((style_points + 1) / 200), use_multiplier = FALSE)
	update_screen()



/datum/component/style/proc/add_action(action, amount)
	if(length(actions) > 9)
		actions.Cut(1, 2)
	if(length(actions))
		var/last_action = actions[length(actions)]
		if(action == actions[last_action])
			amount *= 0.5
	var/id
	while(!id || (id in actions))
		id = "action[rand(1, 1000)]"
	actions[id] = action
	change_points(amount)
	addtimer(CALLBACK(src, PROC_REF(remove_action), id), 10 SECONDS)

/datum/component/style/proc/remove_action(action_id)
	actions -= action_id
	update_screen()

/datum/component/style/proc/change_points(amount, use_multiplier = TRUE)
	if(!amount)
		return

	var/modified_amount = amount * (amount > 0 ? 1 - 0.1 * rank : 1) * (use_multiplier ? point_multiplier : 1)
	style_points = max(style_points + modified_amount, -1)
	update_screen()

	if(style_points > high_score)
		var/mob/mob_parent = parent
		if((mob_parent.flags_1 & ADMIN_SPAWNED_1) || (mob_parent.datum_flags & DF_VAR_EDITED) || (datum_flags & DF_VAR_EDITED) || !SSachievements.achievements_enabled || !mob_parent.client) // No varediting/spawning this or the owner
			return

		var/award_status = mob_parent.client.get_award_status(/datum/award/score/style_score)

		if(award_status >= style_points)
			high_score = style_points
			return

		mob_parent.client.give_award(/datum/award/score/style_score, mob_parent, style_points - award_status)
		high_score = style_points

/datum/component/style/proc/update_screen(rank_changed)
	var/go_back = null
	if(!isnull(rank_changed))
		timerid = null
		if(rank_changed == point_to_rank())
			go_back = rank > rank_changed ? 100 : 0

			if(multitooled && (rank_changed > rank)) // make funny noises
				var/mob/mob_parent = parent
				mob_parent.playsound_local(get_turf(mob_parent), pick(rankup_sounds[rank_changed]), 70, vary = FALSE)

			if((rank < hotswap_rank) && (rank_changed >= hotswap_rank))
				var/mob/mob_parent = parent
				mob_parent.balloon_alert(mob_parent, "hotswapping enabled")

			else if((rank >= hotswap_rank) && (rank_changed < hotswap_rank))
				var/mob/mob_parent = parent
				mob_parent.balloon_alert(mob_parent, "hotswapping disabled")

			rank = rank_changed
	meter.maptext = "[format_rank_string(rank)][generate_multiplier()][generate_actions()]"
	meter.maptext_y = 100 - 9 * length(actions)
	update_meter(point_to_rank(), go_back)

/datum/component/style/proc/update_meter(new_rank, go_back)
	if(!isnull(go_back))
		animate(meter_image.get_filter("meter_mask"), time = 0 SECONDS, flags = ANIMATION_END_NOW, x = go_back)
	animate(meter_image.get_filter("meter_mask"), time = 1 SECONDS, x = (rank > new_rank ? 0 : ((rank < new_rank) || (style_points >= 500) ? 100 : (style_points % 100) + 1)))
	if(!isnull(new_rank) && new_rank != rank && !timerid)
		timerid = addtimer(CALLBACK(src, PROC_REF(update_screen), new_rank), 1 SECONDS)

/datum/component/style/proc/rank_to_color(new_rank)
	switch(new_rank)
		if(STYLE_DULL)
			return "#aaaaaa"
		if(STYLE_COOL)
			return "#aaaaff"
		if(STYLE_BRUTAL)
			return "#aaffff"
		if(STYLE_ABSOLUTE)
			return "#66ffff"
		if(STYLE_SPACED)
			return "#ffaa00"

/datum/component/style/proc/point_to_rank()
	switch(style_points)
		if(-1 to 99)
			return STYLE_DULL
		if(100 to 199)
			return STYLE_COOL
		if(200 to 299)
			return STYLE_BRUTAL
		if(300 to 399)
			return STYLE_ABSOLUTE
		if(400 to INFINITY)
			return STYLE_SPACED


/datum/component/style/proc/rank_to_string(new_rank)
	switch(new_rank)
		if(STYLE_DULL)
			return "DULL"
		if(STYLE_COOL)
			return "COOL"
		if(STYLE_BRUTAL)
			return "BRUTAL"
		if(STYLE_ABSOLUTE)
			return "ABSOLUTE"
		if(STYLE_SPACED)
			return "SPACED!"

/datum/component/style/proc/format_rank_string(new_rank)
	var/rank_string = rank_to_string(new_rank)
	var/final_string = ""
	final_string += "<span class='maptext' style='font-size: 8px'><font color='[rank_to_color(new_rank)]'><b>[rank_string[1]]</b>"
	final_string += "<span style='font-size: 7px'>[copytext(rank_string, 2)]</span></font></span>"
	return final_string

/datum/component/style/proc/generate_multiplier()
	return "<br><span class='maptext' style='font-size: 7px'>MULTIPLIER: [point_multiplier]X</span>"

/datum/component/style/proc/generate_actions()
	var/action_string = ""
	for(var/action in actions)
		action_string += "<br><span class='maptext'>+ <font color='[action_to_color(actions[action])]'>[actions[action]]</font></span>"
	return action_string

/datum/component/style/proc/action_to_color(action)
	switch(action)
		if(ACTION_KILL)
			return "#ff0000"
		if(ACTION_MINOR_KILL)
			return "#ff6666"
		if(ACTION_MAJOR_KILL)
			return "#ffaa00"
		if(ACTION_DISRESPECT)
			return "#990000"
		if(ACTION_MELEED)
			return "#660033"
		if(ACTION_ROCK_MINED)
			return "#664433"
		if(ACTION_ORE_MINED)
			return "#663366"
		if(ACTION_TRAPPER)
			return "#363366"
		if(ACTION_PARRIED)
			return "#591324"
		if(ACTION_PROJECTILE_BOOST)
			return "#80112c"
		if(ACTION_GIBTONITE_HIT)
			return "#201d40"
		if(ACTION_GIBTONITE_BOOM)
			return "#1e176e"
		if(ACTION_GIBTONITE_DEFUSED)
			return "#2b2573"
		if(ACTION_MARK_DETONATED)
			return "#ac870e"
		if(ACTION_GEYSER_MARKED)
			return "#364866"

/// A proc that lets a user, when their rank >= `hotswap_rank`, swap items in storage with what's in their hands, simply by clicking on the stored item with a held item
/datum/component/style/proc/hotswap(mob/living/source, atom/target, obj/item/weapon, click_parameters)
	SIGNAL_HANDLER

	if((rank < hotswap_rank) || !isitem(target) || !(target in source.get_all_contents()))
		return NONE

	var/obj/item/item_target = target

	if(!(item_target.item_flags & IN_STORAGE))
		return NONE

	var/datum/storage/atom_storage = item_target.loc.atom_storage

	if(!atom_storage.can_insert(weapon, source, messages = FALSE))
		source.balloon_alert(source, "unable to hotswap!")
		return NONE

	atom_storage.attempt_insert(weapon, source, override = TRUE)
	INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living, put_in_hands), target)
	source.visible_message(span_notice("[source] quickly swaps [weapon] out with [target]!"), span_notice("You quickly swap [weapon] with [target]."))
	return ITEM_INTERACT_BLOCKING

// Point givers
/datum/component/style/proc/on_punch(mob/living/carbon/human/punching_person, atom/attacked_atom, proximity)
	SIGNAL_HANDLER

	if(!proximity || !punching_person.combat_mode || !isliving(attacked_atom))
		return

	var/mob/living/disrespected = attacked_atom
	if(disrespected.stat || faction_check(punching_person.faction, disrespected.faction) || !(FACTION_MINING in disrespected.faction))
		return

	add_action(ACTION_DISRESPECT, 60 * (ismegafauna(disrespected) ? 2 : 1))

/datum/component/style/proc/on_attack(mob/living/attacking_person, mob/living/attacked_mob)
	SIGNAL_HANDLER

	if(!istype(attacked_mob) || attacked_mob.stat)
		return

	var/mob/living/attacked = attacked_mob
	var/mob/mob_parent = parent
	if(faction_check(attacking_person.faction, attacked.faction) || !(FACTION_MINING in attacked.faction) || (istype(mob_parent.get_active_held_item(), /obj/item/kinetic_crusher) && attacked.has_status_effect(/datum/status_effect/crusher_mark)))
		return

	add_action(ACTION_MELEED, 50 * (ismegafauna(attacked) ? 1.5 : 1))

/datum/component/style/proc/on_mine(datum/source, turf/closed/mineral/rock, give_exp)
	SIGNAL_HANDLER

	if(istype(rock, /turf/closed/mineral/gibtonite))
		var/turf/closed/mineral/gibtonite/gib_rock = rock
		switch(gib_rock.stage)
			if(GIBTONITE_UNSTRUCK)
				add_action(ACTION_GIBTONITE_HIT, 40)
				return

			if(GIBTONITE_ACTIVE)
				add_action(ACTION_GIBTONITE_BOOM, 50)
				return

			if(GIBTONITE_DETONATE)
				add_action(ACTION_GIBTONITE_BOOM, 50)
				return

	if(rock.mineralType)
		if(give_exp)
			add_action(ACTION_ORE_MINED, 40)
		rock.mineralAmt = ROUND_UP(rock.mineralAmt * (1 + ((rank * 0.1) - 0.3))) // You start out getting 20% less ore, but it goes up to 20% more at S-tier

	else if(give_exp)
		add_action(ACTION_ROCK_MINED, 25)

/datum/component/style/proc/on_resonator_burst(datum/source, mob/creator, mob/living/hit_living)
	SIGNAL_HANDLER

	if(faction_check(creator.faction, hit_living.faction) || (hit_living.stat != CONSCIOUS) || !(FACTION_MINING in hit_living.faction))
		return

	add_action(ACTION_TRAPPER, 70)

/datum/component/style/proc/on_projectile_parry(datum/source, obj/projectile/parried)
	SIGNAL_HANDLER

	if(parried.firer == parent)
		add_action(ACTION_PROJECTILE_BOOST, 160) // This is genuinely really impressive
	else
		add_action(ACTION_PARRIED, 110)

/datum/component/style/proc/on_gibtonite_defuse(datum/source, det_time)
	SIGNAL_HANDLER

	add_action(ACTION_GIBTONITE_DEFUSED, min(40, 20 * (10 - det_time))) // 40 to 180 points depending on speed

/datum/component/style/proc/on_crusher_detonate(datum/source, mob/living/target, obj/item/kinetic_crusher/crusher, backstabbed)
	SIGNAL_HANDLER

	if(target.stat == DEAD)
		return

	var/has_brimdemon_trophy = locate(/obj/item/crusher_trophy/brimdemon_fang) in crusher.trophies

	add_action(ACTION_MARK_DETONATED, round((backstabbed ? 60 : 30) * (ismegafauna(target) ? 1.5 : 1) * (has_brimdemon_trophy ? 1.25 : 1)))


/datum/component/style/proc/on_geyser_discover(datum/source, obj/structure/geyser/geyser)
	SIGNAL_HANDLER

	add_action(ACTION_GEYSER_MARKED, 100)


// Emote-based multipliers
/datum/component/style/proc/on_flip()
	SIGNAL_HANDLER

	point_multiplier = round(min(point_multiplier + 0.5, 3), 0.1)
	update_screen()

/datum/component/style/proc/on_spin()
	SIGNAL_HANDLER

	point_multiplier = round(min(point_multiplier + 0.3, 3), 0.1)
	update_screen()


// Negative effects
/datum/component/style/proc/on_take_damage(...)
	SIGNAL_HANDLER

	point_multiplier = round(max(point_multiplier - 0.3, 1), 0.1)
	change_points(-30, use_multiplier = FALSE)

/datum/component/style/proc/on_death(datum/source, mob/living/died, gibbed)
	SIGNAL_HANDLER

	var/mob/mob_parent = parent
	if(died == parent)
		change_points(-500, use_multiplier = FALSE)
		return
	else if(faction_check(mob_parent.faction, died.faction) || !(FACTION_MINING in died.faction) || (died.z != mob_parent.z) || !(died in view(mob_parent.client?.view, get_turf(mob_parent))))
		return
	if(ismegafauna(died))
		add_action(ACTION_MAJOR_KILL, 350)

	else if(died.maxHealth >= 75) //at least legions
		add_action(ACTION_KILL, 125)

	else if(died.maxHealth >= 30) //at least goliath children, dont count legion skulls
		add_action(ACTION_MINOR_KILL, 75)

#undef STYLE_DULL
#undef STYLE_COOL
#undef STYLE_BRUTAL
#undef STYLE_ABSOLUTE
#undef STYLE_SPACED

#undef ACTION_KILL
#undef ACTION_MINOR_KILL
#undef ACTION_MAJOR_KILL
#undef ACTION_DISRESPECT
#undef ACTION_MELEED
#undef ACTION_ROCK_MINED
#undef ACTION_ORE_MINED
#undef ACTION_TRAPPER
#undef ACTION_PARRIED
#undef ACTION_PROJECTILE_BOOST
#undef ACTION_GIBTONITE_HIT
#undef ACTION_GIBTONITE_BOOM
#undef ACTION_GIBTONITE_DEFUSED
#undef ACTION_MARK_DETONATED
#undef ACTION_GEYSER_MARKED
