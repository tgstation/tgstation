/obj/structure/artifact
	name = "Artifact"
	desc = "Yell at coderbus."
	icon = 'icons/obj/device.dmi'
	icon_state = "ai-slipper0"
	max_integrity = 200
	anchored = 0
	var/datum/artifact/assoc_datum = /datum/artifact
	Initialize(mapload, var/forced_origin = null)
		. = ..()
		SSartifacts.artifacts += src
		assoc_datum = new assoc_datum(src)
		if(forced_origin)
			assoc_datum.valid_origins = list(forced_origin)
		assoc_datum.setup(src)
	Destroy()
		. = ..()
		SSartifacts.artifacts -= src
	examine()
		. = ..()
		if(assoc_datum?.examine_hint)
			. += span_warning(examine_hint)
	attack_hand(mob/user)
		assoc_datum.Touched(user)
		return

	attack_ai(mob/user as mob)
		return attack_hand(user)
	
	attack_by(obj/item/I, mob/user, params)
		if(assoc_datum.attack_by(I,user))
			..()
	
	ex_act(severity)
		. = ..()
		switch(severity)
			if(EXPLODE_DEVASTATE)
				assoc_datum.Stimulate(STIMULUS_FORCE,200)
			if(EXPLODE_HEAVY)
				assoc_datum.Stimulate(STIMULUS_FORCE,100)
			if(EXPLODE_LIGHT)
				assoc_datum.Stimulate(STIMULUS_FORCE,40)