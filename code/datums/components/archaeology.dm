/datum/component/archaeology
	dupe_type = COMPONENT_DUPE_UNIQUE
	var/list/archdrops
	var/prob2drop
	var/dug

/datum/component/archaeology/Initialize(_prob2drop, list/_archdrops = list())
	prob2drop = Clamp(_prob2drop, 0, 100)
	archdrops = _archdrops
	RegisterSignal(COMSIG_PARENT_ATTACKBY,.proc/Dig)
	RegisterSignal(COMSIG_ATOM_EX_ACT, .proc/BombDig)
	RegisterSignal(COMSIG_ATOM_SING_PULL, .proc/SingDig)

/datum/component/archaeology/InheritComponent(datum/component/archaeology/A, i_am_original)
	var/list/other_archdrops = A.archdrops
	var/list/_archdrops = archdrops
	for(var/I in other_archdrops)
		_archdrops[I] += other_archdrops[I]

/datum/component/archaeology/proc/Dig(mob/user, obj/item/W)
	if(dug)
		to_chat(user, "<span class='notice'>Looks like someone has dug here already.</span>")
		return FALSE
	else
		var/digging_speed
		if (istype(W, /obj/item/shovel))
			var/obj/item/shovel/S = W
			digging_speed = S.digspeed
		else if (istype(W, /obj/item/pickaxe))
			var/obj/item/pickaxe/P = W
			digging_speed = P.digspeed

		if (digging_speed && isturf(user.loc))
			to_chat(user, "<span class='notice'>You start digging...</span>")
			playsound(parent, 'sound/effects/shovel_dig.ogg', 50, 1)

			if(do_after(user, digging_speed, target = parent))
				to_chat(user, "<span class='notice'>You dig a hole.</span>")
				gets_dug()
				dug = TRUE
				SSblackbox.add_details("pick_used_mining",W.type)
				return TRUE
		return FALSE

/datum/component/archaeology/proc/gets_dug()
	if(dug)
		return
	else
		var/turf/open/OT = get_turf(parent)
		for(var/thing in archdrops)
			var/maxtodrop = archdrops[thing]
			for(var/i in 1 to maxtodrop)
				if(prob(prob2drop)) // can't win them all!
					new thing(OT)

		if(isopenturf(OT))
			if(OT.postdig_icon_change)
				if(istype(OT, /turf/open/floor/plating/asteroid/) && !OT.postdig_icon)
					var/turf/open/floor/plating/asteroid/AOT = parent
					AOT.icon_plating = "[AOT.environment_type]_dug"
					AOT.icon_state = "[AOT.environment_type]_dug"
				else
					if(isplatingturf(OT))
						var/turf/open/floor/plating/POT = parent
						POT.icon_plating = "[POT.postdig_icon]"
					OT.icon_state = "[OT.postdig_icon]"

			if(OT.slowdown) //Things like snow slow you down until you dig them.
				OT.slowdown = 0
	dug = TRUE

/datum/component/archaeology/proc/SingDig(S, current_size)
	switch(current_size)
		if(STAGE_THREE)
			if(prob(30))
				gets_dug()
		if(STAGE_FOUR)
			if(prob(50))
				gets_dug()
		else
			if(current_size >= STAGE_FIVE && prob(70))
				gets_dug()

/datum/component/archaeology/proc/BombDig(severity, target)
	switch(severity)
		if(3)
			return
		if(2)
			if(prob(20))
				gets_dug()
		if(1)
			gets_dug()
