/obj/item/pod_attachment

	GetAvailableKeybinds()
		return list(P_ATTACHMENT_KEYBIND_SINGLE, P_ATTACHMENT_KEYBIND_SHIFT, P_ATTACHMENT_KEYBIND_CTRL, P_ATTACHMENT_KEYBIND_ALT,
					P_ATTACHMENT_KEYBIND_MIDDLE, P_ATTACHMENT_KEYBIND_CTRLSHIFT)

	primary/
		name = "primary attachment"
		hardpoint_slot = P_HARDPOINT_PRIMARY_ATTACHMENT
		keybind = P_ATTACHMENT_KEYBIND_SINGLE

		GetOverlay(var/list/size = list())
			. = ..()
			if(attached_to && istype(attached_to.GetAttachmentOnHardpoint(P_HARDPOINT_SECONDARY_ATTACHMENT), /obj/item/pod_attachment/secondary/gimbal))
				return 0

		projectile/
			var/projectile = /obj/item/projectile
			var/dual_projectile = 1
			icon_state = "attachment_weapons"

			Use(var/atom/target, var/mob/user, var/flags = P_ATTACHMENT_PLAYSOUND)
				if(!..(target, user, flags))
					return 0

				if(projectile)
					var/gimbal = istype(attached_to.GetAttachmentOnHardpoint(P_HARDPOINT_SECONDARY_ATTACHMENT), /obj/item/pod_attachment/secondary/gimbal)

					// Gimbals only shoot one projectile regardless
					if(dual_projectile && !gimbal)
						if(!HasPower(power_usage))
							attached_to.PrintSystemAlert("Insufficient energy.")
							return 0

						UsePower(power_usage)

					var/turf/pod_turf = get_turf(attached_to)

					var/list/start_points = list()
					var/list/targets = list()
					if(gimbal)
						var/direction = get_dir(pod_turf, get_turf(target))
						var/angle = dir2angle(direction)
						if((angle % 90) != 0)
							// Wooooo edge cases!
							if((target.x == (attached_to.x + 1)) && (target.y > attached_to.y))
								direction = angle2dir(angle - 45)
							else
								direction = angle2dir((angle == 45) ? (angle + 45) : (angle - 45))
						start_points = attached_to.GetDirectionalTurfsUnderPod(direction)
						// Wooooo more edge cases!
						var/index_to_remove = 2
						if(((target.x < attached_to.x) && (target.y > attached_to.y)) || ((target.x > attached_to.x) && (target.y > attached_to.y)))
							index_to_remove = 1
						start_points.Remove(start_points[index_to_remove])
						targets.Add(target)
						if(dual_projectile)
							last_use = (world.time - (cooldown / 2)) // Halve the cooldown so we get the same DPS
					else
						start_points = attached_to.GetDirectionalTurfsUnderPod(attached_to.dir)
						targets = attached_to.GetDirectionalTurfs(attached_to.dir)

					for(var/turf/T in start_points)
						var/obj/item/projectile/P = new projectile(T)
						var/index = start_points.Find(T)
						P.firer = attached_to.pilot
						P.permutated.Add(attached_to)
						P.preparePixelProjectile(targets[index], T)
						P.fire(null, null)

					var/list/additions[length(targets)]
					for(var/atom/A in targets)
						additions[targets.Find(A)] = "(DIR: [dir2text(get_dir(pod_turf, A))])[isliving(A) ? " (MOB-TARGET: [key_name(A)])" : ""]"

					attached_to.pod_log.LogUsage(user, src, targets, additions)

				return 1