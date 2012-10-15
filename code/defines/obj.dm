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

/obj/effect/beam
	name = "beam"
	unacidable = 1//Just to be sure.
	var/def_zone
	pass_flags = PASSTABLE


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

	proc/get_manifest(monochrome)
		var/list/heads = new()
		var/list/sec = new()
		var/list/eng = new()
		var/list/med = new()
		var/list/sci = new()
		var/list/civ = new()
		var/list/bot = new()
		var/list/misc = new()

		var/dat = {"
		<head><style>
			.manifest {border-collapse:collapse;}
			.manifest td, th {border:1px solid [monochrome?"black":"#DEF; background-color:white; color:black"]; padding:.25em}
			.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: #48C; color:white"]}
			.manifest tr.head th { [monochrome?"border-top-width: 1px":"background-color: #488;"] }
			.manifest td:first-child {text-align:right}
			.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: #DEF"]}
		</style></head>
		<table class="manifest">
		<tr class='head'><th>Name</th><th>Rank</th></tr>
		"}
		var/even = 0

		// sort mobs
		for(var/datum/data/record/t in data_core.general)
			var/name = t.fields["name"]
			var/rank = t.fields["rank"]
			var/real_rank = t.fields["real_rank"]

			//world << "[name]: [rank]"

			if(real_rank in command_positions)
				heads[name] = rank
			if(real_rank in security_positions)
				sec[name] = rank
				continue
			if(real_rank in engineering_positions)
				eng[name] = rank
				continue
			if(real_rank in medical_positions)
				med[name] = rank
				continue
			if(real_rank in science_positions)
				sci[name] = rank
				continue
			if(real_rank in civilian_positions)
				civ[name] = rank
				continue
			if(real_rank in nonhuman_positions)
				bot[name] = rank
				continue

			if(!(name in heads))
				misc[name] = rank

		if(heads.len > 0)
			dat += "<tr><th colspan=2>Heads</th></tr>"
			for(name in heads)
				dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[heads[name]]</td></tr>"
				even = !even
		if(sec.len > 0)
			dat += "<tr><th colspan=2>Security</th></tr>"
			for(name in sec)
				dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[sec[name]]</td></tr>"
				even = !even
		if(eng.len > 0)
			dat += "<tr><th colspan=2>Engineering</th></tr>"
			for(name in eng)
				dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[eng[name]]</td></tr>"
				even = !even
		if(med.len > 0)
			dat += "<tr><th colspan=2>Medical</th></tr>"
			for(name in med)
				dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[med[name]]</td></tr>"
				even = !even
		if(sci.len > 0)
			dat += "<tr><th colspan=2>Science</th></tr>"
			for(name in sci)
				dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[sci[name]]</td></tr>"
				even = !even
		if(civ.len > 0)
			dat += "<tr><th colspan=2>Civilian</th></tr>"
			for(name in civ)
				dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[civ[name]]</td></tr>"
				even = !even
		// in case somebody is insane and added them to the manifest, why not
		if(bot.len > 0)
			dat += "<tr><th colspan=2>Silicon</th></tr>"
			for(name in bot)
				dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[bot[name]]</td></tr>"
				even = !even
		// misc guys
		if(misc.len > 0)
			dat += "<tr><th colspan=2>Miscellaneous</th></tr>"
			for(name in misc)
				dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[misc[name]]</td></tr>"
				even = !even


		dat += "</table>"
		dat = dd_replacetext(dat, "\n", "") // so it can be placed on paper correctly
		dat = dd_replacetext(dat, "\t", "")
		return dat

/obj/item/device/infra_sensor
	name = "Infrared Sensor"
	desc = "Scans for infrared beams in the vicinity."
	icon_state = "infra_sensor"
	var/passive = 1.0
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	m_amt = 150
	origin_tech = "magnets=2"


/obj/effect/laser
	name = "laser"
	desc = "IT BURNS!!!"
	icon = 'icons/obj/projectiles.dmi'
	var/damage = 0.0
	var/range = 10.0


/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )


/obj/structure/cable
	level = 1
	anchored =1
	var/datum/powernet/powernet
	name = "power cable"
	desc = "A flexible superconducting cable for heavy-duty power transfer"
	icon = 'icons/obj/power_cond_red.dmi'
	icon_state = "0-1"
	var/d1 = 0
	var/d2 = 1
	layer = 2.44 //Just below unary stuff, which is at 2.45 and above pipes, which are at 2.4
	var/color = "red"
	var/obj/structure/powerswitch/power_switch

/obj/structure/cable/yellow
	color = "yellow"
	icon = 'icons/obj/power_cond_yellow.dmi'

/obj/structure/cable/green
	color = "green"
	icon = 'icons/obj/power_cond_green.dmi'

/obj/structure/cable/blue
	color = "blue"
	icon = 'icons/obj/power_cond_blue.dmi'

/obj/structure/cable/pink
	color = "pink"
	icon = 'icons/obj/power_cond_pink.dmi'

/obj/structure/cable/orange
	color = "orange"
	icon = 'icons/obj/power_cond_orange.dmi'

/obj/structure/cable/cyan
	color = "cyan"
	icon = 'icons/obj/power_cond_cyan.dmi'

/obj/structure/cable/white
	color = "white"
	icon = 'icons/obj/power_cond_white.dmi'

/obj/effect/projection
	name = "Projection"
	desc = "This looks like a projection of something."
	anchored = 1.0


/obj/effect/shut_controller
	name = "shut controller"
	var/moving = null
	var/list/parts = list(  )

/obj/effect/showcase
	name = "Showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = 1
	anchored = 1
	unacidable = 1//temporary until I decide whether the borg can be removed. -veyveyr


// Basically this Metroid Core catalyzes reactions that normally wouldn't happen anywhere
/obj/item/metroid_core
	name = "roro core"
	desc = "A very slimy and tender part of a Rorobeast. Legends claim these to have \"magical powers\"."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "roro core"
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

/obj/effect/spawner
	name = "object spawner"
