//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj
	//var/datum/module/mod		//not used
	var/m_amt = 0	// metal
	var/g_amt = 0	// glass
	var/w_amt = 0	// waster amounts
	var/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/reliability = 100	//Used by SOME devices to determine how reliable they are.
	var/crit_fail = 0
	var/unacidable = 0 //universal "unacidabliness" var, here so you can use it in any obj.
	var/datum/marked_datum
	animate_movement = 2
	var/throwforce = 1
	var/list/attack_verb = list() //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"

	proc/handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
		//Return: (NONSTANDARD)
		//		null if object handles breathing logic for lifeform
		//		datum/air_group to tell lifeform to process using that breath return
		//DEFAULT: Take air from turf to give to have mob process
		if(breath_request>0)
			return remove_air(breath_request)
		else
			return null

	proc/initialize()

/obj/structure/signpost
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "signpost"
	anchored = 1
	density = 1

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return attack_hand(user)

	attack_hand(mob/user as mob)
		switch(alert("Travel back to ss13?",,"Yes","No"))
			if("Yes")
				if(user.z != src.z)	return
				user.loc.loc.Exited(user)
				user.loc = pick(latejoin)
			if("No")
				return

/obj/effect/mark
		var/mark = ""
		icon = 'icons/misc/mark.dmi'
		icon_state = "blank"
		anchored = 1
		layer = 99
		mouse_opacity = 0
		unacidable = 1//Just to be sure.

/obj/admins
	name = "admins"
	var/rank = null
	var/owner = null
	var/state = 1
	//state = 1 for playing : default
	//state = 2 for observing

/obj/effect/beam
	name = "beam"
	unacidable = 1//Just to be sure.
	var/def_zone
	pass_flags = PASSTABLE

/obj/structure/bedsheetbin
	name = "linen bin"
	desc = "A bin for containing bedsheets. It looks rather cosy."
	icon = 'icons/obj/items.dmi'
	icon_state = "bedbin"
	var/amount = 23.0
	anchored = 1.0

/obj/effect/begin
	name = "begin"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "begin"
	anchored = 1.0
	unacidable = 1

/obj/effect/datacore
	name = "datacore"
	var/medical[] = list()
	var/general[] = list()
	var/security[] = list()
	//This list tracks characters spawned in the world and cannot be modified in-game. Currently referenced by respawn_character().
	var/locked[] = list()

/obj/effect/equip_e
	name = "equip e"
	var/mob/source = null
	var/s_loc = null
	var/t_loc = null
	var/obj/item/item = null
	var/place = null

/obj/effect/equip_e/human
	name = "human"
	var/mob/living/carbon/human/target = null

/obj/effect/equip_e/monkey
	name = "monkey"
	var/mob/living/carbon/monkey/target = null

/obj/effect/sign/securearea
	desc = "A warning sign which reads 'SECURE AREA'. This obviously applies to a nun-Clown."
	name = "SECURE AREA"
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/biohazard
	desc = "A warning sign which reads 'BIOHAZARD'"
	name = "BIOHAZARD"
	icon = 'icons/obj/decals.dmi'
	icon_state = "bio"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/electricshock
	desc = "A warning sign which reads 'HIGH VOLTAGE'"
	name = "HIGH VOLTAGE"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/examroom
	desc = "A guidance sign which reads 'EXAM ROOM'"
	name = "EXAM"
	icon = 'icons/obj/decals.dmi'
	icon_state = "examroom"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/vacuum
	desc = "A warning sign which reads 'HARD VACUUM AHEAD'"
	name = "HARD VACUUM AHEAD"
	icon = 'icons/obj/decals.dmi'
	icon_state = "space"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/deathsposal
	desc = "A warning sign which reads 'DISPOSAL LEADS TO SPACE'"
	name = "DISPOSAL LEADS TO SPACE"
	icon = 'icons/obj/decals.dmi'
	icon_state = "deathsposal"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/pods
	desc = "A warning sign which reads 'ESCAPE PODS'"
	name = "ESCAPE PODS"
	icon = 'icons/obj/decals.dmi'
	icon_state = "pods"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/fire
	desc = "A warning sign which reads 'DANGER: FIRE'"
	name = "DANGER: FIRE"
	icon = 'icons/obj/decals.dmi'
	icon_state = "fire"
	anchored = 1.0
	opacity = 0
	density = 0


/obj/effect/sign/nosmoking_1
	desc = "A warning sign which reads 'NO SMOKING'"
	name = "NO SMOKING"
	icon = 'icons/obj/decals.dmi'
	icon_state = "nosmoking"
	anchored = 1.0
	opacity = 0
	density = 0


/obj/effect/sign/nosmoking_2
	desc = "A warning sign which reads 'NO SMOKING'"
	name = "NO SMOKING"
	icon = 'icons/obj/decals.dmi'
	icon_state = "nosmoking2"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/redcross
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here.'"
	name = "Med-Bay"
	icon = 'icons/obj/decals.dmi'
	icon_state = "redcross"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/goldenplaque
	desc = "To be Robust is not an action or a way of life, but a mental state. Only those with the force of Will strong enough to act during a crisis, saving friend from foe, are truly Robust. Stay Robust my friends."
	name = "The Most Robust Men Award for Robustness"
	icon = 'icons/obj/decals.dmi'
	icon_state = "goldenplaque"
	anchored = 1.0
	opacity = 0
	density = 0

/*/obj/item/weapon/plaque_assembly                       //commenting this out until there's a better rework
	desc = "Put this on a wall and engrave an epitaph"
	name = "Plaque Assembly"
	icon = 'icons/obj/decals.dmi'
	icon_state = "goldenplaque"

/obj/item/weapon/plaque_assembly/afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
	if(istype(A,/turf/simulated/wall) || istype(A,/turf/simulated/shuttle/wall) || istype(A,/turf/unsimulated/wall))
		var/epitaph = input("What would you like to engrave", null)
		if(epitaph)
			var/obj/effect/sign/goldenplaque/gp = new/obj/effect/sign/goldenplaque(A)
			gp.name = epitaph
			gp.layer = 2.9
			del(src)*/

/obj/effect/sign/maltesefalcon1         //The sign is 64x32, so it needs two tiles. ;3
	desc = "The Maltese Falcon, Space Bar and Grill."
	name = "The Maltese Falcon"
	icon = 'icons/obj/decals.dmi'
	icon_state = "maltesefalcon1"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/maltesefalcon2
	desc = "The Maltese Falcon, Space Bar and Grill."
	name = "The Maltese Falcon"
	icon = 'icons/obj/decals.dmi'
	icon_state = "maltesefalcon2"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/science//These 3 have multiple types, just var-edit the icon_state to whatever one you want on the map
	desc = "A warning sign which reads 'SCIENCE!'"
	name = "SCIENCE!"
	icon = 'icons/obj/decals.dmi'
	icon_state = "science1"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/chemistry
	desc = "A warning sign which reads 'CHEMISTY'"
	name = "CHEMISTRY"
	icon = 'icons/obj/decals.dmi'
	icon_state = "chemistry1"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/effect/sign/botany
	desc = "A warning sign which reads 'HYDROPONICS'"
	name = "HYDROPONICS"
	icon = 'icons/obj/decals.dmi'
	icon_state = "hydro1"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/hud
	name = "hud"
	unacidable = 1
	var/mob/mymob = null
	var/list/adding = null
	var/list/other = null
	var/obj/screen/druggy = null
	var/vimpaired = null
	var/obj/screen/alien_view = null
	var/obj/screen/g_dither = null
	var/obj/screen/blurry = null
	var/list/darkMask = null
	var/obj/screen/r_hand_hud_object = null
	var/obj/screen/l_hand_hud_object = null
	var/show_intent_icons = 0
	var/list/obj/screen/hotkeybuttons = null
	var/hotkey_ui_hidden = 0 //This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/list/obj/screen/item_action/item_action_list = null //Used for the item action ui buttons.

	var/h_type = /obj/screen		//this is like...the most pointless thing ever. Use a god damn define!

/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	var/icon/blood_overlay = null //this saves our blood splatter overlay, which will be processed not to go over the edges of the sprite
	var/abstract = 0
	var/force = 0
	var/item_state = null
	var/damtype = "brute"
	var/r_speed = 1.0
	var/health = null
	var/burn_point = null
	var/burning = null
	var/hitsound = null
	var/w_class = 3.0
	flags = FPRINT | TABLEPASS
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	pass_flags = PASSTABLE
	pressure_resistance = 50
//	causeerrorheresoifixthis
	var/obj/item/master = null

	var/icon_action_button //If this is set, The item will make an action button on the player's HUD when picked up. The button will have the icon_action_button sprite from the screen1_action.dmi file.

	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/flags_inv //This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	var/color = null
	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags
	var/protective_temperature = 0
	var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up
	var/canremove = 1 //Mostly for Ninja code at this point but basically will not allow the item to be removed if set to 0. /N
	var/armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/list/allowed = null //suit storage stuff.

/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if(ishuman(usr))
		if(usr.get_active_hand() == null)
			src.attack_hand(usr)
		else
			usr << "\red You already have something in your hand."
	else
		usr << "\red This mob type can't use this verb."

//This proc is executed when someone clicks the on-screen UI button. To make the UI button show, set the 'icon_action_button' to the icon_state of the image of the button in screen1_action.dmi
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click()
	if( src in usr )
		attack_self(usr)

/obj/item/device
	icon = 'icons/obj/device.dmi'

/obj/item/device/infra_sensor
	name = "Infrared Sensor"
	desc = "Scans for infrared beams in the vicinity."
	icon_state = "infra_sensor"
	var/passive = 1.0
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	m_amt = 150
	origin_tech = "magnets=2"

/obj/item/device/multitool
	name = "multitool"
	desc = "Used for pulsing wires to test which to cut. Not recommended by doctors."
	icon_state = "multitool"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	m_amt = 50
	g_amt = 20
	origin_tech = "magnets=1;engineering=1"
	var/obj/machinery/telecomms/buffer // simple machine buffer for device linkage

/obj/item/blueprints
	name = "station blueprints"
	desc = "Blueprints of the station. There's stamp \"Classified\" and several coffee stains on it."
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	attack_verb = list("attacked", "bapped", "hit")

/obj/item/apc_frame
	name = "APC frame"
	desc = "Used for repairing or building APCs"
	icon = 'icons/obj/apc_repair.dmi'
	icon_state = "apc_frame"
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/effect/landmark
	name = "landmark"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1.0
	unacidable = 1

/obj/effect/landmark/alterations
	name = "alterations"

/obj/effect/laser
	name = "laser"
	desc = "IT BURNS!!!"
	icon = 'icons/obj/projectiles.dmi'
	var/damage = 0.0
	var/range = 10.0

/obj/structure/lattice
	desc = "A lightweight support lattice."
	name = "lattice"
	icon = 'icons/obj/structures.dmi'
	icon_state = "latticefull"
	density = 0
	anchored = 1.0
	layer = 2.3 //under pipes
	//	flags = CONDUCT

/obj/structure/lattice/New()
	..()
	if(!(istype(src.loc, /turf/space)))
		del(src)
	for(var/obj/structure/lattice/LAT in src.loc)
		if(LAT != src)
			del(LAT)
	icon = 'icons/obj/smoothlattice.dmi'
	icon_state = "latticeblank"
	updateOverlays()
	for (var/dir in cardinal)
		var/obj/structure/lattice/L
		if(locate(/obj/structure/lattice, get_step(src, dir)))
			L = locate(/obj/structure/lattice, get_step(src, dir))
			L.updateOverlays()

/obj/structure/lattice/Del()
	for (var/dir in cardinal)
		var/obj/structure/lattice/L
		if(locate(/obj/structure/lattice, get_step(src, dir)))
			L = locate(/obj/structure/lattice, get_step(src, dir))
			L.updateOverlays(src.loc)
	..()

/obj/structure/lattice/proc/updateOverlays()
	//if(!(istype(src.loc, /turf/space)))
	//	del(src)
	spawn(1)
		overlays = list()

		var/dir_sum = 0

		for (var/direction in cardinal)
			if(locate(/obj/structure/lattice, get_step(src, direction)))
				dir_sum += direction
			else
				if(!(istype(get_step(src, direction), /turf/space)))
					dir_sum += direction

		icon_state = "lattice[dir_sum]"
		return

		/*
		overlays += icon(icon,"lattice-middlebar") //the nw-se bar in the cneter
		for (var/dir in cardinal)
			if(locate(/obj/structure/lattice, get_step(src, dir)))
				src.overlays += icon(icon,"lattice-[dir2text(dir)]")
			else
				src.overlays += icon(icon,"lattice-nc-[dir2text(dir)]") //t for turf
				if(!(istype(get_step(src, dir), /turf/space)))
					src.overlays += icon(icon,"lattice-t-[dir2text(dir)]") //t for turf

		//if ( !( (locate(/obj/structure/lattice, get_step(src, SOUTH))) || (locate(/obj/structure/lattice, get_step(src, EAST))) ))
		//	src.overlays += icon(icon,"lattice-c-se")
		if ( !( (locate(/obj/structure/lattice, get_step(src, NORTH))) || (locate(/obj/structure/lattice, get_step(src, WEST))) ))
			src.overlays += icon(icon,"lattice-c-nw")
		if ( !( (locate(/obj/structure/lattice, get_step(src, NORTH))) || (locate(/obj/structure/lattice, get_step(src, EAST))) ))
			src.overlays += icon(icon,"lattice-c-ne")
		if ( !( (locate(/obj/structure/lattice, get_step(src, SOUTH))) || (locate(/obj/structure/lattice, get_step(src, WEST))) ))
			src.overlays += icon(icon,"lattice-c-sw")

		if(!(overlays))
			icon_state = "latticefull"
		*/

/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )

/obj/structure/m_tray
	name = "morgue tray"
	desc = "Apply corpse before closing."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morguet"
	density = 1
	layer = 2.0
	var/obj/structure/morgue/connected = null
	anchored = 1.0

/obj/structure/c_tray
	name = "crematorium tray"
	desc = "Apply body before burning."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "cremat"
	density = 1
	layer = 2.0
	var/obj/structure/crematorium/connected = null
	anchored = 1.0





/obj/structure/cable
	level = 1
	anchored =1
	var/netnum = 0
	name = "power cable"
	desc = "A flexible superconducting cable for heavy-duty power transfer"
	icon = 'icons/obj/power_cond_red.dmi'
	icon_state = "0-1"
	var/d1 = 0
	var/d2 = 1
	layer = 2.44 //Just below unary stuff, which is at 2.45 and above pipes, which are at 2.4
	var/color="red"
	var/obj/structure/powerswitch/power_switch

/obj/structure/cable/yellow
	color="yellow"
	icon = 'icons/obj/power_cond_yellow.dmi'

/obj/structure/cable/green
	color="green"
	icon = 'icons/obj/power_cond_green.dmi'

/obj/structure/cable/blue
	color="blue"
	icon = 'icons/obj/power_cond_blue.dmi'

/obj/structure/cable/pink
	color="pink"
	icon = 'icons/obj/power_cond_pink.dmi'

/obj/structure/cable/orange
	color="orange"
	icon = 'icons/obj/power_cond_orange.dmi'

/obj/structure/cable/cyan
	color="cyan"
	icon = 'icons/obj/power_cond_cyan.dmi'

/obj/structure/cable/white
	color="white"
	icon = 'icons/obj/power_cond_white.dmi'

/obj/effect/manifest
	name = "manifest"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	unacidable = 1//Just to be sure.

/obj/structure/morgue
	name = "morgue"
	desc = "Used to keep bodies in untill someone fetches them."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue1"
	density = 1
	var/obj/structure/m_tray/connected = null
	anchored = 1.0

/obj/structure/crematorium
	name = "crematorium"
	desc = "A human incinerator. Works well on barbeque nights."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "crema1"
	density = 1
	var/obj/structure/c_tray/connected = null
	anchored = 1.0
	var/cremating = 0
	var/id = 1
	var/locked = 0

/obj/effect/mine
	name = "Mine"
	desc = "I Better stay away from that thing."
	density = 1
	anchored = 1
	layer = 3
	icon = 'icons/obj/weapons.dmi'
	icon_state = "uglymine"
	var/triggerproc = "explode" //name of the proc thats called when the mine is triggered
	var/triggered = 0

/obj/effect/mine/dnascramble
	name = "Radiation Mine"
	icon_state = "uglymine"
	triggerproc = "triggerrad"

/obj/effect/mine/plasma
	name = "Plasma Mine"
	icon_state = "uglymine"
	triggerproc = "triggerplasma"

/obj/effect/mine/kick
	name = "Kick Mine"
	icon_state = "uglymine"
	triggerproc = "triggerkick"

/obj/effect/mine/n2o
	name = "N2O Mine"
	icon_state = "uglymine"
	triggerproc = "triggern2o"

/obj/effect/mine/stun
	name = "Stun Mine"
	icon_state = "uglymine"
	triggerproc = "triggerstun"

/obj/effect/overlay
	name = "overlay"
	unacidable = 1
	var/i_attached//Added for possible image attachments to objects. For hallucinations and the like.

/obj/effect/overlay/beam//Not actually a projectile, just an effect.
	name="beam"
	icon='icons/effects/beam.dmi'
	icon_state="b_beam"
	var/tmp/atom/BeamSource
	New()
		..()
		spawn(10) del src

/obj/effect/portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	density = 1
	unacidable = 1//Can't destroy energy portals.
	var/failchance = 5
	var/obj/item/target = null
	var/creator = null
	anchored = 1.0

/obj/effect/projection
	name = "Projection"
	desc = "This looks like a projection of something."
	anchored = 1.0

/obj/structure/rack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	density = 1
	flags = FPRINT
	anchored = 1.0
	throwpass = 1	//You can throw objects over this, despite it's density.

/obj/effect/shut_controller
	name = "shut controller"
	var/moving = null
	var/list/parts = list(  )

/obj/effect/landmark/start
	name = "start"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1.0

/obj/structure/stool
	name = "stool"
	desc = "Apply butt."
	icon = 'icons/obj/objects.dmi'
	icon_state = "stool"
	anchored = 1.0
	flags = FPRINT
	pressure_resistance = 3*ONE_ATMOSPHERE

/obj/structure/stool/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	icon_state = "bed"
	var/mob/living/buckled_mob

/obj/structure/stool/bed/alien
	name = "resting contraption"
	desc = "This looks similar to contraptions from earth. Could aliens be stealing our technology?"
	icon_state = "abed"

/obj/structure/stool/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/mob/alien.dmi'
	icon_state = "nest"
	var/health = 100

/obj/structure/stool/bed/chair	//YES, chairs are a type of bed, which are a type of stool. This works, believe me.	-Pete
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "chair"

/obj/structure/stool/bed/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy."

/obj/structure/stool/bed/chair/comfy/brown
	icon_state = "comfychair_brown"

/obj/structure/stool/bed/chair/comfy/beige
	icon_state = "comfychair_beige"

/obj/structure/stool/bed/chair/comfy/teal
	icon_state = "comfychair_teal"

/obj/structure/stool/bed/chair/office
	anchored = 0

/obj/structure/stool/bed/chair/comfy/black
	icon_state = "comfychair_black"

/obj/structure/stool/bed/chair/comfy/lime
	icon_state = "comfychair_lime"

/obj/structure/stool/bed/chair/office/Move()
	..()
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			buckled_mob.loc = src.loc
			buckled_mob.dir = src.dir

/obj/structure/stool/bed/chair/office/light
	icon_state = "officechair_white"

/obj/structure/stool/bed/chair/office/dark
	icon_state = "officechair_dark"

/obj/structure/table
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table"
	density = 1
	anchored = 1.0
	layer = 2.8
	throwpass = 1	//You can throw objects over this, despite it's density.")

/obj/structure/table/New()
	..()
	for(var/obj/structure/table/T in src.loc)
		if(T != src)
			del(T)
	update_icon()
	for(var/direction in list(1,2,4,8,5,6,9,10))
		if(locate(/obj/structure/table,get_step(src,direction)))
			var/obj/structure/table/T = locate(/obj/structure/table,get_step(src,direction))
			T.update_icon()

/obj/structure/table/Del()
	for(var/direction in list(1,2,4,8,5,6,9,10))
		if(locate(/obj/structure/table,get_step(src,direction)))
			var/obj/structure/table/T = locate(/obj/structure/table,get_step(src,direction))
			T.update_icon()
	..()

/obj/structure/table/update_icon()
	spawn(2) //So it properly updates when deleting
		var/dir_sum = 0
		for(var/direction in list(1,2,4,8,5,6,9,10))
			var/skip_sum = 0
			for(var/obj/structure/window/W in src.loc)
				if(W.dir == direction) //So smooth tables don't go smooth through windows
					skip_sum = 1
					continue
			var/inv_direction //inverse direction
			switch(direction)
				if(1)
					inv_direction = 2
				if(2)
					inv_direction = 1
				if(4)
					inv_direction = 8
				if(8)
					inv_direction = 4
				if(5)
					inv_direction = 10
				if(6)
					inv_direction = 9
				if(9)
					inv_direction = 6
				if(10)
					inv_direction = 5
			for(var/obj/structure/window/W in get_step(src,direction))
				if(W.dir == inv_direction) //So smooth tables don't go smooth through windows when the window is on the other table's tile
					skip_sum = 1
					continue
			if(!skip_sum) //means there is a window between the two tiles in this direction
				if(locate(/obj/structure/table,get_step(src,direction)))
					if(direction <5)
						dir_sum += direction
					else
						if(direction == 5)	//This permits the use of all table directions. (Set up so clockwise around the central table is a higher value, from north)
							dir_sum += 16
						if(direction == 6)
							dir_sum += 32
						if(direction == 8)	//Aherp and Aderp.  Jezes I am stupid.  -- SkyMarshal
							dir_sum += 8
						if(direction == 10)
							dir_sum += 64
						if(direction == 9)
							dir_sum += 128

		var/table_type = 0 //stand_alone table
		if(dir_sum%16 in cardinal)
			table_type = 1 //endtable
			dir_sum %= 16
		if(dir_sum%16 in list(3,12))
			table_type = 2 //1 tile thick, streight table
			if(dir_sum%16 == 3) //3 doesn't exist as a dir
				dir_sum = 2
			if(dir_sum%16 == 12) //12 doesn't exist as a dir.
				dir_sum = 4
		if(dir_sum%16 in list(5,6,9,10))
			if(locate(/obj/structure/table,get_step(src.loc,dir_sum%16)))
				table_type = 3 //full table (not the 1 tile thick one, but one of the 'tabledir' tables)
			else
				table_type = 2 //1 tile thick, corner table (treated the same as streight tables in code later on)
			dir_sum %= 16
		if(dir_sum%16 in list(13,14,7,11)) //Three-way intersection
			table_type = 5 //full table as three-way intersections are not sprited, would require 64 sprites to handle all combinations.  TOO BAD -- SkyMarshal
			switch(dir_sum%16)	//Begin computation of the special type tables.  --SkyMarshal
				if(7)
					if(dir_sum == 23)
						table_type = 6
						dir_sum = 8
					else if(dir_sum == 39)
						dir_sum = 4
						table_type = 6
					else if(dir_sum == 55 || dir_sum == 119 || dir_sum == 247 || dir_sum == 183)
						dir_sum = 4
						table_type = 3
					else
						dir_sum = 4
				if(11)
					if(dir_sum == 75)
						dir_sum = 5
						table_type = 6
					else if(dir_sum == 139)
						dir_sum = 9
						table_type = 6
					else if(dir_sum == 203 || dir_sum == 219 || dir_sum == 251 || dir_sum == 235)
						dir_sum = 8
						table_type = 3
					else
						dir_sum = 8
				if(13)
					if(dir_sum == 29)
						dir_sum = 10
						table_type = 6
					else if(dir_sum == 141)
						dir_sum = 6
						table_type = 6
					else if(dir_sum == 189 || dir_sum == 221 || dir_sum == 253 || dir_sum == 157)
						dir_sum = 1
						table_type = 3
					else
						dir_sum = 1
				if(14)
					if(dir_sum == 46)
						dir_sum = 1
						table_type = 6
					else if(dir_sum == 78)
						dir_sum = 2
						table_type = 6
					else if(dir_sum == 110 || dir_sum == 254 || dir_sum == 238 || dir_sum == 126)
						dir_sum = 2
						table_type = 3
					else
						dir_sum = 2 //These translate the dir_sum to the correct dirs from the 'tabledir' icon_state.
		if(dir_sum%16 == 15)
			table_type = 4 //4-way intersection, the 'middle' table sprites will be used.

		if(istype(src,/obj/structure/table/reinforced))
			switch(table_type)
				if(0)
					icon_state = "reinf_table"
				if(1)
					icon_state = "reinf_1tileendtable"
				if(2)
					icon_state = "reinf_1tilethick"
				if(3)
					icon_state = "reinf_tabledir"
				if(4)
					icon_state = "reinf_middle"
				if(5)
					icon_state = "reinf_tabledir2"
				if(6)
					icon_state = "reinf_tabledir3"
		else if(istype(src,/obj/structure/table/woodentable))
			switch(table_type)
				if(0)
					icon_state = "wood_table"
				if(1)
					icon_state = "wood_1tileendtable"
				if(2)
					icon_state = "wood_1tilethick"
				if(3)
					icon_state = "wood_tabledir"
				if(4)
					icon_state = "wood_middle"
				if(5)
					icon_state = "wood_tabledir2"
				if(6)
					icon_state = "wood_tabledir3"
		else
			switch(table_type)
				if(0)
					icon_state = "table"
				if(1)
					icon_state = "table_1tileendtable"
				if(2)
					icon_state = "table_1tilethick"
				if(3)
					icon_state = "tabledir"
				if(4)
					icon_state = "table_middle"
				if(5)
					icon_state = "tabledir2"
				if(6)
					icon_state = "tabledir3"
		if (dir_sum in list(1,2,4,8,5,6,9,10))
			dir = dir_sum
		else
			dir = 2

/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A version of the four legged table. It is stronger."
	icon_state = "reinf_table"
	var/status = 2

/obj/structure/table/woodentable
	name = "wooden table"
	desc = "Do not apply fire to this. Rumour says it burns easily."
	icon_state = "wood_table"

/obj/structure/mopbucket
	desc = "Fill it with water, but don't forget a mop!"
	name = "mop bucket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = 1
	flags = FPRINT
	pressure_resistance = ONE_ATMOSPHERE
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite

/obj/structure/kitchenspike
	name = "a meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals"
	density = 1
	anchored = 1
	var/meat = 0
	var/occupied = 0
	var/meattype = 0 // 0 - Nothing, 1 - Monkey, 2 - Xeno

/obj/structure/displaycase
	name = "Display Case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox1"
	desc = "A display case for prized possessions. It taunts you to kick it."
	density = 1
	anchored = 1
	unacidable = 1//Dissolving the case would also delete the gun.
	var/health = 30
	var/occupied = 1
	var/destroyed = 0

/obj/effect/showcase
	name = "Showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = 1
	anchored = 1
	unacidable = 1//temporary until I decide whether the borg can be removed. -veyveyr

//BEGIN BRAINS=====================================================
/obj/item/brain
	name = "brain"
	desc = "A piece of juicy meat found in a persons head."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain2"
	flags = TABLEPASS
	force = 1.0
	w_class = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=3"
	attack_verb = list("attacked", "slapped", "whacked")

	var/mob/living/carbon/brain/brainmob = null

	New()
		..()
		//Shifting the brain "mob" over to the brain object so it's easier to keep track of. --NEO
		//WASSSSSUUUPPPP /N
		spawn(5)
			if(brainmob && brainmob.client)
				brainmob.client.screen.len = null //clear the hud

	proc
		transfer_identity(var/mob/living/carbon/human/H)
			name = "[H]'s brain"
			brainmob = new(src)
			brainmob.name = H.real_name
			brainmob.real_name = H.real_name
			brainmob.dna = H.dna
			brainmob.timeofhostdeath = H.timeofdeath
			if(H.mind)
				H.mind.transfer_to(brainmob)
			brainmob << "\blue You might feel slightly disoriented. That's normal when your brain gets cut out."
			return

//END BRAINS=====================================================



// Basically this Metroid Core catalyzes reactions that normally wouldn't happen anywhere
/obj/item/metroid_core
	name = "metroid core"
	desc = "A very slimy and tender part of a Metroid. They also legend to have \"magical powers\"."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "metroid core"
	flags = TABLEPASS
	force = 1.0
	w_class = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 6
	origin_tech = "biotech=4"
	var/POWERFLAG = 0 // sshhhhhhh
	var/Flush = 30
	var/Uses = 5 // uses before it goes inert

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		POWERFLAG = rand(1,10)
		Uses = rand(7, 25)
		//flags |= NOREACT

		spawn()
			Life()

	proc/Life()
		while(src)
			sleep(25)
			Flush--
			if(Flush <= 0)
				reagents.clear_reagents()
				Flush = 30





/obj/structure/noticeboard
	name = "Notice Board"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nboard00"
	flags = FPRINT
	desc = "A board for pinning important notices upon."
	density = 0
	anchored = 1
	var/notices = 0

/obj/effect/deskclutter
	name = "desk clutter"
	icon = 'icons/obj/items.dmi'
	icon_state = "deskclutter"
	desc = "Some clutter the detective has accumalated over the years..."
	anchored = 1

/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER

// TODO: robust mixology system! (and merge with beakers, maybe)
/obj/item/weapon/glass
	name = "empty glass"
	desc = "Emptysville."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "glass_empty"
	item_state = "beaker"
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	var/datum/substance/inside = null
	throwforce = 5
	g_amt = 100
	New()
		..()
		src.pixel_x = rand(-5, 5)
		src.pixel_y = rand(-5, 5)


/*
/obj/item/weapon/storage/glassbox
	name = "Glassware Box"
	icon_state = "beakerbox"
	item_state = "syringe_kit"
	New()
		..()
		new /obj/item/weapon/glass( src )
		new /obj/item/weapon/glass( src )
		new /obj/item/weapon/glass( src )
		new /obj/item/weapon/glass( src )
		new /obj/item/weapon/glass( src )
		new /obj/item/weapon/glass( src )
		new /obj/item/weapon/glass( src )
*/


/obj/structure/falsewall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/walls.dmi'
	icon_state = ""
	density = 1
	opacity = 1
	anchored = 1

/obj/structure/falsewall/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag"
	icon_state = ""

/obj/structure/falsewall/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny"
	icon_state = ""

/obj/structure/falsewall/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster"
	icon_state = ""

/obj/structure/falsewall/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea"
	icon_state = ""

/obj/structure/falsewall/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definately a bad idea"
	icon_state = ""

/obj/structure/falsewall/bananium
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk"
	icon_state = ""

/obj/structure/falsewall/sand
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon_state = ""

/*/obj/structure/falsewall/wood
	name = "wooden wall"
	desc = "A wall with classy wooden paneling."
	icon_state = ""*/

/obj/structure/falserwall
	name = "r wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon = 'icons/turf/walls.dmi'
	icon_state = "r_wall"
	density = 1
	opacity = 1
	anchored = 1

/obj/item/stack
	var/singular_name
	var/amount = 1
	var/max_amount //also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount

/obj/item/stack/rods
	name = "metal rods"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 3.0
	force = 9.0
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	m_amt = 1875
	max_amount = 60
	attack_verb = list("hit", "bludgeoned", "whacked")

/obj/item/stack/sheet
	name = "sheet"
//	var/const/length = 2.5 //2.5*1.5*0.01*100000 == 3750 == m_amt
//	var/const/width = 1.5
//	var/const/height = 0.01
	flags = FPRINT | TABLEPASS
	w_class = 3.0
	force = 5
	throwforce = 5
	max_amount = 50
	throw_speed = 3
	throw_range = 3
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")
	var/perunit = 3750

/obj/item/stack/sheet/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/sheetsnatcher))
		var/obj/item/weapon/sheetsnatcher/S = W
		if(!S.mode)
			S.add(src,user)
		else
			for (var/obj/item/stack/sheet/stack in locate(src.x,src.y,src.z))
				S.add(stack,user)
	..()

/obj/item/stack/sheet/wood
	name = "wooden planks"
	desc = "One can only guess that this is a bunch of wood."
	singular_name = "wood plank"
	icon_state = "sheet-wood"
	origin_tech = "materials=1;biotech=1"

/obj/item/stack/sheet/sandstone
	name = "sandstone bricks"
	desc = "This appears to be a combination of both sand and stone."
	singular_name = "sandstone brick"
	icon_state = "sheet-sandstone"
	throw_speed = 4
	throw_range = 5
	origin_tech = "materials=1"

/obj/item/stack/sheet/glass
	name = "glass"
	desc = "HOLY HELL! That is a lot of glass."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	g_amt = 3750
	origin_tech = "materials=1"


/obj/item/stack/sheet/rglass
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"
	g_amt = 3750
	m_amt = 1875
	origin_tech = "materials=2"

/obj/item/stack/sheet/rglass/cyborg
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"
	g_amt = 0
	m_amt = 0

/obj/item/stack/sheet/cloth
	name = "cloth"
	desc = "This roll of cloth is made from only the finest chemicals and bunny rabbits."
	singular_name = "cloth roll"
	icon_state = "sheet-cloth"
	origin_tech = "materials=2"


/obj/item/stack/sheet/metal
	name = "metal"
	desc = "Sheets made out off metal. It has been dubbed Metal Sheets."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	m_amt = 3750
	throwforce = 14.0
	flags = FPRINT | TABLEPASS | CONDUCT
	origin_tech = "materials=1"

/obj/item/stack/sheet/metal/cyborg
	name = "metal"
	desc = "Sheets made out off metal. It has been dubbed Metal Sheets."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	m_amt = 0
	throwforce = 14.0
	flags = FPRINT | TABLEPASS | CONDUCT

/obj/item/stack/sheet/plasteel
	name = "plasteel"
	singular_name = "plasteel sheet"
	desc = "This sheet is an alloy of iron and plasma."
	icon_state = "sheet-plasteel"
	item_state = "sheet-metal"
	m_amt = 7500
	throwforce = 15.0
	flags = FPRINT | TABLEPASS | CONDUCT
	origin_tech = "materials=2"

/obj/item/stack/tile/plasteel
	name = "floor tiles"
	singular_name = "floor tile"
	desc = "Those could work as a pretty decent throwing weapon"
	icon_state = "tile"
	w_class = 3.0
	force = 6.0
	m_amt = 937.5
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT
	max_amount = 60

/obj/item/stack/tile/grass
	name = "grass tiles"
	singular_name = "grass floor tile"
	desc = "A patch of grass like they often use on golf courses"
	icon_state = "tile_grass"
	w_class = 3.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 5
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT
	max_amount = 60
	origin_tech = "biotech=1"

/obj/item/stack/tile/wood
	name = "wood floor tiles"
	singular_name = "wood floor tile"
	desc = "an easy to fit wood floor tile"
	icon_state = "tile-wood"
	w_class = 3.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 5
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT
	max_amount = 60

/obj/item/stack/light_w
	name = "wired glass tiles"
	singular_name = "wired glass floor tile"
	desc = "A glass tile, which is wired, somehow."
	icon_state = "glass_wire"
	w_class = 3.0
	force = 3.0
	throwforce = 5.0
	throw_speed = 5
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT
	max_amount = 60

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		..()
		if(istype(O,/obj/item/weapon/wirecutters))
			var/obj/item/weapon/cable_coil/CC = new/obj/item/weapon/cable_coil(user.loc)
			CC.amount = 5
			amount--
			new/obj/item/stack/sheet/glass(user.loc)
			if(amount <= 0)
				user.drop_from_inventory(src)
				del(src)

		if(istype(O,/obj/item/stack/sheet/metal))
			var/obj/item/stack/sheet/metal/M = O
			M.amount--
			if(M.amount <= 0)
				user.drop_from_inventory(M)
				del(M)
			amount--
			new/obj/item/stack/tile/light(user.loc)
			if(amount <= 0)
				user.drop_from_inventory(src)
				del(src)

/obj/item/stack/tile/light
	name = "light tiles"
	singular_name = "light floor tile"
	desc = "A floor tile, made out off glass. It produces light."
	icon_state = "tile_e"
	w_class = 3.0
	force = 3.0
	throwforce = 5.0
	throw_speed = 5
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT
	max_amount = 60
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")
	var/on = 1
	var/state //0 = fine, 1 = flickering, 2 = breaking, 3 = broken

	New()
		..()
		if(prob(5))
			state = 3 //broken
		else if(prob(5))
			state = 2 //breaking
		else if(prob(10))
			state = 1 //flickering occasionally
		else
			state = 0 //fine

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		..()
		if(istype(O,/obj/item/weapon/crowbar))
			new/obj/item/stack/sheet/metal(user.loc)
			amount--
			new/obj/item/stack/light_w(user.loc)
			if(amount <= 0)
				user.drop_from_inventory(src)
				del(src)

/obj/item/stack/sheet/cardboard	//BubbleWrap
	name = "cardboard"
	desc = "Large sheets of card, like boxes folded flat."
	singular_name = "cardboard sheet"
	icon_state = "sheet-card"
	flags = FPRINT | TABLEPASS
	origin_tech = "materials=1"

/obj/item/weapon/beach_ball
	icon = 'icons/misc/beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	item_state = "beachball"
	density = 0
	anchored = 0
	w_class = 1.0
	force = 0.0
	throwforce = 0.0
	throw_speed = 1
	throw_range = 20
	flags = FPRINT | USEDELAY | TABLEPASS | CONDUCT
	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		user.drop_item()
		src.throw_at(target, throw_range, throw_speed)

/obj/effect/stop
	var/victim = null
	icon_state = "empty"
	name = "Geas"
	desc = "You can't resist."
	// name = ""

/obj/item/clothing
	name = "clothing"

/obj/effect/spawner
	name = "object spawner"
