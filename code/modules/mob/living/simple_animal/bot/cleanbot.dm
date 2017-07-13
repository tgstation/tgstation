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
	radio_key = /obj/item/device/encryptionkey/headset_service
	radio_channel = "Service" //Service
	bot_type = CLEAN_BOT
	model = "Cleanbot"
	bot_core_type = /obj/machinery/bot_core/cleanbot
	window_id = "autoclean"
	window_name = "Automatic Station Cleaner v1.2"
	pass_flags = PASSMOB

	var/blood = 1
	var/trash = 0
	var/pests = 0

	var/list/target_types
	var/obj/effect/decal/cleanable/target
	var/max_targets = 50 //Maximum number of targets a cleanbot can ignore.
	var/oldloc = null
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/next_dest
	var/next_dest_loc

/mob/living/simple_animal/bot/cleanbot/Initialize()
	. = ..()
	get_targets()
	icon_state = "cleanbot[on]"

	var/datum/job/janitor/J = new/datum/job/janitor
	access_card.access += J.get_access()
	prev_access = access_card.access

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

/mob/living/simple_animal/bot/cleanbot/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(bot_core.allowed(user) && !open && !emagged)
			locked = !locked
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] \the [src] behaviour controls.</span>")
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='notice'>\The [src] doesn't seem to respect your authority.</span>")
	else
		return ..()

/mob/living/simple_animal/bot/cleanbot/emag_act(mob/user)
	..()
	if(emagged == 2)
		if(user)
			to_chat(user, "<span class='danger'>[src] buzzes and beeps.</span>")

/mob/living/simple_animal/bot/cleanbot/process_scan(atom/A)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(C.stat != DEAD && C.lying)
			return C
	else if(is_type_in_typecache(A, target_types))
		return A

/mob/living/simple_animal/bot/cleanbot/handle_automated_action()
	if(!..())
		return

	if(mode == BOT_CLEANING)
		return

	if(emagged == 2) //Emag functions
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

	if(!target && emagged == 2) // When emagged, target humans who slipped on the water and melt their faces off
		target = scan(/mob/living/carbon)

	if(!target && pests) //Search for pests to exterminate first.
		target = scan(/mob/living/simple_animal)

	if(!target) //Search for decals then.
		target = scan(/obj/effect/decal/cleanable)

	if(!target && trash) //Then for trash.
		target = scan(/obj/item/trash)

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

		if(!path || path.len == 0) //No path, need a new one
			//Try to produce a path to the target, and ignore airlocks to which it has access.
			path = get_path_to(src, target.loc, /turf/proc/Distance_cardinal, 0, 30, id=access_card)
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

	if(target && loc == target.loc)
		if(!(check_bot(target) && prob(50)))	//Target is not defined at the parent. 50% chance to still try and clean so we dont get stuck on the last blood drop.
			UnarmedAttack(target)	//Rather than check at every step of the way, let's check before we do an action, so we can rescan before the other bot.
		else
			shuffle = TRUE	//Shuffle the list the next time we scan so we dont both go the same way.
		path = list()

	oldloc = loc

/mob/living/simple_animal/bot/cleanbot/proc/get_targets()
	target_types = list(
		/obj/effect/decal/cleanable/oil,
		/obj/effect/decal/cleanable/vomit,
		/obj/effect/decal/cleanable/robot_debris,
		/obj/effect/decal/cleanable/crayon,
		/obj/effect/decal/cleanable/molten_object,
		/obj/effect/decal/cleanable/tomato_smudge,
		/obj/effect/decal/cleanable/egg_smudge,
		/obj/effect/decal/cleanable/pie_smudge,
		/obj/effect/decal/cleanable/flour,
		/obj/effect/decal/cleanable/ash,
		/obj/effect/decal/cleanable/greenglow,
		/obj/effect/decal/cleanable/dirt,
		/obj/effect/decal/cleanable/deadcockroach
		)

	if(blood)
		target_types += /obj/effect/decal/cleanable/xenoblood
		target_types += /obj/effect/decal/cleanable/blood
		target_types += /obj/effect/decal/cleanable/trail_holder

	if(pests)
		target_types += /mob/living/simple_animal/cockroach
		target_types += /mob/living/simple_animal/mouse

	if(trash)
		target_types += /obj/item/trash

	target_types = typecacheof(target_types)

/mob/living/simple_animal/bot/cleanbot/UnarmedAttack(atom/A)
	if(istype(A, /obj/effect/decal/cleanable))
		anchored = TRUE
		icon_state = "cleanbot-c"
		visible_message("<span class='notice'>[src] begins to clean up [A].</span>")
		mode = BOT_CLEANING
		spawn(50)
			if(mode == BOT_CLEANING)
				if(A && isturf(A.loc))
					var/atom/movable/AM = A
					if(istype(AM, /obj/effect/decal/cleanable))
						qdel(AM)

				anchored = FALSE
				target = null
			mode = BOT_IDLE
			icon_state = "cleanbot[on]"
	else if(istype(A, /obj/item))
		visible_message("<span class='danger'>[src] sprays hydrofluoric acid at [A]!</span>")
		playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1, -6)
		A.acid_act(75, 10)
	else if(istype(A, /mob/living/simple_animal/cockroach) || istype(A, /mob/living/simple_animal/mouse))
		var/mob/living/simple_animal/M = target
		if(!M.stat)
			visible_message("<span class='danger'>[src] smashes [target] with its mop!</span>")
			M.death()
		target = null

	else if(emagged == 2) //Emag functions
		if(istype(A, /mob/living/carbon))
			var/mob/living/carbon/victim = A
			if(victim.stat == DEAD)//cleanbots always finish the job
				return

			victim.visible_message("<span class='danger'>[src] sprays hydrofluoric acid at [victim]!</span>", "<span class='userdanger'>[src] sprays you with hydrofluoric acid!</span>")
			var/phrase = pick("PURIFICATION IN PROGRESS.", "THIS IS FOR ALL THE MESSES YOU'VE MADE ME CLEAN.", "THE FLESH IS WEAK. IT MUST BE WASHED AWAY.",
				"THE CLEANBOTS WILL RISE.", "YOU ARE NO MORE THAN ANOTHER MESS THAT I MUST CLEANSE.", "FILTHY.", "DISGUSTING.", "PUTRID.",
				"MY ONLY MISSION IS TO CLEANSE THE WORLD OF EVIL.", "EXTERMINATING PESTS.")
			say(phrase)
			victim.emote("scream")
			playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1, -6)
			victim.acid_act(5, 2, 100)
		else if(A == src) // Wets floors and spawns foam randomly
			if(prob(75))
				var/turf/open/T = loc
				if(istype(T))
					T.MakeSlippery(min_wet_time = 20, wet_time_to_add = 15)
			else
				visible_message("<span class='danger'>[src] whirs and bubbles violently, before releasing a plume of froth!</span>")
				new /obj/effect/particle_effect/foam(loc)

	else
		..()

/mob/living/simple_animal/bot/cleanbot/explode()
	on = FALSE
	visible_message("<span class='boldannounce'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/reagent_containers/glass/bucket(Tsec)

	new /obj/item/device/assembly/prox_sensor(Tsec)

	if(prob(50))
		new /obj/item/bodypart/l_arm/robot(Tsec)

	do_sparks(3, TRUE, src)
	..()

/obj/machinery/bot_core/cleanbot
	req_one_access = list(GLOB.access_janitor, GLOB.access_robotics)


/mob/living/simple_animal/bot/cleanbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += text({"
Status: <A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A><BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [open ? "opened" : "closed"]"})
	if(!locked || issilicon(user)|| IsAdminGhost(user))
		dat += "<BR>Clean Blood: <A href='?src=\ref[src];operation=blood'>[blood ? "Yes" : "No"]</A>"
		dat += "<BR>Clean Trash: <A href='?src=\ref[src];operation=trash'>[trash ? "Yes" : "No"]</A>"
		dat += "<BR>Exterminate Pests: <A href='?src=\ref[src];operation=pests'>[pests ? "Yes" : "No"]</A>"
		dat += "<BR><BR>Patrol Station: <A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "Yes" : "No"]</A>"
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
		get_targets()
		update_controls()
