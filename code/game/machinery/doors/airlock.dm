#define AIRLOCK_WIRE_IDSCAN 1
#define AIRLOCK_WIRE_MAIN_POWER1 2
#define AIRLOCK_WIRE_MAIN_POWER2 3
#define AIRLOCK_WIRE_DOOR_BOLTS 4
#define AIRLOCK_WIRE_BACKUP_POWER1 5
#define AIRLOCK_WIRE_BACKUP_POWER2 6
#define AIRLOCK_WIRE_OPEN_DOOR 7
#define AIRLOCK_WIRE_AI_CONTROL 8
#define AIRLOCK_WIRE_ELECTRIFY 9
#define AIRLOCK_WIRE_CRUSH 10
#define AIRLOCK_WIRE_LIGHT 11
#define AIRLOCK_WIRE_HOLDOPEN 12
#define AIRLOCK_WIRE_FAKEBOLT1 13
#define AIRLOCK_WIRE_FAKEBOLT2 14
#define AIRLOCK_WIRE_ALERTAI 15
#define AIRLOCK_WIRE_DOOR_BOLTS_2 16
//#define AIRLOCK_WIRE_FINGERPRINT 17

/*
	New methods:
	pulse - sends a pulse into a wire for hacking purposes
	cut - cuts a wire and makes any necessary state changes
	mend - mends a wire and makes any necessary state changes
	isWireColorCut - returns 1 if that color wire is cut, or 0 if not
	isWireCut - returns 1 if that wire (e.g. AIRLOCK_WIRE_DOOR_BOLTS) is cut, or 0 if not
	canAIControl - 1 if the AI can control the airlock, 0 if not (then check canAIHack to see if it can hack in)
	canAIHack - 1 if the AI can hack into the airlock to recover control, 0 if not. Also returns 0 if the AI does not *need* to hack it.
	arePowerSystemsOn - 1 if the main or backup power are functioning, 0 if not. Does not check whether the power grid is charged or an APC has equipment on or anything like that. (Check (stat & NOPOWER) for that)
	requiresIDs - 1 if the airlock is requiring IDs, 0 if not
	isAllPowerCut - 1 if the main and backup power both have cut wires.
	regainMainPower - handles the effect of main power coming back on.
	loseMainPower - handles the effect of main power going offline. Usually (if one isn't already running) spawn a thread to count down how long it will be offline - counting down won't happen if main power was completely cut along with backup power, though, the thread will just sleep.
	loseBackupPower - handles the effect of backup power going offline.
	regainBackupPower - handles the effect of main power coming back on.
	shock - has a chance of electrocuting its target.
*/

//This generates the randomized airlock wire assignments for the game.
/proc/RandomAirlockWires()
	//to make this not randomize the wires, just set index to 1 and increment it in the flag for loop (after doing everything else).
	var/list/wires = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	airlockIndexToFlag = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	airlockIndexToWireColor = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	airlockWireColorToIndex = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	var/flagIndex = 1
	for (var/flag=1, flag<4096, flag+=flag)
		var/valid = 0
		while (!valid)
			var/colorIndex = rand(1, 12)
			if (wires[colorIndex] == 0)
				valid = 1
				wires[colorIndex] = flag
				airlockIndexToFlag[flagIndex] = flag
				airlockIndexToWireColor[flagIndex] = colorIndex
				airlockWireColorToIndex[colorIndex] = flagIndex
		flagIndex+=1
	return wires

/* Example:
Airlock wires color -> flag are { 64, 128, 256, 2, 16, 4, 8, 32, 1 }.
Airlock wires color -> index are { 7, 8, 9, 2, 5, 3, 4, 6, 1 }.
Airlock index -> flag are { 1, 2, 4, 8, 16, 32, 64, 128, 256 }.
Airlock index -> wire color are { 9, 4, 6, 7, 5, 8, 1, 2, 3 }.
*/

/obj/machinery/door/airlock
	name = "Airlock"
	icon = 'doorint.dmi'
	icon_state = "door_closed"

	var
		aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
		hackProof = 0 // if 1, this door can't be hacked by the AI
		synDoorHacked = 0 // Has it been hacked? bool 1 = yes / 0 = no
		synHacking = 0 // Is hack in process y/n?
		secondsMainPowerLost = 0 //The number of seconds until power is restored.
		secondsBackupPowerLost = 0 //The number of seconds until power is restored.
		spawnPowerRestoreRunning = 0
		welded = null
		locked = 0
		wires = 4095
		aiDisabledIdScanner = 0
		aiHacking = 0
		obj/machinery/door/airlock/closeOther = null
		closeOtherId = null
		list/signalers[12]
		lockdownbyai = 0
		doortype = 0
		justzap = 0
		safetylight = 1
		obj/item/weapon/airlock_electronics/electronics = null
		alert_probability = 3
		list/wire_index = list(
				"Orange" = 1,
				"Dark red" = 2,
				"White" = 3,
				"Yellow" = 4,
				"Red" = 5,
				"Blue" = 6,
				"Green" = 7,
				"Grey" = 8,
				"Black" = 9,
				"Pink" = 10,
				"Brown" = 11,
				"Maroon" = 12,
				"Aqua" = 13,
				"Turgoise" = 14,
				"Purple" = 15,
				"Rainbow" = 16,
				"Atomic Tangerine" = 17,
				"Neon Green" = 18,
				"Cotton Candy" = 19,
				"Plum" = 20,
				"Shamrock" = 21,
				"Indigo" = 22
			)
		wirenum = 12
	holdopen = 1
	autoclose = 1
	secondsElectrified = 0 //How many seconds remain until the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.


	command
		name = "Airlock"
		icon = 'Doorcom.dmi'
		doortype = 1
		holdopen = 0


	security
		name = "Airlock"
		icon = 'Doorsec.dmi'
		doortype = 2


	engineering
		name = "Airlock"
		icon = 'Dooreng.dmi'
		doortype = 3


	medical
		name = "Airlock"
		icon = 'Doormed.dmi'
		doortype = 4


	maintenance
		name = "Maintenance Access"
		icon = 'Doormaint.dmi'
		doortype = 5

	external
		name = "External Airlock"
		icon = 'Doorext.dmi'
		doortype = 6


	glass
		name = "Glass Airlock"
		icon = 'Doorglass.dmi'
		opacity = 0
		doortype = 7
		glass = 1


		glass_command
			name = "Maintenance Hatch"
			icon = 'Doorcomglass.dmi'
			opacity = 0
			doortype = 14
			glass = 1


		glass_engineering
			name = "Maintenance Hatch"
			icon = 'Doorengglass.dmi'
			opacity = 0
			doortype = 15
			glass = 1


		glass_security
			name = "Maintenance Hatch"
			icon = 'Doorsecglass.dmi'
			opacity = 0
			doortype = 16
			glass = 1


		glass_medical
			name = "Maintenance Hatch"
			icon = 'doormedglass.dmi'
			opacity = 0
			doortype = 17
			glass = 1

		glass_research
			name = "Research Airlock"
			icon = 'doorsciglass.dmi'
			doortype = 20

	centcom
		name = "Airlock"
		icon = 'Doorele.dmi'
		opacity = 0
		doortype = 8


	vault
		name = "Vault"
		icon = 'vault.dmi'
		opacity = 1
		doortype = 9


	glass_large
		name = "Glass Airlock"
		icon = 'Door2x1glassfull.dmi'
		opacity = 0
		doortype = 10
		glass = 1


	freezer
		name = "Freezer Airlock"
		icon = 'Doorfreezer.dmi'
		opacity = 1
		doortype = 11


	hatch
		name = "Airtight Hatch"
		icon = 'Doorhatchele.dmi'
		opacity = 1
		doortype = 12


	maintenance_hatch
		name = "Maintenance Hatch"
		icon = 'Doorhatchmaint2.dmi'
		opacity = 1
		doortype = 13


	mining
		name = "Mining Airlock"
		icon = 'Doormining.dmi'
		doortype = 18


	atmos
		name = "Atmospherics Airlock"
		icon = 'Dooratmo.dmi'
		doortype = 19


	research
		name = "Research Airlock"
		icon = 'doorsci.dmi'
		doortype = 21

	New()
		..()
		if (src.closeOtherId != null)
			spawn (5)
				for (var/obj/machinery/door/airlock/A in machines)
					if (A.closeOtherId == src.closeOtherId && A != src)
						src.closeOther = A
						break


	open()
		if (src.welded || src.locked || (!src.arePowerSystemsOn()) || (stat & NOPOWER) || src.isWireCut(AIRLOCK_WIRE_OPEN_DOOR))
			return 0
		use_power(50)
		playsound(src.loc, 'airlock.ogg', 30, 1)
		if (src.closeOther != null && istype(src.closeOther, /obj/machinery/door/airlock/) && !src.closeOther.density)
			src.closeOther.close()
		return ..()


	close()
		if (src.welded || src.locked || (!src.arePowerSystemsOn()) || (stat & NOPOWER) || src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
			return
		..()
		use_power(50)
		playsound(src.loc, 'airlock.ogg', 30, 1)
		var/obj/structure/window/killthis = (locate(/obj/structure/window) in get_turf(src))
		if(killthis)
			killthis.ex_act(2)//Smashin windows
		return


	bumpopen(mob/user as mob) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
		if (!istype(usr, /mob/living/silicon))
			if (src.isElectrified())
				if (!src.justzap)
					if(src.shock(user, 100))
						src.justzap = 1
						spawn (10)
							src.justzap = 0
						return
				else /*if (src.justzap)*/
					return
			else if(user.hallucination > 50 && prob(10) && src.operating == 0)
				user << "\red <B>You feel a powerful shock course through your body!</B>"
				user.halloss += 10
				user.stunned += 10
				return
		..(user)


	update_icon()
		if(overlays) overlays = null
		if(density)
			if(locked && safetylight)
				icon_state = "door_locked"
			else
				icon_state = "door_closed"
			if(p_open || welded)
				overlays = list()
				if(p_open)
					overlays += image(icon, "panel_open")
				if(welded)
					overlays += image(icon, "welded")
		else
			icon_state = "door_open"
		return


	animate(animation)
		switch(animation)
			if("opening")
				if(overlays) overlays = null
				if(p_open)
					icon_state = "o_door_opening" //can not use flick due to BYOND bug updating overlays right before flicking
				else
					flick("door_opening", src)
			if("closing")
				if(overlays) overlays = null
				if(p_open)
					flick("o_door_closing", src)
				else
					flick("door_closing", src)
			if("spark")
				flick("door_spark", src)
			if("deny")
				flick("door_deny", src)
		return

	requiresID()
		return !(src.isWireCut(AIRLOCK_WIRE_IDSCAN) || aiDisabledIdScanner)

	attackby(C as obj, mob/user as mob)
		//world << text("airlock attackby src [] obj [] mob []", src, C, user)
		if(istype(C, /obj/item/device/detective_scanner))
			return
		if(istype(C, /obj/item/policetaperoll))
			return
		if (!istype(usr, /mob/living/silicon))
			if (src.isElectrified())
				if(src.shock(user, 75))
					return

		src.add_fingerprint(user)
		if ((istype(C, /obj/item/weapon/weldingtool) && !( src.operating ) && src.density))
			var/obj/item/weapon/weldingtool/W = C
			if(W.remove_fuel(0,user))
				if (!src.welded)
					src.welded = 1
				else
					src.welded = null
				src.update_icon()
				return
			else
				return
		else if (istype(C, /obj/item/weapon/screwdriver))
			src.p_open = !( src.p_open )
			src.update_icon()
		else if (istype(C, /obj/item/weapon/wirecutters))
			return src.attack_hand(user)
		else if (istype(C, /obj/item/device/multitool))
			return src.attack_hand(user)
		else if (istype(C, /obj/item/device/hacktool))
			return src.attack_ai(user, C)
		else if (istype(C, /obj/item/device/assembly/signaler))
			return src.attack_hand(user)
		else if (istype(C, /obj/item/weapon/pai_cable))	// -- TLE
			var/obj/item/weapon/pai_cable/cable = C
			cable.plugin(src, user)
		else if (istype(C, /obj/item/weapon/crowbar) || istype(C, /obj/item/weapon/fireaxe) )
			var/beingcrowbarred = null
			if(istype(C, /obj/item/weapon/crowbar) )
				beingcrowbarred = 1 //derp, Agouri
			else
				beingcrowbarred = 0
			if ( ((src.density) && ( src.welded ) && !( src.operating ) && src.p_open && (!src.arePowerSystemsOn() || (stat & NOPOWER)) && !src.locked) && beingcrowbarred == 1 )
				playsound(src.loc, 'Crowbar.ogg', 100, 1)
				user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to remove electronics into the airlock assembly.")
				if(do_after(user,40))
					user << "\blue You removed the airlock electronics!"
					switch(src.doortype)
						if(0) new/obj/structure/door_assembly/door_assembly_0( src.loc )
						if(1) new/obj/structure/door_assembly/door_assembly_com( src.loc )
						if(2) new/obj/structure/door_assembly/door_assembly_sec( src.loc )
						if(3) new/obj/structure/door_assembly/door_assembly_eng( src.loc )
						if(4) new/obj/structure/door_assembly/door_assembly_med( src.loc )
						if(5) new/obj/structure/door_assembly/door_assembly_mai( src.loc )
						if(6) new/obj/structure/door_assembly/door_assembly_ext( src.loc )
						if(7) new/obj/structure/door_assembly/door_assembly_g( src.loc )
					var/obj/item/weapon/airlock_electronics/ae
					if (!electronics)
						ae = new/obj/item/weapon/airlock_electronics( src.loc )
						ae.conf_access = src.req_access
					else
						ae = electronics
						electronics = null
						ae.loc = src.loc

					del(src)
					return
			else if (src.arePowerSystemsOn() && !(stat & NOPOWER))
				user << "\blue The airlock's motors resist your efforts to pry it open."
			else if (src.locked)
				user << "\blue The airlock's bolts prevent it from being pried open."
			if ((src.density) && (!( src.welded ) && !( src.operating ) && ((!src.arePowerSystemsOn()) || (stat & NOPOWER)) && !( src.locked )))

				if(beingcrowbarred == 0) //being fireaxe'd
					var/obj/item/weapon/fireaxe/F = C
					if(F.wielded == 1)
						spawn( 0 )
							src.operating = 1
							animate("opening")

							sleep(15)

							layer = 2.7
							src.density = 0
							update_icon()

							if (!istype(src, /obj/machinery/door/airlock/glass))
								src.sd_SetOpacity(0)
							src.operating = 0
						return
					user << "\red You need to be wielding the Fire axe to do that."
					return
				else
					spawn( 0 )
						src.operating = 1
						animate("opening")

						sleep(15)

						layer = 2.7
						src.density = 0
						update_icon()

						if (!istype(src, /obj/machinery/door/airlock/glass))
							src.sd_SetOpacity(0)
						src.operating = 0
						return

			else
				if ((!src.density) && (!( src.welded ) && !( src.operating ) && !( src.locked )))
					if(beingcrowbarred == 0)
						var/obj/item/weapon/fireaxe/F = C
						if(F.wielded == 1)
							spawn( 0 )
								src.operating = 1
								animate("closing")

								layer = 3.1
								src.density = 1
								sleep(15)
								update_icon()

								if ((src.visible) && (!istype(src, /obj/machinery/door/airlock/glass)))
									src.sd_SetOpacity(1)
								src.operating = 0
						else
							user << "\red You need to be wielding the Fire axe to do that."
					else
						spawn( 0 )
							src.operating = 1
							animate("closing")
							layer = 3.1
							src.density = 1
							sleep(15)
							update_icon()

							if ((src.visible) && (!istype(src, /obj/machinery/door/airlock/glass)))
								src.sd_SetOpacity(1)
							src.operating = 0

		else
			..()
		return


	attack_paw(mob/user as mob)
		return src.attack_hand(user)


	attack_hand(mob/user as mob)
		if (!istype(usr, /mob/living/silicon))
			if (src.isElectrified())
				if(src.shock(user, 100))
					return

		if (ishuman(user) && prob(40) && src.density)
			var/mob/living/carbon/human/H = user
			if(H.getBrainLoss() >= 60)
				playsound(src.loc, 'bang.ogg', 25, 1)
				if(!istype(H.head, /obj/item/clothing/head/helmet))
					for(var/mob/M in viewers(src, null))
						M << "\red [user] headbutts the airlock."
					var/datum/organ/external/affecting = H.get_organ("head")
					affecting.take_damage(10, 0)
					H.Stun(8)
					H.Weaken(5)
					H.UpdateDamageIcon()
				else
					for(var/mob/M in viewers(src, null))
						M << "\red [user] headbutts the airlock. Good thing they're wearing a helmet."
				return

		if (src.p_open)
			user.machine = src
			var/t1 = text("<B>Access Panel</B><br>\n")

			//t1 += text("[]: ", airlockFeatureNames[airlockWireColorToIndex[9]])
			t1 += getAirlockWires()

			t1 += text("<br>\n[]<br>\n[]<br>\n[]<br>\n[]<br>\n[]", (src.locked ? "The door bolts have fallen!" : "The door bolts look up."), ((src.arePowerSystemsOn() && !(stat & NOPOWER)) ? "The test light is on." : "The test light is off!"), (src.aiControlDisabled==0 ? "The 'AI control allowed' light is on." : "The 'AI control allowed' light is off."), (src.secondsElectrified!=0 ? "The safety light is flashing!" : "The safety light is on."), (src.forcecrush==0 ? "The hydraulics control light is a solid green." : "The hydraulics control light is flashing red."))

			t1 += text("<p><a href='?src=\ref[];close=1'>Close</a></p>\n", src)

			user << browse(t1, "window=airlock")
			onclose(user, "airlock")

		else
			..(user)
		return

//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door, 8 engage engineer smasher, 9 enable bolt indicator, 10 wait for clearance
//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door, 8 disable engineer smasher, 9 disable bolt indicator, 10 autoclose
	//This has been converted to be called by either the AI or a mob with a hacktool, permitting either to directly operate the airlock
	attack_ai(mob/user as mob, obj/item/device/hacktool/C)
		if(isAI(user))
			if (!src.canAIControl())
				if (src.canAIHack())
					src.hack(user)
					return
		else if(user && !isrobot(user))
			if(!C)
				return
			if(C.in_use)
				user << "We are already hacking another airlock."
				return
			if (!src.canSynControl() && src.canSynHack(C))
				src.synhack(user, C)
				return
			if(!src.canSynHack(C) && !synDoorHacked)
				user << "The power is cut or something, I can't hack it!"
				return
			if(istype(C, /obj/item/device/hacktool/engineer))
				return
		else if(!isrobot(user))
			world << "ERROR: Mob was null when calling attack_ai on [src.name] at [src.x],[src.y],[src.z]"
			return


		//Separate interface for the AI.
		user.machine = src
		var/t1 = text("<B>Airlock Control</B><br>\n")
		if (src.secondsMainPowerLost > 0)
			if ((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
				t1 += text("Main power is offline for [] seconds.<br>\n", src.secondsMainPowerLost)
			else
				t1 += text("Main power is offline indefinitely.<br>\n")
		else
			t1 += text("Main power is online.")

		if (src.secondsBackupPowerLost > 0)
			if ((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
				t1 += text("Backup power is offline for [] seconds.<br>\n", src.secondsBackupPowerLost)
			else
				t1 += text("Backup power is offline indefinitely.<br>\n")
		else if (src.secondsMainPowerLost > 0)
			t1 += text("Backup power is online.")
		else
			t1 += text("Backup power is offline, but will turn on if main power fails.")
		t1 += "<br>\n"

		if (src.isWireCut(AIRLOCK_WIRE_IDSCAN))
			t1 += text("IdScan wire is cut.<br>\n")
		else if (src.aiDisabledIdScanner)
			t1 += text("IdScan disabled. <A href='?src=\ref[];aiEnable=1'>Enable?</a><br>\n", src)
		else
			t1 += text("IdScan enabled. <A href='?src=\ref[];aiDisable=1'>Disable?</a><br>\n", src)

		if (src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1))
			t1 += text("Main Power Input wire is cut.<br>\n")
		if (src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2))
			t1 += text("Main Power Output wire is cut.<br>\n")
		if (src.secondsMainPowerLost == 0)
			t1 += text("<A href='?src=\ref[];aiDisable=2'>Temporarily disrupt main power?</a>.<br>\n", src)
		if (src.secondsBackupPowerLost == 0)
			t1 += text("<A href='?src=\ref[];aiDisable=3'>Temporarily disrupt backup power?</a>.<br>\n", src)

		if (src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1))
			t1 += text("Backup Power Input wire is cut.<br>\n")
		if (src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2))
			t1 += text("Backup Power Output wire is cut.<br>\n")

		if (src.isWireCut(AIRLOCK_WIRE_CRUSH))
			t1 += text("Airlock extra force wire is cut.<br>\n")
		else if(!src.forcecrush)
			t1 += text("Airlock extra force disabled <A href='?src=\ref[src];aiEnable=8'>Enable it?</a><br>\n")
		else
			t1 += text("Airlock extra force enabled <A href='?src=\ref[src];aiDisable=8'>Disable it?</a><br>\n")

		if (src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
			t1 += text("Door bolt drop wire is cut.<br>\n")
		else if (!src.locked)
			t1 += text("Door bolts are up. <A href='?src=\ref[];aiDisable=4'>Drop them?</a><br>\n", src)
		else
			t1 += text("Door bolts are down.")
			if (src.arePowerSystemsOn())
				t1 += text(" <A href='?src=\ref[];aiEnable=4'>Raise?</a><br>\n", src)
			else
				t1 += text(" Cannot raise door bolts due to power failure.<br>\n")

		if (src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
			t1 += text("Electrification wire is cut.<br>\n")
		if (src.secondsElectrified==-1)
			t1 += text("Door is electrified indefinitely. <A href='?src=\ref[];aiDisable=5'>Un-electrify it?</a><br>\n", src)
		else if (src.secondsElectrified>0)
			t1 += text("Door is electrified temporarily ([] seconds). <A href='?src=\ref[];aiDisable=5'>Un-electrify it?</a><br>\n", src.secondsElectrified, src)
		else
			t1 += text("Door is not electrified. <A href='?src=\ref[];aiEnable=5'>Electrify it for 30 seconds?</a> Or, <A href='?src=\ref[];aiEnable=6'>Electrify it indefinitely until someone cancels the electrification?</a><br>\n", src, src)

		if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
			t1 += "Bolt indication light wire is cut.<br>\n"
		else if(!src.safetylight)
			t1 += text("Bolt Indication light is  disabled <A href='?src=\ref[src];aiEnable=9'>Enable it?</a><br>\n")
		else
			t1 += text("Bolt Indication light is  enabled <A href='?src=\ref[src];aiDisable=9'>Disable it?</a><br>\n")

		if(src.isWireCut(AIRLOCK_WIRE_HOLDOPEN))
			t1 += "Behavior Control light wire is cut.<br>\n"
		else if(!src.holdopen)
			t1 += text("Door behavior is set to: Automatically close <A href='?src=\ref[src];aiEnable=10'>Toggle?</a><br>\n")
		else
			t1 += text("Door behavior is set to: Wait for clearance to close <A href='?src=\ref[src];aiDisable=10'>Toggle?</a><br>\n")

		if (src.welded)
			t1 += text("Door appears to have been welded shut.<br>\n")
		else if (!src.locked)
			if (src.density)
				t1 += text("<A href='?src=\ref[];aiEnable=7'>Open door</a><br>\n", src)
			else
				t1 += text("<A href='?src=\ref[];aiDisable=7'>Close door</a><br>\n", src)

		t1 += text("<p><a href='?src=\ref[];close=1'>Close</a></p>\n", src)
		user << browse(t1, "window=airlock")
		onclose(user, "airlock")


	proc
		hack(mob/user as mob)
			if (src.aiHacking==0)
				src.aiHacking=1
				spawn(20)
					//TODO: Make this take a minute
					user << "Airlock AI control has been blocked. Beginning fault-detection."
					sleep(50)
					if (src.canAIControl())
						user << "Alert cancelled. Airlock control has been restored without our assistance."
						src.aiHacking=0
						return
					else if (!src.canAIHack())
						user << "We've lost our connection! Unable to hack airlock."
						src.aiHacking=0
						return
					user << "Fault confirmed: airlock control wire disabled or cut."
					sleep(20)
					user << "Attempting to hack into airlock. This may take some time."
					sleep(200)
					if (src.canAIControl())
						user << "Alert cancelled. Airlock control has been restored without our assistance."
						src.aiHacking=0
						return
					else if (!src.canAIHack())
						user << "We've lost our connection! Unable to hack airlock."
						src.aiHacking=0
						return
					user << "Upload access confirmed. Loading control program into airlock software."
					sleep(170)
					if (src.canAIControl())
						user << "Alert cancelled. Airlock control has been restored without our assistance."
						src.aiHacking=0
						return
					else if (!src.canAIHack())
						user << "We've lost our connection! Unable to hack airlock."
						src.aiHacking=0
						return
					user << "Transfer complete. Forcing airlock to execute program."
					sleep(50)
					//disable blocked control
					src.aiControlDisabled = 2
					user << "Receiving control information from airlock."
					sleep(10)
					//bring up airlock dialog
					src.aiHacking = 0
					src.attack_ai(user)


		synhack(mob/user as mob, obj/item/device/hacktool/I)
			if (src.synHacking==0)
				var/multiplier = 1.5
				if(istype(I, /obj/item/device/hacktool/engineer))
					if(!src.locked)
						user << "The door bolts are already up!"
						return
					multiplier -= 0.5
				src.synHacking=1
				I.in_use = 1
				user << "You begin hacking..."
				spawn(20*multiplier)
					user << "Jacking in. Stay close to the airlock or you'll rip the cables out and we'll have to start over."
					sleep(25*multiplier)
					if (src.canSynControl() && !istype(I, /obj/item/device/hacktool/engineer))
						user << "Hack cancelled, control already possible."
						src.synHacking=0
						I.in_use = 0
						return
					else if (!src.canSynHack(I))
						user << "\red Connection lost. Stand still and stay near the airlock!"
						src.synHacking=0
						I.in_use = 0
						return
					user << "Connection established."
					sleep(10*multiplier)
					user << "Attempting to hack into airlock. This may take some time."
					sleep(50*multiplier)

					// Alerting the AIs
					var/list/cameras = list()
					for (var/obj/machinery/camera/C in src.loc.loc.contents) // getting all cameras in the area
						cameras += C
					var/alertoption = (prob(alert_probability) || istype(I, /obj/item/device/hacktool/engineer)) // Chance of warning AI, based on doortype's probability
					if(alertoption)
						if(prob(15))       //15% chance of sending the AI all the details (camera, area, warning)
							alertoption = 3
						else if (prob(18)) //18% chance of sending the AI just the area
							alertoption = 2
						for (var/mob/living/silicon/ai/aiPlayer in world)
							if (aiPlayer.stat != 2)
								switch(alertoption)
									if(3) aiPlayer.triggerUnmarkedAlarm("AirlockHacking", src.loc.loc, cameras)
									if(2) aiPlayer.triggerUnmarkedAlarm("AirlockHacking", src.loc.loc)
									if(1) aiPlayer.triggerUnmarkedAlarm("AirlockHacking")
						for (var/mob/living/silicon/robot/robotPlayer in world)
							if (robotPlayer.stat != 2)
								switch(alertoption)
									if(2,3) robotPlayer.triggerUnmarkedAlarm("AirlockHacking", src.loc.loc)
									if(1)   robotPlayer.triggerUnmarkedAlarm("AirlockHacking")
						// ...And done

					if (!src.canSynHack(I))
						user << "\red Hack aborted: landline connection lost. Stay closer to the airlock."
						src.synHacking=0
						I.in_use = 0
						return
					else if (src.canSynControl() && !istype(I, /obj/item/device/hacktool/engineer))
						user << "Local override already in place, hack aborted."
						src.synHacking=0
						I.in_use = 0
						return
					user << "Upload access confirmed. Loading control program into airlock software."
					sleep(35*multiplier)
					if (!src.canSynHack(I))
						user << "\red Hack aborted: cable connection lost. Do not move away from the airlock."
						src.synHacking=0
						I.in_use = 0
						return
					else if (src.canSynControl() && !istype(I, /obj/item/device/hacktool/engineer))
						user << "Upload access aborted, local override already in place."
						src.synHacking=0
						I.in_use = 0
						return
					user << "Transfer complete. Forcing airlock to execute program."
					sleep(25*multiplier)
					//disable blocked control
					if(istype(I, /obj/item/device/hacktool/engineer))
						user << "Raising door bolts..."
						src.synHacking = 0
						src.locked = 0
						I.in_use = 0
						update_icon()
						return
					src.synDoorHacked = 1
					user << "Bingo! We're in. Airlock control panel coming right up."
					sleep(5)
					//bring up airlock dialog
					src.synHacking = 0
					I.in_use = 0
					src.attack_ai(user, I)


		canAIControl()
			return ((src.aiControlDisabled!=1) && (!src.isAllPowerCut()));


		canAIHack()
			return ((src.aiControlDisabled==1) && (!hackProof) && (!src.isAllPowerCut()));


		canSynControl()
			return (src.synDoorHacked && (!src.isAllPowerCut()));


		canSynHack(obj/item/device/hacktool/H)
			return (in_range(src, usr) && get_dist(src, H) <= 1 && src.synDoorHacked==0 && !src.isAllPowerCut());



/*
About the new airlock wires panel:
*	An airlock wire dialog can be accessed by the normal way or by using wirecutters or a multitool on the door while the wire-panel is open. This would show the following wires, which you can either wirecut/mend or send a multitool pulse through. There are 9 wires.
*		one wire from the ID scanner. Sending a pulse through this flashes the red light on the door (if the door has power). If you cut this wire, the door will stop recognizing valid IDs. (If the door has 0000 access, it still opens and closes, though)
*		two wires for power. Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter). Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be \red open, but bolts-raising will not work. Cutting these wires may electrocute the user.
*		one wire for door bolts. Sending a pulse through this drops door bolts (whether the door is powered or not) or raises them (if it is). Cutting this wire also drops the door bolts, and mending it does not raise them. If the wire is cut, trying to raise the door bolts will not work.
*		two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter). Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
*		one wire for opening the door. Sending a pulse through this while the door has power makes it open the door if no access is required.
*		one wire for AI control. Sending a pulse through this blocks AI control for a second or so (which is enough to see the AI control light on the panel dialog go off and back on again). Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
*		one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds. Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted. (Currently it is also STAYING electrified until someone mends the wire)
*/

		pulse(var/wireColor)
			//var/wireFlag = airlockWireColorToFlag[wireColor] //not used in this function
			var/wireIndex = airlockWireColorToIndex[wireColor]
			switch(wireIndex)
				if(AIRLOCK_WIRE_IDSCAN)
					//Sending a pulse through this flashes the red light on the door (if the door has power).
					if ((src.arePowerSystemsOn()) && (!(stat & NOPOWER)))
						animate("deny")
				if (AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
					//Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter).
					src.loseMainPower()
				if (AIRLOCK_WIRE_DOOR_BOLTS)
					//one wire for door bolts. Sending a pulse through this drops door bolts if they're not down (whether power's on or not),
					//raises them if they are down (only if power's on)
					if (!src.locked)
						src.locked = 1
						src.updateUsrDialog()
					else
						if(src.arePowerSystemsOn()) //only can raise bolts if power's on
							src.locked = 0
							usr << "You hear a click from inside the door."
							src.updateUsrDialog()
					update_icon()

				if (AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
					//two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter).
					src.loseBackupPower()
				if (AIRLOCK_WIRE_AI_CONTROL)
					if (src.aiControlDisabled == 0)
						src.aiControlDisabled = 1
					else if (src.aiControlDisabled == -1)
						src.aiControlDisabled = 2
					src.updateDialog()
					spawn(10)
						if (src.aiControlDisabled == 1)
							src.aiControlDisabled = 0
						else if (src.aiControlDisabled == 2)
							src.aiControlDisabled = -1
						src.updateDialog()
				if (AIRLOCK_WIRE_ELECTRIFY)
					//one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds.
					if (src.secondsElectrified==0)
						src.secondsElectrified = 30
						spawn(10)
							//TODO: Move this into process() and make pulsing reset secondsElectrified to 30
							while (src.secondsElectrified>0)
								src.secondsElectrified-=1
								if (src.secondsElectrified<0)
									src.secondsElectrified = 0
		//						src.updateUsrDialog()  //Commented this line out to keep the airlock from clusterfucking you with electricity. --NeoFite
								sleep(10)
				if(AIRLOCK_WIRE_OPEN_DOOR)
					//tries to open the door without ID
					//will succeed only if the ID wire is cut or the door requires no access
					if (!src.requiresID() || src.check_access(null))
						if (src.density)
							open()
						else
							close()
				if(AIRLOCK_WIRE_CRUSH)
					src.forcecrush = !src.forcecrush
				if(AIRLOCK_WIRE_LIGHT)
					src.safetylight = !src.safetylight
				if(AIRLOCK_WIRE_HOLDOPEN)
					src.holdopen = !src.holdopen

		cut(var/wireColor)
			var/wireFlag = airlockWireColorToFlag[wireColor]
			var/wireIndex = airlockWireColorToIndex[wireColor]
			wires &= ~wireFlag
			switch(wireIndex)
				if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
					//Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be crowbarred open, but bolts-raising will not work. Cutting these wires may electocute the user.
					src.loseMainPower()
					src.shock(usr, 50)
					src.updateUsrDialog()
				if (AIRLOCK_WIRE_DOOR_BOLTS)
					//Cutting this wire also drops the door bolts, and mending it does not raise them. (This is what happens now, except there are a lot more wires going to door bolts at present)
					if (src.locked!=1)
						src.locked = 1
					update_icon()
					src.updateUsrDialog()
				if (AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
					//Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
					src.loseBackupPower()
					src.shock(usr, 50)
					src.updateUsrDialog()
				if (AIRLOCK_WIRE_AI_CONTROL)
					//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
					//aiControlDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
					if (src.aiControlDisabled == 0)
						src.aiControlDisabled = 1
					else if (src.aiControlDisabled == -1)
						src.aiControlDisabled = 2
					src.updateUsrDialog()
				if (AIRLOCK_WIRE_ELECTRIFY)
					//Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted.
					if (src.secondsElectrified != -1)
						src.secondsElectrified = -1

		mend(var/wireColor)
			var/wireFlag = airlockWireColorToFlag[wireColor]
			var/wireIndex = airlockWireColorToIndex[wireColor] //not used in this function
			wires |= wireFlag
			switch(wireIndex)
				if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
					if ((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
						src.regainMainPower()
						src.shock(usr, 50)
						src.updateUsrDialog()
				if (AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
					if ((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
						src.regainBackupPower()
						src.shock(usr, 50)
						src.updateUsrDialog()
				if (AIRLOCK_WIRE_AI_CONTROL)
					//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
					//aiControlDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
					if (src.aiControlDisabled == 1)
						src.aiControlDisabled = 0
					else if (src.aiControlDisabled == 2)
						src.aiControlDisabled = -1
					src.updateUsrDialog()
				if (AIRLOCK_WIRE_ELECTRIFY)
					if (src.secondsElectrified == -1)
						src.secondsElectrified = 0

		getAirlockWires()
			var/t1
			var/iterator = 0
			for(var/wiredesc in wire_index)
				if(iterator == wirenum)
					break
				var/is_uncut = src.wires & airlockWireColorToFlag[wire_index[wiredesc]]
				t1 += "[wiredesc] wire: "
				if(!is_uncut)
					t1 += "<a href='?src=\ref[src];wires=[wire_index[wiredesc]]'>Mend</a>"
				else
					t1 += "<a href='?src=\ref[src];wires=[wire_index[wiredesc]]'>Cut</a> "
					t1 += "<a href='?src=\ref[src];pulse=[wire_index[wiredesc]]'>Pulse</a> "
					if(src.signalers[wire_index[wiredesc]])
						t1 += "<a href='?src=\ref[src];remove-signaler=[wire_index[wiredesc]]'>Detach signaler</a>"
					else
						t1 += "<a href='?src=\ref[src];signaler=[wire_index[wiredesc]]'>Attach signaler</a>"
				t1 += "<br>"
				iterator++
			return t1

		isElectrified()
			return (src.secondsElectrified != 0);

		isWireColorCut(var/wireColor)
			var/wireFlag = airlockWireColorToFlag[wireColor]
			return ((src.wires & wireFlag) == 0)

		isWireCut(var/wireIndex)
			var/wireFlag = airlockIndexToFlag[wireIndex]
			return ((src.wires & wireFlag) == 0)

		arePowerSystemsOn()
			return (src.secondsMainPowerLost==0 || src.secondsBackupPowerLost==0)

		isAllPowerCut()
			return ((src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1) || src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)) && (src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1) || src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))

		regainMainPower()
			if (src.secondsMainPowerLost > 0)
				src.secondsMainPowerLost = 0

		loseMainPower()
			if (src.secondsMainPowerLost <= 0)
				src.secondsMainPowerLost = 60
				if (src.secondsBackupPowerLost < 10)
					src.secondsBackupPowerLost = 10
			if (!src.spawnPowerRestoreRunning)
				src.spawnPowerRestoreRunning = 1
				spawn(0)
					var/cont = 1
					while (cont)
						sleep(10)
						cont = 0
						if (src.secondsMainPowerLost>0)
							if ((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
								src.secondsMainPowerLost -= 1
								src.updateDialog()
							cont = 1

						if (src.secondsBackupPowerLost>0)
							if ((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
								src.secondsBackupPowerLost -= 1
								src.updateDialog()
							cont = 1
					src.spawnPowerRestoreRunning = 0
					src.updateDialog()

		loseBackupPower()
			if (src.secondsBackupPowerLost < 60)
				src.secondsBackupPowerLost = 60

		regainBackupPower()
			if (src.secondsBackupPowerLost > 0)
				src.secondsBackupPowerLost = 0

		// shock user with probability prb (if all connections & power are working)
		// returns 1 if shocked, 0 otherwise
		// The preceding comment was borrowed from the grille's shock script
		shock(mob/user, prb)
			if((stat & (NOPOWER)) || !src.arePowerSystemsOn())		// unpowered, no shock
				return 0
			if(!prob(prb))
				return 0 //you lucked out, no shock for you
			if(istype(usr.equipped(),/obj/item/weapon/shard))
				return 0
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, src)
			s.start() //sparks always.
			if (electrocute_mob(user, get_area(src), src))
				return 1
			else
				return 0

		prison_open()
			src.locked = 0
			src.open()
			src.locked = 1
			return



/obj/machinery/door/airlock/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained() )
		return
	if (href_list["close"])
		usr << browse(null, "window=airlock")
		if (usr.machine==src)
			usr.machine = null
			return
	if(in_range(src, usr) && istype(src.loc, /turf) && p_open)
		usr.machine = src
		if (href_list["wires"])
			var/t1 = text2num(href_list["wires"])
			if (!(istype(usr.equipped(), /obj/item/weapon/wirecutters) || istype(usr.equipped(),/obj/item/weapon/shard)))
				usr << "You need wirecutters!"
				return
			if (src.isWireColorCut(t1) && istype(usr.equipped(), /obj/item/weapon/wirecutters))
				src.mend(t1)
			else
				src.cut(t1)
		else if (href_list["pulse"])
			var/t1 = text2num(href_list["pulse"])
			if (!istype(usr.equipped(), /obj/item/device/multitool))
				usr << "You need a multitool!"
				return
			if (src.isWireColorCut(t1))
				usr << "You can't pulse a cut wire."
				return
			else
				src.pulse(t1)
		else if(href_list["signaler"])
			var/wirenum = text2num(href_list["signaler"])
			if(!istype(usr.equipped(), /obj/item/device/assembly/signaler))
				usr << "You need a signaller!"
				return
			if(src.isWireColorCut(wirenum))
				usr << "You can't attach a signaller to a cut wire."
				return
			var/obj/item/device/assembly/signaler/R = usr.equipped()
			if(R.secured)
				usr << "This radio can't be attached!"
				return
			var/mob/M = usr
			M.drop_item()
			R.loc = src
			R.airlock_wire = wirenum
			src.signalers[wirenum] = R
		else if(href_list["remove-signaler"])
			var/wirenum = text2num(href_list["remove-signaler"])
			if(!(src.signalers[wirenum]))
				usr << "There's no signaller attached to that wire!"
				return
			var/obj/item/device/assembly/signaler/R = src.signalers[wirenum]
			R.loc = usr.loc
			R.airlock_wire = null
			src.signalers[wirenum] = null

		src.update_icon()
		add_fingerprint(usr)
		src.updateUsrDialog()
	else	//AI or Syndicate using hacktool
		if (!src.canAIControl() || (istype(usr.equipped(), /obj/item/device/hacktool/) && (!src.canSynControl() || !in_range(src, usr))))
			usr << "Airlock control connection lost!"
			return
		//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door
		//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door
		if (href_list["aiDisable"])
			var/code = text2num(href_list["aiDisable"])
			switch (code)
				if (1)
					//disable idscan
					if (src.isWireCut(AIRLOCK_WIRE_IDSCAN))
						usr << "The IdScan wire has been cut - So, you can't disable it, but it is already disabled anyways."
					else if (src.aiDisabledIdScanner)
						usr << "You've already disabled the IdScan feature."
					else
						src.aiDisabledIdScanner = 1
				if (2)
					//disrupt main power
					if (src.secondsMainPowerLost == 0)
						src.loseMainPower()
					else
						usr << "Main power is already offline."
				if (3)
					//disrupt backup power
					if (src.secondsBackupPowerLost == 0)
						src.loseBackupPower()
					else
						usr << "Backup power is already offline."
				if (4)
					//drop door bolts
					if (src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
						usr << "You can't drop the door bolts - The door bolt dropping wire has been cut."
					else if (src.locked!=1)
						src.locked = 1
						update_icon()
				if (5)
					//un-electrify door
					if (src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						usr << text("Can't un-electrify the airlock - The electrification wire is cut.<br>\n")
					else if (src.secondsElectrified==-1)
						src.secondsElectrified = 0
					else if (src.secondsElectrified>0)
						src.secondsElectrified = 0
				if (7)
					//close door
					if (src.welded)
						usr << text("The airlock has been welded shut!<br>\n")
					else if (src.locked)
						usr << text("The door bolts are down!<br>\n")
					else if (!src.density)
						close()
					else
						usr << text("The airlock is already closed.<br>\n")
				if (8)
					if(!src.forcecrush)
						usr << text("Door extra force not enabled!<br>\n")
					else
						src.forcecrush = 0
				if (9)
					if(!src.safetylight)
						usr << text("Bolt indication light not enabled!<br>\n")
					else
						src.safetylight = 0
				if (10)
					if(!src.holdopen)
						usr << text("Door Behavior already set to: Wait for clearance to close<br>\n")
					else
						src.holdopen = 0

		else if (href_list["aiEnable"])
			var/code = text2num(href_list["aiEnable"])
			switch (code)
				if (1)
					//enable idscan
					if (src.isWireCut(AIRLOCK_WIRE_IDSCAN))
						usr << "You can't enable IdScan - The IdScan wire has been cut."
					else if (src.aiDisabledIdScanner)
						src.aiDisabledIdScanner = 0
					else
						usr << "The IdScan feature is not disabled."
				if (4)
					//raise door bolts
					if (src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
						usr << text("The door bolt drop wire is cut - you can't raise the door bolts.<br>\n")
					else if (!src.locked)
						usr << text("The door bolts are already up.<br>\n")
					else
						if (src.arePowerSystemsOn())
							src.locked = 0
							update_icon()
						else
							usr << text("Cannot raise door bolts due to power failure.<br>\n")

				if (5)
					//electrify door for 30 seconds
					if (src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						usr << text("The electrification wire has been cut.<br>\n")
					else if (src.secondsElectrified==-1)
						usr << text("The door is already indefinitely electrified. You'd have to un-electrify it before you can re-electrify it with a non-forever duration.<br>\n")
					else if (src.secondsElectrified!=0)
						usr << text("The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n")
					else
						src.secondsElectrified = 30
						spawn(10)
							while (src.secondsElectrified>0)
								src.secondsElectrified-=1
								if (src.secondsElectrified<0)
									src.secondsElectrified = 0
								src.updateUsrDialog()
								sleep(10)
				if (6)
					//electrify door indefinitely
					if (src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						usr << text("The electrification wire has been cut.<br>\n")
					else if (src.secondsElectrified==-1)
						usr << text("The door is already indefinitely electrified.<br>\n")
					else if (src.secondsElectrified!=0)
						usr << text("The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n")
					else
						src.secondsElectrified = -1
				if (7)
					//open door
					if (src.welded)
						usr << text("The airlock has been welded shut!<br>\n")
					else if (src.locked)
						usr << text("The door bolts are down!<br>\n")
					else if (src.density)
						open()
	//					close()
					else
						usr << text("The airlock is already opened.<br>\n")
				if (8)
					if(src.forcecrush)
						usr << text("Door extra force already enabled!<br>\n")
					else
						src.forcecrush = 1
				if (9)
					if(src.safetylight)
						usr << text("Bolt indication light already enabled!<br>\n")
					else
						src.safetylight = 1
				if (10)
					if(src.holdopen)
						usr << text("Door Behavior already set to: Automatically close<br>\n")
					else
						src.holdopen = 1

		src.update_icon()
		src.updateUsrDialog()
		if((istype(usr.equipped(), /obj/item/device/hacktool)))
			return attack_ai(usr, usr.equipped())
		else if(issilicon(usr))
			return attack_ai(usr)
	return




/obj/machinery/door/airlock/secure
	name = "Secure Airlock"
	desc = "Good lord, at least they left out the overcomplicated death traps.  Looks to be a layer of armor plate you might be able to remove with a wrench."
	icon = 'Doorhatchele.dmi'

	wires = 65535
	wirenum = 16
	alert_probability = 20
	holdopen = 0
	signalers = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	var
		list/WireColorToFlag = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		list/IndexToFlag = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		list/IndexToWireColor = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		list/WireColorToIndex = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		is_detached = 0
		removal_step = 0



	New()
		..()
		//to make this not randomize the wires, just set index to 1 and increment it in the flag for loop (after doing everything else).
		var/flagIndex = 1
		for (var/flag=1, flag<65536, flag+=flag)
			var/valid = 0
			while (!valid)
				var/colorIndex = rand(1, 16)
				if (WireColorToFlag[colorIndex] == 0)
					valid = 1
					WireColorToFlag[colorIndex] = flag
					IndexToFlag[flagIndex] = flag
					IndexToWireColor[flagIndex] = colorIndex
					WireColorToIndex[colorIndex] = flagIndex
			flagIndex+=1
		return


	isWireColorCut(var/wireColor)
		var/wireFlag = WireColorToFlag[wireColor]
		return ((src.wires & wireFlag) == 0)

	isWireCut(var/wireIndex)
		var/wireFlag = IndexToFlag[wireIndex]
		return ((src.wires & wireFlag) == 0)

	pulse(var/wireColor)
		var/wireIndex = WireColorToIndex[wireColor]
		switch(wireIndex)
			if(AIRLOCK_WIRE_IDSCAN)
				//Sending a pulse through this flashes the red light on the door (if the door has power).
				if ((src.arePowerSystemsOn()) && (!(stat & NOPOWER)))
					animate("deny")
			if (AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
				//Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter).
				src.loseMainPower()
			if (AIRLOCK_WIRE_DOOR_BOLTS, AIRLOCK_WIRE_DOOR_BOLTS_2)
				//one wire for door bolts. Sending a pulse through this drops door bolts if they're not down (whether power's on or not),
				//raises them if they are down (only if power's on)
				if (!src.locked)
					src.locked = 1
					src.updateUsrDialog()
				else
					if(src.arePowerSystemsOn()) //only can raise bolts if power's on
						src.locked = 0
						usr << "You hear a click from inside the door."
						src.updateUsrDialog()
				update_icon()

			if (AIRLOCK_WIRE_FAKEBOLT1, AIRLOCK_WIRE_FAKEBOLT2)
				//one wire for door bolts. Sending a pulse through this drops door bolts if they're not down (whether power's on or not),
				//raises them if they are down (only if power's on)
				if (!src.locked)
					src.locked = 1
					src.updateUsrDialog()
				update_icon()

			if (AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
				//two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter).
				src.loseBackupPower()
			if (AIRLOCK_WIRE_AI_CONTROL)
				if (src.aiControlDisabled == 0)
					src.aiControlDisabled = 1
				else if (src.aiControlDisabled == -1)
					src.aiControlDisabled = 2
				src.updateDialog()
				spawn(10)
					if (src.aiControlDisabled == 1)
						src.aiControlDisabled = 0
					else if (src.aiControlDisabled == 2)
						src.aiControlDisabled = -1
					src.updateDialog()
			if (AIRLOCK_WIRE_ELECTRIFY)
				//one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds.
				if (src.secondsElectrified==0)
					src.secondsElectrified = 30
					spawn(10)
						//TODO: Move this into process() and make pulsing reset secondsElectrified to 30
						while (src.secondsElectrified>0)
							src.secondsElectrified-=1
							if (src.secondsElectrified<0)
								src.secondsElectrified = 0
	//						src.updateUsrDialog()  //Commented this line out to keep the airlock from clusterfucking you with electricity. --NeoFite
							sleep(10)
			if(AIRLOCK_WIRE_OPEN_DOOR)
				//tries to open the door without ID
				//will succeed only if the ID wire is cut or the door requires no access
				if (!src.requiresID() || src.check_access(null))
					if (src.density)
						open()
					else
						close()
			if(AIRLOCK_WIRE_CRUSH)
				src.forcecrush = !src.forcecrush
			if(AIRLOCK_WIRE_LIGHT)
				src.safetylight = !src.safetylight
			if(AIRLOCK_WIRE_HOLDOPEN)
				src.holdopen = !src.holdopen
			if(AIRLOCK_WIRE_ALERTAI)
				if(prob(alert_probability))
					for (var/mob/living/silicon/ai/aiPlayer in world)
						if (aiPlayer.stat != 2)
							aiPlayer.triggerUnmarkedAlarm("AirlockHacking", src.loc.loc)
					for (var/mob/living/silicon/robot/robotPlayer in world)
						if (robotPlayer.stat != 2)
							robotPlayer.triggerUnmarkedAlarm("AirlockHacking", src.loc.loc)

	cut(var/wireColor)
		var/wireFlag = WireColorToFlag[wireColor]
		var/wireIndex = WireColorToIndex[wireColor]
		wires &= ~wireFlag
		switch(wireIndex)
			if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
				//Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be crowbarred open, but bolts-raising will not work. Cutting these wires may electocute the user.
				src.loseMainPower()
				src.shock(usr, 50)
				src.updateUsrDialog()
			if (AIRLOCK_WIRE_DOOR_BOLTS, AIRLOCK_WIRE_DOOR_BOLTS_2)
				//Cutting this wire also drops the door bolts, and mending it does not raise them. (This is what happens now, except there are a lot more wires going to door bolts at present)
				if (src.locked!=1)
					src.locked = 1
				update_icon()
				src.updateUsrDialog()
			if (AIRLOCK_WIRE_FAKEBOLT1, AIRLOCK_WIRE_FAKEBOLT2)
				//one wire for door bolts. Sending a pulse through this drops door bolts if they're not down (whether power's on or not),
				//raises them if they are down (only if power's on)
				if (!src.locked)
					src.locked = 1
					src.updateUsrDialog()
				update_icon()
			if (AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
				//Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
				src.loseBackupPower()
				src.shock(usr, 50)
				src.updateUsrDialog()
			if (AIRLOCK_WIRE_AI_CONTROL)
				//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
				//aiControlDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
				if (src.aiControlDisabled == 0)
					src.aiControlDisabled = 1
				else if (src.aiControlDisabled == -1)
					src.aiControlDisabled = 2
				src.updateUsrDialog()
			if (AIRLOCK_WIRE_ELECTRIFY)
				//Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted.
				if (src.secondsElectrified != -1)
					src.secondsElectrified = -1
			if(AIRLOCK_WIRE_ALERTAI)
				if(prob(alert_probability))
					for (var/mob/living/silicon/ai/aiPlayer in world)
						if (aiPlayer.stat != 2)
							aiPlayer.triggerUnmarkedAlarm("AirlockHacking", src.loc.loc)
					for (var/mob/living/silicon/robot/robotPlayer in world)
						if (robotPlayer.stat != 2)
							robotPlayer.triggerUnmarkedAlarm("AirlockHacking", src.loc.loc)

	mend(var/wireColor)
		var/wireFlag = WireColorToFlag[wireColor]
		var/wireIndex = WireColorToIndex[wireColor] //not used in this function
		wires |= wireFlag
		switch(wireIndex)
			if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
				if ((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
					src.regainMainPower()
					src.shock(usr, 50)
					src.updateUsrDialog()
			if (AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
				if ((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
					src.regainBackupPower()
					src.shock(usr, 50)
					src.updateUsrDialog()
			if (AIRLOCK_WIRE_AI_CONTROL)
				//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
				//aiControlDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
				if (src.aiControlDisabled == 1)
					src.aiControlDisabled = 0
				else if (src.aiControlDisabled == 2)
					src.aiControlDisabled = -1
				src.updateUsrDialog()
			if (AIRLOCK_WIRE_ELECTRIFY)
				if (src.secondsElectrified == -1)
					src.secondsElectrified = 0

	getAirlockWires()
		var/t1
		var/iterator = 0
		for(var/wiredesc in wire_index)
			if(iterator == wirenum)
				break
			var/is_uncut = src.wires & WireColorToFlag[wire_index[wiredesc]]
			t1 += "[wiredesc] wire: "
			if(!is_uncut)
				t1 += "<a href='?src=\ref[src];wires=[wire_index[wiredesc]]'>Mend</a>"
			else
				t1 += "<a href='?src=\ref[src];wires=[wire_index[wiredesc]]'>Cut</a> "
				t1 += "<a href='?src=\ref[src];pulse=[wire_index[wiredesc]]'>Pulse</a> "
				if(src.signalers[wire_index[wiredesc]])
					t1 += "<a href='?src=\ref[src];remove-signaler=[wire_index[wiredesc]]'>Detach signaler</a>"
				else
					t1 += "<a href='?src=\ref[src];signaler=[wire_index[wiredesc]]'>Attach signaler</a>"
			t1 += "<br>"
			iterator++
		return t1

	attackby(C as obj, mob/user as mob)
		//world << text("airlock attackby src [] obj [] mob []", src, C, user)
		if(istype(C, /obj/item/device/detective_scanner))
			return
		if(!src.is_detached && C)
			if (!istype(usr, /mob/living/silicon))
				if (src.isElectrified())
					if(src.shock(user, 75))
						return
			if (istype(C, /obj/item/device/hacktool))
				return src.attack_ai(user, C)
			if(ismob(C))
				return ..(C, user)
			src.add_fingerprint(user)
			switch(removal_step)
				if(0)
					if ((istype(C, /obj/item/weapon/weldingtool) && !( src.operating ) && src.density))
						var/obj/item/weapon/weldingtool/W = C
						if(W.remove_fuel(0,user))
							if (!src.welded)
								src.welded = 1
							else
								src.welded = null
							src.update_icon()
						return
					else if (istype(C, /obj/item/weapon/wrench))
						user << "You start to remove the bolts..."
						if(do_after(user,30))
							user << "Bolts removed"
							src.removal_step = 1
				if(1)
					if ((istype(C, /obj/item/weapon/weldingtool) && !( src.operating ) && src.density))
						var/obj/item/weapon/weldingtool/W = C
						if(W.remove_fuel(0,user))
							user << "You start to slice the armor..."
							if(do_after(user,20))
								user << "Armor sliced open"
								src.removal_step = 2
						return
					else if (istype(C, /obj/item/weapon/wrench))
						user << "You start wrench down the bolts..."
						if(do_after(user,30))
							user << "Bolts secured."
							src.removal_step = 0
				if(2)
					if ((istype(C, /obj/item/weapon/weldingtool) && !( src.operating ) && src.density))
						var/obj/item/weapon/weldingtool/W = C
						if(W.remove_fuel(0,user))
							user << "You start to fuse together the armor..."
							if(do_after(user,20))
								user << "Armor repaired"
								src.removal_step = 1
						return
					else if (istype(C, /obj/item/weapon/wrench))
						user << "You start to unfasted the armor from the circuits..."
						if(do_after(user,40))
							user << "Circuits exposed."
							src.removal_step = 3
							src.is_detached = 1
		else
			if (istype(C, /obj/item/weapon/wrench))
				user << "You start to fix the armor plate..."
				if(do_after(user,40))
					user << "Armor plates are back in position."
					src.is_detached = 0
					src.removal_step = 2
			else
				return ..(C, user)

	centcom
		name = "CentCom Secure Airlock"
		desc = "I hope you have insulated gloves...."
		icon = 'Doorhatchele.dmi'
		var/list/mob/morons

		pulse(var/wireColor)
			if(prob(25))
				usr.ex_act(rand(1,3))
			if (src.secondsElectrified==0)
				src.secondsElectrified = 10
				spawn(10)
					//TODO: Move this into process() and make pulsing reset secondsElectrified to 30
					while (src.secondsElectrified>0)
						src.secondsElectrified-=1
						if (src.secondsElectrified<0)
							src.secondsElectrified = 0
//						src.updateUsrDialog()  //Commented this line out to keep the airlock from clusterfucking you with electricity. --NeoFite
						sleep(10)
			var/wireIndex = WireColorToIndex[wireColor]
			switch(wireIndex)
				if(AIRLOCK_WIRE_IDSCAN)
					//Sending a pulse through this flashes the red light on the door (if the door has power).
					if ((src.arePowerSystemsOn()) && (!(stat & NOPOWER)))
						animate("deny")
				if (AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
					//Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter).
					src.loseMainPower()
				if (AIRLOCK_WIRE_DOOR_BOLTS, AIRLOCK_WIRE_DOOR_BOLTS_2)
					//one wire for door bolts. Sending a pulse through this drops door bolts if they're not down (whether power's on or not),
					//raises them if they are down (only if power's on)
					if (!src.locked)
						src.locked = 1
						src.updateUsrDialog()
					else
						if(src.arePowerSystemsOn()) //only can raise bolts if power's on
							src.locked = 0
							usr << "You hear a click from inside the door."
							src.updateUsrDialog()
					update_icon()

				if (AIRLOCK_WIRE_FAKEBOLT1, AIRLOCK_WIRE_FAKEBOLT2)
					//one wire for door bolts. Sending a pulse through this drops door bolts if they're not down (whether power's on or not),
					//raises them if they are down (only if power's on)
					if (!src.locked)
						src.locked = 1
						src.updateUsrDialog()
					update_icon()

				if (AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
					//two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter).
					src.loseBackupPower()
				if (AIRLOCK_WIRE_AI_CONTROL)
					if (src.aiControlDisabled == 0)
						src.aiControlDisabled = 1
					else if (src.aiControlDisabled == -1)
						src.aiControlDisabled = 2
					src.updateDialog()
					spawn(10)
						if (src.aiControlDisabled == 1)
							src.aiControlDisabled = 0
						else if (src.aiControlDisabled == 2)
							src.aiControlDisabled = -1
						src.updateDialog()
				if(AIRLOCK_WIRE_OPEN_DOOR)
					//tries to open the door without ID
					//will succeed only if the ID wire is cut or the door requires no access
					if (!src.requiresID() || src.check_access(null))
						if (src.density)
							open()
						else
							close()
				if(AIRLOCK_WIRE_CRUSH)
					src.forcecrush = !src.forcecrush
				if(AIRLOCK_WIRE_LIGHT)
					src.safetylight = !src.safetylight
				if(AIRLOCK_WIRE_HOLDOPEN)
					src.holdopen = !src.holdopen
				if(AIRLOCK_WIRE_ALERTAI)
					if(prob(alert_probability))
						for (var/mob/living/silicon/ai/aiPlayer in world)
							if (aiPlayer.stat != 2)
								aiPlayer.triggerUnmarkedAlarm("AirlockHacking", src.loc.loc)
						for (var/mob/living/silicon/robot/robotPlayer in world)
							if (robotPlayer.stat != 2)
								robotPlayer.triggerUnmarkedAlarm("AirlockHacking", src.loc.loc)

		cut(var/wireColor)
			if(prob(25))
				usr.ex_act(rand(1,3))
			if (src.secondsElectrified==0)
				src.secondsElectrified = 30
				spawn(10)
					//TODO: Move this into process() and make pulsing reset secondsElectrified to 30
					while (src.secondsElectrified>0)
						src.secondsElectrified-=1
						if (src.secondsElectrified<0)
							src.secondsElectrified = 0
//						src.updateUsrDialog()  //Commented this line out to keep the airlock from clusterfucking you with electricity. --NeoFite
						sleep(10)
			var/wireFlag = WireColorToFlag[wireColor]
			var/wireIndex = WireColorToIndex[wireColor]
			wires &= ~wireFlag
			switch(wireIndex)
				if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
					//Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be crowbarred open, but bolts-raising will not work. Cutting these wires may electocute the user.
					src.loseMainPower()
					src.shock(usr, 50)
					src.updateUsrDialog()
				if (AIRLOCK_WIRE_DOOR_BOLTS, AIRLOCK_WIRE_DOOR_BOLTS_2)
					//Cutting this wire also drops the door bolts, and mending it does not raise them. (This is what happens now, except there are a lot more wires going to door bolts at present)
					if (src.locked!=1)
						src.locked = 1
					update_icon()
					src.updateUsrDialog()
				if (AIRLOCK_WIRE_FAKEBOLT1, AIRLOCK_WIRE_FAKEBOLT2)
					//one wire for door bolts. Sending a pulse through this drops door bolts if they're not down (whether power's on or not),
					//raises them if they are down (only if power's on)
					if (!src.locked)
						src.locked = 1
						src.updateUsrDialog()
					update_icon()
				if (AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
					//Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
					src.loseBackupPower()
					src.shock(usr, 50)
					src.updateUsrDialog()
				if (AIRLOCK_WIRE_AI_CONTROL)
					//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
					//aiControlDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
					if (src.aiControlDisabled == 0)
						src.aiControlDisabled = 1
					else if (src.aiControlDisabled == -1)
						src.aiControlDisabled = 2
					src.updateUsrDialog()
				if (AIRLOCK_WIRE_ELECTRIFY)
					//Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted.
					if (src.secondsElectrified != -1)
						src.secondsElectrified = -1
				if(AIRLOCK_WIRE_ALERTAI)
					if(prob(alert_probability))
						for (var/mob/living/silicon/ai/aiPlayer in world)
							if (aiPlayer.stat != 2)
								aiPlayer.triggerUnmarkedAlarm("AirlockHacking", src.loc.loc)
						for (var/mob/living/silicon/robot/robotPlayer in world)
							if (robotPlayer.stat != 2)
								robotPlayer.triggerUnmarkedAlarm("AirlockHacking", src.loc.loc)

		attack_ai(mob/user as mob, obj/item/device/hacktool/C)
			if(!(user in morons))
				user << "\red Do that again, and you will die horribly."
				if(prob(50))
					morons.Add(user)
			else
				user << "\red You were warned..."
				world << "\red [user.name] has been found attempting to hack a CentCom Secure Door via AI/Hacktool.  Better luck next time."
				user.ex_act(1)