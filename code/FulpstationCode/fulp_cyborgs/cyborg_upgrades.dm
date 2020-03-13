GLOBAL_LIST_INIT(basic_engiborg_manipulator_allowed, typecacheof(list(
				/obj/item/wallframe,
				/obj/item/tank,
				/obj/item/electronics)))


/obj/item/borg/upgrade/circuit_app/proc/upgrade_engiborg_manipulator(mob/living/silicon/robot/R, mob/user)

	var/obj/item/borg/apparatus/circuit/C = locate() in R.module.modules
	if(!C)
		to_chat(user, "<span class='warning'>This unit has no [C] to upgrade!</span>")
		return FALSE

	if(C.upgraded) //Delete the basic manipulator if we have it
		to_chat(user, "<span class='warning'>This unit already has an upgraded [C].</span>")
		return FALSE

	C.upgraded = TRUE
	C.name = "advanced component manipulation apparatus"
	C.desc = "A special apparatus for carrying and manipulating engineering components like electronics and wall mounted frames. This has been upgraded to also manipulate circuitboards, assemblies, stock parts, gas tanks and vendor refills. Alt-Z or right-click to drop the stored object."
	C.storable = list(/obj/item/wallframe,
					/obj/item/electronics,
					/obj/item/circuitboard,
					/obj/item/stock_parts,
					/obj/item/assembly,
					/obj/item/tank,
					/obj/item/vending_refill)


/obj/item/borg/upgrade/circuit_app/proc/remove_engiborg_manipulator_upgrade(mob/living/silicon/robot/R, mob/user)

	var/obj/item/borg/apparatus/circuit/C = locate() in R.module.modules
	if(C && C.upgraded) //If upgraded, remove the upgrade
		C.upgraded = FALSE
		C.name = initial(C.name)
		C.desc = initial(C.desc)
		C.storable = list(/obj/item/wallframe,
					/obj/item/tank,
					/obj/item/electronics)
		var/obj/item/stored_item = C.stored
		if(is_type_in_typecache(stored_item, GLOB.basic_engiborg_manipulator_allowed)) //Drop stuff we can no longer hold.
			stored_item.forceMove(get_turf(usr))
