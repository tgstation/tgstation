/obj/mecha/working/ripley
	desc = "Autonomous Power Loader Unit. This newer model is refitted with powerful armour against the dangers of the EVA mining process."
	name = "\improper APLU \"Ripley\""
	icon_state = "ripley"
	step_in = 5
	max_temperature = 20000
	health = 200
	lights_power = 7
	deflect_chance = 15
	damage_absorption = list("brute"=0.6,"bomb"=0.2)
	wreckage = /obj/structure/mecha_wreckage/ripley
	var/list/cargo = new
	var/cargo_capacity = 15

/*
/obj/mecha/working/ripley/New()
	..()
	return
*/

/obj/mecha/working/ripley/Destroy()
	while(src.damage_absorption.["brute"] < 0.6)
		new /obj/item/asteroid/goliath_hide(src.loc)
		src.damage_absorption.["brute"] = src.damage_absorption.["brute"] + 0.1 //If a goliath-plated ripley gets killed, all the plates drop
	for(var/atom/movable/A in src.cargo)
		A.loc = loc
		step_rand(A)
	cargo.Cut()
	..()

/obj/mecha/working/ripley/go_out()
	if(!src.occupant) return
	var/atom/movable/mob_container
	if(ishuman(occupant))
		mob_container = src.occupant
		if(occupant.hud_used && last_user_hud)
			occupant.hud_used.show_hud(HUD_STYLE_STANDARD)
	else if(istype(occupant, /mob/living/carbon/brain))
		var/mob/living/carbon/brain/brain = occupant
		mob_container = brain.container
	else
		return
	if(mob_container.forceMove(src.loc))//ejecting mob container
		src.log_message("[mob_container] moved out.")
		occupant.reset_view()
		src.occupant << browse(null, "window=exosuit")
		if(istype(mob_container, /obj/item/device/mmi))
			var/obj/item/device/mmi/mmi = mob_container
			if(mmi.brainmob)
				occupant.loc = mmi
			mmi.mecha = null
			src.occupant.canmove = 0
			src.verbs += /obj/mecha/verb/eject
		src.occupant = null
		src.icon_state = initial(icon_state)+"-open"
		if (src.damage_absorption.["brute"] < 0.6 && src.damage_absorption.["brute"] > 0.3)
			src.overlays = null
			src.overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g-open")
		else if (src.damage_absorption.["brute"] == 0.3)
			src.overlays = null
			src.overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g-full-open")
		src.dir = dir_in
	return

/obj/mecha/working/ripley/moved_inside(var/mob/living/carbon/human/H as mob)
	if(H && H.client && H in range(1))
		H.reset_view(src)
		H.stop_pulling()
		H.forceMove(src)
		if(H.hud_used)
			last_user_hud = H.hud_used.hud_shown
			H.hud_used.show_hud(HUD_STYLE_REDUCED)
		src.occupant = H
		src.add_fingerprint(H)
		src.forceMove(src.loc)
		src.log_append_to_last("[H] moved in as pilot.")
		src.icon_state = initial(icon_state)
		if (src.damage_absorption.["brute"] < 0.6 && src.damage_absorption.["brute"] > 0.3)
			src.overlays = null
			src.overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g")
		else if (src.damage_absorption.["brute"] == 0.3)
			src.overlays = null
			src.overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g-full")
		dir = dir_in
		playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
		if(!hasInternalDamage())
			src.occupant << sound('sound/mecha/nominal.ogg',volume=50)
		return 1
	else
		return 0

/obj/mecha/working/ripley/mmi_moved_inside(var/obj/item/device/mmi/mmi_as_oc as obj,mob/user as mob)
	if(mmi_as_oc && user in range(1))
		if(!mmi_as_oc.brainmob || !mmi_as_oc.brainmob.client)
			user << "Consciousness matrix not detected."
			return 0
		else if(mmi_as_oc.brainmob.stat)
			user << "Beta-rhythm below acceptable level."
			return 0
		if(!user.unEquip(mmi_as_oc))
			user << "<span class='notice'>\the [mmi_as_oc] is stuck to your hand, you cannot put it in \the [src]</span>"
			return
		var/mob/brainmob = mmi_as_oc.brainmob
		brainmob.reset_view(src)
		occupant = brainmob
		brainmob.loc = src //should allow relaymove
		brainmob.canmove = 1
		mmi_as_oc.loc = src
		mmi_as_oc.mecha = src
		src.verbs -= /obj/mecha/verb/eject
		src.icon_state = initial(icon_state)
		if (src.damage_absorption.["brute"] < 0.6 && src.damage_absorption.["brute"] > 0.3)
			src.overlays = null
			src.overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g")
		else if (src.damage_absorption.["brute"] == 0.3)
			src.overlays = null
			src.overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g-full")
		dir = dir_in
		src.log_message("[mmi_as_oc] moved in as pilot.")
		if(!hasInternalDamage())
			src.occupant << sound('sound/mecha/nominal.ogg',volume=50)
		return 1
	else
		return 0

/obj/mecha/working/ripley/firefighter
	desc = "Standart APLU chassis was refitted with additional thermal protection and cistern."
	name = "\improper APLU \"Firefighter\""
	icon_state = "firefighter"
	max_temperature = 65000
	health = 250
	lights_power = 7
	damage_absorption = list("fire"=0.5,"bullet"=0.8,"bomb"=0.5)
	wreckage = /obj/structure/mecha_wreckage/ripley/firefighter

/obj/mecha/working/ripley/deathripley
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE"
	name = "\improper DEATH-RIPLEY"
	icon_state = "deathripley"
	step_in = 3
	opacity=0
	lights_power = 7
	wreckage = /obj/structure/mecha_wreckage/ripley/deathripley
	step_energy_drain = 0

/obj/mecha/working/ripley/deathripley/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/tool/safety_clamp
	ME.attach(src)
	return

/obj/mecha/working/ripley/mining
	desc = "An old, dusty mining ripley."
	name = "\improper APLU \"Miner\""

/obj/mecha/working/ripley/mining/New()
	..()
	//Attach drill
	if(prob(25)) //Possible diamond drill... Feeling lucky?
		var/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill/D = new /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill
		D.attach(src)
	else
		var/obj/item/mecha_parts/mecha_equipment/tool/drill/D = new /obj/item/mecha_parts/mecha_equipment/tool/drill
		D.attach(src)

	//Attach hydrolic clamp
	var/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/HC = new /obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
	HC.attach(src)
	for(var/obj/item/mecha_parts/mecha_tracking/B in src.contents)//Deletes the beacon so it can't be found easily
		qdel(B)

/obj/mecha/working/ripley/Exit(atom/movable/O)
	if(O in cargo)
		return 0
	return ..()

/obj/mecha/working/ripley/Topic(href, href_list)
	..()
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(href_list["drop_from_cargo"])
		if(O && O in src.cargo)
			src.occupant_message("<span class='notice'>You unload [O].</span>")
			O.loc = loc
			src.cargo -= O
			src.log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - src.cargo.len]")
	return



/obj/mecha/working/ripley/get_stats_part()
	var/output = ..()
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(src.cargo.len)
		for(var/obj/O in src.cargo)
			output += "<a href='?src=\ref[src];drop_from_cargo=\ref[O]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output


