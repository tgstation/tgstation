/obj/effect/decal/cleanable/virusdish
	name = "broken virus containment dish"
	icon = 'monkestation/code/modules/virology/icons/virology.dmi'
	icon_state = "brokendish-outline"
	density = 0
	anchored = 1
	mouse_opacity = 1
	layer = OBJ_LAYER
	var/last_openner
	var/datum/disease/contained_virus

/obj/effect/decal/cleanable/virusdish/Entered(var/mob/living/perp)
	..()
	infection_attempt(perp)

/obj/effect/decal/cleanable/virusdish/infection_attempt(mob/living/perp)
	//Now if your feet aren't well protected, or are bleeding, you might get infected.
	var/block = 0
	var/bleeding = 0
	if (perp.body_position & LYING_DOWN)
		block = perp.check_contact_sterility(BODY_ZONE_CHEST)
		bleeding = perp.check_bodypart_bleeding(BODY_ZONE_CHEST)
	else
		block = perp.check_contact_sterility(BODY_ZONE_L_LEG)
		bleeding = perp.check_bodypart_bleeding(BODY_ZONE_L_LEG)

	if (!block)
		if (contained_virus.spread & SPREAD_CONTACT)
			perp.infect_disease(contained_virus, notes="(Contact, from [(perp.body_position & LYING_DOWN)?"lying":"standing"] over a broken virus dish[last_openner ? " broken by [last_openner]" : ""])")
		else if (bleeding && (contained_virus.spread & SPREAD_BLOOD))
			perp.infect_disease(contained_virus, notes="(Blood, from [(perp.body_position & LYING_DOWN)?"lying":"standing"] over a broken virus dish[last_openner ? " broken by [last_openner]" : ""])")
