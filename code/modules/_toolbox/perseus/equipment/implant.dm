/*
	Commenting this entire page incase it gets turned on -falaskian


#define PERSEUS_HUD		"20"
#define HUD_PERSEUS				23
var/list/perseus_implants = list()

/*/var/const/access_penforcer = 501
/var/const/access_pcommander = 502*/

/proc/check_perseus(mob/M)
	if (M)
		if(!ishuman(M))
			return 0
		for (var/obj/item/implant/I in M.contents)
			if (I && I.imp_in == M && I.loc == I.imp_in && istype(I,/obj/item/implant/enforcer))
				return 1
	return 0

/proc/generate_perc_identifier(var/attempt = 0)
	if(attempt>10)
		return "ERROR"
	var/chosen = "[rand(0,9)][rand(0,9)][rand(0,9)]"
	for(var/obj/item/implant/enforcer/I in perseus_implants)
		if (I.perc_identifier == chosen)
			return generate_perc_identifier(attempt+1)
	return chosen

/obj/item/implant
	var/can_remove = 1
	var/access = list()

/obj/item/implant/GetAccess()
	return access

// *****************
// ENFORCER IMPLANT
// *****************

/obj/item/implant/enforcer
	name = "perseus enforcer implant"
	access = list(ACCESS_PERSEUS_ENFORCER, ACCESS_BRIG,ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_MEDICAL,
	ACCESS_CONSTRUCTION, ACCESS_MAILSORTING, ACCESS_ENGINE, ACCESS_RESEARCH, ACCESS_SECURITY)
	actions_types = list()
	can_remove = 0
	var/list/allied_implants = list(/obj/item/implant/enforcer,/obj/item/implant/commander)
	var/perc_identifier = "ERROR"
	var/datum/action/padrenal/padrenal
	var/datum/action/pdoors/pdoors
	var/critical_condition = 0
	var/datum/mind/owner_mind = null

/obj/item/implant/enforcer/implant(mob/living/target, mob/user, silent = FALSE)
	. = ..()
	if (imp_in == loc && istype(imp_in,/mob/living))
		var/mob/living/mob = imp_in
		if(!owner_mind)
			owner_mind = mob.mind
		clear_implants()
		clear_antag()
		perseus_implants += src
		perseusAlert("PercTech Alert System","New implant connection detected, [mob.name]",1)
		padrenal = new(src)
		padrenal.Grant(mob)
		pdoors = new(src)
		pdoors.Grant(mob)
		/*var/datum/atom_hud/P = GLOB.huds[HUD_PERSEUS]
		if (P)
			P.add_hud_to(imp_in)
			imp_in.update_perseus_hud()*/

/obj/item/implant/enforcer/New()
	..()
	SSobj.processing |= src

/obj/item/implant/enforcer/Destroy()
	if(owner_mind && istype(owner_mind.current,/mob/living/carbon/human))
		var/hasimplant = 0
		for(var/obj/item/implant/enforcer/E in owner_mind.current)
			if(E == src)
				continue
			hasimplant = 1
			break
		if(!hasimplant)
			var/obj/item/implant/I = new type(owner_mind.current)
			I.implant(owner_mind.current)
	qdel(padrenal)
	owner_mind = null
	SSobj.processing -= src
	. = ..()

/obj/item/implant/enforcer/process()
	if(istype(loc,/obj/item/implantcase))
		var/obj/item/implantcase/case = loc
		case.imp = null
		case.update_icon()
		moveToNullspace()
	if(istype(loc,/obj/item/implanter))
		var/obj/item/implanter/imper = loc
		imper.imp = null
		imper.update_icon()
		moveToNullspace()
	if(loc && owner_mind && owner_mind.current != loc && istype(owner_mind.current,/mob/living/carbon/human))
		for(var/obj/item/implant/I in loc)
			for(var/Itype in allied_implants)
				if(istype(I,Itype))
					if(istype(I.loc,/mob/living))
						var/mob/living/L = I.loc
						L.implants -= I
					I.imp_in = null
					I.moveToNullspace()
					if(istype(owner_mind.current,/mob/living/carbon/human))
						I.implant(owner_mind.current)
	clear_implants()
	if(imp_in && imp_in.mind && (imp_in.mind.objectives.len || imp_in.mind.special_role))
		clear_antag()
	if(imp_in && imp_in == loc && istype(imp_in))
		var/mob/living/M = imp_in
		if(M.health > 0 && M.stat != DEAD)
			if(critical_condition > initial(critical_condition))
				critical_condition = 0
				perseusAlert("Lifesigns Monitor","[M.name] is no longer in critical condition.", 3)
		else
			var/do_alert = 0
			if(M.stat == DEAD && critical_condition != 2)
				critical_condition = 2
				do_alert = 1
			else if(M.health <= 0 && critical_condition != 1)
				critical_condition = 1
				do_alert = 1
			if(do_alert)
				var/area/current_area = get_area(M)
				if(current_area)
					perseusAlert("Lifesigns Monitor","[M.name] is [imp_in.stat == 1 ? "in critical condition" : "dead"]! Location: [current_area.name] ([imp_in.x],[imp_in.y],[imp_in.z])", 2)

/obj/item/implant/enforcer/proc/clear_antag()
	if (!imp_in || !imp_in.mind)
		return
	var/changed = 0
	if(istype(imp_in.mind.antag_datums,/list))
		for(var/datum/antagonist/A in imp_in.mind.antag_datums)
			if(!changed)
				changed = 1
			qdel(A)

	if(istype(imp_in.mind.objectives,/list) && imp_in.mind.objectives.len)
		for(var/datum/objective/O in imp_in.mind.objectives)
			if(!changed)
				changed = 1
			imp_in.mind.objectives -= O
			qdel(O)
	imp_in.mind.special_role = ""
	if(changed)
		imp_in.mind.memory = ""
		to_chat(imp_in, "<span class='userdanger'>You remember nothing.</span>")
		to_chat(imp_in, "<span class='notice'>Your memories have been wiped clean. If you were previously an antagonist, you no longer are.</span>")
		to_chat(imp_in, "<span class='notice'>You are now a Perseus Enforcer. Follow the SOP and listen to Perseus Commanders.</span>")

/obj/item/implant/enforcer/proc/clear_implants()
	var/found_imp = 0
	for(var/obj/item/implant/E in imp_in)
		if(!istype(E, /obj/item/implant/enforcer) && !istype(E, /obj/item/implant/commander))
			qdel(E)
			found_imp = 1
	if(found_imp)
		to_chat(imp_in, "<span class='warning'>All foreign implants destroyed.</span>")

/obj/item/implant/enforcer/Destroy()
	perseus_implants -= src
	var/datum/atom_hud/P = GLOB.huds[HUD_PERSEUS]
	for(var/datum/action/X in actions)
		if(istype(X, /datum/action/padrenal))
			qdel(X)
	if (imp_in && P)
		P.remove_hud_from(imp_in)
		imp_in.update_perseus_hud()
	..()


// *****************
// PERSEUS ADRENAL
// *****************

#define PERSEUS_ADRENAL_COOLDOWN 60 // 60 seconds until perc adrenal can be used again
/datum/action/padrenal
	name = "PercTech Adrenalin"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/oldschool/perseus.dmi'
	button_icon_state = "padrenal"
	var/cooldown = 0

/datum/action/padrenal/Trigger()
	if (!..())
		return 0
	if (!owner || !check_perseus(owner))
		qdel(src)
		return 0
	if (cooldown)
		return 0

	var/mob/living/carbon/human/H = owner
	if (!istype(H))
		qdel(src)
		return 0

	to_chat(H, "<span class='notice'>You feel a sudden surge of energy!</span>")
	H.SetStun(0)
	H.SetKnockdown(0)
	H.SetUnconscious(0)
	H.adjustStaminaLoss(-75)
	H.lying = 0
	H.update_canmove()

	H.reagents.add_reagent("synaptizine", 10)
	H.reagents.add_reagent("omnizine", 10)
	H.reagents.add_reagent("stimulants", 10)
	cooldown = 1
	UpdateButtonIcon()

	spawn(PERSEUS_ADRENAL_COOLDOWN * 10)
		if(!owner || !check_perseus(owner))
			qdel(src)
			return 0
		cooldown = 0
		UpdateButtonIcon()
		owner << sound('sound/items/timer.ogg')
		to_chat(owner, "<span class='notice'>Your PercTech adrenal has recharged.</span>")

	return 1

/datum/action/padrenal/IsAvailable()
	if (!..())
		return 0
	if (!owner || !check_perseus(owner))
		qdel(src)
		return 0
	if (cooldown)
		return 0
	return 1

// *****************
// MYCENAE LOCKDOWN
// *****************

/datum/action/pdoors
	name = "Mycenae Lockdown"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/oldschool/perseus.dmi'
	button_icon_state = "lock_down"
	var/list/poddoorids = list("prisonship")

/datum/action/pdoors/Trigger()
	var/doorstatus = -1
	for(var/obj/machinery/door/poddoor/P in world)
		if(P.id in poddoorids)
			if(doorstatus == -1)
				doorstatus = P.density
			switch(doorstatus)
				if(0)
					spawn(0)
						P.close()
				if(1)
					spawn(0)
						P.open()
	if(doorstatus >= 0)
		to_chat(owner, "Mycenae blast doors [doorstatus ? "opening" : "closing"].")

// *****************
// COMMANDER IMPLANT
// *****************

/obj/item/implant/commander
	name = "perseus commander implant"
	access = list(ACCESS_PERSEUS_ENFORCER, ACCESS_PERSEUS_COMMANDER, ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG,
	ACCESS_ARMORY, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE,
	ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION,
	ACCESS_MAILSORTING, ACCESS_HEADS, ACCESS_HOS, ACCESS_HEADS)


	actions_types = list()
	var/datum/action/fire_perc/fire_perc
	can_remove = 0

/obj/item/implant/commander/implant(mob/living/target, mob/user, silent = FALSE)
	. = ..()
	if(!imp_in || !check_perseus(imp_in))
		qdel(src)
		return
	/*fire_perc = new(src)
	fire_perc.Grant(imp_in)*/

/obj/item/implant/commander/Destroy()
	..()
	qdel(fire_perc)

/datum/action/fire_perc
	name = "Fire Enforcer"
	icon_icon = 'icons/oldschool/perseus.dmi'
	button_icon_state = "fire_perc"

/datum/action/fire_perc/IsAvailable()
	if (!check_perseus(owner) || !check_commander(owner))
		qdel(src)
		return 0
	return 1

/datum/action/fire_perc/Trigger()
	if (!..())
		return 0
	if (!owner || !check_perseus(owner))
		return 0

	var/list/options = list()
	options["Cancel"] = null
	for(var/mob/M in GLOB.mob_list)
		if(check_perseus(M) && !check_commander(M))
			options["Enforcer #[get_perc_identifier(M)] ([M.real_name])"] = M

	var/chosen = input(owner, "Choose an Enforcer to Fire", "Fire an Enforcer", "Cancel") in options
	if(chosen == null || chosen == "Cancel")
		return 0
	if(!check_perseus(owner) || !check_commander(owner))
		qdel(src)
		return 0

	var/mob/living/chosen_mob = options[chosen]
	if (!istype(chosen_mob) || !check_perseus(chosen_mob))
		return 0
	for(var/obj/item/implant/enforcer/E in chosen_mob)
		E.owner_mind = null
		qdel(E)

	if(!check_perseus(chosen_mob))
		perseusAlert("Perseus Command","[chosen] has been fired by Commander [get_perc_identifier(owner)]. They are no longer Perseus.",1)
		to_chat(chosen_mob, "<span class='boldannounce'>You have been fired by Commander [get_perc_identifier(owner)]!</span>")
		chosen_mob.AdjustKnockdown(200)
		to_chat(owner, "<span class='boldannounce'>You have successfully fired [chosen]!</span>")

	return 1


/proc/check_commander(mob/M)
	if (!check_perseus(M))
		return 0
	for(var/obj/item/implant/I in M)
		if (istype(I,/obj/item/implant/commander))
			return 1
	return 0

/proc/get_perc_identifier(mob/M)
	if (!check_perseus(M))
		return 0
	for(var/obj/item/implant/enforcer/E in M)
		return E.perc_identifier
	return "ERROR"



// *****************
// PERSEUS ADRENAL
// *****************

/datum/atom_hud/perseus
	hud_icons = list(PERSEUS_HUD)

/mob/living/proc/update_perseus_hud()
	var/image/holder = hud_list[PERSEUS_HUD]
	var/datum/atom_hud/P = GLOB.huds[HUD_PERSEUS]
	if (!check_perseus(src))
		P.remove_from_hud(src)
		P.remove_hud_from(src)
	else
		P.add_to_hud(src)
		P.add_hud_to(src)
		if (holder.icon != 'icons/oldschool/perseus.dmi')
			holder.icon = 'icons/oldschool/perseus.dmi'
		var/commander = 0
		for (var/obj/item/implant/I in contents)
			if (I.imp_in == src && istype(I,/obj/item/implant/commander))
				commander = 1
		if (commander)
			holder.icon_state = "pcommander"
		else
			holder.icon_state = "penforcer"
*/