/obj/screen/alert/status_effect/rainbow_protection
	name = "Rainbow Protection"
	desc = "You are defended from harm, but so are those you might seek to injure!"
	icon_state = "slime_rainbowshield"

/datum/status_effect/rainbow_protection
	id = "rainbow_protection"
	duration = 100
	alert_type = /obj/screen/alert/status_effect/rainbow_protection
	var/originalcolor

/datum/status_effect/rainbow_protection/on_apply()
	owner.status_flags |= GODMODE
	owner.add_trait(TRAIT_PACIFISM, "slimestatus")
	owner.visible_message("<span class='warning'>[owner] shines with a brilliant rainbow light.</span>",
		"<span class='notice'>You feel protected by an unknown force!</span>")
	originalcolor = owner.color
	return ..()

/datum/status_effect/rainbow_protection/tick()
	owner.color = rgb(rand(0,255),rand(0,255),rand(0,255))
	return ..()

/datum/status_effect/rainbow_protection/on_remove()
	owner.status_flags &= ~GODMODE
	owner.color = originalcolor
	owner.remove_trait(TRAIT_PACIFISM, "slimestatus")
	owner.visible_message("<span class='notice'>[owner] stops glowing, the rainbow light fading away.</span>",
		"<span class='warning'>You no longer feel protected...</span>")

/obj/screen/alert/status_effect/slimeskin
	name = "Adamantine Slimeskin"
	desc = "You are covered in a thick, non-neutonian gel."
	icon_state = "slime_stoneskin"

/datum/status_effect/slimeskin
	id = "slimeskin"
	duration = 300
	alert_type = /obj/screen/alert/status_effect/slimeskin
	var/originalcolor

/datum/status_effect/slimeskin/on_apply()
	originalcolor = owner.color
	owner.color = "#3070CC"
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.armor += 10
	owner.visible_message("<span class='warning'>[owner] is suddenly covered in a strange, blue-ish gel!</span>",
		"<span class='notice'>You are covered in a thick, rubbery gel.</span>")
	return ..()

/datum/status_effect/slimeskin/on_remove()
	owner.color = originalcolor
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.armor -= 10
	owner.visible_message("<span class='warning'>[owner]'s gel coating liquefies and dissolves away.</span>",
		"<span class='notice'>Your gel second-skin dissolves!</span>")

///////////////////////////////////////////////////////
//////////////////STABILIZED EXTRACTS//////////////////
///////////////////////////////////////////////////////

/datum/status_effect/stabilized //The base stabilized extract effect, has no effect of its' own.
	id = "stabilizedbase"
	duration = -1
	alert_type = null
	var/obj/item/slimecross/stabilized/linked_extract

/datum/status_effect/stabilized/tick() //Removes the effect if the extract is no longer in the owner.
	if(!istype(linked_extract))
		qdel(src)
	if(linked_extract.loc != owner && linked_extract.loc.loc != owner)
		linked_extract.linked_effect = null
		if(!QDELETED(linked_extract))
			linked_extract.owner = null
			START_PROCESSING(SSobj,linked_extract)
		qdel(src)
	return ..()

/datum/status_effect/stabilized/null //This shouldn't ever happen, but just in case.
	id = "stabilizednull"


//Stabilized effects start below.
/datum/status_effect/stabilized/grey
	id = "stabilizedgrey"

/datum/status_effect/stabilized/grey/tick()
	for(var/mob/living/simple_animal/slime/S in range(1, get_turf(owner)))
		if(!(owner in S.Friends))
			to_chat(owner, "<span class='notice'>[linked_extract] pulses gently as it communicates with [S]</span>")
			S.Friends[owner] = 1
	return ..()

/datum/status_effect/stabilized/orange
	id = "stabilizedorange"

/datum/status_effect/stabilized/orange/tick()
	var/body_temperature_difference = BODYTEMP_NORMAL - owner.bodytemperature
	owner.adjust_bodytemperature(min(5,body_temperature_difference))
	return ..()

/datum/status_effect/stabilized/purple
	id = "stabilizedpurple"

/datum/status_effect/stabilized/purple/tick()
	var/is_healing = FALSE
	if(owner.getBruteLoss() > 0)
		owner.adjustBruteLoss(-0.5)
		is_healing = TRUE
	if(owner.getFireLoss() > 0)
		owner.adjustFireLoss(-0.5)
		is_healing = TRUE
	if(owner.getToxLoss() > 0)
		owner.adjustToxLoss(-0.5, forced = TRUE) //Slimepeople should also get healed.
		is_healing = TRUE
	if(is_healing)
		examine_text = "<span class='warning'>SUBJECTPRONOUN is regenerating slowly, purplish goo filling in small injuries!</span>"
	else
		examine_text = null
	..()

/datum/status_effect/stabilized/blue
	id = "stabilizedblue"

/datum/status_effect/stabilized/blue/on_apply()
	owner.add_trait(TRAIT_NOSLIPWATER, "slimestatus")
	return ..()

datum/status_effect/stabilized/blue/on_remove()
	owner.remove_trait(TRAIT_NOSLIPWATER, "slimestatus")

/datum/status_effect/stabilized/metal
	id = "stabilizedmetal"
	var/cooldown = 30
	var/max_cooldown = 30

/datum/status_effect/stabilized/metal/tick()
	if(cooldown > 0)
		cooldown--
	else
		cooldown = max_cooldown
		var/list/sheets = list()
		for(var/obj/item/stack/sheet/S in owner.GetAllContents())
			if(S.amount < S.max_amount)
				sheets += S

		if(sheets.len > 0)
			var/obj/item/stack/sheet/S = pick(sheets)
			S.amount++
			to_chat(owner, "<span class='notice'>[linked_extract] adds a layer of slime to [S], which metamorphosizes into another sheet of material!</span>")
	return ..()


/datum/status_effect/stabilized/yellow
	id = "stabilizedyellow"
	var/cooldown = 10
	var/max_cooldown = 10
	examine_text = "<span class='warning'>Nearby electronics seem just a little more charged wherever SUBJECTPRONOUN goes.</span>"

/datum/status_effect/stabilized/yellow/tick()
	if(cooldown > 0)
		cooldown--
		return ..()
	cooldown = max_cooldown
	var/list/batteries = list()
	for(var/obj/item/stock_parts/cell/C in owner.GetAllContents())
		if(C.charge < C.maxcharge)
			batteries += C
	if(batteries.len)
		var/obj/item/stock_parts/cell/ToCharge = pick(batteries)
		ToCharge.charge += min(ToCharge.maxcharge - ToCharge.charge, ToCharge.maxcharge/10) //10% of the cell, or to maximum.
		to_chat(owner, "<span class='notice'>[linked_extract] discharges some energy into a device you have.</span>")
	return ..()

/datum/status_effect/stabilized/darkpurple
	id = "stabilizeddarkpurple"

/datum/status_effect/stabilized/darkpurple/tick()
	return ..()

/datum/status_effect/stabilized/darkblue
	id = "stabilizeddarkblue"

/datum/status_effect/stabilized/darkblue/tick()
	if(owner.fire_stacks > 0 && prob(80))
		owner.fire_stacks--
		if(owner.fire_stacks <= 0)
			to_chat(owner, "<span class='notice'>[linked_extract] coats you in a watery goo, extinguishing the flames.</span>")
	var/obj/O = owner.get_active_held_item()
	O.extinguish() //All shamelessly copied from water's reaction_obj, since I didn't seem to be able to get it here for some reason.
	O.acid_level = 0
	// Monkey cube
	if(istype(O, /obj/item/reagent_containers/food/snacks/monkeycube))
		to_chat(owner, "<span class='warning'>[linked_extract] kept your hands wet! It makes [O] expand!</span>")
		var/obj/item/reagent_containers/food/snacks/monkeycube/cube = O
		cube.Expand()

	// Dehydrated carp
	else if(istype(O, /obj/item/toy/plush/carpplushie/dehy_carp))
		to_chat(owner, "<span class='warning'>[linked_extract] kept your hands wet! It makes [O] expand!</span>")
		var/obj/item/toy/plush/carpplushie/dehy_carp/dehy = O
		dehy.Swell() // Makes a carp

	else if(istype(O, /obj/item/stack/sheet/hairlesshide))
		to_chat(owner, "<span class='warning'>[linked_extract] kept your hands wet! It wets [O]!</span>")
		var/obj/item/stack/sheet/hairlesshide/HH = O
		var/obj/item/stack/sheet/wetleather/WL = new(get_turf(HH))
		WL.amount = HH.amount
		qdel(HH)
	..()

/datum/status_effect/stabilized/silver
	id = "stabilizedsilver"

/datum/status_effect/stabilized/silver/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.hunger_mod *= 0.8 //20% buff
	..()

/datum/status_effect/stabilized/silver/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.hunger_mod /= 0.8

//Bluespace has an icon because it's kinda active.
/obj/screen/alert/status_effect/bluespaceslime
	name = "Stabilized Bluespace Extract"
	desc = "You shouldn't see this, since we set it to change automatically!"
	icon_state = "slime_bluespace_on"

/datum/status_effect/bluespacestabilization
	id = "stabilizedbluespacecooldown"
	duration = 1200
	alert_type = null

/datum/status_effect/stabilized/bluespace
	id = "stabilizedbluespace"
	alert_type = /obj/screen/alert/status_effect/bluespaceslime
	var/healthcheck

/datum/status_effect/stabilized/bluespace/tick()
	if(owner.has_status_effect(/datum/status_effect/bluespacestabilization))
		linked_alert.desc = "The stabilized bluespace extract is still aligning you with the bluespace axis."
		linked_alert.icon_state = "slime_bluespace_off"
		return ..()
	else
		linked_alert.desc = "The stabilized bluespace extract will try to redirect you from harm!"
		linked_alert.icon_state = "slime_bluespace_on"

	if(healthcheck & (healthcheck - owner.health) > 5)
		owner.visible_message("<span class='warning'>[linked_extract] notices the sudden change in [owner]'s physical health, and activates!</span>")
		do_sparks(5,FALSE,owner)
		var/F = find_safe_turf(zlevels = owner.z, extended_safety_checks = TRUE)
		var/range = 0
		if(!F)
			F = get_turf(owner)
			range = 50
		if(do_teleport(owner, F, range))
			to_chat(owner, "<span class='notice'>[linked_extract] will take some time to re-align you on the bluespace axis.</span>")
			do_sparks(5,FALSE,owner)
			owner.apply_status_effect(/datum/status_effect/bluespacestabilization)
	healthcheck = owner.health
	return ..()

/datum/status_effect/stabilized/sepia
	id = "stabilizedsepia"

/datum/status_effect/stabilized/cerulean
	id = "stabilizedcerulean"

/datum/status_effect/stabilized/pyrite
	id = "stabilizedpyrite"
	var/originalcolor

/datum/status_effect/stabilized/pyrite/on_apply()
	originalcolor = owner.color
	return ..()

/datum/status_effect/stabilized/pyrite/tick()
	owner.color = rgb(rand(0,255),rand(0,255),rand(0,255))
	return ..()

/datum/status_effect/stabilized/pyrite/on_remove()
	owner.color = originalcolor

/datum/status_effect/stabilized/red
	id = "stabilizedred"

/datum/status_effect/stabilized/red/on_apply()
	owner.add_trait(TRAIT_IGNORESLOWDOWN,"slimestatus")
	return ..()

/datum/status_effect/stabilized/red/on_remove()
	owner.remove_trait(TRAIT_IGNORESLOWDOWN,"slimestatus")

/datum/status_effect/stabilized/green
	id = "stabilizedgreen"
	var/originalUI
	var/originalname

/datum/status_effect/stabilized/green/on_apply()
	to_chat(owner, "<span class='warning'>You feel different...</span>")
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		originalUI = H.dna.uni_identity
		originalname = H.real_name
		H.dna.generate_uni_identity()
		H.real_name = random_unique_name(H.gender)
	return ..()

/datum/status_effect/stabilized/green/tick() //Only occasionally give examiners a warning.
	if(prob(50))
		examine_text = "<span class='warning'>SUBJECTPRONOUN looks a bit green...</span>"
	else
		examine_text = null
	return ..()

/datum/status_effect/stabilized/green/on_remove()
	to_chat(owner, "<span class='notice'>You feel more like yourself.</span>")
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.dna.uni_identity = originalUI
		H.real_name = originalname

/datum/status_effect/stabilized/pink
	id = "stabilizedpink"

/datum/status_effect/stabilized/oil
	id = "stabilizedoil"
	examine_text = "<span class='warning'>SUBJECTPRONOUN smells of sulfer and oil!</span>"

/datum/status_effect/stabilized/oil/tick()
	if(owner.stat == DEAD)
		explosion(get_turf(owner),1,2,4,flame_range = 5)
	return ..()

/datum/status_effect/stabilized/black
	id = "stabilizedblack"

/datum/status_effect/stabilized/lightpink
	id = "stabilizedlightpink"

/datum/status_effect/stabilized/lightpink/on_apply()
	owner.add_trait(TRAIT_GOTTAGOFAST,"slimestatus")
	return ..()

/datum/status_effect/stabilized/lightpink/tick()
	for(var/mob/living/carbon/human/H in range(1, get_turf(owner)))
		if(H != owner && H.stat != DEAD && H.health <= 0 && !H.reagents.has_reagent("epinephrine"))
			to_chat(owner, "[linked_extract] pulses in sync with [H]'s heartbeat, trying to keep them alive.")
			H.reagents.add_reagent("epinephrine",5)
	return ..()

/datum/status_effect/stabilized/lightpink/on_remove()
	owner.remove_trait(TRAIT_GOTTAGOFAST,"slimestatus")

/datum/status_effect/stabilized/adamantine
	id = "stabilizedadamantine"
	examine_text = "<span class='warning'>SUBJECTPRONOUN has a strange metallic coating on their skin.</span>"

/datum/status_effect/stabilized/adamantine/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.damage_resistance += 5
	return ..()

/datum/status_effect/stabilized/adamantine/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.damage_resistance += 5

/datum/status_effect/stabilized/rainbow
	id = "stabilizedrainbow"
	var/obj/item/slimecross/stabilized/current
	var/cooldown = 30
	var/max_cooldown = 30

/datum/status_effect/stabilized/rainbow/tick()
	if(cooldown > 0)
		cooldown--
		return ..()
	cooldown = max_cooldown
	var/extracttype = pick(subtypesof(/obj/item/slimecross/stabilized) - /obj/item/slimecross/stabilized/rainbow)
	if(istype(current))
		qdel(current)
	current = new extracttype(owner)
	..()

/datum/status_effect/stabilized/rainbow/on_remove()
	if(current)
		qdel(current)
