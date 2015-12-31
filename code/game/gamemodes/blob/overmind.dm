/mob/camera/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	icon = 'icons/mob/blob.dmi'
	icon_state = "marker"

	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	invisibility = INVISIBILITY_OBSERVER

	pass_flags = PASSBLOB
	faction = list("blob")

	var/obj/effect/blob/core/blob_core = null // The blob overmind's core
	var/blob_points = 0
	var/max_blob_points = 100
	var/last_attack = 0
	var/datum/reagent/blob/blob_reagent_datum = new/datum/reagent/blob()
	var/list/blob_mobs = list()
	var/ghostimage = null

/mob/camera/blob/New()
	var/new_name = "[initial(name)] ([rand(1, 999)])"
	name = new_name
	real_name = new_name
	last_attack = world.time
	var/list/possible_reagents = list()
	for(var/type in (subtypesof(/datum/reagent/blob)))
		possible_reagents.Add(new type)
	blob_reagent_datum = pick(possible_reagents)
	if(blob_core)
		blob_core.update_icon()

	ghostimage = image(src.icon,src,src.icon_state)
	ghost_darkness_images |= ghostimage //so ghosts can see the blob cursor when they disable darkness
	updateallghostimages()
	..()

/mob/camera/blob/Life()
	if(!blob_core)
		qdel(src)
	..()

/mob/camera/blob/Destroy()
	if (ghostimage)
		ghost_darkness_images -= ghostimage
		qdel(ghostimage)
		ghostimage = null;
		updateallghostimages()
	return ..()

/mob/camera/blob/Login()
	..()
	sync_mind()
	src << "<span class='notice'>You are the overmind!</span>"
	blob_help()
	update_health()

/mob/camera/blob/proc/update_health()
	if(blob_core)
		hud_used.blobhealthdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round(blob_core.health)]</font></div>"

/mob/camera/blob/proc/add_points(points)
	if(points != 0)
		blob_points = Clamp(blob_points + points, 0, max_blob_points)
		hud_used.blobpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[round(src.blob_points)]</font></div>"

/mob/camera/blob/say(message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "You cannot send IC messages (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat)
		return

	blob_talk(message)

/mob/camera/blob/proc/blob_talk(message)
	log_say("[key_name(src)] : [message]")

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	var/message_a = say_quote(message, get_spans())
	var/rendered = "<span class='big'><font color=\"#EE4000\">Blob Telepathy, <b>[name](<font color=\"[blob_reagent_datum.color]\">[blob_reagent_datum.name]</font>)</b> [message_a]</font></span>"

	for(var/mob/M in mob_list)
		if(isovermind(M) || isobserver(M) || istype(M, /mob/living/simple_animal/hostile/blob))
			M.show_message(rendered, 2)

/mob/camera/blob/emote(act,m_type=1,message = null)
	return

/mob/camera/blob/blob_act()
	return

/mob/camera/blob/Stat()
	..()
	if(statpanel("Status"))
		if(blob_core)
			stat(null, "Core Health: [blob_core.health]")
		stat(null, "Power Stored: [blob_points]/[max_blob_points]")

/mob/camera/blob/Move(NewLoc, Dir = 0)
	var/obj/effect/blob/B = locate() in range("3x3", NewLoc)
	if(B)
		loc = NewLoc
	else
		return 0

/mob/camera/blob/proc/can_attack()
	return (world.time > (last_attack + CLICK_CD_RANGE))


/obj/screen/blob
	icon = 'icons/mob/blob.dmi'

/obj/screen/blob/BlobHelp
	icon_state = "ui_help"
	name = "Blob Help"
	desc = "Help on playing blob!"

/obj/screen/blob/BlobHelp/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.blob_help()

/obj/screen/blob/JumpToNode
	icon_state = "ui_tonode"
	name = "Jump to Node"
	desc = "Moves your camera to a selected blob node."

/obj/screen/blob/JumpToNode/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.jump_to_node()

/obj/screen/blob/JumpToCore
	icon_state = "ui_tocore"
	name = "Jump to Core"
	desc = "Moves your camera to your blob core."

/obj/screen/blob/JumpToCore/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.transport_core()

/obj/screen/blob/Blobbernaut
	icon_state = "ui_blobbernaut"
	name = "Produce Blobbernaut (20)"
	desc = "Produces a blobbernaut for 20 points."

/obj/screen/blob/Blobbernaut/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_blobbernaut()

/obj/screen/blob/ResourceBlob
	icon_state = "ui_resource"
	name = "Produce Resource Blob (40)"
	desc = "Produces a resource blob for 40 points."

/obj/screen/blob/ResourceBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_resource()

/obj/screen/blob/NodeBlob
	icon_state = "ui_node"
	name = "Produce Node Blob (60)"
	desc = "Produces a node blob for 60 points."

/obj/screen/blob/NodeBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_node()

/obj/screen/blob/FactoryBlob
	icon_state = "ui_factory"
	name = "Produce Factory Blob (60)"
	desc = "Produces a resource blob for 60 points."

/obj/screen/blob/FactoryBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_factory()

/obj/screen/blob/ReadaptChemical
	icon_state = "ui_chemswap"
	name = "Readapt Chemical (40)"
	desc = "Randomly rerolls your chemical for 40 points."

/obj/screen/blob/ReadaptChemical/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.chemical_reroll()

/obj/screen/blob/RelocateCore
	icon_state = "ui_swap"
	name = "Relocate Core (80)"
	desc = "Swaps a node and your core for 80 points."

/obj/screen/blob/RelocateCore/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.relocate_core()

/datum/hud/proc/blob_hud(ui_style = 'icons/mob/screen_midnight.dmi')
	adding = list()

	var/obj/screen/using

	blobpwrdisplay = new /obj/screen()
	blobpwrdisplay.name = "blob power"
	blobpwrdisplay.icon_state = "block"
	blobpwrdisplay.screen_loc = ui_health
	blobpwrdisplay.mouse_opacity = 0
	blobpwrdisplay.layer = 20
	adding += blobpwrdisplay

	blobhealthdisplay = new /obj/screen()
	blobhealthdisplay.name = "blob health"
	blobhealthdisplay.icon_state = "block"
	blobhealthdisplay.screen_loc = ui_internal
	blobhealthdisplay.mouse_opacity = 0
	blobhealthdisplay.layer = 20
	adding += blobhealthdisplay

	using = new /obj/screen/blob/BlobHelp()
	using.screen_loc = "NORTH:-6,WEST:6"
	adding += using

	using = new /obj/screen/blob/JumpToNode()
	using.screen_loc = ui_inventory
	adding += using

	using = new /obj/screen/blob/JumpToCore()
	using.screen_loc = ui_zonesel
	adding += using

	using = new /obj/screen/blob/Blobbernaut()
	using.screen_loc = ui_belt
	adding += using

	using = new /obj/screen/blob/ResourceBlob()
	using.screen_loc = ui_back
	adding += using

	using = new /obj/screen/blob/NodeBlob()
	using.screen_loc = ui_lhand
	adding += using

	using = new /obj/screen/blob/FactoryBlob()
	using.screen_loc = ui_rhand
	adding += using

	using = new /obj/screen/blob/ReadaptChemical()
	using.screen_loc = ui_storage1
	adding += using

	using = new /obj/screen/blob/RelocateCore()
	using.screen_loc = ui_storage2
	adding += using

	mymob.client.screen = list()
	mymob.client.screen += mymob.client.void
	mymob.client.screen += adding
