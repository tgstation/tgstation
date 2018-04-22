//var/list/pod_list = list()
//GLOBAL_LIST_EMPTY(pod_list)

/obj/pod
	name = "Pod"
	icon = 'icons/oldschool/spacepods/pod-1-1.dmi'
	icon_state = "miniputt"
	density = 1
	anchored = 1
	layer = 3.2
	resistance_flags = UNACIDABLE

	var/list/size = list(1, 1)
	var/obj/machinery/portable_atmospherics/canister/internal_canister
	var/datum/gas_mixture/internal_air
	var/obj/item/stock_parts/cell/power_source
	var/inertial_direction = NORTH
	var/turn_direction = NORTH
	var/last_move_time = 0
	var/move_cooldown = 2
	var/enter_delay = 10
	var/exit_delay = 10
	var/list/locks = list() // DNA (unique_enzymes) or code lock.
	var/lumens = 6
	var/toggles = 0
	var/seats = 0 // Amount of additional people that can fit into the pod (excludes pilot)
	var/being_repaired = 0
	var/emagged = 0

	var/list/hardpoints = list()
	var/list/attachments = list()

	var/datum/global_iterator/pod_inertial_drift/inertial_drift_iterator
	var/datum/global_iterator/pod_equalize_air/equalize_air_iterator
	var/datum/global_iterator/pod_attachment_processor/process_attachments_iterator
	var/datum/global_iterator/pod_damage/pod_damage_iterator

	var/mob/living/carbon/human/pilot = 0

	var/datum/effect_system/spark_spread/sparks

	var/datum/pod_log/pod_log

	Initialize()
		..()

		if(!size || !size.len)
			qdel(src)
			return

		//GLOB.pod_list += src

		bound_width = size[1] * 32
		bound_height = size[2] * 32

		internal_canister = GetCanister()
		internal_air = GetEnvironment()
		hardpoints = GetHardpoints()
		power_source = GetPowercell()
		attachments = (GetAdditionalAttachments() + GetArmor() + GetEngine())
		seats = GetSeats()
		pod_log = new(src)

		// Should be fine if we initialize a global variable in here.
		/*if(!GLOB.pod_config)
			GLOB.pod_config = new()*/

		spawn(0)
			inertial_drift_iterator = new(list(src))
			equalize_air_iterator = new(list(src))
			process_attachments_iterator = new(list(src))
			pod_damage_iterator = new(list(src))

		max_health = initial(health)

		sparks = new /datum/effect_system/spark_spread()
		sparks.set_up(5, 0, src)
		sparks.attach(src)

		if(fexists("icons/oldschool/spacepods/pod-[size[1]]-[size[2]].dmi"))
			icon = file("icons/oldschool/spacepods/pod-[size[1]]-[size[2]].dmi")

		// Place attachments / batteries under the pod and they'll get attached (map editor)
		spawn(10)
			for(var/turf/T in GetTurfsUnderPod())
				for(var/obj/item/pod_attachment/P in T)
					if(CanAttach(P))
						P.OnAttach(src, 0)

				var/obj/item/stock_parts/cell/cell = locate() in T
				if(cell)
					qdel(power_source)
					cell.loc = src
					power_source = cell

	Del()
		DestroyPod()
		..()

	examine()
		..()
		var/hp = HealthPercent()
		switch(hp)
			if(-INFINITY to 25)
				to_chat(usr,"<span class='warning'>It looks severely damaged.</span>")
			if(26 to 50)
				to_chat(usr,"<span class='warning'>It looks significantly damaged.</span>")
			if(51 to 75)
				to_chat(usr,"<span class='warning'>It looks moderately damaged.</span>")
			if(76 to 99)
				to_chat(usr,"<span class='warning'>It looks slightly damaged.</span>")
			if(100 to INFINITY)
				to_chat(usr,"<span class='info'>It looks undamaged.</span>")

		to_chat(usr,"<span class='info'>Attached are:</span>")
		for(var/obj/item/pod_attachment/attachment in GetAttachments())
			if(attachment.hardpoint_slot in list(P_HARDPOINT_PRIMARY_ATTACHMENT, P_HARDPOINT_ARMOR, P_HARDPOINT_SHIELD, P_HARDPOINT_SECONDARY_ATTACHMENT))
				to_chat(usr,"<span class='info'>- \The [attachment.name]")

	update_icon()
		overlays.Cut()

		for(var/obj/item/pod_attachment/A in attachments)
			var/image/overlay = A.GetOverlay(size)
			if(!overlay)	continue
			overlays += overlay

		if(HasDamageFlag(P_DAMAGE_GENERAL))
			overlays += image(icon = "icons/oldschool/spacepods/pod-[size[1]]-[size[2]].dmi", icon_state = "pod_damage")

		if(HasDamageFlag(P_DAMAGE_FIRE))
			overlays += image(icon = "icons/oldschool/spacepods/pod-[size[1]]-[size[2]].dmi", icon_state = "pod_fire")

	proc/HandleExit(var/mob/living/carbon/human/H)
		if(toggles & P_TOGGLE_HUDLOCK)
			if(alert(H, "Outside HUD Access is diabled, are you sure you want to exit?", "Confirmation", "Yes", "No") == "No")
				return 0

		var/as_pilot = (H == pilot)

		to_chat(H,"<span class='info'>You start leaving the [src]..<span>")
		if(do_after(H, exit_delay))
			to_chat(H,"<span class='info'>You leave the [src].</span>")
			H.loc = get_turf(src)
			if(as_pilot)
				pilot = 0

		pod_log.LogOccupancy(H, as_pilot)

	proc/HandleEnter(var/mob/living/carbon/human/H)
		if(!CanOpenPod(H))
			return 0

		var/as_passenger = 0
		if(pilot)
			if(HasOpenSeat())
				var/enter_anyways = input("The [src] is already manned. Do you want to enter as a passenger?") in list("Yes", "No")
				if(enter_anyways == "Yes")
					as_passenger = 1
				else
					return 0
			else
				to_chat(H,"<span class='warning'>The [src] is already manned[seats ? " and all the seats are occupied" : ""].")
				return 0

		to_chat(H,"<span class='info'>You start to enter the [src]..</span>")
		if(do_after(H, enter_delay,target = src))
			to_chat(H,"<span class='info'>You enter the [src].</span>")
			H.loc = src
			if(!as_passenger)
				pilot = H
				PrintSystemNotice("Systems initialized.")
				if(power_source)
					PrintSystemNotice("Power Charge: [power_source.charge]/[power_source.maxcharge] ([power_source.percent()]%)")
				else
					PrintSystemAlert("No power source installed.")
				PrintSystemNotice("Integrity: [round((health / max_health) * 100)]%.")
			playsound(H, 'sound/machines/windowdoor.ogg', 50, 1)

		pod_log.LogOccupancy(H, !as_passenger)

	MouseDrop_T(var/atom/dropping, var/mob/user)
		if(istype(dropping, /mob/living/carbon/human))
			if(dropping == user)
				HandleEnter(dropping)

	relaymove(var/mob/user, var/_dir)
		if(user == pilot)
			DoMove(user, _dir)

	proc/DoMove(var/mob/user, var/_dir)
		if(user != pilot)
			return 0

		var/obj/item/pod_attachment/engine/engine = GetAttachmentOnHardpoint(P_HARDPOINT_ENGINE)
		if(!engine)
			PrintSystemAlert("No engine attached.")
			return 0
		else if(engine.active & P_ATTACHMENT_INACTIVE)
			PrintSystemAlert("Engine is turned off.")
			return 0

		if(!HasPower(GLOB.pod_config.movement_cost))
			PrintSystemAlert("Insufficient power.")
			return 0

		if(HasDamageFlag(P_DAMAGE_EMPED))
			_dir = pick(GLOB.cardinals)

		var/can_drive_over = 0
		var/is_dense = 0
		for(var/turf/T in GetDirectionalTurfs(_dir))
			if(T.density)
				is_dense = 1
			for(var/path in GLOB.pod_config.drivable)
				path = text2path(path)
				if(!ispath(path))
					continue
				if(istype(T, path) || istype(get_area(T), path) || (T.icon_state == "plating"))
					can_drive_over = 1
					break
				else
					if(istype(T, /turf/open/floor))
						var/turf/open/floor/F = T
						if(F.icon_state == F.icon_plating)
							can_drive_over = 1
							break

		// Bump() does not play nice with 64x64, so this will have to do.
		if(is_dense)
			dir = _dir
			var/list/turfs = GetDirectionalTurfs(dir)
			for(var/obj/item/pod_attachment/attachment in GetAttachments())
				attachment.PodBumpedAction(turfs)
			last_move_time = world.time
			return 0

		if(!can_drive_over)
			dir = _dir
			last_move_time = world.time
			return 0

		if(size[1] > 1)
			// So for some reason when going north or east, Entered() isn't called on the turfs in a 2x2 pod
			for(var/turf/open/space/space in GetTurfsUnderPod())
				space.Entered(src)

		if(istype(get_turf(src), /turf/open/space) && !HasTraction())
			if((_dir == turn(inertial_direction, 180)) && (toggles & P_TOGGLE_SOR))
				inertial_direction = 0
				return 1

			if(turn_direction == _dir)
				inertial_direction = _dir
			else
				dir = _dir
				turn_direction = _dir
		else
			if((last_move_time + move_cooldown) > world.time)
				return 0
			step(src, _dir)
			UsePower(GLOB.pod_config.movement_cost)
			turn_direction = _dir
			inertial_direction = _dir

		last_move_time = world.time

	attack_hand(var/mob/living/user)
		if(user.a_intent == "grab")
			var/list/possible_targets = list()
			for(var/mob/living/M in GetOccupants())
				possible_targets["[M.name] ([(pilot && M == pilot) ? "Pilot" : "Passenger"])"] = M

			if(!length(possible_targets))
				return 0

			var/chosen = input(user, "Who do you want to pull out?", "Input") in possible_targets + "Cancel"
			if(!chosen || chosen == "Cancel")
				return 0

			var/mob/living/chosen_mob = possible_targets[chosen]
			if(!chosen_mob || (!(chosen_mob in GetOccupants())))
				return 0

			var/is_pilot = 0
			if(pilot && (pilot == chosen_mob))
				is_pilot = 1

			to_chat(chosen_mob,"<span class='warning'>You are being pulled out of the pod by [user].</span>")
			to_chat(user,"<span class='info'>You start to pull out [chosen_mob].</span>")
			if(do_after(user, GLOB.pod_config.pod_pullout_delay,target = src))
				if(chosen_mob && (chosen_mob in GetOccupants()))
					to_chat(chosen_mob,"<span class='warning'>You were pulled out of \the [src] from [user].</span>")
					pod_log.LogOccupancy(chosen_mob, 1, user)
					chosen_mob.loc = get_turf(src)
					if(is_pilot)
						pilot = 0
				else
					return 0
			else
				to_chat(user,"<span class='info'>\The [src] is unmanned.</span>")

			return 1

		..()

	attackby(var/obj/item/I, var/mob/living/user)
		if(istype(I, /obj/item/pod_attachment))
			var/obj/item/pod_attachment/attachment = I

			var/can_attach_result = CanAttach(attachment)
			if(can_attach_result & P_ATTACH_ERROR_CLEAR)
				attachment.StartAttach(src, user)
			else
				switch(can_attach_result)
					if(P_ATTACH_ERROR_TOOBIG)
						to_chat(user,"<span class='warning'>The [src] is too small for the [I].</span>")
					if(P_ATTACH_ERROR_ALREADY_ATTACHED)
						to_chat(user,"<span class='warning'>There is already an attachment on that slot.</span>")
				return 0
			return 1

		if(user.a_intent == "harm")
			goto Damage

		if(istype(I, /obj/item/stock_parts/cell))
			if(power_source)
				to_chat(user,"<span class='warning'>There is already a cell installed.</span>")
				return 0
			else
				to_chat(user,"<span class='notice'>You start to install \the [I] into \the [src].</span>")
				if(do_after(user, 20,target = src))
					user.doUnEquip(I, 1)
					I.loc = src
					power_source = I
					to_chat(user,"<span class='notice'>You install \the [I] into \the [src].</span>")
			return 0

		if(istype(I, /obj/item/device/multitool))
			if(CanOpenPod(user))
				OpenHUD(user)

			return 1

		if(istype(I, /obj/item/stack/sheet/metal))
			if(being_repaired)
				return 0

			if(HealthPercent() > GLOB.pod_config.metal_repair_threshold_percent)
				to_chat(user,"<span class='warning'>\The [src] doesn't require any more metal.</span>")
				return 0

			var/obj/item/stack/sheet/metal/M = I

			being_repaired = 1

			to_chat(user,"<span class='info'>You start to add metal to \the [src].</span>")
			while(do_after(user, 30,target = src) && M && M.amount)
				to_chat(user,"<span class='info'>You add some metal to \the [src].</span>")
				health += GLOB.pod_config.metal_repair_amount
				update_icon()
				M.use(1)
				if(HealthPercent() > GLOB.pod_config.metal_repair_threshold_percent)
					to_chat(user,"<span class='warning'>\The [src] doesn't require any more metal.</span>")
					break

			being_repaired = 0

			to_chat(user,"<span class='info'>You stop repairing \the [src].</span>")

			return 0

		if(istype(I, /obj/item/weldingtool))
			if(being_repaired)
				return 0

			if(HealthPercent() < GLOB.pod_config.metal_repair_threshold_percent)
				to_chat(user,"<span class='warning'>\The [src] is too damaged to repair without additional metal.</span>")
				return 0

			if(HealthPercent() >= 100)
				to_chat(user,"<span class='info'>\The [src] is already fully repaired.</span>")
				return 0

			var/obj/item/weldingtool/W = I

			being_repaired = 1

			to_chat(user,"<span class='info'>You start to repair some damage on \the [src].</span>")
			while(do_after(user, 30,target = src) && W.isOn())
				to_chat(user,"<span class='info'>You repair some damage.</span>")
				health += GLOB.pod_config.welding_repair_amount
				update_icon()
				W.use(1)
				if(HealthPercent() >= 100)
					to_chat(user,"<span class='info'>\The [src] is now fully repaired.</span>")
					break

			being_repaired = 0

			to_chat(user,"<span class='info'>You stop repairing \the [src].</span>")

			return 0

		if(istype(I, /obj/item/pen))
			var/new_name = input(user, "Please enter a new name for the pod.", "Input") as text
			new_name = strip_html(new_name)
			new_name = trim(new_name)

			to_chat(user,"<span class='info'>You change the [name]'s name to [new_name].</span>")
			name = "\"[new_name]\""
			return 0

		// Give attachments a chance to handle attackby.
		for(var/obj/item/pod_attachment/attachment in GetAttachments())
			if(attachment.PodAttackbyAction(I, user))
				return 0

		Damage

		if(I.force)
			to_chat(user,"<span class='attack'>You hit \the [src] with the [I].</span>")
			TakeDamage(I.force, 0, I, user)
			add_logs(user, (pilot ? pilot : 0), "attacked a space pod", 1, I, " (REMHP: [health])")
			user.changeNext_move(8)

		update_icon()

	emag_act(mob/user)
		if(emagged)
			return 0
		sparks.start()
		to_chat(user,"<span class='notice'>You emag \the [src].</span>")
		emagged = 1

	return_air()
		if(toggles & P_TOGGLE_ENVAIR)
			return loc.return_air()
		if(internal_air)
			return internal_air
		else	..()

	remove_air(var/amt)
		if(toggles & P_TOGGLE_ENVAIR)
			var/datum/gas_mixture/env = loc.return_air()
			return env.remove(amt)
		if(internal_air)
			return internal_air.remove(amt)
		else return ..()

	return_temperature()
		if(toggles & P_TOGGLE_ENVAIR)
			var/datum/gas_mixture/env = loc.return_air()
			return env.return_temperature()
		if(internal_air)
			return internal_air.return_temperature()
		else return ..()

	proc/return_pressure()
		if(toggles & P_TOGGLE_ENVAIR)
			var/datum/gas_mixture/env = loc.return_air()
			return env.return_pressure()
		if(internal_air)
			return internal_air.return_pressure()
		else return ..()

	proc/OnClick(var/atom/A, var/mob/M, var/list/modifiers = list())
		var/click_type = GetClickTypeFromList(modifiers)

		if(click_type == P_ATTACHMENT_KEYBIND_SHIFT)
			A.examine()

		if(click_type == P_ATTACHMENT_KEYBIND_CTRL)
			if(istype(A, /obj/machinery/portable_atmospherics/canister) && A in bounds(1))
				var/obj/machinery/portable_atmospherics/canister/canister = A
				if(internal_canister)
					to_chat(M,"<span class='notice'>There already is a gas canister installed.</span>")
					return 0
				to_chat(M,"<span class='info'>\The [src] starts to load \the [canister].</span>")
				sleep(30)
				if(src && (canister in bounds(1)) && !internal_canister)
					canister.loc = src
					internal_canister = canister
					to_chat(M,"<span class='info'>\The [src] loaded \the [canister].</span>")

		if(!pilot || M != pilot)
			return 0

		for(var/obj/item/pod_attachment/attachment in attachments)
			if(attachment.keybind)
				if(attachment.keybind == click_type)
					attachment.Use(A, M)

		M.changeNext_move(3)
	CollidedWith(var/atom/movable/AM)
		if(istype(AM, /obj/effect/particle_effect/water))
			if(HasDamageFlag(P_DAMAGE_FIRE))
				RemoveDamageFlag(P_DAMAGE_FIRE)
				PrintSystemNotice("Fire extinguished.")
		..()

	CtrlShiftClick(var/mob/user)
		if(!check_rights(R_ADMIN))
			return ..()

		if(user.client)
			user.client.debug_variables(pod_log)

		OpenDebugMenu(user)
