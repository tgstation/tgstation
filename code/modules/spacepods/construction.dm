/obj/structure/spacepod_frame
	density = 1
	opacity = 0

	anchored = 1
	layer = SPACEPOD_LAYER

	name = "\improper spacepod frame"
	desc = "An unwired pod frame."

	icon = 'goon/icons/48x48/pod_construction.dmi'
	icon_state = "pod_1"

	var/datum/construction/construct

/obj/structure/spacepod_frame/Initialize()
	. = ..()
	bound_width = 64
	bound_height = 64

	construct = new /datum/construction/reversible2/pod(src)

	setDir(EAST)
	desc = "An unwired pod frame."

/obj/structure/spacepod_frame/Destroy()
	. = ..()
	QDEL_NULL(construct)

/obj/structure/spacepod_frame/attackby(obj/item/W as obj, mob/user as mob, params)
	if(!construct || !construct.action(W, user))
		..()
	return

/obj/structure/spacepod_frame/attack_hand()
	return



/////////////////////////////////
//     CONSTRUCTION STEPS     ///
/////////////////////////////////

/datum/construction/reversible2/pod/spawn_result()
	if(result)
		var/obj/spacepod/A = new result(get_turf(holder), pod_armor)
		A.bound_width = 64
		A.bound_height = 64
		A.armor_multiplier_applied = TRUE
		A.max_integrity *= pod_armor.armor_multiplier
		A.obj_integrity *= pod_armor.armor_multiplier
		qdel(holder)
		qdel(src)
	return


/datum/construction/reversible2/pod
	result = /obj/spacepod
	base_icon="pod"
	var/datum/pod_armor/pod_armor
	//taskpath = /datum/job_objective/make_pod
	steps = list(
				// 1. Initial state
				list(
					"desc" = "An unwired pod frame.",
					STATE_NEXT = list(
						"key"      = /obj/item/stack/cable_coil,
						"vis_msg"  = "{USER} wires the {HOLDER}.",
						"self_msg" = "You wire the {HOLDER}."
					)
				),
				// 2. Crudely Wired
				list(
					"desc" = "A crudely-wired pod frame.",
					STATE_PREV = list(
						"key"      = /obj/item/wirecutters,
						"vis_msg"  = "{USER} cuts out the {HOLDER}'s wiring.",
						"self_msg" = "You remove the {HOLDER}'s wiring."
					),
					STATE_NEXT = list(
						"key"      = /obj/item/screwdriver,
						"vis_msg"  = "{USER} adjusts the wiring.",
						"self_msg" = "You adjust the {HOLDER}'s wiring."
					)
				),
				// 3. Cleanly wired
				list(
					"desc" = "A wired pod frame, without a mainboard.",
					STATE_PREV = list(
						"key"      = /obj/item/screwdriver,
						"vis_msg"  = "{USER} unclips {HOLDER}'s wiring harnesses.",
						"self_msg" = "You unclip {HOLDER}'s wiring harnesses."
					),
					STATE_NEXT = list(
						"key"      = /obj/item/circuitboard/mecha/pod,
						"vis_msg"  = "{USER} inserts the mainboard into the {HOLDER}.",
						"self_msg" = "You insert the mainboard into the {HOLDER}.",
						"delete"   = 1
					)
				),
				// 4. Circuit added
				list(
					"desc" = "A wired pod frame with a loose mainboard.",
					STATE_PREV = list(
						"key"      = /obj/item/crowbar,
						"vis_msg"  = "{USER} pries out the mainboard.",
						"self_msg" = "You pry out the mainboard.",

						"spawn"    = /obj/item/circuitboard/mecha/pod,
						"amount"   = 1
					),
					STATE_NEXT = list(
						"key"      = /obj/item/screwdriver,
						"vis_msg"  = "{USER} secures the mainboard.",
						"self_msg" = "You secure the mainboard."
					)
				),
				// 5. Circuit secured
				list(
					"desc" = "A wired pod frame with a secured mainboard. It is missing a pod core.",
					STATE_PREV = list(
						"key"      = /obj/item/screwdriver,
						"vis_msg"  = "{USER} unsecures the mainboard.",
						"self_msg" = "You unscrew the mainboard from the {HOLDER}."
					),
					STATE_NEXT = list(
						"key"      = /obj/item/pod_parts/core,
						,
						"vis_msg"  = "{USER} inserts the core into the {HOLDER}.",
						"self_msg" = "You carefully insert the core into the {HOLDER}.",
						"delete"   = 1
					)
				),
				// 6. Core inserted
				list(
					"desc" = "A naked space pod with a loose core.",
					STATE_PREV = list(
						"key"      = /obj/item/crowbar,
						"vis_msg"  = "{USER} delicately removes the core from the {HOLDER} with a crowbar.",
						"self_msg" = "You delicately remove the core from the {HOLDER} with a crowbar.",

						"spawn"    = /obj/item/pod_parts/core,
						"amount"   = 1
					),
					STATE_NEXT = list(
						"key"      = /obj/item/wrench,
						"vis_msg"  = "{USER} secures the core's bolts.",
						"self_msg" = "You secure the core's bolts."
					)
				),
				// 7. Core secured
				list(
					"desc" = "A naked space pod with an exposed core, without a metal bulkhead. How lewd.",
					STATE_PREV = list(
						"key"      = /obj/item/wrench,
						"vis_msg"  = "{USER} unsecures the {HOLDER}'s core.",
						"self_msg" = "You unsecure the {HOLDER}'s core."
					),
					STATE_NEXT = list(
						"key"      = /obj/item/stack/sheet/metal,
						"amount"   = 5,
						"vis_msg"  = "{USER} fabricates a pressure bulkhead for the {HOLDER}.",
						"self_msg" = "You frabricate a pressure bulkhead for the {HOLDER}."
					)
				),
				// 8. Bulkhead added
				list(
					"desc" = "A space pod with loose bulkhead panelling exposed.",
					STATE_PREV = list(
						"key"      = /obj/item/crowbar,
						"vis_msg"  = "{USER} pops the {HOLDER}'s bulkhead panelling loose.",
						"self_msg" = "You pop the {HOLDER}'s bulkhead panelling loose.",

						"spawn"    = /obj/item/stack/sheet/metal,
						"amount"   = 5,
					),
					STATE_NEXT = list(
						"key"      = /obj/item/wrench,
						"vis_msg"  = "{USER} secures the {HOLDER}'s bulkhead panelling.",
						"self_msg" = "You secure the {HOLDER}'s bulkhead panelling."
					)
				),
				// 9. Bulkhead secured with bolts
				list(
					"desc" = "A space pod with unwelded bulkhead panelling exposed.",
					STATE_PREV = list(
						"key"      = /obj/item/wrench,
						"vis_msg"  = "{USER} unbolts the {HOLDER}'s bulkhead panelling.",
						"self_msg" = "You unbolt the {HOLDER}'s bulkhead panelling."
					),
					STATE_NEXT = list(
						"key"      = /obj/item/weldingtool,
						"vis_msg"  = "{USER} seals the {HOLDER}'s bulkhead panelling with a weld.",
						"self_msg" = "You seal the {HOLDER}'s bulkhead panelling with a weld."
					)
				),
				// 10. Welded bulkhead
				list(
					"desc" = "A space pod with sealed bulkhead panelling exposed... It needs the armor now.",
					STATE_PREV = list(
						"key"      = /obj/item/weldingtool,
						"vis_msg"  = "{USER} cuts the {HOLDER}'s bulkhead panelling loose.",
						"self_msg" = "You cut the {HOLDER}'s bulkhead panelling loose."
					),
					STATE_NEXT = list(
						"key"      = /obj/item/pod_parts/armor,
						"vis_msg"  = "{USER} installs the {HOLDER}'s armor plating.",
						"self_msg" = "You install the {HOLDER}'s armor plating.",
						"delete"   = 1
					)
				),
				// 11. Loose armor
				list(
					"desc" = "A space pod with unsecured armor.",
					STATE_PREV = list(
						"key"      = /obj/item/crowbar,
						"vis_msg"  = "{USER} pries off {HOLDER}'s armor.",
						"self_msg" = "You pry off {HOLDER}'s armor.",
						"spawn"    = /obj/item/pod_parts/armor,
						"amount"   = 1
					),
					STATE_NEXT = list(
						"key"      = /obj/item/wrench,
						"vis_msg"  = "{USER} bolts down the {HOLDER}'s armor.",
						"self_msg" = "You bolt down the {HOLDER}'s armor."
					)
				),
				// 12. Bolted-down armor
				list(
					"desc" = "A space pod with unwelded armor.",
					STATE_PREV = list(
						"key"      = /obj/item/wrench,
						"vis_msg"  = "{USER} unsecures the {HOLDER}'s armor.",
						"self_msg" = "You unsecure the {HOLDER}'s armor."
					),
					STATE_NEXT = list(
						"key"      = /obj/item/weldingtool,
						"vis_msg"  = "{USER} welds the {HOLDER}'s armor.",
						"self_msg" = "You weld the {HOLDER}'s armor."
					)
				)
				// EOF
			)

	spawn_result(mob/user as mob)
		..()
		SSblackbox.add_details("spacepod_created",1)
		return

/datum/construction/reversible2/pod/custom_action(index, diff, used_atom, var/mob/user)
	if(index == 10 && istype(used_atom, /obj/item/pod_parts/armor))
		var/obj/item/pod_parts/armor/A = used_atom
		pod_armor = A.armor_type
	. = ..()

/obj/item/circuitboard/mecha/pod
	name = "spacepod circuit board"