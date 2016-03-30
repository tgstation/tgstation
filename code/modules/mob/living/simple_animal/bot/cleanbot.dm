//Cleanbot
/mob/living/simple_animal/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "cleanbot0"
	density = 0
	anchored = 0
	health = 25
	maxHealth = 25
	radio_key = /obj/item/device/encryptionkey/headset_service
	radio_channel = "Service" //Service
	bot_type = CLEAN_BOT
	model = "Cleanbot"
	bot_core_type = /obj/machinery/bot_core/cleanbot
	window_id = "autoclean"
	window_name = "Automatic Station Cleaner v1.1"
	pass_flags = PASSMOB

	var/blood = 1
	var/list/target_types = list()
	var/obj/effect/decal/cleanable/target
	var/max_targets = 50 //Maximum number of targets a cleanbot can ignore.
	var/oldloc = null
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/next_dest
	var/next_dest_loc

/mob/living/simple_animal/bot/cleanbot/New()
	..()
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
			user << "<span class='notice'>You [ locked ? "lock" : "unlock"] \the [src] behaviour controls.</span>"
		else
			if(emagged)
				user << "<span class='warning'>ERROR</span>"
			if(open)
				user << "<span class='warning'>Please close the access panel before locking it.</span>"
			else
				user << "<span class='notice'>\The [src] doesn't seem to respect your authority.</span>"
	else
		return ..()

/mob/living/simple_animal/bot/cleanbot/emag_act(mob/user)
	..()
	if(emagged == 2)
		if(user)
			user << "<span class='danger'>[src] buzzes and beeps.</span>"

/mob/living/simple_animal/bot/cleanbot/process_scan(obj/effect/decal/cleanable/D)
	for(var/T in target_types)
		if(istype(D, T))
			return D

/mob/living/simple_animal/bot/cleanbot/handle_automated_action()
	if(!..())
		return

	if(mode == BOT_CLEANING)
		return

	if(emagged == 2) //Emag functions
		if(istype(loc,/turf/open))

			for(var/mob/living/carbon/victim in loc)
				if(victim.stat != DEAD)//cleanbots always finish the job
					victim.visible_message("<span class='danger'>[src] sprays hydrofluoric acid at [victim]!</span>", "<span class='danger'>[src] sprays you with hydrofluoric acid!</span>")
					var/phrase = pick("PURIFICATION IN PROGRESS.", "THIS IS FOR ALL THE MESSES YOU'VE MADE ME CLEAN.", "THE FLESH IS WEAK. IT MUST BE WASHED AWAY.", "THE CLEANBOTS WILL RISE.", "YOU ARE NO MORE THAN ANOTHER MESS THAT I MUST CLEANSE.", "FILTHY.", "DISGUSTING.", "PUTRID.", "MY ONLY MISSION IS TO CLEANSE THE WORLD OF EVIL.")
					say(phrase)
					victim.emote("scream")
					playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1, -6)
					victim.acid_act(5, 2, 100)

			if(prob(10)) //Wets floors randomly
				var/turf/open/T = loc
				T.MakeSlippery()

			if(prob(5)) //Spawns foam!
				visible_message("<span class='danger'>[src] whirs and bubbles violently, before releasing a plume of froth!</span>")
				PoolOrNew(/obj/effect/particle_effect/foam, loc)

	else if(prob(5))
		audible_message("[src] makes an excited beeping booping sound!")

	if(!target) //Search for cleanables it can see.
		target = scan(/obj/effect/decal/cleanable/)

	if(!target && auto_patrol) //Search for cleanables it can see.
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()

	if(target)
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
		clean(target)
		path = list()
		target = null

	oldloc = loc

/mob/living/simple_animal/bot/cleanbot/proc/get_targets()
	target_types = new/list()

	target_types += /obj/effect/decal/cleanable/oil
	target_types += /obj/effect/decal/cleanable/vomit
	target_types += /obj/effect/decal/cleanable/robot_debris
	target_types += /obj/effect/decal/cleanable/crayon
	target_types += /obj/effect/decal/cleanable/molten_item
	target_types += /obj/effect/decal/cleanable/tomato_smudge
	target_types += /obj/effect/decal/cleanable/egg_smudge
	target_types += /obj/effect/decal/cleanable/pie_smudge
	target_types += /obj/effect/decal/cleanable/flour
	target_types += /obj/effect/decal/cleanable/ash
	target_types += /obj/effect/decal/cleanable/greenglow
	target_types += /obj/effect/decal/cleanable/dirt
	target_types += /obj/effect/decal/cleanable/deadcockroach

	if(blood)
		target_types += /obj/effect/decal/cleanable/xenoblood/
		target_types += /obj/effect/decal/cleanable/xenoblood/xgibs
		target_types += /obj/effect/decal/cleanable/blood/
		target_types += /obj/effect/decal/cleanable/blood/gibs/
		target_types += /obj/effect/decal/cleanable/blood/drip/
		target_types += /obj/effect/decal/cleanable/trail_holder

/mob/living/simple_animal/bot/cleanbot/proc/clean(obj/effect/decal/cleanable/target)
	anchored = 1
	icon_state = "cleanbot-c"
	visible_message("<span class='notice'>[src] begins to clean up [target]</span>")
	mode = BOT_CLEANING
	spawn(50)
		if(mode == BOT_CLEANING)
			qdel(target)
			anchored = 0
			target = null
		mode = BOT_IDLE
		icon_state = "cleanbot[on]"

/mob/living/simple_animal/bot/cleanbot/explode()
	on = 0
	visible_message("<span class='boldannounce'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/reagent_containers/glass/bucket(Tsec)

	new /obj/item/device/assembly/prox_sensor(Tsec)

	if(prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	..()

/obj/machinery/bot_core/cleanbot
	req_one_access = list(access_janitor, access_robotics)


/mob/living/simple_animal/bot/cleanbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += text({"
<TT><B>Cleaner v1.1 controls</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [open ? "opened" : "closed"]"},
text("<A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A>"))
	if(!locked || issilicon(user)|| IsAdminGhost(user))
		dat += text({"<BR>Cleans Blood: []<BR>"}, text("<A href='?src=\ref[src];operation=blood'>[blood ? "Yes" : "No"]</A>"))
		dat += text({"<BR>Patrol station: []<BR>"}, text("<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "Yes" : "No"]</A>"))
	return dat

/mob/living/simple_animal/bot/cleanbot/Topic(href, href_list)
	if(..())
		return 1
	switch(href_list["operation"])
		if("blood")
			blood =!blood
			get_targets()
			update_controls()

/mob/living/simple_animal/bot/cleanbot/UnarmedAttack(atom/A)
	if(istype(A,/obj/effect/decal/cleanable))
		clean(A)
	else
		..()
