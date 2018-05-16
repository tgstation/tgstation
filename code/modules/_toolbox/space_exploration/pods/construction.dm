/obj/item/storage/box/pod_frame_left
	name = "left pod frame box"
	icon = 'icons/oldschool/spacepods/pod_attachments.dmi'
	icon_state = "attachment_default"
	foldable = /obj/item/pod_construction_part/parts/frames/left
	can_hold = list()
	var/list/construction_cost = list("metal" = 2000)
	var/construction_time = 100

	show_to()
		return 0

	handle_item_insertion()
		return 0

/obj/item/storage/box/pod_frame_right
	name = "right pod frame box"
	icon = 'icons/oldschool/spacepods/pod_attachments.dmi'
	icon_state = "attachment_default"
	foldable = /obj/item/pod_construction_part/parts/frames/right
	can_hold = list()
	var/list/construction_cost = list("metal" = 2000)
	var/construction_time = 100

	show_to()
		return 0

	handle_item_insertion()
		return 0

// NOTE(drache): Redo this. Such a mess.
/obj/item/pod_construction_part
	name = "pod construction part"
	icon = 'icons/oldschool/spacepods/pod-2-2.dmi'
	icon_state = "pod_frame"

	proc/GetRequiredToolUsage(var/obj/item/pod_construction_part/frame/frame)
		if(frame.CSHasFlag(P_CS_ACTION_WIRECUT))
			return P_CS_ACTION_WIRECUT
		else if(frame.CSHasFlag(P_CS_ACTION_WELD))
			return P_CS_ACTION_WELD
		else if(frame.CSHasFlag(P_CS_ACTION_WRENCH))
			return P_CS_ACTION_WRENCH
		else if(frame.CSHasFlag(P_CS_ACTION_SCREW))
			return P_CS_ACTION_SCREW
		else if(frame.CSHasFlag(P_CS_ACTION_MULTI))
			return P_CS_ACTION_MULTI
		return 0

	// Convert stage bitflag to text for player output
	proc/BF2Text(var/bf)
		switch(bf)
			if(P_CS_FRAME_WELDED)
				return "a welded frame"
			if(P_CS_CIRCUITS)
				return "circuits"
			if(P_CS_WIRES)
				return "wires"
			if(P_CS_CONTROL)
				return "a control unit"
			if(P_CS_ENGINE)
				return "an engine"
			if(P_CS_COVERS)
				return "engine covers"
			if(P_CS_ACTION_WIRECUT)
				return "wirecut"
			if(P_CS_ACTION_WELD)
				return "weld"
			if(P_CS_ACTION_WRENCH)
				return "wrench"
			if(P_CS_ACTION_SCREW)
				return "screw"
			if(P_CS_ACTION_MULTI)
				return "multitool"
			if(P_CS_CELL)
				return "powercell"

	// The frame is what the parts will attach to.
	frame/
		name = "pod frame"
		density = 1
		bound_height = 64
		bound_width = 64
		w_class = INFINITY
		var/engine_type = 0
		var/cell_type = 0

		pickup()
			return 0

		attack_hand()
			return 0

		var/construction_stage = P_CS_FRAME_WELDED

		proc/CSHasFlag(var/bf)
			return construction_stage & bf

		proc/CSAddFlag(var/bf)
			construction_stage |= bf

		proc/CSRemoveFlag(var/bf)
			construction_stage &= ~bf

		proc/PlayToolSound(var/bf)
			switch(bf)
				if(P_CS_ACTION_WIRECUT)
					playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 100, 0, 0)
				if(P_CS_ACTION_WELD)
					playsound(get_turf(src), pick('sound/items/Welder.ogg', 'sound/items/Welder2.ogg'), 100, 0, 0)
				if(P_CS_ACTION_WRENCH)
					playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 0, 0)
				if(P_CS_ACTION_SCREW)
					playsound(get_turf(src), pick('sound/items/Screwdriver.ogg', 'sound/items/Screwdriver2.ogg'), 100, 0, 0)
				if(P_CS_ACTION_MULTI)
					return 0

		update_icon()
			if(CSHasFlag(P_CS_CIRCUITS))
				overlays += image(icon = icon, icon_state = "pod_circuits")

			if(CSHasFlag(P_CS_ENGINE))
				overlays += image(icon = icon, icon_state = "pod_engine")

			if(CSHasFlag(P_CS_WIRES))
				overlays += image(icon = icon, icon_state = "pod_wires")

			if(CSHasFlag(P_CS_COVERS))
				overlays += image(icon = icon, icon_state = "pod_covers")

			if(CSHasFlag(P_CS_CONTROL))
				overlays += image(icon = icon, icon_state = "pod_control")

		examine()
			to_chat(usr,"\blue Attached are:")
			if(CSHasFlag(P_CS_CIRCUITS))
				to_chat(usr,"\blue * Circuits")

			if(CSHasFlag(P_CS_ENGINE))
				to_chat(usr,"\blue * Engine")

			if(CSHasFlag(P_CS_WIRES))
				to_chat(usr,"\blue * Wires")

			if(CSHasFlag(P_CS_COVERS))
				to_chat(usr,"\blue * Covers")

			if(CSHasFlag(P_CS_CONTROL))
				to_chat(usr,"\blue * Control")

			if(CSHasFlag(P_CS_CELL))
				to_chat(usr,"\blue * Cell.")

		attackby(var/obj/item/I, var/mob/living/user)
			var/requires_tool = GetRequiredToolUsage(src)
			if(!requires_tool)
				..()
			else
				var/required_tool
				switch(requires_tool)
					if(P_CS_ACTION_WIRECUT)
						required_tool = /obj/item/wirecutters
					if(P_CS_ACTION_WELD)
						required_tool = /obj/item/weldingtool
					if(P_CS_ACTION_WRENCH)
						required_tool = /obj/item/wrench
					if(P_CS_ACTION_SCREW)
						required_tool = /obj/item/screwdriver
					if(P_CS_ACTION_MULTI)
						required_tool = /obj/item/device/multitool
				if(istype(I, required_tool))
					CSRemoveFlag(requires_tool)
					if(requires_tool == P_CS_ACTION_MULTI)
						to_chat(user,"<span class='info'>You use the multitool on the [src].</span>")
					else if(required_tool == P_CS_ACTION_WELD)
						var/obj/item/weldingtool/welder = I
						if(!welder.isOn())
							return 0
						if(!welder.use(1))
							return 0
					else
						to_chat(user,"<span class='info'>You [BF2Text(requires_tool)] the [src].</span>")
					PlayToolSound(requires_tool)

			// Special behavior for engines.
			if(istype(I, /obj/item/pod_attachment/engine))
				if(CSHasFlag(P_CS_CIRCUITS) && !CSHasFlag(!P_CS_ENGINE) && GetRequiredToolUsage(src) == 0)
					to_chat(user,"<span class='info'>You start attaching the [I] to the [src].</span>")
					if(do_after(user, 20,target = src))
						to_chat(user,"<span class='info'>You attached the [I] to the [src].</span>")
						CSAddFlag(P_CS_ACTION_WRENCH)
						CSAddFlag(P_CS_ENGINE)
						playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 100, 0, 0)
						engine_type = I.type
						update_icon()
						qdel(I)

			else if(istype(I, /obj/item/stack/cable_coil))
				if(CSHasFlag(P_CS_ENGINE) && !CSHasFlag(P_CS_WIRES) && GetRequiredToolUsage(src) == 0)
					to_chat(user,"<span class='info'>You start attaching the [I] to the [src].</span>")
					if(do_after(user, 20,target = src))
						to_chat(user,"<span class='info'>You attached the [I] to the [src].</span>")
						CSAddFlag(P_CS_ACTION_WIRECUT)
						CSAddFlag(P_CS_WIRES)
						playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 100, 0, 0)
						update_icon()
						var/obj/item/stack/cable_coil/C = I
						C.use(1)

			else if(istype(I, /obj/item/stock_parts/cell))
				if(CSHasFlag(P_CS_CONTROL) && !CSHasFlag(P_CS_CELL) && GetRequiredToolUsage(src) == 0)
					to_chat(user,"<span class='info'>You start attaching the [I] to the [src].</span>")
					if(do_after(user, 20,target = src))
						to_chat(user,"<span class='info'>You attached the [I] to the [src].</span>")
						CSAddFlag(P_CS_ACTION_SCREW)
						CSAddFlag(P_CS_CELL)
						playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 100, 0, 0)
						cell_type = I.type
						update_icon()
						qdel(I)

	parts/
		icon = 'icons/oldschool/spacepods/pod_attachments.dmi'
		icon_state = "attachment_default"
		w_class = 4

		var/required_construction_stage = 0
		var/added_construction_stage = 0
		var/required_action = 0 // What tool (if any) you need to use after attaching (bitflag)
		var/attach_delay = 20
		var/list/construction_cost = list("metal" = 2000)
		var/construction_time = 100

		proc/CanAttach(var/obj/item/pod_construction_part/frame/frame)
			if(!required_construction_stage)
				return 0
			var/has_required = frame.CSHasFlag(required_construction_stage)
			var/already_has_part = frame.CSHasFlag(added_construction_stage)
			var/has_used_tool = GetRequiredToolUsage(frame) == 0

			var/can_attach = (has_required && !already_has_part && has_used_tool)
			if(!can_attach)
				if(!has_required)
					return P_C_ERROR_REQUIRES
				else if(already_has_part)
					return P_C_ERROR_ALREADY_HAS
				else if(!has_used_tool)
					return P_C_ERROR_NEEDS_TOOL

			return 0

		afterattack(var/atom/target, var/mob/user, var/proximity_flag)
			if(!proximity_flag)
				return 0

			if(istype(target, /obj/item/pod_construction_part/frame))
				var/obj/item/pod_construction_part/frame/frame = target
				FrameAction(frame, user)

				return 0

			..()

		proc/FrameAction(var/obj/item/pod_construction_part/frame/frame, var/mob/user)
			var/result = CanAttach(frame)
			if(result == 0)
				to_chat(user,"<span class='info'>You start attaching the [src] to the [frame].</span>")
				if(do_after(user, attach_delay,target = src))
					if(istype(src, /obj/item/pod_construction_part/parts/armor))
						var/obj/item/pod_construction_part/parts/armor/A = src
						spawn(-1)
							A.CreatePod(get_turf(frame), frame)
						qdel(frame)
						qdel(src)
						return 0

					to_chat(user,"<span class='info'>You attached the [src] to the [frame].</span>")
					frame.CSAddFlag(added_construction_stage)
					frame.CSAddFlag(required_action)
					frame.update_icon()
					playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 100, 0, 0)
					qdel(src)
			else
				if(result == P_C_ERROR_REQUIRES)
					to_chat(user,"<span class='info'>The [src] requires [BF2Text(required_construction_stage)].</span>")
				else if(result == P_C_ERROR_ALREADY_HAS)
					to_chat(user,"<span class='info'>The frame already has that part.")
				else if(result == P_C_ERROR_NEEDS_TOOL)
					var/required_tool = GetRequiredToolUsage(frame)
					if(required_tool == P_CS_ACTION_MULTI)
						to_chat(user,"<span class='warning'>You need to use a multitool on the frame.</span>")
					else
						to_chat(user,"<span class='warning'>You need to [BF2Text(required_tool)] the frame.</span>")

		frames/
			name = "pod frame part"
			icon = 'icons/oldschool/spacepods/pod-2-2.dmi'
			icon_state = "pod_frame2"
			density = 0
			bound_height = 64
			w_class = INFINITY
			//origin_tech = "materials=1"
			flags_1 = ABSTRACT_1

			attackby(var/obj/item/I, var/mob/living/user)
				if(istype(I, /obj/item/weldingtool))
					var/obj/item/pod_construction_part/parts/frames/left/left_frame = locate() in range(1, get_turf(src))
					var/obj/item/pod_construction_part/parts/frames/right/right_frame = locate() in range(1, get_turf(src))
					if(!left_frame || !right_frame)
						return 0

					if(left_frame.dir != right_frame.dir)
						return 0

					var/obj/item/weldingtool/W = I
					if(W.isOn())
						var/obj/item/pod_construction_part/frame/F = new(get_turf(left_frame))
						F.dir = left_frame.dir
						qdel(left_frame)
						qdel(right_frame)

						F.PlayToolSound(P_CS_ACTION_WELD)

						to_chat(user,"<span class='info'>You weld the frames together.</span>")

			pickup()
				return 0

			attack_hand()
				return 0

			CanAttach()
				return 0

			left/
				name = "left pod frame"
				icon_state = "pod_frame2"

			right/
				name = "right pod frame"
				icon_state = "pod_frame1"

		circuits/
			name = "pod circuits"
			added_construction_stage = P_CS_CIRCUITS
			required_construction_stage = P_CS_FRAME_WELDED
			required_action = P_CS_ACTION_SCREW
			construction_cost = list("metal" = 2000)
			//origin_tech = "materials=1"

		covers/
			name = "pod covers"
			added_construction_stage = P_CS_COVERS
			required_construction_stage = P_CS_WIRES
			required_action = P_CS_ACTION_WELD
			construction_cost = list("metal" = 4000)
			//origin_tech = "materials=1"

		control/
			name = "pod control"
			added_construction_stage = P_CS_CONTROL
			required_construction_stage = P_CS_COVERS
			required_action = P_CS_ACTION_MULTI
			construction_cost = list("metal" = 4000)
			//origin_tech = "materials=1"

		armor/
			name = "pod armor"
			required_construction_stage = P_CS_CELL
			var/pod_type = /obj/pod/large

			proc/CreatePod(var/turf/location, var/obj/item/pod_construction_part/frame/F)
				var/obj/pod/pod = new pod_type(location)
				if(pod.GetAttachmentOnHardpoint(P_HARDPOINT_ENGINE))
					qdel(pod.GetAttachmentOnHardpoint(P_HARDPOINT_ENGINE))
				var/obj/item/pod_attachment/engine/E = new F.engine_type(pod)
				E.OnAttach(pod)

				var/obj/item/stock_parts/cell/cell = new F.cell_type(pod)
				pod.power_source = cell

			light/
				name = "light pod armor"
				pod_type = /obj/pod/large/light
				construction_cost = list("metal" = 16000)
				//origin_tech = "engineering=1;materials=1"

			heavy/
				name = "heavy pod armor"
				pod_type = /obj/pod/large/heavy
				construction_cost = list("metal" = 16000, "uranium" = 12000)
				//origin_tech = "engineering=4;materials=4;combat=3"

			gold/
				name = "gold pod armor"
				pod_type = /obj/pod/large/gold
				construction_cost = list("metal" = 16000, "gold" = 8000)
				//origin_tech = "engineering=2;materials=2"

			industrial/
				name = "industrial pod armor"
				pod_type = /obj/pod/large/industrial
				construction_cost = list("metal" = 16000, "uranium" = 8000)
				//origin_tech = "engineering=5;materials=5"

			prototype/
				name = "prototype pod armor"
				pod_type = /obj/pod/large/prototype
				construction_cost = list("metal" = 16000, "uranium" = 12000, "diamond" = 6000, "silver" = 6000)
				//origin_tech = "engineering=6;materials=6;illegal=2"

			precursor/
				name = "precursor pod armor"
				pod_type = /obj/pod/large/precursor
				construction_cost = list("metal" = 16000, "uranium" = 12000, "diamond" = 10000, "silver" = 8000)
				//origin_tech = "engineering=6;materials=7;illegal=3"

#undef P_CS_FRAME_WELDED
#undef P_CS_CIRCUITS
#undef P_CS_WIRES
#undef P_CS_CONTROL
#undef P_CS_ENGINE
#undef P_CS_COVERS
#undef P_CS_ACTION_WIRECUT
#undef P_CS_ACTION_WELD
#undef P_CS_ACTION_WRENCH
#undef P_CS_ACTION_SCREW
#undef P_CS_ACTION_MULTI
#undef P_C_ERROR_REQUIRES
#undef P_C_ERROR_ALREADY_HAS
#undef P_C_ERROR_NEEDS_TOOL
#undef P_CS_CELL

/obj/item/book/manual/podmanual
	name = "Pod construction guide"
	icon_state ="bookEngineering"
	author = "Pody Mcpodface"
	title = "Pod Construction Guide"
	dat = {"
		<html>
		<head>
		<title>Page Title</title>
		</head>
		<body>

		<B><font size='4'>This is a guide on how to construct a space pod from scratch.</font></B><BR><BR>

		<B>You will need the following parts from the Pod Fabricator:</B><BR>
		left frame<BR>
		right frame<BR>
		pod circuit module<BR>
		pod control module<BR>
		pod covers module<BR>
		pod armor module(any)<BR>
		pod engine module(any)<BR>
		Power cell(any)<BR><BR>

		<B>Construction</B><BR>
		Follow these steps once you have all the parts ready.<BR><BR>
		<B>Step 1:</B> Hold either the left or right frame modules in your hand and click it in your hand to unpackage it on to the floor below your feet. Do this for both the left and right

		frames.<BR>
		<B>Step 2:</B> Make sure both frames are arranged together to form the correct shape.<BR>
		<B>Step 3:</B> Use a welding tool to secure the frames together in to one piece.<BR>
		<B>Step 4:</B> Attach the pod circuit module to the frame.<BR>
		<B>Step 5:</B> Use a screwdriver on the frame to secure the circuits in place.<BR>
		<B>Step 6:</B> Attach the engine module to the frame.<BR>
		<B>Step 7:</B> Use a wrench on the frame to bolt the engine in place.<BR>
		<B>Step 8:</B> Add wires to the frame.<BR>
		<B>Step 9:</B> Use wirecutters on the frame to connect the wires together.<BR>
		<B>Step 10:</B> Attach pod covers to the frame.<BR>
		<B>Step 11:</B> Use a welding tool on the frame to secure the pod covers.<BR>
		<B>Step 12:</B> Attach the pod control module to the frame.<BR>
		<B>Step 13:</B> Use a multitool on the frame to configure the control module.<BR>
		<B>Step 14:</B> Attach the power cell to the frame.<BR>
		<B>Step 15:</B> Use a screwdriver on the frame to secure it the power cell.<BR>
		<B>Step 16:</B> Attach pod armor to the frame.<BR>
		<BR>
		Your space pod is now complete! You can now begin adding upgrades to your pod.

		</body>
		</html>
		"}