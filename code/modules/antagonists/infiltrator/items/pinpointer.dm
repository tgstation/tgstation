#define MODE_CUTTER 1
#define MODE_TARGET 2

/obj/item/pinpointer/infiltrator
	name = "infiltration pinpointer"
	var/upgraded = FALSE
	var/datum/team/team
	var/mode = MODE_CUTTER
	var/current_target

/obj/item/pinpointer/infiltrator/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>It is tracking [mode == MODE_CUTTER ? "the syndicate cutter" : "an objective target"].</span>")

/obj/item/pinpointer/infiltrator/scan_for_target()
	switch(mode)
		if(MODE_CUTTER)
			target = SSshuttle.getShuttle("syndicatecutter")
		if(MODE_TARGET)
			if(team && LAZYLEN(team.objectives))
				for(var/A in team.objectives)
					var/datum/objective/O = A
					if(istype(O) && O.target && !O.check_completion())
						if(istype(O.target, /datum/mind))
							var/datum/mind/M = O.target
							target = M.current
						else if(istype(O.target, /atom))
							target = O.target
						else
							continue
						break
	..()

/obj/item/pinpointer/infiltrator/attack_self(mob/user)
	if(!upgraded)
		return ..()
	if(!active)
		active = TRUE
		START_PROCESSING(SSfastprocess, src)
	if(mode == MODE_CUTTER)
		mode = MODE_TARGET
		scan_for_target()
		to_chat(user, "<span class='notice'>[src] is now tracking [target].</span>")
	else
		mode = MODE_CUTTER
		scan_for_target()
		to_chat(user, "<span class='notice'>[src] is now tracking the syndicate cutter.</span>")
	update_icon()

/obj/item/pinpointer/infiltrator/attackby(obj/item/I, mob/user, params)
	if(!upgraded && istype(I, /obj/item/infiltrator_pinpointer_upgrade) && user.mind)
		var/datum/antagonist/infiltrator/DAI = user.mind.has_antag_datum(/datum/antagonist/infiltrator)
		if(!DAI || !DAI.infiltrator_team)
			return ..()
		team = DAI.infiltrator_team
		icon_state = "pinpointer_upgraded"
		upgraded = TRUE
		to_chat(user, "<span class='notice'>You attach the new antenna to [src].</span>")
		qdel(I)
	else
		return ..()



/obj/item/infiltrator_pinpointer_upgrade
	name = "infiltration pinpointer upgrade"
	desc = "Upgrades your pinpointer to allow for tracking objective targets."
	icon = 'icons/obj/device.dmi'
	icon_state = "shitty_antenna"

#undef MODE_CUTTER
#undef MODE_TARGET