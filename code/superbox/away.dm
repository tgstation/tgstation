// Event fluff items
/datum/outfit/centcom_commander/away_mission
	name = "CentCom Commander (Away Mission Kit)"

	l_hand = /obj/item/briefcase_away_mission
	backpack_contents = list(
		/obj/item/storage/wallet/random = 1,
		/obj/item/folder/away_mission = 1,
	)

/obj/item/folder/away_mission
	name = "folder - Bluespace Anomaly Investigation"
	icon_state = "folder_red"

/obj/item/folder/away_mission/Initialize()
	. = ..()
	//new /obj/item/paper/fluff/commandeer(src)
	//new /obj/item/paper/fluff/away_mission(src)
	new /obj/item/documents/nanotrasen/away_mission(src)
	new /obj/item/disk/away_mission(src)
	update_icon()

/obj/item/paper/fluff/commandeer
	name = "formal authorization (for emergencies)"

/obj/item/paper/fluff/commandeer/Initialize()
	. = ..()
	info = {"
The POSSESSOR of this DOCUMENT is hereby authorized by NANOTRASEN and CENTRAL
COMMAND to at will claim CAPTAINSHIP and in doing so COMANDEER the vessel
"[station_name()]". Failure by any EMPLOYEE to acknowledge the LEGITIMACY of
this DOCUMENT shall result in INVESTIGATION and probable TERMINATION.
"}

	for(var/stamp in list("stamp-ok", "stamp-qm", "stamp-hop", "stamp-hos", "stamp-cap"))
		stamps += "<img src=large_[stamp].png><br>"
		var/mutable_appearance/stampoverlay = mutable_appearance('icons/obj/bureaucracy.dmi', "paper_[stamp]")
		stampoverlay.pixel_x = rand(-2, 2)
		stampoverlay.pixel_y = rand(-3, 2)

		LAZYADD(stamped, stamp)
		add_overlay(stampoverlay)

/obj/item/paper/fluff/away_mission
	name = "note"
	icon_state = "scrap_bloodied"

/obj/item/paper/fluff/away_mission/Initialize()
	. = ..()
	info = {"<style>body{background:darkred;}</style>
Gateway for Fiel<font color='red'>d D.L:kjme.t O</font>uick Reference:<br>
1. <font color='red'>Clear a l</font>arge open area<font color='red'> in which 00 d#I%Uv</font><br>
2. Activate the <font color='red'>s$:0(re br*(()se to prep(_@ the</font> beacon.<br>
<font color='red'>4.</font>In<img src="\ref['icons/effects/blood.dmi']"><font color='darkred'>disk.</font><br>
S. Stan<font color='red'>d c1ear of ih</font>e deployment zone and voila!<br>
6. The gateway w<font color='red'>il. .: u;:_|. af.er a sh</font>ort charging period.
"}

/obj/item/documents/nanotrasen/away_mission
	desc = "\"Top Secret\" Nanotrasen documents, filled with complex signal analysis printouts."

/obj/item/disk/away_mission
	name = "bluespace signal disk"
	desc = "An experimental data storage device capable of encoding the signatures of distant bluespace signals."
	icon_state = "holodisk"

// Gateway deployment briefcase
/obj/item/briefcase_away_mission
	name = "secure briefcase"
	desc = "A large briefcase with a digital locking system."
	icon = 'icons/obj/storage.dmi'
	icon_state = "secure"
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 8
	hitsound = "swing_hit"
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	resistance_flags = FLAMMABLE
	max_integrity = 150
	var/obj/machinery/gateway_deploy/pad

/obj/item/briefcase_away_mission/Initialize()
	. = ..()
	pad = new(src)

/obj/item/briefcase_away_mission/Destroy()
	if (!QDELETED(pad))
		QDEL_NULL(pad)
	return ..()

/obj/item/briefcase_away_mission/attack_self(mob/user)
	if(!isturf(user.loc)) //no setting up in a locker
		return
	add_fingerprint(user)
	user.visible_message("<span class='notice'>[user] starts setting down [src]...", "You start setting up [pad]...</span>")
	if(do_after(user, 30, target = user))
		pad.forceMove(get_turf(src))
		pad.closed = FALSE
		user.transferItemToLoc(src, pad, TRUE)

/obj/machinery/gateway_deploy
	name = "bluespace briefcase emitter"
	desc = "A portable bluespace pad storing a larger permanent gateway."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "blpad-idle"
	anchored = FALSE
	use_power = FALSE
	idle_power_usage = 0
	active_power_usage = 0
	var/closed = TRUE
	var/provided_disk = FALSE
	var/provided_capsule = FALSE
	var/obj/item/briefcase_away_mission/briefcase

/obj/machinery/gateway_deploy/Initialize()
	. = ..()
	if(istype(loc, /obj/item/briefcase_away_mission))
		briefcase = loc
	else
		log_game("[src] has been spawned without a briefcase.")
		return INITIALIZE_HINT_QDEL

/obj/machinery/gateway_deploy/Destroy()
	if (!QDELETED(briefcase))
		QDEL_NULL(briefcase)
	return ..()

/obj/machinery/gateway_deploy/examine(mob/user)
	..()
	if (!provided_disk)
		to_chat(user, "Its display indicates it requires a signal disk to determine its target.")
	if (!provided_capsule)
		to_chat(user, "Its display indicates it requires a shelter capsule as a catalyst.")

/obj/machinery/gateway_deploy/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr))
		if(!briefcase || !usr.can_hold_items())
			return
		if(usr.incapacitated())
			to_chat(usr, "<span class='warning'>You can't do that right now!</span>")
			return
		usr.visible_message("<span class='notice'>[usr] starts closing [src]...</span>", "<span class='notice'>You start closing [src]...</span>")
		if(do_after(usr, 30, target = usr))
			usr.put_in_hands(briefcase)
			forceMove(briefcase)
			closed = TRUE

/obj/machinery/gateway_deploy/attack_hand(mob/user)
	if (anchored || !provided_disk || !provided_capsule)
		return

	anchored = TRUE
	icon_state = "blpad-beam"
	var/turf/T = get_turf(src)
	visible_message("<span class='danger'>[src] begins shaking violently... step back!</span>")
	spawn
		for(var/i in 1 to 20)
			sleep(1)
			pixel_x = rand(-3, 3)
			pixel_y = rand(-3, 3)
		qdel(src)

		var/datum/effect_system/smoke_spread/smoke = new()
		smoke.set_up(3, T)
		smoke.start()
		sleep(1)

		var/datum/map_template/gateway = new("_maps/templates/gateway.dmm", "Gateway")
		gateway.load(T, centered = TRUE)

/obj/machinery/gateway_deploy/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/disk/away_mission) && !provided_disk && user.transferItemToLoc(I, src))
		provided_disk = TRUE
		user.visible_message("[user] inserts [I] into [src].", "<span class='notice'>You insert [I] into [src].</span>")
		qdel(I)
	else if(istype(I, /obj/item/survivalcapsule) && !provided_capsule && user.transferItemToLoc(I, src))
		provided_capsule = TRUE
		user.visible_message("[user] inserts [I] into [src].", "<span class='notice'>You insert [I] into [src].</span>")
		qdel(I)
	else
		return ..()

