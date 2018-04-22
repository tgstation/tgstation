/obj/item/pod_attachment/sensor
	icon_state = "attachment_sensors"
	name = "pod sensor"
	hardpoint_slot = P_HARDPOINT_SENSOR
	power_usage = 100
	keybind = P_ATTACHMENT_KEYBIND_CTRL
	cooldown = 200
	var/interval = 0
	var/last_scan = 0

	GetAvailableKeybinds()
		return list(P_ATTACHMENT_KEYBIND_MIDDLE, P_ATTACHMENT_KEYBIND_SHIFT, P_ATTACHMENT_KEYBIND_CTRL, P_ATTACHMENT_KEYBIND_ALT,
					P_ATTACHMENT_KEYBIND_CTRLSHIFT)

	// The Sense and Output procs are up for own interpretation and do not need to follow this format.
	proc/Sense(var/mob/living/user)
		return 0

	Use(var/atom/target, var/mob/user)
		if(!(..(target, user)))
			return 0

		Sense(user)

		last_use = world.time

	PodProcess(var/obj/pod/pod)
		if(!(..(pod)))
			return 0

		if(pod.pilot && interval)
			if((last_scan + interval) <= world.time)
				Use(null, pod.pilot)
				last_scan = world.time

	GetAdditionalMenuData()
		var/dat = "Scan Interval: <a href='?src=\ref[src];action=setinterval'>[interval ? (interval / 10) : "No Interval"]</a><br>"
		dat += "Next Scan in [CLAMP(round(((last_scan + interval) - world.time) / 10), 0, INFINITY)] seconds."

		return dat

	Topic(href, href_list)
		..()

		if(href_list["action"] == "setinterval")
			var/_interval = input(usr, "Set Interval between 0 (off), 20 and 60 seconds.", "Input") as num
			if(!_interval)
				return 0

			_interval = round(CLAMP(_interval, 20, 60))
			_interval *= 10
			interval = _interval
			last_scan = world.time

	gps/ // This is used in human.Stat
		name = "gps"
		active = P_ATTACHMENT_PASSIVE
		construction_cost = list("metal" = 400)
		//origin_tech = "programming=1"
		has_menu = 0

	lifeform/
		name = "lifeform sensor"
		cooldown = 10
		construction_cost = list("metal" = 400)
		//origin_tech = "engineering=2;powerstorage=2;magnets=2;programming=2"

		Sense(var/mob/living/user)
			var/turf/user_turf = get_turf(user)
			var/list/data = list()

			for(var/mob/living/L in GLOB.mob_list)
				if(!istype(L.loc, /turf))
					continue

				var/turf/mob_turf = get_turf(L)
				if(mob_turf.z != user_turf.z)
					continue

				var/strength = 0
				switch(user_turf.Distance(mob_turf))
					if(0 to 50)
						strength = "strong"
					if(51 to 150)
						strength = "weak"
					if(151 to world.maxx)
						strength = "faint"

				var/direction = dir2text(get_dir(user_turf, mob_turf))
				if(!(direction in data))
					data.Add(direction)
					data[direction] = list()

				var/list/strengths = data[direction]

				if(!(strength in data[direction]))
					strengths.Add(strength)
					data[direction] = strengths

				strengths[strength]++
				data[direction] = strengths

			for(var/direction in data)
				to_chat(user,"<span class='notice'>----------[uppertext(direction)]----------</span>")
				var/list/strengths = data[direction]
				for(var/strength in strengths)
					var/amount = strengths[strength]
					if(amount > 0)
						to_chat(user,"<span class='notice'>[amount] [strength] signal[(amount > 1) ? "s" : ""] detected.</span>")
