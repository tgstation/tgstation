var/list/image/ghost_darkness_images = list() //this is a list of images for things ghosts should still be able to see when they toggle darkness, BUT NOT THE GHOSTS THEMSELVES!
var/list/image/ghost_images_full = list() //this is a list of full images of the ghosts themselves
var/list/image/ghost_images_default = list() //this is a list of the default (non-accessorized, non-dir) images of the ghosts themselves
var/list/image/ghost_images_simple = list() //this is a list of all ghost images as the simple white ghost
/mob/dead/observer
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" //jinkies!
	icon = 'icons/mob/mob.dmi'
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
	var/mob/observetarget = null	//The target mob that the ghost is observing. Used as a reference in logout()
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

	var/turf/T
	if(ismob(body))
		T = get_turf(body)				//Where is the body located?
		attack_log = body.attack_log	//preserve our attack logs by copying them to our ghost

		gender = body.gender
		if(body.mind && body.mind.name)
			name = body.mind.name
		else
			if(body.real_name)
				name = body.real_name
			else
				name = random_unique_name(gender)

		mind = body.mind	//we don't transfer the mind but we keep a reference to it.
		if(ishuman(body))
			var/mob/living/carbon/human/body_human = body
			if(HAIR in body_human.dna.species.species_traits)
				hair_style = body_human.hair_style
				hair_color = brighten_color(body_human.hair_color)
			if(FACEHAIR in body_human.dna.species.species_traits)
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
	addtimer(src, "update_atom_colour", 10)

/mob/dead/observer/ratvar_act()
	var/old_color = color
	color = "#FAE48C"
	animate(src, color = old_color, time = 10)
	addtimer(src, "update_atom_colour", 10)

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

/*
Transfer_mind is there to check if mob is being deleted/not going to have a body.
Works together with spawning an observer, noted above.
*/

/mob/proc/ghostize(can_reenter_corpse = 1)
	if(key)
		if(!cmptext(copytext(key,1,2),"@")) // Skip aghosts.
			var/mob/dead/observer/ghost = new(src)	// Transfer safety to observer spawning proc.
			SStgui.on_transfer(src, ghost) // Transfer NanoUIs.
			ghost.can_reenter_corpse = can_reenter_corpse
			ghost.key = key
			return ghost

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."

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
	if(NewLoc)
		loc = NewLoc
		for(var/obj/effect/step_trigger/S in NewLoc)
			S.Crossed(src)

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

	for(var/obj/effect/step_trigger/S in locate(x, y, z))	//<-- this is dumb
		S.Crossed(src)

/mob/dead/observer/is_active()
	return 0

/mob/dead/observer/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Station Time: [worldtime2text()]")
		if(ticker && ticker.mode)
			for(var/datum/gang/G in ticker.mode.gangs)
				if(G.is_dominating)
					stat(null, "[G.name] Gang Takeover: [max(G.domination_time_remaining(), 0)]")
			if(istype(ticker.mode, /datum/game_mode/blob))
				var/datum/game_mode/blob/B = ticker.mode
				if(B.message_sent)
					stat(null, "Blobs to Blob Win: [blobs_legit.len]/[B.blobwincount]")

/mob/dead/observer/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"
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
				var/old_plane = source.plane
				source.layer = FLOAT_LAYER
				source.plane = FLOAT_PLANE
				A.add_overlay(source)
				source.layer = old_layer
				source.plane = old_plane
	src << "<span class='ghostalert'><a href=?src=\ref[src];reenter=1>(Click to re-enter)</a></span>"
	if(sound)
		src << sound(sound)

/mob/dead/observer/proc/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"
	if(!isobserver(usr))
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

	if(orbiting && orbiting.orbiting != target)
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
	setDir(2)//reset dir so the right directional sprites show up
	..()

/mob/dead/observer/stop_orbit()
	..()
	//restart our floating animation after orbit is done.
	pixel_y = 0
	animate(src, pixel_y = 2, time = 10, loop = -1)

/mob/dead/observer/verb/jumptomob() //Moves the ghost instead of just changing the ghosts's eye -Nodrak
	set category = "Ghost"
	set name = "Jump to Mob"
	set desc = "Teleport to a mob"

	if(isobserver(usr)) //Make sure they're an observer!


		var/list/dest = list() //List of possible destinations (mobs)
		var/target = null	   //Chosen target.

		dest += getpois(mobs_only=1) //Fill list, prompt user with list
		target = input("Please, select a player!", "Jump to Mob", null, null) as null|anything in dest

		if (!target)//Make sure we actually have a target
			return
		else
			var/mob/M = dest[target] //Destination mob
			var/mob/A = src			 //Source mob
			var/turf/T = get_turf(M) //Turf of the destination mob

			if(T && isturf(T))	//Make sure the turf exists, then move the source to that destination.
				A.loc = T
			else
				A << "This mob is not located in the game world."

/mob/dead/observer/verb/boo()
	set category = "Ghost"
	set name = "Boo!"
	set desc= "Scare your crew members because of boredom!"

	if(bootime > world.time) return
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

	if(ismegafauna(target))
		src << "<span class='warning'>This creature is too powerful for you to possess!</span>"
		return 0

	if(can_reenter_corpse || (mind && mind.current))
		if(alert(src, "Your soul is still tied to your former life as [mind.current.name], if you go foward there is no going back to that life. Are you sure you wish to continue?", "Move On", "Yes", "No") == "No")
			return 0
	if(target.key)
		src << "<span class='warning'>Someone has taken this body while you were choosing!</span>"
		return 0

	target.key = key
	target.faction = list("neutral")
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
	set name = "View Crew Manifest"
	set category = "Ghost"

	var/dat
	dat += "<h4>Crew Manifest</h4>"
	dat += data_core.get_manifest()

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

	if(HAIR in client.prefs.pref_species.species_traits)
		hair_style = client.prefs.hair_style
		hair_color = brighten_color(client.prefs.hair_color)
	if(FACEHAIR in client.prefs.pref_species.species_traits)
		facial_hair_style = client.prefs.facial_hair_style
		facial_hair_color = brighten_color(client.prefs.facial_hair_color)

	update_icon()

/mob/dead/observer/canUseTopic()
	if(check_rights(R_ADMIN, 0))
		return 1
	return

/mob/dead/observer/is_literate()
	return 1

/mob/dead/observer/vv_edit_var(var_name, var_value)
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

/mob/dead/observer/reset_perspective(atom/A)
	if(client)
		if(ismob(client.eye) && (client.eye != src))
			var/mob/target = client.eye
			observetarget = null
			if(target.observers)
				target.observers -= src
				UNSETEMPTY(target.observers)
	if(..())
		if(hud_used)
			client.screen = list()
			hud_used.show_hud(hud_used.hud_version)

/mob/dead/observer/verb/observe()
	set name = "Observe"
	set category = "OOC"

	var/list/creatures = getpois()

	reset_perspective(null)

	var/eye_name = null

	eye_name = input("Please, select a player!", "Observe", null, null) as null|anything in creatures

	if (!eye_name)
		return

	var/mob/mob_eye = creatures[eye_name]
	//Istype so we filter out points of interest that are not mobs
	if(client && mob_eye && istype(mob_eye))
		client.eye = mob_eye
		client.screen = list()
		if(mob_eye.hud_used)
			LAZYINITLIST(mob_eye.observers)
			mob_eye.observers |= src
			mob_eye.hud_used.show_hud(1,src)
			observetarget = mob_eye