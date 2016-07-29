<<<<<<< HEAD
var/list/image/ghost_darkness_images = list() //this is a list of images for things ghosts should still be able to see when they toggle darkness, BUT NOT THE GHOSTS THEMSELVES!
var/list/image/ghost_images_full = list() //this is a list of full images of the ghosts themselves
var/list/image/ghost_images_default = list() //this is a list of the default (non-accessorized, non-dir) images of the ghosts themselves
var/list/image/ghost_images_simple = list() //this is a list of all ghost images as the simple white ghost
=======
#define POLTERGEIST_COOLDOWN 300 // 30s

#define GHOST_CAN_REENTER 1
#define GHOST_IS_OBSERVER 2
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/mob/dead/observer
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" //jinkies!
	icon = 'icons/mob/mob.dmi'
<<<<<<< HEAD
	icon_state = "ghost"
	layer = GHOST_LAYER
	stat = DEAD
	density = 0
	canmove = 0
	anchored = 1	//  don't get pushed around
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	see_invisible = SEE_INVISIBLE_OBSERVER
	see_in_dark = 100
	invisibility = INVISIBILITY_OBSERVER
	languages_spoken = ALL
	languages_understood = ALL
	var/can_reenter_corpse
	var/datum/hud/living/carbon/hud = null // hud
	var/bootime = 0
	var/started_as_observer //This variable is set to 1 when you enter the game as an observer.
							//If you died in the game and are a ghsot - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.
	var/atom/movable/following = null
	var/fun_verbs = 0
	var/image/ghostimage = null //this mobs ghost image, for deleting and stuff
	var/image/ghostimage_default = null //this mobs ghost image without accessories and dirs
	var/image/ghostimage_simple = null //this mob with the simple white ghost sprite
	var/ghostvision = 1 //is the ghost able to see things humans can't?
	var/seedarkness = 1
	var/ghost_hud_enabled = 1 //did this ghost disable the on-screen HUD?
	var/data_huds_on = 0 //Are data HUDs currently enabled?
	var/list/datahuds = list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC) //list of data HUDs shown to ghosts.
	var/ghost_orbit = GHOST_ORBIT_CIRCLE

	//These variables store hair data if the ghost originates from a species with head and/or facial hair.
	var/hair_style
	var/hair_color
	var/image/hair_image
	var/facial_hair_style
	var/facial_hair_color
	var/image/facial_hair_image

	var/updatedir = 1						//Do we have to update our dir as the ghost moves around?
	var/lastsetting = null	//Stores the last setting that ghost_others was set to, for a little more efficiency when we update ghost images. Null means no update is necessary

	//We store copies of the ghost display preferences locally so they can be referred to even if no client is connected.
	//If there's a bug with changing your ghost settings, it's probably related to this.
	var/ghost_accs = GHOST_ACCS_DEFAULT_OPTION
	var/ghost_others = GHOST_OTHERS_DEFAULT_OPTION
	// Used for displaying in ghost chat, without changing the actual name
	// of the mob
	var/deadchat_name

/mob/dead/observer/New(mob/body)
	verbs += /mob/dead/observer/proc/dead_tele

	if(global.cross_allowed)
		verbs += /mob/dead/observer/proc/server_hop

	ghostimage = image(src.icon,src,src.icon_state)
	if(icon_state in ghost_forms_with_directions_list)
		ghostimage_default = image(src.icon,src,src.icon_state + "_nodir")
	else
		ghostimage_default = image(src.icon,src,src.icon_state)
	ghostimage_simple = image(src.icon,src,"ghost_nodir")
	ghost_images_full |= ghostimage
	ghost_images_default |= ghostimage_default
	ghost_images_simple |= ghostimage_simple
	updateallghostimages()
=======
	icon_state = "ghost1"
	layer = 8
	stat = DEAD
	density = 0
	lockflags = 0 //Neither dense when locking or dense when locked to something
	canmove = 0
	blinded = 0
	anchored = 1	//  don't get pushed around
	flags = HEAR
	invisibility = INVISIBILITY_OBSERVER
	universal_understand = 1
	universal_speak = 1
	//languages = ALL
	plane = PLANE_LIGHTING
	// For Aghosts dicking with telecoms equipment.
	var/obj/item/device/multitool/ghostMulti = null

	var/can_reenter_corpse
	var/datum/hud/living/carbon/hud = null // hud
	var/bootime = 0
	var/next_poltergeist = 0
	var/started_as_observer //This variable is set to 1 when you enter the game as an observer.
							//If you died in the game and are a ghsot - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.
	var/has_enabled_antagHUD = 0
	var/medHUD = 0
	var/antagHUD = 0
	var/atom/movable/following = null
	var/mob/canclone = null
	incorporeal_move = INCORPOREAL_GHOST
	var/movespeed = 0.75

/mob/dead/observer/New(var/mob/body=null, var/flags=1)
	sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	see_invisible = SEE_INVISIBLE_OBSERVER
	see_in_dark = 100
	verbs += /mob/dead/observer/proc/dead_tele

	// Our new boo spell.
	add_spell(new /spell/aoe_turf/boo, "grey_spell_ready")

	can_reenter_corpse = flags & GHOST_CAN_REENTER
	started_as_observer = flags & GHOST_IS_OBSERVER

	stat = DEAD
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	var/turf/T
	if(ismob(body))
		T = get_turf(body)				//Where is the body located?
		attack_log = body.attack_log	//preserve our attack logs by copying them to our ghost
<<<<<<< HEAD
=======
		if(!istype(attack_log, /list)) attack_log = list()
		// NEW SPOOKY BAY GHOST ICONS
		//////////////

		/*//What's the point of that? The icon and overlay renders without problem even with just the bottom part. I putting the old code in comment. -Deity Link
		if (ishuman(body))
			var/mob/living/carbon/human/H = body
			icon = H.stand_icon
			overlays = H.overlays_standing//causes issue with sepia cameras
		else
			icon = body.icon
			icon_state = body.icon_state
			overlays = body.overlays
		*/

		icon = body.icon
		icon_state = body.icon_state
		overlays = body.overlays

		// No icon?  Ghost icon time.
		if(isnull(icon) || isnull(icon_state))
			icon = initial(icon)
			icon_state = initial(icon_state)

		alpha = 127
		// END BAY SPOOKY GHOST SPRITES
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

		gender = body.gender
		if(body.mind && body.mind.name)
			name = body.mind.name
		else
			if(body.real_name)
				name = body.real_name
			else
<<<<<<< HEAD
				name = random_unique_name(gender)

		mind = body.mind	//we don't transfer the mind but we keep a reference to it.
		if(ishuman(body))
			var/mob/living/carbon/human/body_human = body
			if(HAIR in body_human.dna.species.specflags)
				hair_style = body_human.hair_style
				hair_color = brighten_color(body_human.hair_color)
			if(FACEHAIR in body_human.dna.species.specflags)
				facial_hair_style = body_human.facial_hair_style
				facial_hair_color = brighten_color(body_human.facial_hair_color)

	update_icon()

	if(!T)
		T = pick(latejoin)			//Safety in case we cannot find the body's position
	loc = T

	if(!name)							//To prevent nameless ghosts
		name = random_unique_name(gender)
	real_name = name

	if(!fun_verbs)
		verbs -= /mob/dead/observer/verb/boo
		verbs -= /mob/dead/observer/verb/possess

	animate(src, pixel_y = 2, time = 10, loop = -1)
	..()

/mob/dead/observer/narsie_act()
	var/old_color = color
	color = "#960000"
	animate(src, color = old_color, time = 10)

/mob/dead/observer/ratvar_act()
	var/old_color = color
	color = "#FAE48C"
	animate(src, color = old_color, time = 10)

/mob/dead/observer/Destroy()
	ghost_images_full -= ghostimage
	qdel(ghostimage)
	ghostimage = null

	ghost_images_default -= ghostimage_default
	qdel(ghostimage_default)
	ghostimage_default = null

	ghost_images_simple -= ghostimage_simple
	qdel(ghostimage_simple)
	ghostimage_simple = null

	updateallghostimages()
	return ..()

/mob/dead/CanPass(atom/movable/mover, turf/target, height=0)
	return 1

/*
 * This proc will update the icon of the ghost itself, with hair overlays, as well as the ghost image.
 * Please call update_icon(icon_state) from now on when you want to update the icon_state of the ghost,
 * or you might end up with hair on a sprite that's not supposed to get it.
 * Hair will always update its dir, so if your sprite has no dirs the haircut will go all over the place.
 * |- Ricotez
 */
/mob/dead/observer/proc/update_icon(new_form)
	if(client) //We update our preferences in case they changed right before update_icon was called.
		ghost_accs = client.prefs.ghost_accs
		ghost_others = client.prefs.ghost_others

	if(hair_image)
		overlays -= hair_image
		ghostimage.overlays -= hair_image
		hair_image = null

	if(facial_hair_image)
		overlays -= facial_hair_image
		ghostimage.overlays -= facial_hair_image
		facial_hair_image = null


	if(new_form)
		icon_state = new_form
		ghostimage.icon_state = new_form
		if(icon_state in ghost_forms_with_directions_list)
			ghostimage_default.icon_state = new_form + "_nodir" //if this icon has dirs, the default ghostimage must use its nodir version or clients with the preference set to default sprites only will see the dirs
		else
			ghostimage_default.icon_state = new_form

	if(ghost_accs >= GHOST_ACCS_DIR && icon_state in ghost_forms_with_directions_list) //if this icon has dirs AND the client wants to show them, we make sure we update the dir on movement
		updatedir = 1
	else
		updatedir = 0	//stop updating the dir in case we want to show accessories with dirs on a ghost sprite without dirs
		setDir(2 		)//reset the dir to its default so the sprites all properly align up

	if(ghost_accs == GHOST_ACCS_FULL && icon_state in ghost_forms_with_accessories_list) //check if this form supports accessories and if the client wants to show them
		var/datum/sprite_accessory/S
		if(facial_hair_style)
			S = facial_hair_styles_list[facial_hair_style]
			if(S)
				facial_hair_image = image("icon" = S.icon, "icon_state" = "[S.icon_state]_s", "layer" = -HAIR_LAYER)
				if(facial_hair_color)
					facial_hair_image.color = "#" + facial_hair_color
				facial_hair_image.alpha = 200
				add_overlay(facial_hair_image)
				ghostimage.overlays += facial_hair_image
		if(hair_style)
			S = hair_styles_list[hair_style]
			if(S)
				hair_image = image("icon" = S.icon, "icon_state" = "[S.icon_state]_s", "layer" = -HAIR_LAYER)
				if(hair_color)
					hair_image.color = "#" + hair_color
				hair_image.alpha = 200
				add_overlay(hair_image)
				ghostimage.overlays += hair_image

/*
 * Increase the brightness of a color by calculating the average distance between the R, G and B values,
 * and maximum brightness, then adding 30% of that average to R, G and B.
 *
 * I'll make this proc global and move it to its own file in a future update. |- Ricotez
 */
/mob/proc/brighten_color(input_color)
	var/r_val
	var/b_val
	var/g_val
	var/color_format = lentext(input_color)
	if(color_format == 3)
		r_val = hex2num(copytext(input_color, 1, 2))*16
		g_val = hex2num(copytext(input_color, 2, 3))*16
		b_val = hex2num(copytext(input_color, 3, 0))*16
	else if(color_format == 6)
		r_val = hex2num(copytext(input_color, 1, 3))
		g_val = hex2num(copytext(input_color, 3, 5))
		b_val = hex2num(copytext(input_color, 5, 0))
	else
		return 0 //If the color format is not 3 or 6, you're using an unexpected way to represent a color.

	r_val += (255 - r_val) * 0.4
	if(r_val > 255)
		r_val = 255
	g_val += (255 - g_val) * 0.4
	if(g_val > 255)
		g_val = 255
	b_val += (255 - b_val) * 0.4
	if(b_val > 255)
		b_val = 255

	return num2hex(r_val, 2) + num2hex(g_val, 2) + num2hex(b_val, 2)

=======
				if(gender == MALE)
					name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
				else
					name = capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))

		mind = body.mind	//we don't transfer the mind but we keep a reference to it.

	if(!T)	T = pick(latejoin)			//Safety in case we cannot find the body's position
	loc = T

	if(!name)							//To prevent nameless ghosts
		name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
	real_name = name

	start_poltergeist_cooldown() //FUCK OFF GHOSTS
	..()

/mob/dead/observer/Destroy()
	..()
	following = null
	ghostMulti = null
	canclone = null
	observers.Remove(src)

/mob/dead/observer/hasFullAccess()
	return isAdminGhost(src)

/mob/dead/observer/GetAccess()
	return isAdminGhost(src) ? get_all_accesses() : list()

/mob/dead/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/weapon/tome))
		var/mob/dead/M = src
		if(src.invisibility != 0)
			M.invisibility = 0
			user.visible_message(
				"<span class='warning'>[user] drags ghost, [M], to our plane of reality!</span>",
				"<span class='warning'>You drag [M] to our plane of reality!</span>"
			)
		else
			user.visible_message (
				"<span class='warning'>[user] just tried to smash his book into that ghost!  It's not very effective</span>",
				"<span class='warning'>You get the feeling that the ghost can't become any more visible.</span>"
			)

	if(istype(W,/obj/item/weapon/storage/bible) || istype(W,/obj/item/weapon/nullrod))
		var/mob/dead/M = src
		if(src.invisibility == 0)
			M.invisibility = 60
			user.visible_message(
				"<span class='warning'>[user] banishes the ghost from our plane of reality!</span>",
				"<span class='warning'>You banish the ghost from our plane of reality!</span>"
			)

/mob/dead/observer/get_multitool(var/active_only=0)
	return ghostMulti


/mob/dead/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	return 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/*
Transfer_mind is there to check if mob is being deleted/not going to have a body.
Works together with spawning an observer, noted above.
*/

<<<<<<< HEAD
/mob/proc/ghostize(can_reenter_corpse = 1)
	if(key)
		if(!cmptext(copytext(key,1,2),"@")) // Skip aghosts.
			var/mob/dead/observer/ghost = new(src)	// Transfer safety to observer spawning proc.
			SStgui.on_transfer(src, ghost) // Transfer NanoUIs.
			ghost.can_reenter_corpse = can_reenter_corpse
			ghost.key = key
			return ghost
=======
/mob/dead/observer/Life()
	if(timestopped) return 0 //under effects of time magick

	..()
	if(!loc) return
	if(!client) return 0


	if(client.images.len)
		for(var/image/hud in client.images)
			if(findtext(hud.icon_state, "hud", 1, 4))
				client.images.Remove(hud)
	if(antagHUD)
		var/list/target_list = list()
		for(var/mob/living/target in oview(src))
			if( target.mind&&(target.mind.special_role||issilicon(target)) )
				target_list += target
		if(target_list.len)
			assess_targets(target_list, src)
	if(medHUD)
		process_medHUD(src)

	if(visible)
		if(invisibility == 0)
			visible.icon_state = "visible1"
		else
			visible.icon_state = "visible0"

// Direct copied from medical HUD glasses proc, used to determine what health bar to put over the targets head.
/mob/dead/proc/RoundHealth(var/health)
	switch(health)
		if(100 to INFINITY)
			return "health100"
		if(70 to 100)
			return "health80"
		if(50 to 70)
			return "health60"
		if(30 to 50)
			return "health40"
		if(18 to 30)
			return "health25"
		if(5 to 18)
			return "health10"
		if(1 to 5)
			return "health1"
		if(-99 to 0)
			return "health0"
		else
			return "health-100"
	return "0"


// Pretty much a direct copy of Medical HUD stuff, except will show ill if they are ill instead of also checking for known illnesses.

/mob/dead/proc/process_medHUD(var/mob/M)
	var/client/C = M.client
	var/image/holder
	for(var/mob/living/carbon/human/patient in oview(M))
		var/foundVirus = 0
		if(patient && patient.virus2 && patient.virus2.len)
			foundVirus = 1
		if(!C) return
		holder = patient.hud_list[HEALTH_HUD]
		if(holder)
			if(patient.stat == 2)
				holder.icon_state = "hudhealth-100"
			else
				holder.icon_state = "hud[RoundHealth(patient.health)]"
			C.images += holder

		holder = patient.hud_list[STATUS_HUD]
		if(holder)
			if(patient.stat == 2)
				holder.icon_state = "huddead"
			else if(patient.status_flags & XENO_HOST)
				holder.icon_state = "hudxeno"
			else if(foundVirus)
				holder.icon_state = "hudill"
			else if(patient.has_brain_worms())
				var/mob/living/simple_animal/borer/B = patient.has_brain_worms()
				if(B.controlling)
					holder.icon_state = "hudbrainworm"
				else
					holder.icon_state = "hudhealthy"
			else
				holder.icon_state = "hudhealthy"

			C.images += holder

/mob/dead/proc/assess_targets(list/target_list, mob/dead/observer/U)
	var/icon/tempHud = 'icons/mob/hud.dmi'
	for(var/mob/living/target in target_list)
		if(iscarbon(target))
			switch(target.mind.special_role)
				if("traitor","Syndicate")
					U.client.images += image(tempHud,target,"hudsyndicate")
				if("Revolutionary")
					U.client.images += image(tempHud,target,"hudrevolutionary")
				if("Head Revolutionary")
					U.client.images += image(tempHud,target,"hudheadrevolutionary")
				if("Cultist")
					U.client.images += image(tempHud,target,"hudcultist")
				if("Changeling")
					U.client.images += image(tempHud,target,"hudchangeling")
				if("Wizard","Fake Wizard")
					U.client.images += image(tempHud,target,"hudwizard")
				if("Hunter","Sentinel","Drone","Queen")
					U.client.images += image(tempHud,target,"hudalien")
				if("Death Commando")
					U.client.images += image(tempHud,target,"huddeathsquad")
				if("Vampire")
					U.client.images += image(tempHud,target,"vampire")
				if("VampThrall")
					U.client.images += image(tempHud,target,"vampthrall")
				else//If we don't know what role they have but they have one.
					U.client.images += image(tempHud,target,"hudunknown1")
		else if(issilicon(target))//If the silicon mob has no law datum, no inherent laws, or a law zero, add them to the hud.
			var/mob/living/silicon/silicon_target = target
			if(!silicon_target.laws||(silicon_target.laws&&(silicon_target.laws.zeroth||!silicon_target.laws.inherent.len))||silicon_target.mind.special_role=="traitor")
				if(isrobot(silicon_target))//Different icons for robutts and AI.
					U.client.images += image(tempHud,silicon_target,"hudmalborg")
				else
					U.client.images += image(tempHud,silicon_target,"hudmalai")
	return 1

/mob/proc/ghostize(var/flags = GHOST_CAN_REENTER)
	if(key && !(copytext(key,1,2)=="@"))
		var/mob/dead/observer/ghost = new(src, flags)	//Transfer safety to observer spawning proc.
		ghost.timeofdeath = src.timeofdeath //BS12 EDIT
		ghost.key = key
		if(ghost.client && !ghost.client.holder && !config.antag_hud_allowed)		// For new ghosts we remove the verb from even showing up if it's not allowed.
			ghost.verbs -= /mob/dead/observer/verb/toggle_antagHUD	// Poor guys, don't know what they are missing!
		return ghost
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."

<<<<<<< HEAD
	if(mental_dominator)
		src << "<span class='warning'>This body's force of will is too strong! You can't break it enough to force them into a catatonic state.</span>"
		if(mind_control_holder)
			mind_control_holder << "<span class='userdanger'>Through tremendous force of will, you stop a catatonia attempt!</span>"
		return 0
	if(stat != DEAD)
		succumb()
	if(stat == DEAD)
		ghostize(1)
	else
		var/response = alert(src, "Are you -sure- you want to ghost?\n(You are alive. If you ghost whilst still alive you may not play again this round! You can't change your mind so choose wisely!!)","Are you sure you want to ghost?","Ghost","Stay in body")
		if(response != "Ghost")
			return	//didn't want to ghost after-all
		ghostize(0)						//0 parameter is so we can never re-enter our body, "Charlie, you can never come baaaack~" :3
	return


/mob/dead/observer/Move(NewLoc, direct)
	if(updatedir)
		setDir(direct )//only update dir if we actually need it, so overlays won't spin on base sprites that don't have directions of their own
=======
	if(src.health < 0 && stat != DEAD) //crit people
		succumb()
		ghostize(1)
	else if(stat == DEAD)
		ghostize(1)
	else
		var/response = alert(src, "Are you -sure- you want to ghost?\n(You are alive. If you ghost, you will not be able to re-enter your current body!  You can't change your mind so choose wisely!)","Are you sure you want to ghost?","Ghost","Stay in body")
		if(response != "Ghost")	return	//didn't want to ghost after-all
		resting = 1
		if(client && key)
			var/mob/dead/observer/ghost = ghostize(0)						//0 parameter is so we can never re-enter our body, "Charlie, you can never come baaaack~" :3
			ghost.timeofdeath = world.time // Because the living mob won't have a time of death and we want the respawn timer to work properly.
			if(ghost.client)
				ghost.client.time_died_as_mouse = world.time //We don't want people spawning infinite mice on the station
	return

// Check for last poltergeist activity.
/mob/dead/observer/proc/can_poltergeist(var/start_cooldown=1)
	if(world.time >= next_poltergeist)
		if(start_cooldown)
			start_poltergeist_cooldown()
		return 1
	return 0

/mob/dead/observer/proc/start_poltergeist_cooldown()
	next_poltergeist=world.time + POLTERGEIST_COOLDOWN

/mob/dead/observer/proc/reset_poltergeist_cooldown()
	next_poltergeist=0

/* WHY
/mob/dead/observer/Move(NewLoc, direct)
	dir = direct
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(NewLoc)
		loc = NewLoc
		for(var/obj/effect/step_trigger/S in NewLoc)
			S.Crossed(src)

<<<<<<< HEAD
=======
		var/area/A = get_area_master(src)
		if(A)
			A.Entered(src)

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		return
	loc = get_turf(src) //Get out of closets and such as a ghost
	if((direct & NORTH) && y < world.maxy)
		y++
	else if((direct & SOUTH) && y > 1)
		y--
	if((direct & EAST) && x < world.maxx)
		x++
	else if((direct & WEST) && x > 1)
		x--

<<<<<<< HEAD
	for(var/obj/effect/step_trigger/S in locate(x, y, z))	//<-- this is dumb
		S.Crossed(src)

/mob/dead/observer/is_active()
	return 0
=======
	for(var/obj/effect/step_trigger/S in get_turf(src))	//<-- this is dumb
		S.Crossed(src)

	var/area/A = get_area_master(src)
	if(A)
		A.Entered(src)
*/

/mob/dead/observer/can_use_hands()	return 0
/mob/dead/observer/is_active()		return 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/mob/dead/observer/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Station Time: [worldtime2text()]")
		if(ticker)
			if(ticker.mode)
<<<<<<< HEAD
				for(var/datum/gang/G in ticker.mode.gangs)
					if(G.is_dominating)
						stat(null, "[G.name] Gang Takeover: [max(G.domination_time_remaining(), 0)]")
=======
//				to_chat(world, "DEBUG: ticker not null")
				if(ticker.mode.name == "AI malfunction")
//					to_chat(world, "DEBUG: malf mode ticker test")
					if(ticker.mode:malf_mode_declared)
						stat(null, "Time left: [max(ticker.mode:AI_win_timeleft/(ticker.mode:apcs/3), 0)]")
		if(emergency_shuttle)
			if(emergency_shuttle.online && emergency_shuttle.location < 2)
				var/timeleft = emergency_shuttle.timeleft()
				if (timeleft)
					stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/mob/dead/observer/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"
<<<<<<< HEAD
	if(!client)
		return
	if(!(mind && mind.current))
		src << "<span class='warning'>You have no body.</span>"
		return
	if(!can_reenter_corpse)
		src << "<span class='warning'>You cannot re-enter your body.</span>"
		return
	if(mind.current.key && copytext(mind.current.key,1,2)!="@")	//makes sure we don't accidentally kick any clients
		usr << "<span class='warning'>Another consciousness is in your body...It is resisting you.</span>"
		return
	SStgui.on_transfer(src, mind.current) // Transfer NanoUIs.
	mind.current.key = key
	return 1

/mob/dead/observer/proc/notify_cloning(var/message, var/sound, var/atom/source)
	if(message)
		src << "<span class='ghostalert'>[message]</span>"
		if(source)
			var/obj/screen/alert/A = throw_alert("\ref[source]_notify_cloning", /obj/screen/alert/notify_cloning)
			if(A)
				if(client && client.prefs && client.prefs.UI_style)
					A.icon = ui_style2icon(client.prefs.UI_style)
				A.desc = message
				var/old_layer = source.layer
				source.layer = FLOAT_LAYER
				A.add_overlay(source)
				source.layer = old_layer
	src << "<span class='ghostalert'><a href=?src=\ref[src];reenter=1>(Click to re-enter)</a></span>"
	if(sound)
		src << sound(sound)
=======
	if(!client)	return
	if(!(mind && mind.current && can_reenter_corpse))
		to_chat(src, "<span class='warning'>You have no body.</span>")
		return
	if(mind.current.key && copytext(mind.current.key,1,2)!="@")	//makes sure we don't accidentally kick any clients
		to_chat(usr, "<span class='warning'>Another consciousness is in your body...It is resisting you.</span>")
		return
	if(mind.current.ajourn && mind.current.stat != DEAD) 	//check if the corpse is astral-journeying (it's client ghosted using a cultist rune).
		var/obj/effect/rune/R = mind.current.ajourn	//whilst corpse is alive, we can only reenter the body if it's on the rune
		if(!(R && R.word1 == cultwords["hell"] && R.word2 == cultwords["travel"] && R.word3 == cultwords["self"]))	//astral journeying rune
			to_chat(usr, "<span class='warning'>The astral cord that ties your body and your spirit has been severed. You are likely to wander the realm beyond until your body is finally dead and thus reunited with you.</span>")
			return
	if(mind && mind.current && mind.current.ajourn)
		mind.current.ajourn.ajourn = null
		mind.current.ajourn = null
	mind.current.key = key
	mind.isScrying = 0
	return 1

/mob/dead/observer/verb/toggle_medHUD()
	set category = "Ghost"
	set name = "Toggle MedicHUD"
	set desc = "Toggles Medical HUD allowing you to see how everyone is doing"
	if(!client)
		return
	if(medHUD)
		medHUD = 0
		to_chat(src, "<span class='notice'><B>Medical HUD Disabled</B></span>")
	else
		medHUD = 1
		to_chat(src, "<span class='notice'><B>Medical HUD Enabled</B></span>")

/mob/dead/observer/verb/toggle_antagHUD()
	set category = "Ghost"
	set name = "Toggle AntagHUD"
	set desc = "Toggles AntagHUD allowing you to see who is the antagonist"
	if(!config.antag_hud_allowed && !client.holder)
		to_chat(src, "<span class='warning'>Admins have disabled this for this round.</span>")
		return
	if(!client)
		return
	var/mob/dead/observer/M = src
	if(jobban_isbanned(M, "AntagHUD"))
		to_chat(src, "<span class='danger'>You have been banned from using this feature.</span>")
		return
	if(config.antag_hud_restricted && !M.has_enabled_antagHUD &&!client.holder)
		var/response = alert(src, "If you turn this on, you will not be able to take any part in the round.","Are you sure you want to turn this feature on?","Yes","No")
		if(response == "No") return
		M.can_reenter_corpse = 0
	if(!M.has_enabled_antagHUD && !client.holder)
		M.has_enabled_antagHUD = 1
	if(M.antagHUD)
		M.antagHUD = 0
		to_chat(src, "<span class='notice'><B>AntagHUD Disabled</B></span>")
	else
		M.antagHUD = 1
		to_chat(src, "<span class='notice'><B>AntagHUD Enabled</B></span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/mob/dead/observer/proc/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"
<<<<<<< HEAD
	if(!istype(usr, /mob/dead/observer))
		usr << "Not when you're not dead!"
		return
	var/A
	A = input("Area to jump to", "BOOYEA", A) as null|anything in sortedAreas
	var/area/thearea = A
	if(!thearea)
		return

	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		L+=T

	if(!L || !L.len)
		usr << "No area available."

	usr.loc = pick(L)

/mob/dead/observer/verb/follow()
	set category = "Ghost"
	set name = "Orbit" // "Haunt"
	set desc = "Follow and orbit a mob."

	var/list/mobs = getpois(skip_mindless=1)
	var/input = input("Please, select a mob!", "Haunt", null, null) as null|anything in mobs
	var/mob/target = mobs[input]
	ManualFollow(target)

// This is the ghost's follow verb with an argument
/mob/dead/observer/proc/ManualFollow(atom/movable/target)
	if (!istype(target))
		return

	var/icon/I = icon(target.icon,target.icon_state,target.dir)

	var/orbitsize = (I.Width()+I.Height())*0.5
	orbitsize -= (orbitsize/world.icon_size)*(world.icon_size*0.25)

	if(orbiting != target)
		src << "<span class='notice'>Now orbiting [target].</span>"

	var/rot_seg

	switch(ghost_orbit)
		if(GHOST_ORBIT_TRIANGLE)
			rot_seg = 3
		if(GHOST_ORBIT_SQUARE)
			rot_seg = 4
		if(GHOST_ORBIT_PENTAGON)
			rot_seg = 5
		if(GHOST_ORBIT_HEXAGON)
			rot_seg = 6
		else //Circular
			rot_seg = 36 //360/10 bby, smooth enough aproximation of a circle

	orbit(target,orbitsize, FALSE, 20, rot_seg)

/mob/dead/observer/orbit()
	setDir(2 )//reset dir so the right directional sprites show up
	..()
	//restart our floating animation after orbit is done.
	sleep 2  //orbit sets up a 2ds animation when it finishes, so we wait for that to end
	if (!orbiting) //make sure another orbit hasn't started
		pixel_y = 0
		animate(src, pixel_y = 2, time = 10, loop = -1)
=======

	if(!istype(usr, /mob/dead/observer))
		to_chat(usr, "Not when you're not dead!")
		return
	usr.verbs -= /mob/dead/observer/proc/dead_tele
	spawn(30)
		usr.verbs += /mob/dead/observer/proc/dead_tele
	var/A
	A = input("Area to jump to", "BOOYEA", A) as null|anything in ghostteleportlocs
	var/area/thearea = ghostteleportlocs[A]
	if(!thearea)	return

	if(thearea && thearea.anti_ethereal && !isAdminGhost(usr))
		to_chat(usr, "<span class='sinister'>As you are about to arrive, a strange dark form grabs you and sends you back where you came from.</span>")
		return

	var/list/L = list()
	var/holyblock = 0

	if((usr.invisibility == 0) || (ticker && ticker.mode && (ticker.mode.name == "cult") && (usr.mind in ticker.mode.cult)))
		for(var/turf/T in get_area_turfs(thearea.type))
			if(!T.holy)
				L+=T
			else
				holyblock = 1
	else
		for(var/turf/T in get_area_turfs(thearea.type))
			L+=T

	if(!L || !L.len)
		if(holyblock)
			to_chat(usr, "<span class='warning'>This area has been entirely made into sacred grounds, you cannot enter it while you are in this plane of existence!</span>")
		else
			to_chat(usr, "No area available.")

	usr.loc = pick(L)
	if(locked_to)
		manual_stop_follow(locked_to)

/mob/dead/observer/verb/follow()
	set category = "Ghost"
	set name = "Haunt" //Flavor name for following mobs
	set desc = "Haunt a mob, stalking them everywhere they go."

	var/list/mobs = getmobs()
	var/input = input("Please, select a mob!", "Haunt", null, null) as null|anything in mobs
	var/mob/target = mobs[input]
	manual_follow(target)

/mob/dead/observer/verb/end_follow()
	set category = "Ghost"
	set name = "Stop Haunting"
	set desc = "Stop haunting a mob. They weren't worth your eternal time anyways."

	if(locked_to)
		manual_stop_follow(locked_to)

//This is the ghost's follow verb with an argument
/mob/dead/observer/proc/manual_follow(var/atom/movable/target)
	if(target)
		var/turf/targetloc = get_turf(target)
		var/area/targetarea = get_area(target)
		if(targetarea && targetarea.anti_ethereal && !isAdminGhost(usr))
			to_chat(usr, "<span class='sinister'>You can sense a sinister force surrounding that mob, your spooky body itself refuses to follow it.</span>")
			return
		if(targetloc && targetloc.holy && ((!invisibility) || (mind in ticker.mode.cult)))
			to_chat(usr, "<span class='warning'>You cannot follow a mob standing on holy grounds!</span>")
			return
		if(target != src)
			if(locked_to)
				if(locked_to == target) //Trying to follow same target, don't do anything
					return
				manual_stop_follow(locked_to) //So you can switch follow target on a whim
			target.lock_atom(src, /datum/locking_category/observer)
			to_chat(src, "<span class='sinister'>You are now haunting \the [target]</span>")

/mob/dead/observer/proc/manual_stop_follow(var/atom/movable/target)

	if(!target)
		to_chat(src, "<span class='warning'>You are not currently haunting anyone.</span>")
		return
	else
		to_chat(src, "<span class='sinister'>You are no longer haunting \the [target].</span>")
		unlock_from()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/mob/dead/observer/verb/jumptomob() //Moves the ghost instead of just changing the ghosts's eye -Nodrak
	set category = "Ghost"
	set name = "Jump to Mob"
	set desc = "Teleport to a mob"

	if(istype(usr, /mob/dead/observer)) //Make sure they're an observer!


		var/list/dest = list() //List of possible destinations (mobs)
		var/target = null	   //Chosen target.

<<<<<<< HEAD
		dest += getpois(mobs_only=1) //Fill list, prompt user with list
=======
		dest += getmobs() //Fill list, prompt user with list
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		target = input("Please, select a player!", "Jump to Mob", null, null) as null|anything in dest

		if (!target)//Make sure we actually have a target
			return
		else
<<<<<<< HEAD
=======
			var/turf/targetloc = get_turf(target)
			var/area/targetarea = get_area(target)
			if(targetarea && targetarea.anti_ethereal && !isAdminGhost(usr))
				to_chat(usr, "<span class='sinister'>You can sense a sinister force surrounding that mob, your spooky body itself refuses to jump to it.</span>")
				return
			if(targetloc && targetloc.holy && ((src.invisibility == 0) || (src.mind in ticker.mode.cult)))
				to_chat(usr, "<span class='warning'>The mob that you are trying to follow is standing on holy grounds, you cannot reach him!</span>")
				return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			var/mob/M = dest[target] //Destination mob
			var/mob/A = src			 //Source mob
			var/turf/T = get_turf(M) //Turf of the destination mob

			if(T && isturf(T))	//Make sure the turf exists, then move the source to that destination.
				A.loc = T
<<<<<<< HEAD
			else
				A << "This mob is not located in the game world."

=======
				if(locked_to)
					manual_stop_follow(locked_to)
			else
				to_chat(A, "This mob is not located in the game world.")

/* Now a spell.  See spells.dm
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/mob/dead/observer/verb/boo()
	set category = "Ghost"
	set name = "Boo!"
	set desc= "Scare your crew members because of boredom!"

	if(bootime > world.time) return
<<<<<<< HEAD
	var/obj/machinery/light/L = locate(/obj/machinery/light) in view(1, src)
	if(L)
		L.flicker()
		bootime = world.time + 600
		return
	//Maybe in the future we can add more <i>spooky</i> code here!
	return


/mob/dead/observer/memory()
	set hidden = 1
	src << "<span class='danger'>You are dead! You have no mind to store memory!</span>"

/mob/dead/observer/add_memory()
	set hidden = 1
	src << "<span class='danger'>You are dead! You have no mind to store memory!</span>"

/mob/dead/observer/verb/toggle_ghostsee()
	set name = "Toggle Ghost Vision"
	set desc = "Toggles your ability to see things only ghosts can see, like other ghosts"
	set category = "Ghost"
	ghostvision = !(ghostvision)
	updateghostsight()
	usr << "You [(ghostvision?"now":"no longer")] have ghost vision."

/mob/dead/observer/verb/toggle_darkness()
	set name = "Toggle Darkness"
	set category = "Ghost"
	seedarkness = !(seedarkness)
	updateghostsight()

/mob/dead/observer/proc/updateghostsight()
	if(client)
		ghost_others = client.prefs.ghost_others //A quick update just in case this setting was changed right before calling the proc

	if (seedarkness)
		see_invisible = SEE_INVISIBLE_OBSERVER
		if (!ghostvision || ghost_others <= GHOST_OTHERS_DEFAULT_SPRITE)
			see_invisible = SEE_INVISIBLE_LIVING
	else
		see_invisible = SEE_INVISIBLE_NOLIGHTING

	updateghostimages()

/proc/updateallghostimages()
	for (var/mob/dead/observer/O in player_list)
		O.updateghostimages()

/mob/dead/observer/proc/updateghostimages()
	if (!client)
		return

	if(lastsetting)
		switch(lastsetting) //checks the setting we last came from, for a little efficiency so we don't try to delete images from the client that it doesn't have anyway
			if(GHOST_OTHERS_THEIR_SETTING)
				client.images -= ghost_images_full
			if(GHOST_OTHERS_DEFAULT_SPRITE)
				client.images -= ghost_images_default
			if(GHOST_OTHERS_SIMPLE)
				client.images -= ghost_images_simple

	if ((seedarkness || !ghostvision) && client.prefs.ghost_others == GHOST_OTHERS_THEIR_SETTING)
		client.images -= ghost_darkness_images
		lastsetting = null
	else if(ghostvision && (!seedarkness || client.prefs.ghost_others <= GHOST_OTHERS_DEFAULT_SPRITE))
		//add images for the 60inv things ghosts can normally see when darkness is enabled so they can see them now
		if(!lastsetting)
			client.images |= ghost_darkness_images
		switch(client.prefs.ghost_others)
			if(GHOST_OTHERS_THEIR_SETTING)
				client.images |= ghost_images_full
				if (ghostimage)
					client.images -= ghostimage //remove ourself
			if(GHOST_OTHERS_DEFAULT_SPRITE)
				client.images |= ghost_images_default
				if(ghostimage_default)
					client.images -= ghostimage_default
			if(GHOST_OTHERS_SIMPLE)
				client.images |= ghost_images_simple
				if(ghostimage_simple)
					client.images -= ghostimage_simple
		lastsetting = client.prefs.ghost_others

/mob/dead/observer/verb/possess()
	set category = "Ghost"
	set name = "Possess!"
	set desc= "Take over the body of a mindless creature!"

	var/list/possessible = list()
	for(var/mob/living/L in living_mob_list)
		if(!(L in player_list) && !L.mind)
			possessible += L

	var/mob/living/target = input("Your new life begins today!", "Possess Mob", null, null) as null|anything in possessible

	if(!target)
		return 0

	if(istype (target, /mob/living/simple_animal/hostile/megafauna))
		src << "<span class='warning'>This creature is too powerful for you to possess!</span>"
		return 0

	if(can_reenter_corpse || (mind && mind.current))
		if(alert(src, "Your soul is still tied to your former life as [mind.current.name], if you go foward there is no going back to that life. Are you sure you wish to continue?", "Move On", "Yes", "No") == "No")
			return 0
	if(target.key)
		src << "<span class='warning'>Someone has taken this body while you were choosing!</span>"
		return 0

	target.key = key
	return 1

/mob/dead/observer/proc/server_hop()
	set category = "Ghost"
	set name = "Server Hop!"
	set desc= "Jump to the other server"
	if (alert(src, "Jump to server running at [global.cross_address]?", "Server Hop", "Yes", "No") != "Yes")
		return 0
	if (client && global.cross_allowed)
		src << "<span class='notice'>Sending you to [global.cross_address].</span>"
		winset(src, null, "command=.options") //other wise the user never knows if byond is downloading resources
		client << link(global.cross_address)
	else
		src << "<span class='error'>There is no other server configured!</span>"

//this is a mob verb instead of atom for performance reasons
//see /mob/verb/examinate() in mob.dm for more info
//overriden here and in /mob/living for different point span classes and sanity checks
/mob/dead/observer/pointed(atom/A as mob|obj|turf in view())
	if(!..())
		return 0
	usr.visible_message("<span class='deadsay'><b>[src]</b> points to [A].</span>")
	return 1

/mob/dead/observer/verb/view_manifest()
=======
	bootime = world.time + 600
	var/obj/machinery/light/L = locate(/obj/machinery/light) in view(1, src)
	if(L)
		L.flicker()
	//Maybe in the future we can add more <i>spooky</i> code here!
	return
*/

/mob/dead/observer/memory()
	set hidden = 1
	to_chat(src, "<span class='warning'>You are dead! You have no mind to store memory!</span>")

/mob/dead/observer/add_memory()
	set hidden = 1
	to_chat(src, "<span class='warning'>You are dead! You have no mind to store memory!</span>")

/mob/dead/observer/verb/analyze_air()
	set name = "Analyze Air"
	set category = "Ghost"

	if(!istype(usr, /mob/dead/observer)) return

	// Shamelessly copied from the Gas Analyzers
	if (!( istype(usr.loc, /turf) ))
		return

	var/datum/gas_mixture/environment = usr.loc.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()

	to_chat(src, "<span class='notice'><B>Results:</B></span>")
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		to_chat(src, "<span class='notice'>Pressure: [round(pressure,0.1)] kPa</span>")
	else
		to_chat(src, "<span class='warning'>Pressure: [round(pressure,0.1)] kPa</span>")
	if(total_moles)
		var/o2_concentration = environment.oxygen/total_moles
		var/n2_concentration = environment.nitrogen/total_moles
		var/co2_concentration = environment.carbon_dioxide/total_moles
		var/plasma_concentration = environment.toxins/total_moles

		var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)
		if(abs(n2_concentration - N2STANDARD) < 20)
			to_chat(src, "<span class='notice'>Nitrogen: [round(n2_concentration*100)]% ([round(environment.nitrogen,0.01)] moles)</span>")
		else
			to_chat(src, "<span class='warning'>Nitrogen: [round(n2_concentration*100)]% ([round(environment.nitrogen,0.01)] moles)</span>")

		if(abs(o2_concentration - O2STANDARD) < 2)
			to_chat(src, "<span class='notice'>Oxygen: [round(o2_concentration*100)]% ([round(environment.oxygen,0.01)] moles)</span>")
		else
			to_chat(src, "<span class='warning'>Oxygen: [round(o2_concentration*100)]% ([round(environment.oxygen,0.01)] moles)</span>")

		if(co2_concentration > 0.01)
			to_chat(src, "<span class='warning'>CO2: [round(co2_concentration*100)]% ([round(environment.carbon_dioxide,0.01)] moles)</span>")
		else
			to_chat(src, "<span class='notice'>CO2: [round(co2_concentration*100)]% ([round(environment.carbon_dioxide,0.01)] moles)</span>")

		if(plasma_concentration > 0.01)
			to_chat(src, "<span class='warning'>Plasma: [round(plasma_concentration*100)]% ([round(environment.toxins,0.01)] moles)</span>")

		if(unknown_concentration > 0.01)
			to_chat(src, "<span class='warning'>Unknown: [round(unknown_concentration*100)]% ([round(unknown_concentration*total_moles,0.01)] moles)</span>")

		to_chat(src, "<span class='notice'>Temperature: [round(environment.temperature-T0C,0.1)]&deg;C</span>")
		to_chat(src, "<span class='notice'>Heat Capacity: [round(environment.heat_capacity(),0.1)]</span>")


/mob/dead/observer/verb/toggle_darkness()
	set name = "Toggle Darkness"
	set category = "Ghost"

	if (see_invisible == SEE_INVISIBLE_OBSERVER_NOLIGHTING)
		see_invisible = SEE_INVISIBLE_OBSERVER
	else
		see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING

/mob/dead/observer/verb/become_mouse()
	set name = "Become mouse"
	set category = "Ghost"

	if(!config.respawn_as_mouse)
		to_chat(src, "<span class='warning'>Respawning as mouse is disabled..</span>")
		return

	var/timedifference = world.time - client.time_died_as_mouse
	if(client.time_died_as_mouse && timedifference <= mouse_respawn_time * 600)
		var/timedifference_text
		timedifference_text = time2text(mouse_respawn_time * 600 - timedifference,"mm:ss")
		to_chat(src, "<span class='warning'>You may only spawn again as a mouse more than [mouse_respawn_time] minutes after your death. You have [timedifference_text] left.</span>")
		return

	var/response = alert(src, "Are you -sure- you want to become a mouse?","Are you sure you want to squeek?","Squeek!","Nope!")
	if(response != "Squeek!") return  //Hit the wrong key...again.


	//find a viable mouse candidate
	var/mob/living/simple_animal/mouse/host
	var/obj/machinery/atmospherics/unary/vent_pump/vent_found
	var/list/found_vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/v in atmos_machines)
		if(!v.welded && v.z == src.z && v.canSpawnMice==1) // No more spawning in atmos.  Assuming the mappers did their jobs, anyway.
			found_vents.Add(v)
	if(found_vents.len)
		vent_found = pick(found_vents)
		host = new /mob/living/simple_animal/mouse(vent_found.loc)
	else
		to_chat(src, "<span class='warning'>Unable to find any unwelded vents to spawn mice at.</span>")

	if(host)
		if(config.uneducated_mice)
			host.universal_understand = 0
		host.ckey = src.ckey
		to_chat(host, "<span class='info'>You are now a mouse. Try to avoid interaction with players, and do not give hints away that you are more than a simple rodent.</span>")

/mob/dead/observer/verb/view_manfiest()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	set name = "View Crew Manifest"
	set category = "Ghost"

	var/dat
	dat += "<h4>Crew Manifest</h4>"
	dat += data_core.get_manifest()

<<<<<<< HEAD
	src << browse(dat, "window=manifest;size=387x420;can_close=1")

//this is called when a ghost is drag clicked to something.
/mob/dead/observer/MouseDrop(atom/over)
	if(!usr || !over) return
	if (isobserver(usr) && usr.client.holder && isliving(over))
		if (usr.client.holder.cmd_ghost_drag(src,over))
			return

	return ..()

/mob/dead/observer/Topic(href, href_list)
	..()
	if(usr == src)
		if(href_list["follow"])
			var/atom/movable/target = locate(href_list["follow"])
			if(istype(target) && (target != src))
				ManualFollow(target)
		if(href_list["reenter"])
			reenter_corpse()

//We don't want to update the current var
//But we will still carry a mind.
/mob/dead/observer/mind_initialize()
	return

/mob/dead/observer/proc/show_data_huds()
	for(var/hudtype in datahuds)
		var/datum/atom_hud/H = huds[hudtype]
		H.add_hud_to(src)

/mob/dead/observer/proc/remove_data_huds()
	for(var/hudtype in datahuds)
		var/datum/atom_hud/H = huds[hudtype]
		H.remove_hud_from(src)

/mob/dead/observer/verb/toggle_data_huds()
	set name = "Toggle Sec/Med/Diag HUD"
	set desc = "Toggles whether you see medical/security/diagnostic HUDs"
	set category = "Ghost"

	if(data_huds_on) //remove old huds
		remove_data_huds()
		src << "<span class='notice'>Data HUDs disabled.</span>"
		data_huds_on = 0
	else
		show_data_huds()
		src << "<span class='notice'>Data HUDs enabled.</span>"
		data_huds_on = 1

/mob/dead/observer/verb/restore_ghost_apperance()
	set name = "Restore Ghost Character"
	set desc = "Sets your deadchat name and ghost appearance to your \
		roundstart character."
	set category = "Ghost"

	set_ghost_appearance()
	if(client && client.prefs)
		deadchat_name = client.prefs.real_name

/mob/dead/observer/proc/set_ghost_appearance()
	if((!client) || (!client.prefs))
		return

	if(client.prefs.be_random_name)
		client.prefs.real_name = random_unique_name(gender)
	if(client.prefs.be_random_body)
		client.prefs.random_character(gender)

	if(HAIR in client.prefs.pref_species.specflags)
		hair_style = client.prefs.hair_style
		hair_color = brighten_color(client.prefs.hair_color)
	if(FACEHAIR in client.prefs.pref_species.specflags)
		facial_hair_style = client.prefs.facial_hair_style
		facial_hair_color = brighten_color(client.prefs.facial_hair_color)

	update_icon()

/mob/dead/observer/canUseTopic()
	if(check_rights(R_ADMIN, 0))
		return 1
	return

/mob/dead/observer/is_literate()
	return 1

/mob/dead/observer/on_varedit(var_name)
	. = ..()
	switch(var_name)
		if("icon")
			ghostimage.icon = icon
			ghostimage_default.icon = icon
			ghostimage_simple.icon = icon
		if("icon_state")
			ghostimage.icon_state = icon_state
			ghostimage_default.icon_state = icon_state
			ghostimage_simple.icon_state = icon_state
		if("fun_verbs")
			if(fun_verbs)
				verbs += /mob/dead/observer/verb/boo
				verbs += /mob/dead/observer/verb/possess
			else
				verbs -= /mob/dead/observer/verb/boo
				verbs -= /mob/dead/observer/verb/possess
=======
	src << browse(dat, "window=manifest;size=370x420;can_close=1")

//Used for drawing on walls with blood puddles as a spooky ghost.
/mob/dead/verb/bloody_doodle()
	set category = "Ghost"
	set name = "Write in blood"
	set desc = "If the round is sufficiently spooky, write a short message in blood on the floor or a wall. Remember, no IC in OOC or OOC in IC."

	if(!(config.cult_ghostwriter))
		to_chat(src, "<span class='warning'>That verb is not currently permitted.</span>")
		return

	if (!src.stat)
		return

	if (usr != src)
		return 0 //something is terribly wrong

	var/ghosts_can_write
	if(ticker.mode.name == "cult")
		var/datum/game_mode/cult/C = ticker.mode
		if(C.cult.len > config.cult_ghostwriter_req_cultists)
			ghosts_can_write = 1

	if(!ghosts_can_write)
		to_chat(src, "<span class='warning'>The veil is not thin enough for you to do that.</span>")
		return

	var/list/choices = list()
	for(var/obj/effect/decal/cleanable/blood/B in view(1,src))
		if(B.amount > 0)
			choices += B

	if(!choices.len)
		to_chat(src, "<span class = 'warning'>There is no blood to use nearby.</span>")
		return

	var/obj/effect/decal/cleanable/blood/choice = input(src,"What blood would you like to use?") in null|choices

	var/direction = input(src,"Which way?","Tile selection") as anything in list("Here","North","South","East","West")
	var/turf/simulated/T = src.loc
	if (direction != "Here")
		T = get_step(T,text2dir(direction))

	if (!istype(T))
		to_chat(src, "<span class='warning'>You cannot doodle there.</span>")
		return

	if(!choice || choice.amount == 0 || !(src.Adjacent(choice)))
		return

	var/doodle_color = (choice.basecolor) ? choice.basecolor : "#A10808"

	var/num_doodles = 0
	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if (num_doodles > 4)
		to_chat(src, "<span class='warning'>There is no space to write on!</span>")
		return

	var/max_length = 50

	var/message = stripped_input(src,"Write a message. It cannot be longer than [max_length] characters.","Blood writing", "")

	if (message)

		if (length(message) > max_length)
			message += "-"
			to_chat(src, "<span class='warning'>You ran out of blood to write with!</span>")

		var/obj/effect/decal/cleanable/blood/writing/W = getFromPool(/obj/effect/decal/cleanable/blood/writing,T)
		W.New(T)
		W.basecolor = doodle_color
		W.update_icon()
		W.message = message
		W.add_hiddenprint(src)
		W.visible_message("<span class='warning'>Invisible fingers crudely paint something in blood on [T]...</span>")


// For filming shit.
/mob/dead/observer/verb/hide_sprite()
	set name = "Hide Sprite"
	set category = "Ghost"


	// Toggle alpha
	if(alpha == 127)
		alpha = 0
		to_chat(src, "<span class='warning'>Sprite hidden.</span>")
	else
		alpha = 127
		to_chat(src, "<span class='info'>Sprite shown.</span>")


/mob/dead/observer/verb/become_mommi()
	set name = "Become MoMMI"
	set category = "Ghost"

	if(!config.respawn_as_mommi)
		to_chat(src, "<span class='warning'>Respawning as MoMMI is disabled..</span>")
		return

	var/timedifference = world.time - client.time_died_as_mouse
	if(client.time_died_as_mouse && timedifference <= mouse_respawn_time * 600)
		var/timedifference_text
		timedifference_text = time2text(mouse_respawn_time * 600 - timedifference,"mm:ss")
		to_chat(src, "<span class='warning'>You may only spawn again as a mouse or MoMMI more than [mouse_respawn_time] minutes after your death. You have [timedifference_text] left.</span>")
		return

	//find a viable mouse candidate
	var/list/found_spawners = list()
	for(var/obj/machinery/mommi_spawner/s in machines)
		if(s.canSpawn())
			found_spawners.Add(s)
	if(found_spawners.len)
		var/options[found_spawners.len]
		for(var/t=1,t<=found_spawners.len,t++)
			var/obj/machinery/mommi_spawner/S = found_spawners[t]
			var/dat = text("[] on z-level = []",get_area(S),S.z)
			options[t] = dat
		var/selection = input(src,"Select a MoMMI spawn location", "Become MoMMI",null) as null|anything in options
		if(selection)
			for(var/i = 1, i<=options.len, i++)
				if(options[i] == selection)
					var/obj/machinery/mommi_spawner/final = found_spawners[i]
					final.attack_ghost(src)
					break
	else
		to_chat(src, "<span class='warning'>Unable to find any MoMMI Spawners ready to build a MoMMI in the universe. Please try again.</span>")

	//if(host)
	//	host.ckey = src.ckey
//		to_chat(host, "<span class='info'>You are now a mouse. Try to avoid interaction with players, and do not give hints away that you are more than a simple rodent.</span>")

/mob/dead/observer/verb/find_arena()
	set category = "Ghost"
	set name = "Search For Arenas"
	set desc = "Try to find an Arena to polish your robust bomb placement skills.."

	if(!arenas.len)
		to_chat(usr, "There are no arenas in the world! Ask the admins to spawn one.")
		return

	var/datum/bomberman_arena/arena_target = input("Which arena do you wish to reach?", "Arena Search Panel") in arenas
	to_chat(usr, "Reached [arena_target]")

	usr.loc = arena_target.center
	to_chat(usr, "Remember to enable darkness to be able to see the spawns. Click on a green spawn between rounds to register on it.")

/mob/dead/observer/Topic(href, href_list)
	if (href_list["reentercorpse"])
		if(istype(usr, /mob/dead/observer))
			var/mob/dead/observer/A = usr
			A.reenter_corpse()

	//BEGIN TELEPORT HREF CODE
	if(usr != src)
		return
	..()

	if(href_list["follow"])
		var/target = locate(href_list["follow"])
		if(target)
			if(isAI(target))
				var/mob/living/silicon/ai/M = target
				target = M.eyeobj
			manual_follow(target)

	if (href_list["jump"])
		var/mob/target = locate(href_list["jump"])
		var/mob/A = usr;
		to_chat(A, "Teleporting to [target]...")
		//var/mob/living/silicon/ai/A = locate(href_list["track2"]) in mob_list
		if(target && target != usr)
			var/turf/pos = get_turf(A)
			var/turf/T=get_turf(target)
			if(T != pos)
				if(!T)
					to_chat(A, "<span class='warning'>Target not in a turf.</span>")
					return
				// Why.
				//if(!client)
				//	to_chat(A, "<span class='warning'>Target doesn't have a client.</span>")
				//	return
				forceMove(T)
			following = null

	if(href_list["jumptoarenacood"])
		var/datum/bomberman_arena/targetarena = locate(href_list["targetarena"])
		usr.loc = targetarena.center
		to_chat(usr, "Remember to enable darkness to be able to see the spawns. Click on a green spawn between rounds to register on it.")

	..()

//END TELEPORT HREF CODE

/mob/dead/observer/html_mob_check()
	return 1

/mob/dead/observer/dexterity_check()
	return 1

//this is a mob verb instead of atom for performance reasons
//see /mob/verb/examinate() in mob.dm for more info
//overriden here and in /mob/living for different point span classes and sanity checks
/mob/dead/observer/pointed(atom/A as mob|obj|turf in view())
	if(!..())
		return 0
	usr.visible_message("<span class='deadsay'><b>[src]</b> points to [A]</span>")
	return 1

/mob/dead/observer/Login()
	..()
	observers += src

/mob/dead/observer/Logout()
	observers -= src
	..()

/mob/dead/observer/verb/modify_movespeed()
	set name = "Change Speed"
	set category = "Ghost"
	var/speed = input(usr,"What speed would you like to move at?","Observer Move Speed") in list("100%","125%","150%","175%","200%","FUCKING HYPERSPEED")
	if(speed == "FUCKING HYPERSPEED") //April fools
		client.move_delayer.min_delay = 0
		movespeed = 0
		return
	speed = text2num(copytext(speed,1,4))/100
	movespeed = 1/speed

/datum/locking_category/observer
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
