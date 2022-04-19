#define DULL 1
#define COOL 2
#define BRUTAL 3
#define ABSOLUTE 4
#define SPACED 5

/datum/component/style
	/// Amount of style we have.
	var/style_points = -1
	/// Our style point multiplier.
	var/point_multiplier = 1
	/// The current rank we have.
	var/rank = DULL
	/// The last point affecting actions we've done
	var/list/actions = list()
	/// The style meter shown on screen.
	var/atom/movable/screen/style_meter_background/meter
	/// The image of the style meter.
	var/atom/movable/screen/style_meter/meter_image
	/// The timer for meter updating
	var/timerid

/datum/component/style/Initialize()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/mob_parent = parent
	meter = new()
	meter_image = new()
	meter.vis_contents += meter_image
	meter_image.add_filter("meter_mask", 1, list(type="alpha",icon=icon('icons/hud/style_meter.dmi', "style_meter"),flags=MASK_INVERSE))
	update_screen()
	mob_parent.hud_used?.static_inventory += meter
	START_PROCESSING(SSdcs, src)

/datum/component/style/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_MINED, .proc/on_mine)
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, .proc/on_take_damage)
	RegisterSignal(parent, COMSIG_MOB_EMOTED("flip"), .proc/on_flip)
	RegisterSignal(parent, COMSIG_MOB_EMOTED("spin"), .proc/on_spin)
	RegisterSignal(parent, COMSIG_MOB_ITEM_ATTACK, .proc/on_attack)
	RegisterSignal(parent, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, .proc/on_punch)
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH, .proc/on_death)

/datum/component/style/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT))
	UnregisterSignal(parent, list(COMSIG_MOB_MINED))
	UnregisterSignal(parent, list(COMSIG_MOB_APPLY_DAMAGE))
	UnregisterSignal(parent, list(COMSIG_MOB_EMOTED("flip"), COMSIG_MOB_EMOTED("spin")))
	UnregisterSignal(parent, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_HUMAN_MELEE_UNARMED_ATTACK))
	UnregisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH)

/datum/component/style/Destroy(force, silent)
	STOP_PROCESSING(SSdcs, src)
	var/mob/mob_parent = parent
	mob_parent.hud_used?.static_inventory -= meter
	return ..()

/datum/component/style/process(delta_time)
	point_multiplier = round(max(point_multiplier - 0.2 * delta_time, 1), 0.1)
	change_points(-5*delta_time*ROUND_UP((style_points+1)/200), use_multiplier = FALSE)

/datum/component/style/proc/on_mine(datum/source, turf/closed/mineral/rock, give_exp)
	SIGNAL_HANDLER

	if(!give_exp)
		return
	if(rock.mineralType)
		add_action("ORE MINED", 40)
		rock.mineralAmt = ROUND_UP(rock.mineralAmt * (1 + (rank * 0.2)))
	else
		add_action("ROCK MINED", 25)

/datum/component/style/proc/on_take_damage()
	SIGNAL_HANDLER

	point_multiplier = round(max(point_multiplier - 0.3, 1), 0.1)
	change_points(-30, use_multiplier = FALSE)

/datum/component/style/proc/on_flip()
	SIGNAL_HANDLER

	point_multiplier = round(min(point_multiplier + 0.5, 3), 0.1)
	update_screen()

/datum/component/style/proc/on_spin()
	SIGNAL_HANDLER

	point_multiplier = round(min(point_multiplier + 0.3, 3), 0.1)
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
	addtimer(CALLBACK(src, .proc/remove_action, id), 10 SECONDS)

/datum/component/style/proc/remove_action(action_id)
	actions -= action_id
	update_screen()

/datum/component/style/proc/change_points(amount, use_multiplier = TRUE)
	if(!amount)
		return
	var/modified_amount = amount * (amount > 0 ? 1-0.1*rank : 1) * (use_multiplier ? point_multiplier : 1)
	style_points = clamp(style_points + modified_amount, -1, 499)
	update_screen()

/datum/component/style/proc/update_screen(rank_changed)
	var/go_back = null
	if(!isnull(rank_changed))
		timerid = null
		if(rank_changed == point_to_rank())
			go_back = rank > rank_changed ? 100 : 0
			rank = rank_changed
	meter.maptext = "[format_rank_string(rank)][generate_multiplier()][generate_actions()]"
	meter.maptext_y = 100 - 9 * length(actions)
	update_meter(point_to_rank(), go_back)

/datum/component/style/proc/update_meter(new_rank, go_back)
	if(!isnull(go_back))
		animate(meter_image.get_filter("meter_mask"), time = 0 SECONDS, flags = ANIMATION_END_NOW, x = go_back)
	animate(meter_image.get_filter("meter_mask"), time = 1 SECONDS, x = (rank > new_rank ? 0 : (rank < new_rank ? 100 : (style_points % 100) + 1)))
	if(!isnull(new_rank) && new_rank != rank && !timerid)
		timerid = addtimer(CALLBACK(src, .proc/update_screen, new_rank), 1 SECONDS)

/datum/component/style/proc/rank_to_color(new_rank)
	switch(new_rank)
		if(DULL)
			return "#aaaaaa"
		if(COOL)
			return "#aaaaff"
		if(BRUTAL)
			return "#aaffff"
		if(ABSOLUTE)
			return "#66ffff"
		if(SPACED)
			return "#ffaa00"

/datum/component/style/proc/point_to_rank()
	switch(style_points)
		if(-1 to 99)
			return DULL
		if(100 to 199)
			return COOL
		if(200 to 299)
			return BRUTAL
		if(300 to 399)
			return ABSOLUTE
		if(400 to 499)
			return SPACED

/datum/component/style/proc/rank_to_string(new_rank)
	switch(new_rank)
		if(DULL)
			return "DULL"
		if(COOL)
			return "COOL"
		if(BRUTAL)
			return "BRUTAL"
		if(ABSOLUTE)
			return "ABSOLUTE"
		if(SPACED)
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
		if("KILL")
			return "#ff0000"
		if("MINOR KILL")
			return "#ff6666"
		if("MAJOR KILL")
			return "#ffaa00"
		if("DISRESPECT")
			return "#990000"
		if("MELEE'D")
			return "#660033"
		if("ROCK MINED")
			return "#664433"
		if("ORE MINED")
			return "#663366"

/datum/component/style/proc/on_punch(mob/living/carbon/human/punching_person, atom/attacked_atom, proximity)
	if(!ishostile(attacked_atom) || !proximity || !punching_person.combat_mode)
		return
	var/mob/living/simple_animal/hostile/disrespected = attacked_atom
	if(disrespected.stat || faction_check(punching_person.faction, disrespected.faction))
		return
	add_action("DISRESPECT", 60 * (ismegafauna(disrespected) ? 2 : 1))

/datum/component/style/proc/on_attack(mob/living/attacking_person, mob/living/attacked_mob)
	if(!ishostile(attacked_mob) || attacked_mob.stat)
		return
	var/mob/living/simple_animal/hostile/attacked_hostile = attacked_mob
	if(faction_check(attacking_person.faction, attacked_hostile.faction))
		return
	add_action("MELEE'D", 50 * (ismegafauna(attacked_hostile) ? 1.5 : 1))

/datum/component/style/proc/on_death(datum/source, mob/living/died, gibbed)
	SIGNAL_HANDLER

	var/mob/mob_parent = parent
	if(died == parent)
		change_points(-500, use_multiplier = FALSE)
	else if(!ishostile(died) || faction_check(mob_parent.faction, died.faction) || !(died in view(mob_parent.client?.view, get_turf(mob_parent))))
		return
	if(ismegafauna(died))
		add_action("MAJOR KILL", 350)
	else if(died.maxHealth >= 75) //at least legions
		add_action("KILL", 125)
	else if(died.maxHealth >= 30) //at least goliath children, dont count legion skulls
		add_action("MINOR KILL", 75)

/obj/item/style_meter
	name = "style meter attachment"
	desc = "Attach this to a pair of glasses to install a style meter system in them. \
		You get style points from performing stylish acts and lose them for breaking your style. \
		The style affects the quality of your mining, with you being able to mine ore better during a good chain."
	icon_state = "style_meter"
	icon = 'icons/obj/clothing/glasses.dmi'
	/// The style meter component we give.
	var/datum/component/style/style_meter

/obj/item/style_meter/afterattack(atom/movable/attacked_atom, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!istype(attacked_atom, /obj/item/clothing/glasses))
		return
	forceMove(attacked_atom)
	attacked_atom.vis_contents += src
	RegisterSignal(attacked_atom, COMSIG_ITEM_EQUIPPED, .proc/check_wearing)
	RegisterSignal(attacked_atom, COMSIG_ITEM_DROPPED, .proc/on_drop)
	RegisterSignal(attacked_atom, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	balloon_alert(user, "style meter attached")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	if(!iscarbon(attacked_atom.loc))
		return
	var/mob/living/carbon/carbon_wearer = attacked_atom.loc
	if(carbon_wearer.glasses != attacked_atom)
		return
	style_meter = carbon_wearer.AddComponent(/datum/component/style)

/obj/item/style_meter/Moved(atom/old_loc, Dir)
	. = ..()
	if(!istype(old_loc, /obj/item/clothing/glasses))
		return
	clean_up(old_loc)

/obj/item/style_meter/Destroy(force)
	if(istype(loc, /obj/item/clothing/glasses))
		clean_up(loc)
	return ..()

/obj/item/style_meter/proc/check_wearing(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!(slot & ITEM_SLOT_EYES))
		if(style_meter)
			QDEL_NULL(style_meter)
		return
	style_meter = equipper.AddComponent(/datum/component/style)

/obj/item/style_meter/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!style_meter)
		return
	QDEL_NULL(style_meter)

/obj/item/style_meter/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("<b>Alt-click</b> to remove the style meter.")

/obj/item/style_meter/proc/clean_up(atom/movable/old_location)
	old_location.vis_contents -= src
	UnregisterSignal(old_location, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(old_location, COMSIG_ITEM_DROPPED)
	UnregisterSignal(old_location, COMSIG_PARENT_EXAMINE)
	if(!style_meter)
		return
	QDEL_NULL(style_meter)

/atom/movable/screen/style_meter_background
	icon_state = "style_meter_background"
	icon = 'icons/hud/style_meter.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "WEST,CENTER:16"
	maptext_height = 120
	maptext_width = 105
	maptext_x = 5
	maptext_y = 100
	maptext = ""
	layer = SCREENTIP_LAYER

/atom/movable/screen/style_meter
	icon_state = "style_meter"
	icon = 'icons/hud/style_meter.dmi'
	layer = SCREENTIP_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
