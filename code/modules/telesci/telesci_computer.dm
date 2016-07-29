<<<<<<< HEAD
/obj/machinery/computer/telescience
	name = "\improper Telepad Control Console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	circuit = /obj/item/weapon/circuitboard/computer/telesci_console
	var/sending = 1
	var/obj/machinery/telepad/telepad = null
	var/temp_msg = "Telescience control console initialized.<BR>Welcome."

	// VARIABLES //
	var/teles_left	// How many teleports left until it becomes uncalibrated
	var/datum/projectile_data/last_tele_data = null
	var/z_co = 1
	var/power_off
	var/rotation_off
	//var/angle_off
	var/last_target

	var/rotation = 0
	var/angle = 45
	var/power = 5

	// Based on the power used
	var/teleport_cooldown = 0 // every index requires a bluespace crystal
	var/list/power_options = list(5, 10, 20, 25, 30, 40, 50, 80, 100)
	var/teleporting = 0
	var/starting_crystals = 3
	var/max_crystals = 4
	var/list/crystals = list()
	var/obj/item/device/gps/inserted_gps

/obj/machinery/computer/telescience/New()
	..()
	recalibrate()

/obj/machinery/computer/telescience/Destroy()
	eject()
	if(inserted_gps)
		inserted_gps.loc = loc
		inserted_gps = null
	return ..()

/obj/machinery/computer/telescience/examine(mob/user)
	..()
	user << "There are [crystals.len ? crystals.len : "no"] bluespace crystal\s in the crystal slots."

/obj/machinery/computer/telescience/initialize()
	..()
	for(var/i = 1; i <= starting_crystals; i++)
		crystals += new /obj/item/weapon/ore/bluespace_crystal/artificial(null) // starting crystals

/obj/machinery/computer/telescience/attack_paw(mob/user)
	user << "<span class='warning'>You are too primitive to use this computer!</span>"
	return

/obj/machinery/computer/telescience/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/ore/bluespace_crystal))
		if(crystals.len >= max_crystals)
			user << "<span class='warning'>There are not enough crystal slots.</span>"
			return
		if(!user.drop_item())
			return
		crystals += W
		W.loc = null
		user.visible_message("[user] inserts [W] into \the [src]'s crystal slot.", "<span class='notice'>You insert [W] into \the [src]'s crystal slot.</span>")
		updateDialog()
	else if(istype(W, /obj/item/device/gps))
		if(!inserted_gps)
			inserted_gps = W
			user.unEquip(W)
			W.loc = src
			user.visible_message("[user] inserts [W] into \the [src]'s GPS device slot.", "<span class='notice'>You insert [W] into \the [src]'s GPS device slot.</span>")
	else if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/telepad))
			telepad = M.buffer
			M.buffer = null
			user << "<span class='caution'>You upload the data from the [W.name]'s buffer.</span>"
	else
		return ..()

/obj/machinery/computer/telescience/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/telescience/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/telescience/interact(mob/user)
	var/t
	if(!telepad)
		in_use = 0     //Yeah so if you deconstruct teleporter while its in the process of shooting it wont disable the console
		t += "<div class='statusDisplay'>No telepad located. <BR>Please add telepad data.</div><BR>"
	else
		if(inserted_gps)
			t += "<A href='?src=\ref[src];ejectGPS=1'>Eject GPS</A>"
			t += "<A href='?src=\ref[src];setMemory=1'>Set GPS memory</A>"
		else
			t += "<span class='linkOff'>Eject GPS</span>"
			t += "<span class='linkOff'>Set GPS memory</span>"
		t += "<div class='statusDisplay'>[temp_msg]</div><BR>"
		t += "<A href='?src=\ref[src];setrotation=1'>Set Bearing</A>"
		t += "<div class='statusDisplay'>[rotation]°</div>"
		t += "<A href='?src=\ref[src];setangle=1'>Set Elevation</A>"
		t += "<div class='statusDisplay'>[angle]°</div>"
		t += "<span class='linkOn'>Set Power</span>"
		t += "<div class='statusDisplay'>"

		for(var/i = 1; i <= power_options.len; i++)
			if(crystals.len + telepad.efficiency  < i)
				t += "<span class='linkOff'>[power_options[i]]</span>"
				continue
			if(power == power_options[i])
				t += "<span class='linkOn'>[power_options[i]]</span>"
				continue
			t += "<A href='?src=\ref[src];setpower=[i]'>[power_options[i]]</A>"
		t += "</div>"

		t += "<A href='?src=\ref[src];setz=1'>Set Sector</A>"
		t += "<div class='statusDisplay'>[z_co ? z_co : "NULL"]</div>"

		t += "<BR><A href='?src=\ref[src];send=1'>Send</A>"
		t += " <A href='?src=\ref[src];receive=1'>Receive</A>"
		t += "<BR><A href='?src=\ref[src];recal=1'>Recalibrate Crystals</A> <A href='?src=\ref[src];eject=1'>Eject Crystals</A>"

		// Information about the last teleport
		t += "<BR><div class='statusDisplay'>"
		if(!last_tele_data)
			t += "No teleport data found."
		else
			t += "Source Location: ([last_tele_data.src_x], [last_tele_data.src_y])<BR>"
			//t += "Distance: [round(last_tele_data.distance, 0.1)]m<BR>"
			t += "Time: [round(last_tele_data.time, 0.1)] secs<BR>"
		t += "</div>"

	var/datum/browser/popup = new(user, "telesci", name, 300, 500)
	popup.set_content(t)
	popup.open()
	return

/obj/machinery/computer/telescience/proc/sparks()
	if(telepad)
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(5, 1, get_turf(telepad))
		s.start()
	else
		return

/obj/machinery/computer/telescience/proc/telefail()
	sparks()
	visible_message("<span class='warning'>The telepad weakly fizzles.</span>")
	return

/obj/machinery/computer/telescience/proc/doteleport(mob/user)

	if(teleport_cooldown > world.time)
		temp_msg = "Telepad is recharging power.<BR>Please wait [round((teleport_cooldown - world.time) / 10)] seconds."
		return

	if(teleporting)
		temp_msg = "Telepad is in use.<BR>Please wait."
		return

	if(telepad)

		var/truePower = Clamp(power + power_off, 1, 1000)
		var/trueRotation = rotation + rotation_off
		var/trueAngle = Clamp(angle, 1, 90)

		var/datum/projectile_data/proj_data = projectile_trajectory(telepad.x, telepad.y, trueRotation, trueAngle, truePower)
		last_tele_data = proj_data

		var/trueX = Clamp(round(proj_data.dest_x, 1), 1, world.maxx)
		var/trueY = Clamp(round(proj_data.dest_y, 1), 1, world.maxy)
		var/spawn_time = round(proj_data.time) * 10

		var/turf/target = locate(trueX, trueY, z_co)
		last_target = target
		var/area/A = get_area(target)
		flick("pad-beam", telepad)

		if(spawn_time > 15) // 1.5 seconds
			playsound(telepad.loc, 'sound/weapons/flash.ogg', 25, 1)
			// Wait depending on the time the projectile took to get there
			teleporting = 1
			temp_msg = "Powering up bluespace crystals.<BR>Please wait."


		spawn(round(proj_data.time) * 10) // in seconds
			if(!telepad)
				return
			if(telepad.stat & NOPOWER)
				return
			teleporting = 0
			teleport_cooldown = world.time + (power * 2)
			teles_left -= 1

			// use a lot of power
			use_power(power * 10)

			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(5, 1, get_turf(telepad))
			s.start()

			temp_msg = "Teleport successful.<BR>"
			if(teles_left < 10)
				temp_msg += "<BR>Calibration required soon."
			else
				temp_msg += "Data printed below."

			var/sparks = get_turf(target)
			var/datum/effect_system/spark_spread/y = new /datum/effect_system/spark_spread
			y.set_up(5, 1, sparks)
			y.start()

			var/turf/source = target
			var/turf/dest = get_turf(telepad)
			var/log_msg = ""
			log_msg += ": [key_name(user)] has teleported "

			if(sending)
				source = dest
				dest = target

			flick("pad-beam", telepad)
			playsound(telepad.loc, 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff = 5)
			for(var/atom/movable/ROI in source)
				// if is anchored, don't let through
				if(ROI.anchored)
					if(isliving(ROI))
						var/mob/living/L = ROI
						if(L.buckled)
							// TP people on office chairs
							if(L.buckled.anchored)
								continue

							log_msg += "[key_name(L)] (on a chair), "
						else
							continue
					else if(!isobserver(ROI))
						continue
				if(ismob(ROI))
					var/mob/T = ROI
					log_msg += "[key_name(T)], "
				else
					log_msg += "[ROI.name]"
					if (istype(ROI, /obj/structure/closet))
						var/obj/structure/closet/C = ROI
						log_msg += " ("
						for(var/atom/movable/Q as mob|obj in C)
							if(ismob(Q))
								log_msg += "[key_name(Q)], "
							else
								log_msg += "[Q.name], "
						if (dd_hassuffix(log_msg, "("))
							log_msg += "empty)"
						else
							log_msg = dd_limittext(log_msg, length(log_msg) - 2)
							log_msg += ")"
					log_msg += ", "
				do_teleport(ROI, dest)

			if (dd_hassuffix(log_msg, ", "))
				log_msg = dd_limittext(log_msg, length(log_msg) - 2)
			else
				log_msg += "nothing"
			log_msg += " [sending ? "to" : "from"] [trueX], [trueY], [z_co] ([A ? A.name : "null area"])"
			investigate_log(log_msg, "telesci")
			updateDialog()

/obj/machinery/computer/telescience/proc/teleport(mob/user)
	if(rotation == null || angle == null || z_co == null)
		temp_msg = "ERROR!<BR>Set a angle, rotation and sector."
		return
	if(power <= 0)
		telefail()
		temp_msg = "ERROR!<BR>No power selected!"
		return
	if(angle < 1 || angle > 90)
		telefail()
		temp_msg = "ERROR!<BR>Elevation is less than 1 or greater than 90."
		return
	if(z_co == ZLEVEL_CENTCOM || z_co < 1 || z_co > ZLEVEL_SPACEMAX)
		telefail()
		temp_msg = "ERROR! Sector is outside known time and space!"
		return
	if(teles_left > 0)
		doteleport(user)
	else
		telefail()
		temp_msg = "ERROR!<BR>Calibration required."
		return
	return

/obj/machinery/computer/telescience/proc/eject()
	for(var/obj/item/I in crystals)
		I.loc = src.loc
		crystals -= I
	power = 0

/obj/machinery/computer/telescience/Topic(href, href_list)
	if(..())
		return
	if(!telepad)
		updateDialog()
		return
	if(telepad.panel_open)
		temp_msg = "Telepad undergoing physical maintenance operations."

	if(href_list["setrotation"])
		var/new_rot = input("Please input desired bearing in degrees.", name, rotation) as num
		if(..()) // Check after we input a value, as they could've moved after they entered something
			return
		rotation = Clamp(new_rot, -900, 900)
		rotation = round(rotation, 0.01)

	if(href_list["setangle"])
		var/new_angle = input("Please input desired elevation in degrees.", name, angle) as num
		if(..())
			return
		angle = Clamp(round(new_angle, 0.1), 1, 9999)

	if(href_list["setpower"])
		var/index = href_list["setpower"]
		index = text2num(index)
		if(index != null && power_options[index])
			if(crystals.len + telepad.efficiency >= index)
				power = power_options[index]

	if(href_list["setz"])
		var/new_z = input("Please input desired sector.", name, z_co) as num
		if(..())
			return
		z_co = Clamp(round(new_z), 1, 10)

	if(href_list["ejectGPS"])
		if(inserted_gps)
			inserted_gps.loc = loc
			inserted_gps = null

	if(href_list["setMemory"])
		if(last_target && inserted_gps)
			inserted_gps.locked_location = last_target
			temp_msg = "Location saved."
		else
			temp_msg = "ERROR!<BR>No data was stored."

	if(href_list["send"])
		sending = 1
		teleport(usr)

	if(href_list["receive"])
		sending = 0
		teleport(usr)

	if(href_list["recal"])
		recalibrate()
		sparks()
		temp_msg = "NOTICE:<BR>Calibration successful."

	if(href_list["eject"])
		eject()
		temp_msg = "NOTICE:<BR>Bluespace crystals ejected."

	updateDialog()

/obj/machinery/computer/telescience/proc/recalibrate()
	teles_left = rand(30, 40)
	//angle_off = rand(-25, 25)
	power_off = rand(-4, 0)
	rotation_off = rand(-10, 10)
=======
/obj/machinery/computer/telescience
	name = "telepad control console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_state = "teleport"
	circuit = "/obj/item/weapon/circuitboard/telesci_computer"
	var/sending = 1
	var/obj/machinery/telepad/telepad = null

	// VARIABLES //
	var/teles_left	// How many teleports left until it becomes uncalibrated
	var/x_off	// X offset
	var/y_off	// Y offset
	var x_player_off // x offset set by player
	var y_player_off // y offset set by player
	var/x_co = 1	// X coordinate
	var/y_co = 1	// Y coordinate
	var/z_co = 1	// Z coordinate

	use_power = 1
	idle_power_usage = 10
	active_power_usage = 300
	power_channel = EQUIP
	var/obj/item/weapon/cell/cell
	var/teleport_cell_usage=1000 // 100% of a standard cell
	processing=1

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/telescience/New()
	..()
	teles_left = rand(12,14)
	x_off = rand(-10,10)
	y_off = rand(-10,10)
	x_player_off = 0
	y_player_off = 0
	if(ticker)
		initialize()

/obj/machinery/computer/telescience/initialize()
	..()
	if(!ticker)
		cell=new/obj/item/weapon/cell(src)
		cell.charge = 0
	telepad = locate() in range(src, 7)

/obj/machinery/computer/telescience/process()
	if(!cell || (stat & (BROKEN|NOPOWER)) || !anchored)
		return
	if(cell.give(100))
		use_power(200)		//this used to use CELLRATE, but CELLRATE is fucking awful. feel free to fix this properly!
	src.updateUsrDialog()

/obj/machinery/computer/telescience/attackby(obj/item/weapon/W, mob/user)
	if(..())
		return 1

	if(stat & BROKEN)
		return

	if(istype(W, /obj/item/weapon/cell) && anchored)
		if(cell)
			to_chat(user, "<span class='warning'>There is already a cell in \the [name].</span>")
			return
		else
			if(areaMaster.power_equip == 0) // There's no APC in this area, don't try to cheat power!
				to_chat(user, "<span class='warning'>\The [name] blinks red as you try to insert the cell!</span>")
				return

			if(user.drop_item(W, src))
				cell = W
				user.visible_message("[user] inserts a cell into the [src].", "You insert a cell into the [src].")
			else
				user << "<span class='warning'>You can't let go of \the [W]!</span>"
		update_icon()

/obj/machinery/computer/telescience/update_icon()
	if(stat & BROKEN)
		icon_state = "teleportb"
	else
		if(stat & NOPOWER)
			src.icon_state = "teleport0"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER

 /**
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  *
  * @return nothing
  */
/obj/machinery/computer/telescience/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(stat & (BROKEN|NOPOWER)) return
	if(user.stat || user.restrained()) return

	// this is the data which will be sent to the ui
	var/list/cell_data=null
	if(cell)
		cell_data = list(
			"charge" = cell.charge,
			"maxcharge" = cell.maxcharge
		)
	var/list/data=list(
		"pOffsetX" = x_player_off,
		"pOffsetY" = y_player_off,
		"coordx" = x_co,
		"coordy" = y_co,
		"coordz" = z_co,
		"cell" = cell_data
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		// the ui does not exist, so we'll create a new one
		ui = new(user, src, ui_key, "telescience_console.tmpl", name, 380, 210)
		// When the UI is first opened this is the data it will use
		ui.set_initial_data(data)
		// Open the new ui window.
		ui.open()
		// Auto update every Master Controller tick.
		ui.set_auto_update(1)

/obj/machinery/computer/telescience/attack_paw(mob/user)
	to_chat(user, "You are too primitive to use this computer.")
	return

/obj/machinery/computer/telescience/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/computer/telescience/attack_hand(mob/user as mob)
	if(user.client && user.client.prefs.usenanoui)//Check if the player is using nanoUI or not.
		ui_interact(user)
		return
	else
		interact(user)

/obj/machinery/computer/telescience/interact(mob/user)
	if(stat & BROKEN)
		user.unset_machine(src)
		return


	var/out = {"
		<div class='item'>
			<div class='itemLabel'>
				Offsets:
			</div>
			<div class='itemContent'>
				<a href='?src=\ref[src];setPOffsetX=1'>X offset: [x_player_off]</a>
				<a href='?src=\ref[src];setPOffsetY=1'>Y offset: [y_player_off]</a>
			</div>
		</div>
		<div class='item'>
			<div class='itemLabel'>
				Coordinates:
			</div>
			<div class='itemContent'>
				<a href='?src=\ref[src];setx=1'>X: [x_co]</a>
				<a href='?src=\ref[src];sety=1'>Y: [y_co]</a>
				<a href='?src=\ref[src];setz=1'>Z: [z_co]</a>
			</div>
		</div>
		<div class='item'>
			<div class='itemLabel'>
				Controls:
			</div>
			<div class='itemContent'>
				<a href='?src=\ref[src];send=1' [x_co && y_co && z_co ? "" : "class='linkOff'"]>Send</a>
				<a href='?src=\ref[src];receive=1' [x_co && y_co && z_co ? "" : "class='linkOff'"]>Receive</a>
				<a href='?src=\ref[src];recal=1'>Recalibrate</a>
			</div>
		</div>
		"}
	if(!cell)
		out += {"
		<div class="notice">No power cell detected.</div>
		"}
	else
		out += {"
		<div class='statusDisplay'>
			<div class='line'>
				<div class='statusLabel'>
					[cell.charge]/[cell.maxcharge]
					<a href='?src=\ref[src];eject_cell=1'>Eject</a>
				</div>
			</div>
		</div>
		"}

	user.set_machine(src)
	var/datum/browser/browserdatum = new(user, "telescience", name, 380, 210, src)
	browserdatum.add_stylesheet("shared", 'nano/css/shared.css')
	browserdatum.set_content(out)
	browserdatum.open()

/obj/machinery/computer/telescience/proc/sparks(var/atom/target)
	if(!target)
		if(telepad && get_turf(telepad))
			target = telepad
		else
			return
	var/L = get_turf(target)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, L)
	s.start()

/obj/machinery/computer/telescience/proc/telefail()
	if(prob(95))
		sparks()
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='warning'>The telepad weakly fizzles.</span>", 2)
		return
	if(prob(5))
		// Irradiate everyone in telescience!
		for(var/obj/machinery/telepad/E in machines)
			var/L = get_turf(E)
			sparks(target = L)
			for(var/mob/living/carbon/human/M in viewers(L, null))
				M.apply_effect((rand(10, 20)), IRRADIATE, 0)
				to_chat(M, "<span class='warning'>You feel strange.</span>")
		return
	/* Lets not, for now.  - N3X
	if(prob(1))
		// AI CALL SHUTTLE I SAW RUNE, SUPER LOW CHANCE, CAN HARDLY HAPPEN
		for(var/mob/living/carbon/O in viewers(src, null))
			var/datum/game_mode/cult/temp = new
			O.show_message("<span class='warning'>The telepad flashes with a strange light, and you have a sudden surge of allegiance toward the true dark one!</span>", 2)
			O.mind.make_Cultist()
			temp.grant_runeword(O)
			sparks()
		return
	if(prob(1))
		// VIVA LA FUCKING REVOLUTION BITCHES, SUPER LOW CHANCE, CAN HARDLY HAPPEN
		for(var/mob/living/carbon/O in viewers(src, null))
			O.show_message("<span class='warning'>The telepad flashes with a strange light, and you see all kind of images flash through your mind, of murderous things Nanotrasen has done, and you decide to rebel!</span>", 2)
			O.mind.make_Rev()
			sparks()
		return
	*/
	if(prob(1))
		// The OH SHIT FUCK GOD DAMN IT LYNCH THE SCIENTISTS event.
		visible_message("<span class='warning'>The telepad changes colors rapidly, and opens a portal, and you see what your mind seems to think is the very threads that hold the pattern of the universe together, and a eerie sense of paranoia creeps into you.</span>")
		for(var/mob/living/carbon/O in viewers(src, null)) //I-IT'S A FEEEEATUUUUUUUREEEEE
			spacevine_infestation()
		sparks()
		return
	if(prob(5))
		// HOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOONK
		for(var/mob/living/carbon/M in hearers(src, null))
			M << sound('sound/items/AirHorn.ogg')
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(H.earprot())
					continue
			to_chat(M, "<font color='red' size='7'>HONK</font>")
			M.sleeping = 0
			M.stuttering += 20
			M.ear_deaf += 30
			M.Weaken(3)
			if(prob(30))
				M.Stun(10)
				M.Paralyse(4)
			else
				M.Jitter(500)
			sparks(target = M)
		return
	if(prob(1))
		// They did the mash! (They did the monster mash!) The monster mash! (It was a graveyard smash!)
		sparks()
		for(var/obj/machinery/telepad/E in machines)
			var/L = get_turf(E)
			var/blocked = list(/mob/living/simple_animal/hostile,
				/mob/living/simple_animal/hostile/alien/queen/large,
				/mob/living/simple_animal/hostile/retaliate,
				/mob/living/simple_animal/hostile/retaliate/clown,
				/mob/living/simple_animal/hostile/giant_spider/nurse)
			var/list/hostiles = typesof(/mob/living/simple_animal/hostile) - blocked
			playsound(L, 'sound/effects/phasein.ogg', 100, 1, extrarange = 3, falloff = 5)
			for(var/mob/living/carbon/human/M in viewers(L, null))
				M.flash_eyes(visual = 1)
			var/chosen = pick(hostiles)
			var/mob/living/simple_animal/hostile/H = new chosen
			H.loc = L
			return
		return
	return
var/global/list/telesci_warnings = list(/obj/machinery/power/supermatter,
										/obj/machinery/the_singularitygen,
										/obj/item/weapon/grenade,
										/obj/item/device/transfer_valve,
										/obj/item/device/fuse_bomb,
										/obj/item/device/onetankbomb,
										/obj/machinery/portable_atmospherics/canister)
/obj/machinery/computer/telescience/proc/doteleport(mob/user)
	var/trueX = x_co + x_off - x_player_off + WORLD_X_OFFSET[z_co]
	var/trueY = y_co + y_off - y_player_off + WORLD_Y_OFFSET[z_co]
	trueX = Clamp(trueX, 1, world.maxx)
	trueY = Clamp(trueY, 1, world.maxy)
	if(telepad)
		var/turf/target = locate(trueX, trueY, z_co)
		var/area/A=target.loc
		if(A && A.jammed)
			if(!telepad.amplifier || A.jammed==SUPER_JAMMED)
				src.visible_message("<span class='warning'>[bicon(src)] [src] turns on and the lights dim.  You can see a faint shape, but it loses focus and the telepad shuts off with a buzz.  Perhaps you need more signal strength?", "[bicon(src)]<span class='warning'>You hear something buzz.</span></span>")
				return
			if(prob(25))
				qdel(telepad.amplifier)
				telepad.amplifier = null
				src.visible_message("[bicon(src)]<span class='notice'>You hear something shatter.</span>","[bicon(src)]<span class='notice'>You hear something shatter.</span>")
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, telepad)
		s.start()
		flick("pad-beam", telepad)
		to_chat(user, "<span class='caution'>Teleport successful.</span>")
		var/sparks = get_turf(target)
		var/datum/effect/effect/system/spark_spread/y = new /datum/effect/effect/system/spark_spread
		y.set_up(5, 1, sparks)
		y.start()
		var/turf/source = target
		var/turf/dest = get_turf(telepad)
		if(sending)
			source = dest
			dest = target
		var/things=0
		for(var/atom/movable/ROI in source)
			if(ROI.anchored || things>=10) continue
			if(is_type_in_list(ROI,telesci_warnings))
				message_admins("[user.real_name]/([formatPlayerPanel(user,user.ckey)]) teleported a [ROI] to [formatJumpTo(dest)] from [formatJumpTo(source)]")
			log_admin("[user.real_name]/([formatPlayerPanel(user,user.ckey)]) teleported a [ROI] to [formatJumpTo(dest)] from [formatJumpTo(source)]")
			do_teleport(ROI, dest, 0)
			things++
		return
	return

/obj/machinery/computer/telescience/proc/teleport(mob/user)
	if(x_co == null || y_co == null || z_co == null)
		to_chat(user, "<span class='caution'>Error: coordinates not set.</span>")
		telefail()
		return
	if(cell && cell.charge<teleport_cell_usage)
		to_chat(user, "<span class='caution'>Error: not enough energy.</span>")
		return
	cell.use(teleport_cell_usage)
	if(teles_left > 0)
		teles_left -= 1
		doteleport(user)
	else
		telefail()
		return
	return

/obj/machinery/computer/telescience/Topic(href, href_list)
	if(href_list["close"])
		if(usr.machine == src) usr.unset_machine()
		return 1

	if(..())
		return 1

	if(href_list["setPOffsetX"])
		var/new_x = input("Please input desired X offset.", name, x_player_off) as num
		if(new_x < -10 || new_x > 10)
			to_chat(usr, "<span class='caution'>Error: Invalid X offset (-10 to 10)</span>")
		else
			x_player_off = new_x
		src.updateUsrDialog()
		return 1

	if(href_list["setPOffsetY"])
		var/new_y = input("Please input desired X offset.", name, y_player_off) as num
		if(new_y < -10 || new_y > 10)
			to_chat(usr, "<span class='caution'>Error: Invalid Y offset (-10 to 10)</span>")
		else
			y_player_off = new_y
		src.updateUsrDialog()
		return 1


	if(href_list["setx"])
		var/new_x = input("Please input desired X coordinate.", name, x_co) as num
		var/x_validate=new_x+x_off
		if(x_validate < -49 || x_validate > world.maxx+50)
			to_chat(usr, "<span class='caution'>Error: Invalid X coordinate.</span>")
		else
			x_co = new_x
		src.updateUsrDialog()
		return 1

	if(href_list["sety"])
		var/new_y = input("Please input desired Y coordinate.", name, y_co) as num
		var/y_validate=new_y+y_off
		if(y_validate < -49 || y_validate > world.maxy+50)
			to_chat(usr, "<span class='caution'>Error: Invalid Y coordinate.</span>")
		else
			y_co = new_y
		src.updateUsrDialog()
		return 1

	if(href_list["setz"])
		var/new_z = input("Please input desired Z coordinate.", name, z_co) as num
		if(new_z == map.zCentcomm || new_z < 1 || new_z > map.zLevels.len)
			to_chat(usr, "<span class='caution'>Error: Invalid Z coordinate.</span>")
		else
			z_co = new_z
		src.updateUsrDialog()
		return 1

	if(href_list["send"])
		if(cell && cell.charge>=teleport_cell_usage)
			sending = 1
			teleport(usr)
		src.updateUsrDialog()
		return 1

	if(href_list["receive"])
		if(cell && cell.charge>=teleport_cell_usage)
			sending = 0
			teleport(usr)
		src.updateUsrDialog()
		return 1

	if(href_list["eject_cell"])
		if(cell)
			usr.put_in_hands(cell)
			cell.add_fingerprint(usr)
			cell.updateicon()
			src.cell = null
			usr.visible_message("[usr] removes the cell from \the [name].", "You remove the cell from \the [name].")
			update_icon()
		src.updateUsrDialog()
		return 1

	if(href_list["recal"])
		teles_left = rand(12,14)
		x_off = rand(-10,10)
		y_off = rand(-10,10)
		sparks()
		to_chat(usr, "<span class='caution'>Calibration successful.</span>")
		src.updateUsrDialog()
		return 1
	return 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
