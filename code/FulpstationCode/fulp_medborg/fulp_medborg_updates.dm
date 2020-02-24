/datum/design/borg_upgrade_defibrillator
	name = "Cyborg Upgrade (Heal Beam)"
	id = "borg_upgrade_medbeam"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/medbeam
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 10000, /datum/material/plasma = 4000, /datum/material/uranium = 4000)
	construction_time = 80
	category = list("Cyborg Upgrade Modules")

/obj/item/borg/upgrade/medbeam
	name = "medical cyborg heal beam"
	desc = "An upgrade to the Medical module, installing a built-in \
		healing beam."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = list(/obj/item/robot_module/medical)
	var/backpack = FALSE //True if we get the defib from a physical backpack unit rather than an upgrade card, so that we can return that upon deactivate()

/obj/item/borg/upgrade/heal_beam/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/gun/medbeam/MB = new(R.module)
		R.module.basic_modules += MB
		R.module.add_module(MB, FALSE, TRUE)

/obj/item/borg/upgrade/processor/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/gun/medbeam/MB = locate() in R.module
		R.module.remove_module(MB, TRUE)

/obj/item/gun/medbeam/cyborg
	name = "Integrated Medical Beamgun"
	desc = "Advanced protonic nano-something or other miracle healing beam. Crossing its stream with another is ill-advised."
	var/power_cost = 75

/obj/item/gun/medbeam/cyborg/process_fire(atom/target, mob/living/silicon/robot/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)

	if(user.cell.charge < power_cost) //Check if we have enough power.
		to_chat(user, "<span class='warning'>Power inadequate to initiate beam projection.</span>")
		LoseTarget()
		return
	. = ..()

/obj/item/gun/medbeam/cyborg/on_beam_tick(var/mob/living/target, mob/living/silicon/robot/user)
	if(!user) //Sanity
		LoseTarget()
		return

	if(user.cell.charge < power_cost) //Check if we have enough power.
		to_chat(user, "<span class='warning'>Power inadequate to maintain beam projection.</span>")
		LoseTarget()
		return

	user.cell.charge -= power_cost

	if(target.health != target.maxHealth)
		new /obj/effect/temp_visual/heal(get_turf(target), "#80F5FF")
	target.adjustBruteLoss(-4)
	target.adjustFireLoss(-4)
	target.adjustToxLoss(-1)
	target.adjustOxyLoss(-1)
	return

/obj/item/borg/apparatus/beaker/medical //Medborgs can now manipulate medicines and medicine containers
	name = "medicine storage apparatus"
	desc = "A special apparatus for carrying beakers, medicines and medicine containers without spilling the contents. Alt-Z or right-click to drop its contents."
	storable = list(/obj/item/reagent_containers/glass/beaker,
				/obj/item/reagent_containers/glass/bottle,
				/obj/item/reagent_containers/pill/patch,
				/obj/item/reagent_containers/medigel,
				/obj/item/reagent_containers/pill,
				/obj/item/reagent_containers/chem_pack,
				/obj/item/reagent_containers/blood)

/obj/item/borg/apparatus/beaker/medical/extra
	name = "secondary medicine storage apparatus"
	desc = "A special apparatus for carrying beakers, medicines and medicine containers without spilling the contents. Alt-Z or right-click to drop its contents."

/mob/living/silicon/robot/proc/fulp_borg_unbuckle(mob/living/M) //Allows borgs to unbuckle people via loading them.
	if(!M.buckled)
		return
	if(M.buckled)
		M.buckled.unbuckle_mob(M, force = TRUE)
	if(M.has_buckled_mobs())
		M.unbuckle_all_mobs(force = TRUE)
