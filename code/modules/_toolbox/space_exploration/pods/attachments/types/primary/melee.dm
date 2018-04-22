/obj/item/pod_attachment/primary/melee

	drill/
		name = "mining drill"
		overlay_icon_state = "pod_weapon_drills"
		icon_state = "attachment_utility"
		power_usage = 10
		var/speed = 20
		var/predicate = "drilling"
		var/damage_predicate = "drilled"
		var/damage = 15
		var/damage_type = BRUTE
		var/automine = 0
		construction_cost = list("metal" = 4000)
		//origin_tech = "engineering=1"

		Use(var/atom/target, var/mob/user, var/flags = P_ATTACHMENT_IGNORE_POWER)
			if(!(..(target, user, flags)))
				return 0

			if(!HasPower(power_usage))
				attached_to.PrintSystemAlert("Insufficient power.")
				return 0

			var/list/turfs = attached_to.GetDirectionalTurfs(attached_to.dir)
			var/list/additions[length(turfs)]
			var/needs_logging = 0
			var/turf/closed/mineral/mineralwall = locate(/turf/closed/mineral) in turfs
			if(mineralwall)
				to_chat(user,"<span class='info'>You start [predicate]...</span>")
				if(do_after(user, speed,target = mineralwall))
					if(!length((turfs & attached_to.GetDirectionalTurfs(attached_to.dir))))
						return 0
					if(!UsePower(power_usage))
						return 0
					for(var/turf/closed/mineral/M in turfs)
						M.gets_drilled()

			for(var/turf/T in turfs)
				for(var/mob/living/L in T)
					if(damage_type == BRUTE)
						L.take_overall_damage(damage, 0)
					else if(damage_type == BURN)
						L.take_overall_damage(0, damage)
					to_chat(user,"<span class='warning'>You [damage_predicate] [L].</span>")
					add_logs(user, L, damage_predicate, 1, src, " with a space pod ([attached_to]) ([attached_to.type])")
					additions[turfs.Find(T)] = "harmed [key_name(L)] (damage: [damage], damage type: [damage_type])"
					needs_logging = 1

			// We don't need to log general mining operations.
			if(needs_logging)
				attached_to.pod_log.LogUsage(user, src, turfs, additions)

		PodBumpedAction(var/list/turfs = list())
			if(!attached_to)
				return 0

			if(!attached_to.pilot)
				return 0

			if(!automine)
				return 0

			Use(0, attached_to.pilot)

		GetAdditionalMenuData()
			var/dat = "Automine: <a href='?src=\ref[src];action=toggle_automine'>[automine ? "On" : "Off"]</a>"
			return dat

		Topic(href, href_list)
			..()

			if(href_list["action"] == "toggle_automine")
				automine = !automine
				to_chat(usr,"<span class='info'>You turn auto-mining [automine ? "on" : "off"].</span>")

		plasma/
			name = "mining plasma cutter"
			overlay_icon_state = "pod_weapon_cutter"
			power_usage = 20
			speed = 10
			predicate = "cutting"
			damage_predicate = "cut"
			damage = 20
			damage_type = BURN
			construction_cost = list("metal" = 4000, "plasma" = 1500, "silver" = 1500)
			//origin_tech = "engineering=2;magnets=2"
