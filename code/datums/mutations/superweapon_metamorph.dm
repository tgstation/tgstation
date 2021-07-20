///special protagonist only mutation that makes the user have to cocoon every 20 minutes, granting a slew of positive and negative mutations (the negative ones unremovable)
/datum/mutation/human/superweapon
	name = "Genetic Superweapon"
	desc = "Analysis of the genetic structure of this patient has lead to pure confusion on the absolute level of biological sabotage. Occasionally, the patient will \
	need to \"molt\" and further develop their potential."
	text_gain_indication = "You feel REALLY unstable."
	text_lose_indication = "You feel your genes settling."
	quality = NEGATIVE
	time_coeff = 2
	locked = TRUE //protagonists only!

	///what sets of mutations to grant with each cocooning
	var/metamorph_path

	///how many times they've cocooned
	var/progress

	///timer until the owner gets a warning about the cocoon
	var/warning_timer
	///timer until the next cocoon
	var/metamorph_timer

/datum/mutation/human/superweapon/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	metamorph_path = pick(SUPERWEAPON_PSIONICS, SUPERWEAPON_CRYONICS)

	warning_timer = addtimer(CALLBACK(src, .proc/warning), METAMORPH_COCOON_TIME - 2 MINUTES)
	metamorph_timer = addtimer(CALLBACK(src, .proc/metamorph), METAMORPH_COCOON_TIME)

/datum/mutation/human/superweapon/proc/warning()
	to_chat(owner, span_boldwarning("Your genes begin to feel unsettled. you are going to cocoon soon, and should find some safe place for this!"))

/datum/mutation/human/superweapon/proc/metamorph()
	to_chat(owner, )

	owner.visible_message(
		span_warning("A chrysalis forms around [H], sealing them inside."),
		span_userdanger("You begin uncontrollably vomiting a resinous cocoon that forms around you!")
	)

	var/turf/cocoon_turf = get_turf(owner)
	for(var/turf/open/cocoonable_ground in orange(1, cocoon_turf))
		playsound(W, 'sound/effects/splat.ogg', 50, 1)
		new /obj/structure/alien/resin/wall/superweapon_cocoon(cocoonable_ground)
	new /obj/structure/alien/weeds/node/superweapon_cocoon(cocoon_turf)


/datum/mutation/human/superweapon/on_losing(mob/living/carbon/human/owner)
	deltimer(warning_timer)
	deltimer(metamorph_timer)
	. = ..()
