
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
	C.storable = list(/obj/item/circuitboard,
			/obj/item/wallframe,
			/obj/item/stock_parts,
			/obj/item/electronics)


/obj/item/borg/upgrade/circuit_app/proc/remove_engiborg_manipulator_upgrade(mob/living/silicon/robot/R, mob/user)

	var/obj/item/borg/apparatus/circuit/C = locate() in R.module.modules
	if(C && C.upgraded) //If upgraded, remove the upgrade
		C.upgraded = FALSE
		C.name = "basic component manipulation apparatus"
		C.storable = list(/obj/item/wallframe,
					/obj/item/electronics)
