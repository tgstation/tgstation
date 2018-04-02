var/list/perseus_implants = list()

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
	access = list(access_penforcer, GLOB.access_brig,GLOB.access_sec_doors, GLOB.access_court, GLOB.access_maint_tunnels, GLOB.access_morgue, GLOB.access_medical,
	GLOB.access_construction, GLOB.access_mailsorting, GLOB.access_engine, GLOB.access_research, GLOB.access_security)
	actions_types = list()
	can_remove = 0
	var/perc_identifier = "ERROR"
	var/datum/action/padrenal/padrenal

/obj/item/implant/enforcer/implanted()
	if (imp_in && check_perseus(imp_in))
		clear_implants()
		clear_antag()
		perseus_implants += src
		perseusAlert("PercTech Alert System","New implant connection detected, [imp_in]",1)
		padrenal = new(src)
		padrenal.Grant(imp_in)
		var/datum/atom_hud/P = GLOB.huds[HUD_PERSEUS]
		if (P)
			P.add_hud_to(imp_in)
			imp_in.update_perseus_hud()

/obj/item/implant/enforcer/New()
	..()
	SSobj.processing |= src

/obj/item/implant/enforcer/Destroy()
	..()
	qdel(padrenal)
	SSobj.processing -= src

var/list/dying_perseus = list()

/obj/item/implant/enforcer/process()
	if(!imp_in || !check_perseus(imp_in))
		qdel(src)
		return
	if(imp_in && imp_in.mind && (imp_in.mind.objectives.len || imp_in.mind.special_role))
		clear_antag()
	clear_implants()
	if (imp_in.stat == 1 || imp_in.stat == 2)
		if (!(imp_in in dying_perseus) || world.time > dying_perseus[imp_in])
			dying_perseus[imp_in] = world.time + 100
			var/area/current_area = get_area(imp_in)
			perseusAlert("Lifesigns Monitor","[imp_in] is [imp_in.stat == 1 ? "in critical condition" : "dead"]! Location: [current_area.name] ([imp_in.x],[imp_in.y],[imp_in.z])", 2)
	else if (imp_in in dying_perseus)
		dying_perseus[imp_in] = null
		dying_perseus -= imp_in
		perseusAlert("Lifesigns Monitor","[imp_in] is no longer in critical condition.", 3)

/obj/item/implant/enforcer/proc/clear_antag() CHANGELING DOESNT WORK LIKE THIS ANY MORE
	if (!imp_in || !imp_in.mind)
		return
	if (imp_in.mind.changeling)
		qdel(imp_in.mind.changeling)
		imp_in.mind.changeling = null

	imp_in.mind.remove_objectives()
	imp_in.mind.special_role = ""
	imp_in.mind.memory = ""
	to_chat(imp_in, "<span class='userdanger'>You remember nothing.</span>")
	to_chat(imp_in, "<span class='notice'>Your memories have been wiped clean. If you were previously an antagonist, you no longer are.</span>")
	to_chat(imp_in, "<span class='notice'>You are now a Perseus Enforcer. Follow the SOP and listen to Perseus Commanders.</span>")

/obj/item/implant/enforcer/proc/clear_implants()
	if(!imp_in)
		qdel(src)
		return 0
	var/found_imp = 0
	for(var/obj/item/implant/E in imp_in)
		if (E != src && E.type == /obj/item/implant/enforcer)
			qdel(E)
			found_imp = 1
		else if (!istype(E, /obj/item/implant/enforcer) && !istype(E, /obj/item/implant/commander))
			qdel(E)
			found_imp = 1
	var/commander_cnt = 0
	for(var/obj/item/implant/commander/C in imp_in)
		if(commander_cnt)
			qdel(C)
		commander_cnt++
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
// COMMANDER IMPLANT
// *****************

/obj/item/implant/commander
	name = "perseus commander implant"
	access = list(access_pcommander, access_penforcer, GLOB.access_security, GLOB.access_sec_doors, GLOB.access_brig,
	GLOB.access_armory, GLOB.access_court, GLOB.access_forensics_lockers, GLOB.access_morgue,
	GLOB.access_maint_tunnels, GLOB.access_research, GLOB.access_engine, GLOB.access_mining, GLOB.access_medical, GLOB.access_construction,
	GLOB.access_mailsorting, GLOB.access_heads, GLOB.access_hos, GLOB.access_heads)
	actions_types = list()
	var/datum/action/fire_perc/fire_perc
	can_remove = 0

/obj/item/implant/commander/implanted()
	if(!imp_in || !check_perseus(imp_in))
		qdel(src)
		return
	fire_perc = new(src)
	fire_perc.Grant(imp_in)

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
