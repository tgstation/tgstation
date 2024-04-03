/obj/item/implanter/stealthimplanter/attack(mob/living/M, mob/user)
	if(!istype(M))
		return
	if(user && imp)
		var/turf/T = get_turf(M)
		if(T && (M == user || do_after(user, 0.5 SECONDS, M)))
			if(src && imp)
				if(imp.implant(M, user))
					if (M == user)
						to_chat(user, span_notice("You implant yourself."))
					imp = null
					update_appearance(UPDATE_ICON)

///

/obj/item/implanter/stealthimplanter/explosive
	name = "implanter (microbomb)"
	imp_type = /obj/item/implant/explosive/stealth

/obj/item/implant/explosive/stealth
	name = "microbomb implant"
	desc = "And boom goes the weasel."
	icon_state = "explosive"
	actions_types = null
	// Explosive implant action is always available.
	explosion_light = 2
	explosion_heavy = 0.8
	explosion_devastate = 0.4
	delay = 0.7 SECONDS
	popup = FALSE // is the DOUWANNABLOWUP window open?
	active = FALSE

/obj/item/implanter/stealthimplanter/megaexplosive
	name = "implanter (macrobomb)"
	imp_type = /obj/item/implant/explosive/macro/stealth

/obj/item/implant/explosive/macro/stealth
	name = "macrobomb implant"
	desc = "And boom goes the weasel. And everything else nearby."
	icon_state = "explosive"
	explosion_light = 16
	explosion_heavy = 8
	explosion_devastate = 4
	delay = 7 SECONDS

/obj/item/implanter/stealthimplanter/tracking
	name = "implanter"
	imp_type = /obj/item/implant/tracking/syndicate

/obj/item/implant/tracking/syndicate
	name = "tracking implant"
	desc = "Track with this."
	actions_types = null
	lifespan_postmortem = 30 MINUTES //for how long after user death will the implant work?

/obj/item/implantcase/tracking/syndicate
	name = "implant case - 'Tracking'"
	desc = "A glass case containing a tracking implant."
	imp_type = /obj/item/implant/tracking/syndicate
