/datum/global_iterator/pod_inertial_drift
	delay = 4

	process(var/obj/pod/pod)
		if(!pod)
			qdel(src)

		if(pod.size[1] > 1)
			// So for some reason when going north or east, Entered() isn't called on the turfs in a 2x2 pod
			for(var/turf/open/space/space in pod.GetTurfsUnderPod())
				space.Entered(pod)

		if(!pod.inertial_direction)
			return 0

		if(!pod.HasTraction())
			step(pod, pod.inertial_direction)
			spawn(-1)
				pod.dir = pod.turn_direction

// Took this from mecha, no need to rewrite anything existing.
/datum/global_iterator/pod_equalize_air
	delay = 10

	process(var/obj/pod/pod)
		if(!pod)
			qdel(src)

		if(pod.internal_canister)
			var/datum/gas_mixture/tank_air = pod.internal_canister.return_air()
			var/datum/gas_mixture/internal_air = pod.internal_air

			if(!internal_air || !tank_air)
				return 0

			var/release_pressure = ONE_ATMOSPHERE
			var/cabin_pressure = internal_air.return_pressure()
			var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
			var/transfer_moles = 0
			if(pressure_delta > 0) //cabin pressure lower than release pressure
				if(tank_air.return_temperature() > 0)
					transfer_moles = pressure_delta*internal_air.return_volume()/(internal_air.return_temperature() * R_IDEAL_GAS_EQUATION)
					var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
					internal_air.merge(removed)
			else if(pressure_delta < 0) //cabin pressure higher than release pressure
				var/datum/gas_mixture/t_air = pod.return_air()
				pressure_delta = cabin_pressure - release_pressure
				if(t_air)
					pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
				if(pressure_delta > 0) //if location pressure is lower than cabin pressure
					transfer_moles = pressure_delta*internal_air.return_volume()/(internal_air.return_temperature() * R_IDEAL_GAS_EQUATION)
					var/datum/gas_mixture/removed = internal_air.remove(transfer_moles)
					if(t_air)
						t_air.merge(removed)
					else //just delete the cabin gas, we're in space or some shit
						qdel(removed)
		else
			stop()

/datum/global_iterator/pod_attachment_processor
	delay = 5

	process(var/obj/pod/pod)
		if(!pod)
			qdel(src)

		for(var/obj/item/pod_attachment/A in pod.attachments)
			A.PodProcess(pod)

		var/obj/item/pod_attachment/engine/E = pod.GetAttachmentOnHardpoint(P_HARDPOINT_ENGINE)
		if(E)
			pod.move_cooldown = CLAMP((initial(pod.move_cooldown) + E.pod_move_reduction), 0.1, 5)
			pod.inertial_drift_iterator.delay = initial(pod.inertial_drift_iterator.delay) + E.pod_move_reduction
		else
			pod.move_cooldown = initial(pod.move_cooldown)
			pod.inertial_drift_iterator.delay = initial(pod.inertial_drift_iterator.delay)

		if(pod.toggles & P_TOGGLE_LIGHTS)
			pod.set_light(pod.lumens)
			//pod.SetLuminosity(pod.lumens)
		else
			pod.set_light(0)
			//pod.SetLuminosity(0)

// The pod damage iterator is in damage.dm