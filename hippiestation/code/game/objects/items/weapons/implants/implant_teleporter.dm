/obj/item/implant/teleporter
	var/list/whitelist = list()
	var/list/blacklist = list()
	var/pointofreturn = null //where to return them to if they go out of bounds
	var/usewhitelist = FALSE
	var/useblacklist = TRUE
	var/on = FALSE
	var/retrievalmessage = "Retrieval complete."

/obj/item/implant/teleporter/Initialize()
	START_PROCESSING(SSobj, src)

/obj/item/implant/teleporter/process()

	if(usewhitelist)
		useblacklist = FALSE

	if(imp_in)
		if(imp_in.z != ZLEVEL_CENTCOM) //teleporting doesn't work on centcom

			if(blacklist.len && useblacklist)
				var/i = 0
				for(var/zlevel in blacklist)
					i++
					if(zlevel == imp_in.z)
						if(on && pointofreturn)
							retrieve_exile()
						else
							break //we're on a blacklisted z but not on (e.g. station prior to being exiled) so stop
					else
						if(!on && i >= blacklist.len)  //we've just arrived on a non-blacklisted z, start blocking
							on = TRUE
							pointofreturn = imp_in.loc //we'll teleport back here if we go out of bounds

			if(whitelist.len && usewhitelist)
				for(var/zlevel in whitelist)
					if(zlevel == imp_in.z)
						if(!on)
							on = TRUE //we're on a whitelisted z, start blocking
							pointofreturn = imp_in.loc //we'll teleport back here if we go out of bounds
						return // we're allowed here, stop

				if(on && pointofreturn)
					retrieve_exile()

/obj/item/implant/teleporter/proc/retrieve_exile()
	if(imp_in.z != ZLEVEL_CENTCOM)
		do_teleport(imp_in, pointofreturn)
		say(retrievalmessage)

/obj/item/implant/teleporter/implant(mob/living/target, mob/user, silent = 0)
	LAZYINITLIST(target.implants)
	if(!target.can_be_implanted() || !can_be_implanted_in(target))
		return 0
	for(var/X in target.implants)
		if(istype(X, type))
			var/obj/item/implant/imp_e = X
			if(!allow_multiple)
				if(imp_e.uses < initial(imp_e.uses)*2)
					if(uses == -1)
						imp_e.uses = -1
					else
						imp_e.uses = min(imp_e.uses + uses, initial(imp_e.uses)*2)
					qdel(src)
					return 1
				else
					return 0

	src.loc = target
	imp_in = target
	target.implants += src
	if(activated)
		for(var/X in actions)
			var/datum/action/A = X
			A.Grant(target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.sec_hud_set_implants()

	if(user)
		add_logs(user, target, "implanted", object="[name]")

	if(useblacklist && !blacklist.len)
		blacklist += imp_in.z

	if(usewhitelist && !whitelist.len)
		whitelist += imp_in.z
		pointofreturn = imp_in.loc

	return 1

/obj/item/implant/teleporter/removed(mob/living/source, silent = 0, special = 0)
	..()
	say("Implant tampering detected.")
	source.gib()

/obj/item/implant/teleporter/ghost_role
	name = "employee retrieval implant"
	usewhitelist = TRUE
	retrievalmessage = "Employee retrieval complete."

