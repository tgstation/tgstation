/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	GLOB.mob_list -= src
	GLOB.dead_mob_list -= src
	GLOB.alive_mob_list -= src
	GLOB.all_clockwork_mobs -= src
	GLOB.mob_directory -= tag
	focus = null
	for (var/alert in alerts)
		clear_alert(alert, TRUE)
	if(observers && observers.len)
		for(var/M in observers)
			var/mob/dead/observe = M
			observe.reset_perspective(null)
	qdel(hud_used)
	for(var/cc in client_colours)
		qdel(cc)
	client_colours = null
	ghostize()
	..()
	return QDEL_HINT_HARDDEL

/mob/Initialize()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_CREATED, src)
	GLOB.mob_list += src
	GLOB.mob_directory[tag] = src
	if(stat == DEAD)
		GLOB.dead_mob_list += src
	else
		GLOB.alive_mob_list += src
	set_focus(src)
	prepare_huds()
	for(var/v in GLOB.active_alternate_appearances)
		if(!v)
			continue
		var/datum/atom_hud/alternate_appearance/AA = v
		AA.onNewMob(src)
	set_nutrition(rand(NUTRITION_LEVEL_START_MIN, NUTRITION_LEVEL_START_MAX))
	. = ..()
	update_config_movespeed()
	update_movespeed(TRUE)

/mob/GenerateTag()
	tag = "mob_[next_mob_id++]"

/atom/proc/prepare_huds()
	hud_list = list()
	for(var/hud in hud_possible)
		var/hint = hud_possible[hud]
		switch(hint)
			if(HUD_LIST_LIST)
				hud_list[hud] = list()
			else
				var/image/I = image('icons/mob/hud.dmi', src, "")
				I.appearance_flags = RESET_COLOR|RESET_TRANSFORM
				hud_list[hud] = I

/mob/proc/Cell()
	set category = "Admin"
	set hidden = 1

	if(!loc)
		return 0

	var/datum/gas_mixture/environment = loc.return_air()

	var/t =	"<span class='notice'>Coordinates: [x],[y] \n</span>"
	t +=	"<span class='danger'>Temperature: [environment.temperature] \n</span>"
	for(var/id in environment.gases)
		var/gas = environment.gases[id]
		if(gas[MOLES])
			t+="<span class='notice'>[gas[GAS_META][META_GAS_NAME]]: [gas[MOLES]] \n</span>"

	to_chat(usr, t)

/mob/proc/get_photo_description(obj/item/camera/camera)
	return "a ... thing?"

/mob/proc/show_message(msg, type, alt_msg, alt_type)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)

	if(!client)
		return

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if(type)
		if(type & 1 && eye_blind )//Vision related
			if(!alt_msg)
				return
			else
				msg = alt_msg
				type = alt_type

		if(type & 2 && !can_hear())//Hearing related
			if(!alt_msg)
				return
			else
				msg = alt_msg
				type = alt_type
				if(type & 1 && eye_blind)
					return
	// voice muffling
	if(stat == UNCONSCIOUS)
		if(type & 2) //audio
			to_chat(src, "<I>... You can almost hear something ...</I>")
	else
		to_chat(src, msg)

// Show a message to all player mobs who sees this atom
// Show a message to the src mob (if the src is a mob)
// Use for atoms performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// self_message (optional) is what the src mob sees e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
// vision_distance (optional) define how many tiles away the message can be seen.
// ignored_mob (optional) doesn't show any message to a given mob if TRUE.

/atom/proc/visible_message(message, self_message, blind_message, vision_distance, ignored_mob)
	var/turf/T = get_turf(src)
	if(!T)
		return
	var/range = 7
	if(vision_distance)
		range = vision_distance
	for(var/mob/M in get_hearers_in_view(range, src))
		if(!M.client)
			continue
		if(M == ignored_mob)
			continue
		var/msg = message
		if(M == src) //the src always see the main message or self message
			if(self_message)
				msg = self_message
		else
			if(M.see_invisible<invisibility || (T != loc && T != src))//if src is invisible to us or is inside something (and isn't a turf),
				if(blind_message) // then people see blind message if there is one, otherwise nothing.
					msg = blind_message
				else
					continue

			else if(T.lighting_object)
				if(T.lighting_object.invisibility <= M.see_invisible && T.is_softly_lit()) //the light object is dark and not invisible to us
					if(blind_message)
						msg = blind_message
					else
						continue

		M.show_message(msg,1,blind_message,2)

// Show a message to all mobs in earshot of this one
// This would be for audible actions by the src mob
// message is the message output to anyone who can hear.
// self_message (optional) is what the src mob hears.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.

/mob/audible_message(message, deaf_message, hearing_distance, self_message)
	var/range = 7
	if(hearing_distance)
		range = hearing_distance
	for(var/mob/M in get_hearers_in_view(range, src))
		var/msg = message
		if(self_message && M==src)
			msg = self_message
		M.show_message( msg, 2, deaf_message, 1)

// Show a message to all mobs in earshot of this atom
// Use for objects performing audible actions
// message is the message output to anyone who can hear.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.

/atom/proc/audible_message(message, deaf_message, hearing_distance)
	var/range = 7
	if(hearing_distance)
		range = hearing_distance
	for(var/mob/M in get_hearers_in_view(range, src))
		M.show_message( message, 2, deaf_message, 1)

/mob/proc/Life()
	set waitfor = FALSE

/mob/proc/get_item_by_slot(slot_id)
	return null

/mob/proc/restrained(ignore_grab)
	return

/mob/proc/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE, check_immobilized = FALSE)
	return

//This proc is called whenever someone clicks an inventory ui slot.
/mob/proc/attack_ui(slot)
	var/obj/item/W = get_active_held_item()

	if(istype(W))
		if(equip_to_slot_if_possible(W, slot,0,0,0))
			return 1

	if(!W)
		// Activate the item
		var/obj/item/I = get_item_by_slot(slot)
		if(istype(I))
			I.attack_hand(src)

	return 0

//This is a SAFE proc. Use this instead of equip_to_slot()!
//set qdel_on_fail to have it delete W if it fails to equip
//set disable_warning to disable the 'you are unable to equip that' warning.
//unset redraw_mob to prevent the mob from being redrawn at the end.
/mob/proc/equip_to_slot_if_possible(obj/item/W, slot, qdel_on_fail = FALSE, disable_warning = FALSE, redraw_mob = TRUE, bypass_equip_delay_self = FALSE)
	if(!istype(W))
		return FALSE
	if(!W.mob_can_equip(src, null, slot, disable_warning, bypass_equip_delay_self))
		if(qdel_on_fail)
			qdel(W)
		else
			if(!disable_warning)
				to_chat(src, "<span class='warning'>You are unable to equip that!</span>")
		return FALSE
	equip_to_slot(W, slot, redraw_mob) //This proc should not ever fail.
	return TRUE

//This is an UNSAFE proc. It merely handles the actual job of equipping. All the checks on whether you can or can't equip need to be done before! Use mob_can_equip() for that task.
//In most cases you will want to use equip_to_slot_if_possible()
/mob/proc/equip_to_slot(obj/item/W, slot)
	return

//This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to equip people when the round starts and when events happen and such.
//Also bypasses equip delay checks, since the mob isn't actually putting it on.
/mob/proc/equip_to_slot_or_del(obj/item/W, slot)
	return equip_to_slot_if_possible(W, slot, TRUE, TRUE, FALSE, TRUE)

//puts the item "W" into an appropriate slot in a human's inventory
//returns 0 if it cannot, 1 if successful
/mob/proc/equip_to_appropriate_slot(obj/item/W)
	if(!istype(W))
		return 0
	var/slot_priority = W.slot_equipment_priority

	if(!slot_priority)
		slot_priority = list( \
			SLOT_BACK, SLOT_WEAR_ID,\
			SLOT_W_UNIFORM, SLOT_WEAR_SUIT,\
			SLOT_WEAR_MASK, SLOT_HEAD, SLOT_NECK,\
			SLOT_SHOES, SLOT_GLOVES,\
			SLOT_EARS, SLOT_GLASSES,\
			SLOT_BELT, SLOT_S_STORE,\
			SLOT_L_STORE, SLOT_R_STORE,\
			SLOT_GENERC_DEXTROUS_STORAGE\
		)

	for(var/slot in slot_priority)
		if(equip_to_slot_if_possible(W, slot, 0, 1, 1)) //qdel_on_fail = 0; disable_warning = 1; redraw_mob = 1
			return 1

	return 0

// reset_perspective(thing) set the eye to the thing (if it's equal to current default reset to mob perspective)
// reset_perspective() set eye to common default : mob on turf, loc otherwise
/mob/proc/reset_perspective(atom/A)
	if(client)
		if(A)
			if(ismovableatom(A))
				//Set the the thing unless it's us
				if(A != src)
					client.perspective = EYE_PERSPECTIVE
					client.eye = A
				else
					client.eye = client.mob
					client.perspective = MOB_PERSPECTIVE
			else if(isturf(A))
				//Set to the turf unless it's our current turf
				if(A != loc)
					client.perspective = EYE_PERSPECTIVE
					client.eye = A
				else
					client.eye = client.mob
					client.perspective = MOB_PERSPECTIVE
			else
				//Do nothing
		else
			//Reset to common defaults: mob if on turf, otherwise current loc
			if(isturf(loc))
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
		return 1

/mob/proc/show_inv(mob/user)
	return

//mob verbs are faster than object verbs. See https://secure.byond.com/forum/?post=1326139&page=2#comment8198716 for why this isn't atom/verb/examine()
/mob/verb/examinate(atom/A as mob|obj|turf in view()) //It used to be oview(12), but I can't really say why
	set name = "Examine"
	set category = "IC"

	if(isturf(A) && !(sight & SEE_TURFS) && !(A in view(client ? client.view : world.view, src)))
		// shift-click catcher may issue examinate() calls for out-of-sight turfs
		return

	if(is_blind(src))
		to_chat(src, "<span class='notice'>Something is there but you can't see it.</span>")
		return

	face_atom(A)
	A.examine(src)

//same as above
//note: ghosts can point, this is intended
//visible_message will handle invisibility properly
//overridden here and in /mob/dead/observer for different point span classes and sanity checks
/mob/verb/pointed(atom/A as mob|obj|turf in view())
	set name = "Point To"
	set category = "Object"

	if(!src || !isturf(src.loc) || !(A in view(src.loc)))
		return FALSE
	if(istype(A, /obj/effect/temp_visual/point))
		return FALSE

	var/tile = get_turf(A)
	if (!tile)
		return FALSE

	new /obj/effect/temp_visual/point(A,invisibility)

	return TRUE

/mob/proc/can_resist()
	return FALSE		//overridden in living.dm

/mob/proc/spin(spintime, speed)
	set waitfor = 0
	var/D = dir
	if((spintime < 1)||(speed < 1)||!spintime||!speed)
		return
	while(spintime >= speed)
		sleep(speed)
		switch(D)
			if(NORTH)
				D = EAST
			if(SOUTH)
				D = WEST
			if(EAST)
				D = SOUTH
			if(WEST)
				D = NORTH
		setDir(D)
		spintime -= speed

/mob/proc/update_pull_hud_icon()
	if(hud_used)
		if(hud_used.pull_icon)
			hud_used.pull_icon.update_icon(src)

/mob/proc/update_rest_hud_icon()
	if(hud_used)
		if(hud_used.rest_icon)
			hud_used.rest_icon.update_icon(src)

/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "Object"
	set src = usr

	if(ismecha(loc))
		return

	if(incapacitated())
		return

	var/obj/item/I = get_active_held_item()
	if(I)
		I.attack_self(src)
		update_inv_hands()

/mob/verb/memory()
	set name = "Notes"
	set category = "IC"
	set desc = "View your character's notes memory."
	if(mind)
		mind.show_memory(src)
	else
		to_chat(src, "You don't have a mind datum for some reason, so you can't look at your notes, if you had any.")

/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	msg = sanitize(msg)

	if(mind)
		mind.store_memory(msg)
	else
		to_chat(src, "You don't have a mind datum for some reason, so you can't add a note to it.")

/mob/verb/abandon_mob()
	set name = "Respawn"
	set category = "OOC"

	if (CONFIG_GET(flag/norespawn))
		return
	if ((stat != DEAD || !( SSticker )))
		to_chat(usr, "<span class='boldnotice'>You must be dead to use this!</span>")
		return

	log_game("[key_name(usr)] used abandon mob.")

	to_chat(usr, "<span class='boldnotice'>Please roleplay correctly!</span>")

	if(!client)
		log_game("[key_name(usr)] AM failed due to disconnect.")
		return
	client.screen.Cut()
	client.screen += client.void
	if(!client)
		log_game("[key_name(usr)] AM failed due to disconnect.")
		return

	var/mob/dead/new_player/M = new /mob/dead/new_player()
	if(!client)
		log_game("[key_name(usr)] AM failed due to disconnect.")
		qdel(M)
		return

	M.key = key
//	M.Login()	//wat
	return



/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	reset_perspective(null)
	unset_machine()

//suppress the .click/dblclick macros so people can't use them to identify the location of items or aimbot
/mob/verb/DisClick(argu = null as anything, sec = "" as text, number1 = 0 as num  , number2 = 0 as num)
	set name = ".click"
	set hidden = TRUE
	set category = null
	return

/mob/verb/DisDblClick(argu = null as anything, sec = "" as text, number1 = 0 as num  , number2 = 0 as num)
	set name = ".dblclick"
	set hidden = TRUE
	set category = null
	return

/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)

	if(href_list["refresh"])
		if(machine && in_range(src, usr))
			show_inv(machine)


	if(href_list["item"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
		var/slot = text2num(href_list["item"])
		var/hand_index = text2num(href_list["hand_index"])
		var/obj/item/what
		if(hand_index)
			what = get_item_for_held_index(hand_index)
			slot = list(slot,hand_index)
		else
			what = get_item_by_slot(slot)
		if(what)
			if(!(what.item_flags & ABSTRACT))
				usr.stripPanelUnequip(what,src,slot)
		else
			usr.stripPanelEquip(what,src,slot)

	if(usr.machine == src)
		if(Adjacent(usr))
			show_inv(usr)
		else
			usr << browse(null,"window=mob[REF(src)]")

// The src mob is trying to strip an item from someone
// Defined in living.dm
/mob/proc/stripPanelUnequip(obj/item/what, mob/who)
	return

// The src mob is trying to place an item on someone
// Defined in living.dm
/mob/proc/stripPanelEquip(obj/item/what, mob/who)
	return

/mob/MouseDrop(mob/M)
	. = ..()
	if(M != usr)
		return
	if(usr == src)
		return
	if(!Adjacent(usr))
		return
	if(isAI(M))
		return
	show_inv(usr)

/mob/proc/is_muzzled()
	return 0

/mob/Stat()
	..()

	if(statpanel("Status"))
		if (client)
			stat(null, "Ping: [round(client.lastping, 1)]ms (Average: [round(client.avgping, 1)]ms)")
		stat(null, "Map: [SSmapping.config?.map_name || "Loading..."]")
		var/datum/map_config/cached = SSmapping.next_map_config
		if(cached)
			stat(null, "Next Map: [cached.map_name]")
		stat(null, "Round ID: [GLOB.round_id ? GLOB.round_id : "NULL"]")
		stat(null, "Server Time: [time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")]")
		stat(null, "Round Time: [worldtime2text()]")
		stat(null, "Station Time: [station_time_timestamp()]")
		stat(null, "Time Dilation: [round(SStime_track.time_dilation_current,1)]% AVG:([round(SStime_track.time_dilation_avg_fast,1)]%, [round(SStime_track.time_dilation_avg,1)]%, [round(SStime_track.time_dilation_avg_slow,1)]%)")
		if(SSshuttle.emergency)
			var/ETA = SSshuttle.emergency.getModeStr()
			if(ETA)
				stat(null, "[ETA] [SSshuttle.emergency.getTimerStr()]")

	if(client && client.holder)
		if(statpanel("MC"))
			var/turf/T = get_turf(client.eye)
			stat("Location:", COORD(T))
			stat("CPU:", "[world.cpu]")
			stat("Instances:", "[num2text(world.contents.len, 10)]")
			stat("World Time:", "[world.time]")
			GLOB.stat_entry()
			config.stat_entry()
			stat(null)
			if(Master)
				Master.stat_entry()
			else
				stat("Master Controller:", "ERROR")
			if(Failsafe)
				Failsafe.stat_entry()
			else
				stat("Failsafe Controller:", "ERROR")
			if(Master)
				stat(null)
				for(var/datum/controller/subsystem/SS in Master.subsystems)
					SS.stat_entry()
			GLOB.cameranet.stat_entry()
		if(statpanel("Tickets"))
			GLOB.ahelp_tickets.stat_entry()

	if(listed_turf && client)
		if(!TurfAdjacent(listed_turf))
			listed_turf = null
		else
			statpanel(listed_turf.name, null, listed_turf)
			var/list/overrides = list()
			for(var/image/I in client.images)
				if(I.loc && I.loc.loc == listed_turf && I.override)
					overrides += I.loc
			for(var/atom/A in listed_turf)
				if(!A.mouse_opacity)
					continue
				if(A.invisibility > see_invisible)
					continue
				if(overrides.len && (A in overrides))
					continue
				if(A.IsObscured())
					continue
				statpanel(listed_turf.name, null, A)


	if(mind)
		add_spells_to_statpanel(mind.spell_list)
	add_spells_to_statpanel(mob_spell_list)

/mob/proc/add_spells_to_statpanel(list/spells)
	for(var/obj/effect/proc_holder/spell/S in spells)
		if(S.can_be_cast_by(src))
			switch(S.charge_type)
				if("recharge")
					statpanel("[S.panel]","[S.charge_counter/10.0]/[S.charge_max/10]",S)
				if("charges")
					statpanel("[S.panel]","[S.charge_counter]/[S.charge_max]",S)
				if("holdervar")
					statpanel("[S.panel]","[S.holder_var_type] [S.holder_var_amount]",S)

#define MOB_FACE_DIRECTION_DELAY 1

// facing verbs
/mob/proc/canface()
	if(world.time < client.last_turn)
		return FALSE
	if(stat == DEAD || stat == UNCONSCIOUS)
		return FALSE
	if(anchored)
		return FALSE
	if(notransform)
		return FALSE
	if(restrained())
		return FALSE
	return TRUE

/mob/living/canface()
	if(!(mobility_flags & MOBILITY_MOVE))
		return FALSE
	return ..()

/mob/verb/eastface()
	set hidden = TRUE
	if(!canface())
		return FALSE
	setDir(EAST)
	client.last_turn = world.time + MOB_FACE_DIRECTION_DELAY
	return TRUE

/mob/verb/westface()
	set hidden = TRUE
	if(!canface())
		return FALSE
	setDir(WEST)
	client.last_turn = world.time + MOB_FACE_DIRECTION_DELAY
	return TRUE

/mob/verb/northface()
	set hidden = TRUE
	if(!canface())
		return FALSE
	setDir(NORTH)
	client.last_turn = world.time + MOB_FACE_DIRECTION_DELAY
	return TRUE

/mob/verb/southface()
	set hidden = TRUE
	if(!canface())
		return FALSE
	setDir(SOUTH)
	client.last_turn = world.time + MOB_FACE_DIRECTION_DELAY
	return TRUE

/mob/proc/IsAdvancedToolUser()//This might need a rename but it should replace the can this mob use things check
	return FALSE

/mob/proc/swap_hand()
	return

/mob/proc/activate_hand(selhand)
	return

/mob/proc/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null) //For sec bot threat assessment
	return 0

/mob/proc/get_ghost(even_if_they_cant_reenter, ghosts_with_clients)
	if(mind)
		return mind.get_ghost(even_if_they_cant_reenter, ghosts_with_clients)

/mob/proc/grab_ghost(force)
	if(mind)
		return mind.grab_ghost(force = force)

/mob/proc/notify_ghost_cloning(var/message = "Someone is trying to revive you. Re-enter your corpse if you want to be revived!", var/sound = 'sound/effects/genetics.ogg', var/atom/source = null, flashwindow)
	var/mob/dead/observer/ghost = get_ghost()
	if(ghost)
		ghost.notify_cloning(message, sound, source, flashwindow)
		return ghost

/mob/proc/AddSpell(obj/effect/proc_holder/spell/S)
	mob_spell_list += S
	S.action.Grant(src)

/mob/proc/RemoveSpell(obj/effect/proc_holder/spell/spell)
	if(!spell)
		return
	for(var/X in mob_spell_list)
		var/obj/effect/proc_holder/spell/S = X
		if(istype(S, spell))
			mob_spell_list -= S
			qdel(S)

/mob/proc/anti_magic_check(magic = TRUE, holy = FALSE, major = TRUE, self = FALSE)
	if(!magic && !holy)
		return
	var/list/protection_sources = list()
	if(SEND_SIGNAL(src, COMSIG_MOB_RECEIVE_MAGIC, src, magic, holy, major, self, protection_sources) & COMPONENT_BLOCK_MAGIC)
		if(protection_sources.len)
			return pick(protection_sources)
		else
			return src
	if((magic && has_trait(TRAIT_ANTIMAGIC)) || (holy && has_trait(TRAIT_HOLY)))
		return src

//You can buckle on mobs if you're next to them since most are dense
/mob/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(M.buckled)
		return 0
	var/turf/T = get_turf(src)
	if(M.loc != T)
		var/old_density = density
		density = FALSE
		var/can_step = step_towards(M, T)
		density = old_density
		if(!can_step)
			return 0
	return ..()

//Default buckling shift visual for mobs
/mob/post_buckle_mob(mob/living/M)
	var/height = M.get_mob_buckling_height(src)
	M.pixel_y = initial(M.pixel_y) + height
	if(M.layer < layer)
		M.layer = layer + 0.1

/mob/post_unbuckle_mob(mob/living/M)
	M.layer = initial(M.layer)
	M.pixel_y = initial(M.pixel_y)

//returns the height in pixel the mob should have when buckled to another mob.
/mob/proc/get_mob_buckling_height(mob/seat)
	if(isliving(seat))
		var/mob/living/L = seat
		if(L.mob_size <= MOB_SIZE_SMALL) //being on top of a small mob doesn't put you very high.
			return 0
	return 9

//can the mob be buckled to something by default?
/mob/proc/can_buckle()
	return 1

//can the mob be unbuckled from something by default?
/mob/proc/can_unbuckle()
	return 1

//Can the mob interact() with an atom?
/mob/proc/can_interact_with(atom/A)
	return IsAdminGhost(src) || Adjacent(A)

//Can the mob see reagents inside of containers?
/mob/proc/can_see_reagents()
	if(stat == DEAD) //Ghosts and such can always see reagents
		return 1
	if(has_unlimited_silicon_privilege) //Silicons can automatically view reagents
		return 1
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.head && istype(H.head, /obj/item/clothing))
			var/obj/item/clothing/CL = H.head
			if(CL.scan_reagents)
				return 1
		if(H.wear_mask && H.wear_mask.scan_reagents)
			return 1
		if(H.glasses && istype(H.glasses, /obj/item/clothing))
			var/obj/item/clothing/CL = H.glasses
			if(CL.scan_reagents)
				return 1
	return 0

//Can the mob use Topic to interact with machines
/mob/proc/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE, no_tk=FALSE)
	return

/mob/proc/canUseStorage()
	return FALSE

/mob/proc/faction_check_mob(mob/target, exact_match)
	if(exact_match) //if we need an exact match, we need to do some bullfuckery.
		var/list/faction_src = faction.Copy()
		var/list/faction_target = target.faction.Copy()
		if(!("[REF(src)]" in faction_target)) //if they don't have our ref faction, remove it from our factions list.
			faction_src -= "[REF(src)]" //if we don't do this, we'll never have an exact match.
		if(!("[REF(target)]" in faction_src))
			faction_target -= "[REF(target)]" //same thing here.
		return faction_check(faction_src, faction_target, TRUE)
	return faction_check(faction, target.faction, FALSE)

/proc/faction_check(list/faction_A, list/faction_B, exact_match)
	var/list/match_list
	if(exact_match)
		match_list = faction_A&faction_B //only items in both lists
		var/length = LAZYLEN(match_list)
		if(length)
			return (length == LAZYLEN(faction_A)) //if they're not the same len(gth) or we don't have a len, then this isn't an exact match.
	else
		match_list = faction_A&faction_B
		return LAZYLEN(match_list)
	return FALSE


//This will update a mob's name, real_name, mind.name, GLOB.data_core records, pda, id and traitor text
//Calling this proc without an oldname will only update the mob and skip updating the pda, id and records ~Carn
/mob/proc/fully_replace_character_name(oldname,newname)
	log_message("[src] name changed from [oldname] to [newname]", LOG_OWNERSHIP)
	if(!newname)
		return 0

	log_played_names(ckey,newname)

	real_name = newname
	name = newname
	if(mind)
		mind.name = newname
		if(mind.key)
			log_played_names(mind.key,newname) //Just in case the mind is unsynced at the moment.

	if(oldname)
		//update the datacore records! This is goig to be a bit costly.
		replace_records_name(oldname,newname)

		//update our pda and id if we have them on our person
		replace_identification_name(oldname,newname)

		for(var/datum/mind/T in SSticker.minds)
			for(var/datum/objective/obj in T.get_all_objectives())
				// Only update if this player is a target
				if(obj.target && obj.target.current && obj.target.current.real_name == name)
					obj.update_explanation_text()
	return 1

//Updates GLOB.data_core records with new name , see mob/living/carbon/human
/mob/proc/replace_records_name(oldname,newname)
	return

/mob/proc/replace_identification_name(oldname,newname)
	var/list/searching = GetAllContents()
	var/search_id = 1
	var/search_pda = 1

	for(var/A in searching)
		if( search_id && istype(A, /obj/item/card/id) )
			var/obj/item/card/id/ID = A
			if(ID.registered_name == oldname)
				ID.registered_name = newname
				ID.update_label()
				if(ID.registered_account?.account_holder == oldname)
					ID.registered_account.account_holder = newname
				if(!search_pda)
					break
				search_id = 0

		else if( search_pda && istype(A, /obj/item/pda) )
			var/obj/item/pda/PDA = A
			if(PDA.owner == oldname)
				PDA.owner = newname
				PDA.update_label()
				if(!search_id)
					break
				search_pda = 0

/mob/proc/update_stat()
	return

/mob/proc/update_health_hud()
	return

/mob/proc/update_sight()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()

/mob/proc/sync_lighting_plane_alpha()
	if(hud_used)
		var/obj/screen/plane_master/lighting/L = hud_used.plane_masters["[LIGHTING_PLANE]"]
		if (L)
			L.alpha = lighting_alpha

/mob/proc/update_mouse_pointer()
	if (!client)
		return
	client.mouse_pointer_icon = initial(client.mouse_pointer_icon)
	if (ismecha(loc))
		var/obj/mecha/M = loc
		if(M.mouse_pointer)
			client.mouse_pointer_icon = M.mouse_pointer
	else if (istype(loc, /obj/vehicle/sealed))
		var/obj/vehicle/sealed/E = loc
		if(E.mouse_pointer)
			client.mouse_pointer_icon = E.mouse_pointer



/mob/proc/is_literate()
	return FALSE

/mob/proc/can_read(obj/O)
	if(is_blind(src))
		to_chat(src, "<span class='warning'>As you are trying to read [O], you suddenly feel very stupid!</span>")
		return
	if(!is_literate())
		to_chat(src, "<span class='notice'>You try to read [O], but can't comprehend any of it.</span>")
		return
	return TRUE

/mob/proc/can_hold_items()
	return FALSE

/mob/proc/get_idcard(hand_first)
	return

/mob/vv_get_dropdown()
	. = ..()
	. += "---"
	.["Gib"] = "?_src_=vars;[HrefToken()];gib=[REF(src)]"
	.["Give Spell"] = "?_src_=vars;[HrefToken()];give_spell=[REF(src)]"
	.["Remove Spell"] = "?_src_=vars;[HrefToken()];remove_spell=[REF(src)]"
	.["Give Disease"] = "?_src_=vars;[HrefToken()];give_disease=[REF(src)]"
	.["Toggle Godmode"] = "?_src_=vars;[HrefToken()];godmode=[REF(src)]"
	.["Drop Everything"] = "?_src_=vars;[HrefToken()];drop_everything=[REF(src)]"
	.["Regenerate Icons"] = "?_src_=vars;[HrefToken()];regenerateicons=[REF(src)]"
	.["Show player panel"] = "?_src_=vars;[HrefToken()];mob_player_panel=[REF(src)]"
	.["Toggle Build Mode"] = "?_src_=vars;[HrefToken()];build_mode=[REF(src)]"
	.["Assume Direct Control"] = "?_src_=vars;[HrefToken()];direct_control=[REF(src)]"
	.["Offer Control to Ghosts"] = "?_src_=vars;[HrefToken()];offer_control=[REF(src)]"

/mob/vv_get_var(var_name)
	switch(var_name)
		if("logging")
			return debug_variable(var_name, logging, 0, src, FALSE)
	. = ..()

/mob/verb/open_language_menu()
	set name = "Open Language Menu"
	set category = "IC"

	var/datum/language_holder/H = get_language_holder()
	H.open_language_menu(usr)

/mob/proc/adjust_nutrition(var/change) //Honestly FUCK the oldcoders for putting nutrition on /mob someone else can move it up because holy hell I'd have to fix SO many typechecks
	nutrition = max(0, nutrition + change)

/mob/proc/set_nutrition(var/change) //Seriously fuck you oldcoders.
	nutrition = max(0, change)

/mob/setMovetype(newval)
	. = ..()
	update_movespeed(FALSE)
