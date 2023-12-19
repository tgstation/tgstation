GLOBAL_LIST_INIT(infected_cleanables, list())

/obj/effect/decal/cleanable/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	spawn(1)//cleanables can get infected in many different ways when they spawn so it's much easier to handle the pathogen overlay here after a delay
		if (src.diseases && length(src.diseases))
			GLOB.infected_cleanables += src
			if (!pathogen)
				pathogen = image('monkestation/code/modules/virology/icons/effects.dmi',src,"pathogen_blood")
				pathogen.plane = HUD_PLANE
				pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
			for (var/mob/L in GLOB.science_goggles_wearers)
				if (L.client)
					L.client.images |= pathogen

/obj/effect/decal/cleanable/Destroy()
	. = ..()
	GLOB.infected_cleanables -= src

/obj/effect/decal/cleanable/Entered(mob/living/perp)
	..()
	infection_attempt(perp)

/obj/effect/decal/cleanable/infection_attempt(mob/living/perp)
	//Now if your feet aren't well protected, or are bleeding, you might get infected.
	var/block = 0
	var/bleeding = 0
	if (perp.body_position & LYING_DOWN)
		block = perp.check_contact_sterility(BODY_ZONE_EVERYTHING)
		bleeding = perp.check_bodypart_bleeding(BODY_ZONE_EVERYTHING)
	else
		block = perp.check_contact_sterility(BODY_ZONE_LEGS)
		bleeding = perp.check_bodypart_bleeding(BODY_ZONE_LEGS)

	for(var/datum/disease/advanced/contained_virus as anything in diseases)
		if (!block && (contained_virus.spread_flags & DISEASE_SPREAD_CONTACT_SKIN))
			perp.infect_disease(contained_virus, notes="(Contact, from [(perp.body_position & LYING_DOWN)?"lying":"standing"] over [src]])")
		else if (bleeding && (contained_virus.spread_flags & DISEASE_SPREAD_BLOOD))
			perp.infect_disease(contained_virus, notes="(Blood, from [(perp.body_position & LYING_DOWN)?"lying":"standing"] over [src]])")
