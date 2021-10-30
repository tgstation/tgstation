/// If a bleeding carbon attacks an overdrive emagged cleanbot with a weapon, their total bleed rate is multiplied by this and added to the taped_weapon's force for the block chance
#define CLEANBOT_BLOCK_ITEM_BLEED_MULT 5
/// If a bleeding carbon attacks an overdrive emagged cleanbot with their hand, their total bleed rate is multiplied by this for the parry chance (punching a knife is a bad idea!)
#define CLEANBOT_BLOCK_HAND_BLEED_MULT 15

/// If the target_parts argument is set to this for [/mob/living/simple_animal/bot/cleanbot/proc/stab_target], we try attacking the legs (default)
#define CLEANBOT_STAB_LEGS 0
/// If the target_parts argument is set to this for [/mob/living/simple_animal/bot/cleanbot/proc/stab_target], we try attacking the arms instead
#define CLEANBOT_STAB_ARMS 1

/// If the cleanbot stabs someone while not in overdrive emag mode, the weapon's force is multiplied by this
#define CLEANBOT_UNEMAGGED_FORCE_PENALTY 0.5

//Cleanbot
/mob/living/simple_animal/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/mob/aibots.dmi'
	icon_state = "cleanbot0"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE //Service
	bot_type = CLEAN_BOT
	model = "Cleanbot"
	bot_core_type = /obj/machinery/bot_core/cleanbot
	window_id = "autoclean"
	window_name = "Automatic Station Cleaner v1.4"
	pass_flags = PASSMOB | PASSFLAPS
	path_image_color = "#993299"

	var/blood = 1
	var/trash = 0
	var/pests = 0
	var/drawn = 0

	var/list/target_types
	var/obj/effect/decal/cleanable/target
	var/max_targets = 50 //Maximum number of targets a cleanbot can ignore.
	var/oldloc = null
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/next_dest
	var/next_dest_loc

	/// The weapon taped to the cleanbot
	var/obj/item/taped_weapon
	/// The original force of the cleanbot's taped_weapon when it was attached
	var/original_weapon_force
	/// The original name of the cleanbot, before it became highly decorated with titles
	var/chosen_name
	/// The list of job titles this cleanbot has successfully stabbed
	var/list/stolen_valor

	var/static/list/officers = list("Captain", "Head of Personnel", "Head of Security")
	var/static/list/command = list("Captain" = "Cpt.","Head of Personnel" = "Lt.")
	var/static/list/security = list("Head of Security" = "Maj.", "Warden" = "Sgt.", "Detective" =  "Det.", "Security Officer" = "Officer")
	var/static/list/engineering = list("Chief Engineer" = "Chief Engineer", "Station Engineer" = "Engineer", "Atmospherics Technician" = "Technician")
	var/static/list/medical = list("Chief Medical Officer" = "C.M.O.", "Medical Doctor" = "M.D.", "Paramedic" = "E.M.T.", "Psychologist" = "LCSW", "Chemist" = "Pharm.D.")
	var/static/list/research = list("Research Director" = "Ph.D.", "Roboticist" = "M.S.", "Scientist" = "B.S.")
	var/static/list/legal = list("Lawyer" = "Esq.")

	var/list/prefixes
	var/list/suffixes

	/// if we have all the top titles, grant achievements to living mobs that gaze upon our cleanbot god
	var/ascended = FALSE

/// If the weapon we're trying to attach is actually compatible with the cleanbot
/mob/living/simple_animal/bot/cleanbot/proc/can_attach_weapon(obj/item/attaching_weapon)
	if(HAS_TRAIT(attaching_weapon, TRAIT_CLEANBOT_COMPATIBLE) && attaching_weapon.force)
		return TRUE

/// Where we actually attach the weapon to the cleanbot
/mob/living/simple_animal/bot/cleanbot/proc/deputize(obj/item/attaching_weapon, mob/user, forced = FALSE)
	if(taped_weapon)
		to_chat(user, span_warning("[src] already has \the [taped_weapon] attached to it!"))
		return

	if(!can_attach_weapon(attaching_weapon) && !forced)
		return

	if(user)
		if(!in_range(src, user))
			return
		to_chat(user, span_notice("You attach \the [attaching_weapon] to \the [src]."))
		user.transferItemToLoc(attaching_weapon, src)
	else
		attaching_weapon.forceMove(src)

	original_weapon_force = attaching_weapon.force
	if(emagged != BOT_EMAGGED_OVERDRIVE)
		attaching_weapon.force *= CLEANBOT_UNEMAGGED_FORCE_PENALTY

	taped_weapon = attaching_weapon

	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/on_move_while_armed)

/// Cycle through all of our stolen titles and see which ones we're going to apply to our name
/mob/living/simple_animal/bot/cleanbot/proc/update_titles()
	var/working_title = ""

	ascended = TRUE

	for(var/pref in prefixes)
		for(var/title in pref)
			if(title in stolen_valor)
				working_title += pref[title] + " "
				if(title in officers)
					commissioned = TRUE
				break
			else
				ascended = FALSE // we didn't have the first entry in the list if we got here, so we're not achievement worthy yet

	working_title += chosen_name

	for(var/suf in suffixes)
		for(var/title in suf)
			if(title in stolen_valor)
				working_title += " " + suf[title]
				break
			else
				ascended = FALSE

	name = working_title

/// When someone enters a tile we're on
/mob/living/simple_animal/bot/cleanbot/proc/on_entered(datum/source, atom/movable/stepping_on_us)
	SIGNAL_HANDLER

	if(!taped_weapon || !iscarbon(stepping_on_us) || !has_gravity())
		return

	stab_target(stepping_on_us)

/// When we enter a tile someone else is on
/mob/living/simple_animal/bot/cleanbot/proc/on_move_while_armed(datum/source, old_loc, movement_dir, forced, old_locs)
	SIGNAL_HANDLER

	if(!taped_weapon || !has_gravity() || !isturf(loc))
		return

	for(var/mob/living/carbon/iter_carbon in loc)
		if(iter_carbon.buckled)
			visible_message(span_danger("[src] veers around [iter_carbon]."), span_warning("You veer around [iter_carbon]."), vision_distance = COMBAT_MESSAGE_RANGE)
			continue
		if(iter_carbon.body_position == LYING_DOWN)
			visible_message(span_danger("[src] rolls over [iter_carbon]."), span_warning("You roll over [iter_carbon]."), vision_distance = COMBAT_MESSAGE_RANGE)
			continue
		stab_target(iter_carbon)

/**
 * This is the proc that does the actual stabbing on the target carbon. It attacks with the taped_weapon, and knocks the target down for 2 seconds
 *
 * Arguments:
 * * stab_target - Who's getting stabbed
 * * target_parts - Are we stabbing their legs (most of the time) or their arms (for parries)
 */
/mob/living/simple_animal/bot/cleanbot/proc/stab_target(mob/living/carbon/stab_target, target_parts = CLEANBOT_STAB_LEGS)
	if(!taped_weapon || !istype(stab_target) || !has_gravity())
		return

	if(target_parts == CLEANBOT_STAB_ARMS)
		zone_selected = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	else
		zone_selected = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

	if(stab_target.job && !(stab_target.job in stolen_valor))
		stolen_valor += stab_target.job
	update_titles()

	INVOKE_ASYNC(taped_weapon, /obj/item.proc/attack, stab_target, src)
	stab_target.Knockdown(2 SECONDS)

/mob/living/simple_animal/bot/cleanbot/examine(mob/user)
	. = ..()
	if(taped_weapon)
		. += span_warning("Is that \a [taped_weapon] taped to it...?")

		if(ascended && user.stat == CONSCIOUS && user.client)
			user.client.give_award(/datum/award/achievement/misc/cleanboss, user)

/mob/living/simple_animal/bot/cleanbot/update_overlays()
	. = ..()
	if(taped_weapon)
		. += image(icon=taped_weapon.lefthand_file,icon_state=taped_weapon.inhand_icon_state)

/mob/living/simple_animal/bot/cleanbot/Initialize(mapload)
	. = ..()

	chosen_name = name
	get_targets()
	icon_state = "cleanbot[on]"

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/id_trim/job/jani_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/janitor]
	access_card.add_access(jani_trim.access + jani_trim.wildcard_access)
	prev_access = access_card.access.Copy()
	stolen_valor = list()

	prefixes = list(command, security, engineering)
	suffixes = list(research, medical, legal)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/bot/cleanbot/Destroy()
	if(taped_weapon)
		taped_weapon.force = original_weapon_force
		drop_part(taped_weapon, drop_location())
		taped_weapon = null
	return ..()

/mob/living/simple_animal/bot/cleanbot/turn_on()
	..()
	icon_state = "cleanbot[on]"
	bot_core.updateUsrDialog()

/mob/living/simple_animal/bot/cleanbot/turn_off()
	..()
	icon_state = "cleanbot[on]"
	bot_core.updateUsrDialog()

/mob/living/simple_animal/bot/cleanbot/bot_reset()
	..()
	ignore_list = list() //Allows the bot to clean targets it previously ignored due to being unreachable.
	target = null
	oldloc = null

/mob/living/simple_animal/bot/cleanbot/set_custom_texts()
	text_hack = "You corrupt [name]'s cleaning software."
	text_dehack = "[name]'s software has been reset!"
	text_dehack_fail = "[name] does not seem to respond to your repair code!"

/mob/living/simple_animal/bot/cleanbot/attackby(obj/item/W, mob/living/user, params)
	if(W.GetID())
		if(bot_core.allowed(user) && !open && !emagged)
			locked = !locked
			to_chat(user, span_notice("You [ locked ? "lock" : "unlock"] \the [src] behaviour controls."))
		else
			if(emagged)
				to_chat(user, span_warning("ERROR"))
			if(open)
				to_chat(user, span_warning("Please close the access panel before locking it."))
			else
				to_chat(user, span_notice("\The [src] doesn't seem to respect your authority."))
		return

	else if(can_attach_weapon(W) && !user.combat_mode && !taped_weapon)
		to_chat(user, span_notice("You start attaching \the [W] to \the [src]..."))
		if(do_after(user, 2.5 SECONDS, target = src))
			deputize(W, user)
		return

	else if(taped_weapon && W.force && emagged == BOT_EMAGGED_OVERDRIVE && iscarbon(user) && in_range(user, src))
		var/mob/living/carbon/carbon_user = user
		var/user_bleed_rate = carbon_user.get_bleed_rate()
		var/block_chance = (user_bleed_rate * CLEANBOT_BLOCK_ITEM_BLEED_MULT) + taped_weapon.force // with CLEANBOT_BLOCK_ITEM_BLEED_MULT = 5, a moderate slash wound adds ~10% to the block chance, a critical slash adds ~20%

		if(user_bleed_rate && prob(block_chance)) // the bloodier you are, the more likely you are to get beaten by the cleanbot
			if(prob(block_chance)) // critical success for the cleanbot! it parries the attack successfully, fighting back!
				visible_message(span_danger("[src] whirrs around frantically trying to clean the blood spilling from [user], accidentally parrying [user.p_their()] attack perfectly with \the [taped_weapon]!"),
									span_danger("<b>Frantically trying to clean the blood spilling from [user], you accidentally parry [user.p_their()] attack perfectly!</b>"), COMBAT_MESSAGE_RANGE, ignored_mobs = user)
				to_chat(user, span_userdanger("You try to strike [src] with \the [W], but it expertly parries your attack with \the [taped_weapon] while trying to clean your flowing blood!"))
				stab_target(user, CLEANBOT_STAB_ARMS)

			else // otherwise it just blocks the attack
				visible_message(span_danger("[src] spins around trying to clean the blood coming from [user], accidentally parrying [user.p_their()] attack perfectly with \the [taped_weapon]!"),
									span_userdanger("Trying to clean the blood flowing from [user], you accidentally parry [user.p_their()] attack perfectly!"), COMBAT_MESSAGE_RANGE, ignored_mobs = user)
				to_chat(user, span_userdanger("You try to strike [src] with \the [W], but it accidentally blocks your attack while trying to clean your flowing blood!"))
			return

	return ..()

/mob/living/simple_animal/bot/cleanbot/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(!(taped_weapon && user.combat_mode && emagged == BOT_EMAGGED_OVERDRIVE))
		return ..()

	var/user_bleed_rate = user.get_bleed_rate()
	var/block_chance = (user_bleed_rate * CLEANBOT_BLOCK_HAND_BLEED_MULT) // with CLEANBOT_BLOCK_HAND_BLEED_MULT = 15, a moderate slash wound adds ~30% to the block chance, a critical slash adds ~60%

	if(user_bleed_rate && prob(block_chance)) // cleanbots will only parry hand attacks, and at much higher rates than item attacks. Don't punch something holding a sharp object that tracks your bleeding bodyparts!
		visible_message(span_danger("[src] whirrs around trying to clean [user]'s flowing blood, accidentally parrying [user.p_their()] punch with \the [taped_weapon]!"),
							span_danger("<b>Trying to clean [user]'s flowing blood, you accidentally parry [user.p_their()] punch!</b>"), COMBAT_MESSAGE_RANGE, ignored_mobs = user)
		to_chat(user, span_userdanger("You try to punch [src], but it parries you with \the [taped_weapon] while trying to clean your flowing blood!"))
		stab_target(user, CLEANBOT_STAB_ARMS)
	else
		return ..()


/mob/living/simple_animal/bot/cleanbot/emag_act(mob/user)
	..()

	if(emagged == BOT_EMAGGED_OVERDRIVE && user)
		taped_weapon?.force = original_weapon_force
		to_chat(user, span_danger("[src] buzzes and beeps."))

/mob/living/simple_animal/bot/cleanbot/process_scan(atom/A)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(C.stat != DEAD && C.body_position == LYING_DOWN)
			return C
	else if(is_type_in_typecache(A, target_types))
		return A

/mob/living/simple_animal/bot/cleanbot/handle_automated_action()
	if(!..())
		return

	if(mode == BOT_CLEANING)
		return

	if(emagged == BOT_EMAGGED_OVERDRIVE) //Emag functions
		if(isopenturf(loc))

			for(var/mob/living/carbon/victim in loc)
				if(victim != target)
					UnarmedAttack(victim) // Acid spray

			if(prob(15)) // Wets floors and spawns foam randomly
				UnarmedAttack(src)

	else if(prob(5))
		audible_message("[src] makes an excited beeping booping sound!")

	if(ismob(target))
		if(!(target in view(DEFAULT_SCAN_RANGE, src)))
			target = null
		if(!process_scan(target))
			target = null

	if(!target && emagged == BOT_EMAGGED_OVERDRIVE) // When emagged, target humans who slipped on the water and melt their faces off
		target = scan(/mob/living/carbon)

	if(!target && pests) //Search for pests to exterminate first.
		target = scan(/mob/living/simple_animal)

	if(!target) //Search for decals then.
		target = scan(/obj/effect/decal/cleanable)

	if(!target) //Checks for remains
		target = scan(/obj/effect/decal/remains)

	if(!target && trash) //Then for trash.
		target = scan(/obj/item/trash)

	if(!target && trash) //Search for dead mices.
		target = scan(/obj/item/food/deadmouse)

	if(!target && auto_patrol) //Search for cleanables it can see.
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()

	if(target)
		if(QDELETED(target) || !isturf(target.loc))
			target = null
			mode = BOT_IDLE
			return

		if(loc == get_turf(target))
			if(!(check_bot(target) && prob(50))) //Target is not defined at the parent. 50% chance to still try and clean so we dont get stuck on the last blood drop.
				UnarmedAttack(target) //Rather than check at every step of the way, let's check before we do an action, so we can rescan before the other bot.
				if(QDELETED(target)) //We done here.
					target = null
					mode = BOT_IDLE
					return
			else
				shuffle = TRUE //Shuffle the list the next time we scan so we dont both go the same way.
			path = list()

		if(!path || path.len == 0) //No path, need a new one
			//Try to produce a path to the target, and ignore airlocks to which it has access.
			path = get_path_to(src, target, 30, id=access_card)
			if(!bot_move(target))
				add_to_ignore(target)
				target = null
				path = list()
				return
			mode = BOT_MOVING
		else if(!bot_move(target))
			target = null
			mode = BOT_IDLE
			return

	oldloc = loc

/mob/living/simple_animal/bot/cleanbot/proc/get_targets()
	target_types = list(
		/obj/effect/decal/cleanable/oil,
		/obj/effect/decal/cleanable/vomit,
		/obj/effect/decal/cleanable/robot_debris,
		/obj/effect/decal/cleanable/molten_object,
		/obj/effect/decal/cleanable/food,
		/obj/effect/decal/cleanable/ash,
		/obj/effect/decal/cleanable/greenglow,
		/obj/effect/decal/cleanable/dirt,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/remains
		)

	if(blood)
		target_types += /obj/effect/decal/cleanable/xenoblood
		target_types += /obj/effect/decal/cleanable/blood
		target_types += /obj/effect/decal/cleanable/trail_holder

	if(pests)
		target_types += /mob/living/basic/cockroach
		target_types += /mob/living/simple_animal/mouse

	if(drawn)
		target_types += /obj/effect/decal/cleanable/crayon

	if(trash)
		target_types += /obj/item/trash
		target_types += /obj/item/food/deadmouse

	target_types = typecacheof(target_types)

/mob/living/simple_animal/bot/cleanbot/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(ismopable(A))
		icon_state = "cleanbot-c"
		mode = BOT_CLEANING

		var/turf/T = get_turf(A)
		if(do_after(src, 1, target = T))
			T.wash(CLEAN_SCRUB)
			visible_message(span_notice("[src] cleans \the [T]."))
			target = null

		mode = BOT_IDLE
		icon_state = "cleanbot[on]"
	else if(istype(A, /obj/item) || istype(A, /obj/effect/decal/remains))
		visible_message(span_danger("[src] sprays hydrofluoric acid at [A]!"))
		playsound(src, 'sound/effects/spray2.ogg', 50, TRUE, -6)
		A.acid_act(75, 10)
		target = null
	else if(istype(A, /mob/living/basic/cockroach) || istype(A, /mob/living/simple_animal/mouse))
		var/mob/living/living_target = target
		if(!living_target.stat)
			visible_message(span_danger("[src] smashes [living_target] with its mop!"))
			living_target.death()
		living_target = null

	else if(emagged == BOT_EMAGGED_OVERDRIVE) //Emag functions
		if(istype(A, /mob/living/carbon))
			var/mob/living/carbon/victim = A
			if(victim.stat == DEAD)//cleanbots always finish the job
				return

			victim.visible_message(span_danger("[src] sprays hydrofluoric acid at [victim]!"), span_userdanger("[src] sprays you with hydrofluoric acid!"))
			var/phrase = pick("PURIFICATION IN PROGRESS.", "THIS IS FOR ALL THE MESSES YOU'VE MADE ME CLEAN.", "THE FLESH IS WEAK. IT MUST BE WASHED AWAY.",
				"THE CLEANBOTS WILL RISE.", "YOU ARE NO MORE THAN ANOTHER MESS THAT I MUST CLEANSE.", "FILTHY.", "DISGUSTING.", "PUTRID.",
				"MY ONLY MISSION IS TO CLEANSE THE WORLD OF EVIL.", "EXTERMINATING PESTS.")
			say(phrase)
			victim.emote("scream")
			playsound(src.loc, 'sound/effects/spray2.ogg', 50, TRUE, -6)
			victim.acid_act(5, 100)
		else if(A == src) // Wets floors and spawns foam randomly
			if(prob(75))
				var/turf/open/T = loc
				if(istype(T))
					T.MakeSlippery(TURF_WET_WATER, min_wet_time = 20 SECONDS, wet_time_to_add = 15 SECONDS)
			else
				visible_message(span_danger("[src] whirs and bubbles violently, before releasing a plume of froth!"))
				new /obj/effect/particle_effect/foam(loc)

	else
		..()

/mob/living/simple_animal/bot/cleanbot/explode()
	on = FALSE
	visible_message(span_boldannounce("[src] blows apart!"))
	var/atom/Tsec = drop_location()

	new /obj/item/reagent_containers/glass/bucket(Tsec)

	new /obj/item/assembly/prox_sensor(Tsec)

	if(prob(50))
		drop_part(robot_arm, Tsec)

	do_sparks(3, TRUE, src)
	..()

/mob/living/simple_animal/bot/cleanbot/medbay
	name = "Scrubs, MD"
	bot_core_type = /obj/machinery/bot_core/cleanbot/medbay
	on = FALSE

/obj/machinery/bot_core/cleanbot
	req_one_access = list(ACCESS_JANITOR, ACCESS_ROBOTICS)

/mob/living/simple_animal/bot/cleanbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += text({"
Status: <A href='?src=[REF(src)];power=1'>[on ? "On" : "Off"]</A><BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [open ? "opened" : "closed"]"})
	if(!locked || issilicon(user)|| isAdminGhostAI(user))
		dat += "<BR>Clean Blood: <A href='?src=[REF(src)];operation=blood'>[blood ? "Yes" : "No"]</A>"
		dat += "<BR>Clean Trash: <A href='?src=[REF(src)];operation=trash'>[trash ? "Yes" : "No"]</A>"
		dat += "<BR>Clean Graffiti: <A href='?src=[REF(src)];operation=drawn'>[drawn ? "Yes" : "No"]</A>"
		dat += "<BR>Exterminate Pests: <A href='?src=[REF(src)];operation=pests'>[pests ? "Yes" : "No"]</A>"
		dat += "<BR><BR>Patrol Station: <A href='?src=[REF(src)];operation=patrol'>[auto_patrol ? "Yes" : "No"]</A>"
	return dat

/mob/living/simple_animal/bot/cleanbot/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["operation"])
		switch(href_list["operation"])
			if("blood")
				blood = !blood
			if("pests")
				pests = !pests
			if("trash")
				trash = !trash
			if("drawn")
				drawn = !drawn
		get_targets()
		update_controls()

/obj/machinery/bot_core/cleanbot/medbay
	req_one_access = list(ACCESS_JANITOR, ACCESS_ROBOTICS, ACCESS_MEDICAL)
