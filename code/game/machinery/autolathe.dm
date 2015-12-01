#define AUTOLATHE_BUILD_TIME	0.5
#define AUTOLATHE_MAX_TIME		50 //5 seconds max, * time_coeff

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe
	name = "\improper Autolathe"
	desc = "Produces a large range of common items using metal and glass."
	icon_state = "autolathe"
	icon_state_open = "autolathe_t"
	nano_file = "autolathe.tmpl"
	density = 1

	design_types = list()

	start_end_anims = 1

	use_power = 1
	idle_power_usage = 50
	active_power_usage = 500

	build_time = AUTOLATHE_BUILD_TIME

	removable_designs = 0
	plastic_added = 0

	allowed_materials = list(
						MAT_IRON,
						MAT_GLASS
	)

	machine_flags = SCREWTOGGLE | CROWDESTROY | EMAGGABLE | WRENCHMOVE | FIXED2WORK

	research_flags = NANOTOUCH | TAKESMATIN | HASOUTPUT | IGNORE_CHEMS | HASMAT_OVER

	light_color = LIGHT_COLOR_CYAN

	part_sets = list(
		"Tools"=list(
		new /obj/item/device/multitool(), \
		new /obj/item/weapon/weldingtool/empty(), \
		new /obj/item/weapon/crowbar(), \
		new /obj/item/weapon/screwdriver(), \
		new /obj/item/weapon/wirecutters(), \
		new /obj/item/weapon/wrench(), \
		new /obj/item/weapon/solder(),\
		new /obj/item/device/analyzer(), \
		new /obj/item/device/t_scanner(), \
		new /obj/item/weapon/pickaxe/shovel/spade(), \
		new /obj/item/device/silicate_sprayer/empty(), \
		),
		"Containers"=list(
		new /obj/item/weapon/reagent_containers/glass/beaker(), \
		new /obj/item/weapon/reagent_containers/glass/beaker/large(), \
		new /obj/item/weapon/reagent_containers/glass/bucket(), \
		new /obj/item/weapon/reagent_containers/glass/beaker/vial(), \
		new /obj/item/weapon/reagent_containers/food/drinks/mug(), \
		),
		"Assemblies"=list(
		new /obj/item/device/assembly/igniter(), \
		new /obj/item/device/assembly/signaler(), \
		/*new /obj/item/device/assembly/infra(), \*/
		new /obj/item/device/assembly/timer(), \
		new /obj/item/device/assembly/voice(), \
		new /obj/item/device/assembly/prox_sensor(), \
		new /obj/item/device/assembly/speaker(), \
		),
		"Stock_Parts"=list(
		new /obj/item/weapon/stock_parts/console_screen(), \
		new /obj/item/weapon/stock_parts/capacitor(), \
		new /obj/item/weapon/stock_parts/scanning_module(), \
		new /obj/item/weapon/stock_parts/manipulator(), \
		new /obj/item/weapon/stock_parts/micro_laser(), \
		new /obj/item/weapon/stock_parts/matter_bin(), \
		),
		"Medical"=list(
		new /obj/item/weapon/storage/pill_bottle(),\
		new /obj/item/weapon/reagent_containers/syringe(), \
		new /obj/item/weapon/scalpel(), \
		new /obj/item/weapon/circular_saw(), \
		new /obj/item/weapon/surgicaldrill(),\
		new /obj/item/weapon/retractor(),\
		new /obj/item/weapon/cautery(),\
		new /obj/item/weapon/hemostat(),\
		),
		"Ammunition"=list(
		new /obj/item/ammo_casing/shotgun/blank(), \
		new /obj/item/ammo_casing/shotgun/beanbag(), \
		new /obj/item/ammo_casing/shotgun/flare(), \
		new /obj/item/ammo_storage/speedloader/c38/empty(), \
		new /obj/item/ammo_storage/box/c38(), \
		),
		"Misc_Tools"=list(
		new /obj/item/device/flashlight(), \
		new /obj/item/weapon/extinguisher(), \
		new /obj/item/device/radio/headset(), \
		new /obj/item/device/radio/off(), \
		new /obj/item/weapon/kitchen/utensil/knife/large(), \
		new /obj/item/clothing/head/welding(), \
		new /obj/item/device/taperecorder(), \
		new /obj/item/weapon/chisel(), \
		new /obj/item/device/rcd/tile_painter(), \
		),
		"Misc_Other"=list(
		new /obj/item/weapon/rcd_ammo(), \
		new /obj/item/weapon/light/tube(), \
		new /obj/item/weapon/light/bulb(), \
		new /obj/item/ashtray/glass(), \
		new /obj/item/weapon/storage/pill_bottle/dice(),\
		new /obj/item/weapon/camera_assembly(), \
		new /obj/item/stack/sheet/glass/rglass(), \
		new /obj/item/stack/rods(), \
		),
		"Hidden_Items" = list(
		new /obj/item/weapon/flamethrower/full(), \
		new /obj/item/ammo_storage/box/flare(), \
		new /obj/item/device/rcd/matter/engineering(), \
		new /obj/item/device/rcd/rpd(),\
		new /obj/item/device/rcd/matter/rsf(), \
		new /obj/item/device/radio/electropack(), \
		new /obj/item/weapon/weldingtool/largetank/empty(), \
		new /obj/item/weapon/handcuffs(), \
		new /obj/item/ammo_storage/box/a357(), \
		new /obj/item/ammo_casing/shotgun(), \
		new /obj/item/ammo_casing/shotgun/dart(), \
		)
	)

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/autolathe,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/get_construction_time_w_coeff(datum/design/part)
	return min(..(), (AUTOLATHE_MAX_TIME * time_coeff)) //we have set designs, so we can make them quickly

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/is_contraband(var/datum/design/part)
	if(part in part_sets["Hidden_Items"])
		return 1

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/update_hacked()
	if(screen == 51) screen = 11 //take the autolathe away from the contraband menu, since otherwise it can still print contraband until another category is selected
	/*if(hacked)
		part_sets["Items"] |= part_sets["Hidden Items"]
	else
		part_sets["Items"] -= part_sets["Hidden Items"]*/

/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/attackby(obj/item/I, mob/user)
	if(..())
		return 1

	else if(I.materials)
		if(I.materials.getVolume() + src.materials.getVolume() > max_material_storage)
			to_chat(user, "\The [src]'s material bin is too full to recycle \the [I].")
			return 1
		else if(I.materials.getAmount(MAT_IRON) + I.materials.getAmount(MAT_GLASS) < I.materials.getVolume())
			to_chat(user, "\The [src] can only accept objects made out of metal and glass.")
			return 1
		else if(isrobot(user))
			if(isMoMMI(user))
				var/mob/living/silicon/robot/mommi/M = user
				if(M.is_in_modules(I))
					to_chat(user, "You cannot recycle your built in tools.")
					return 1
			else
				to_chat(user, "You cannot recycle your built in tools.")
				return 1
		user.drop_item(I, src)
		materials.removeFrom(I.materials)
		user.visible_message("[user] puts \the [I] into \the [src]'s recycling unit.",
							"You put \the [I] in \the [src]'s reycling unit.")
		qdel(I)
		return 1