/obj/item/grenade/hypnotic
	name = "flashbang"
	desc = "A modified flashbang which uses hypnotic flashes and mind-altering soundwaves to induce an instant trance upon detonation."
	icon_state = "flashbang"
	worn_icon_state = "grenade"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	var/flashbang_range = 7

/obj/item/grenade/hypnotic/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/empprotection, EMP_PROTECT_WIRES)

/obj/item/grenade/hypnotic/Initialize()
	. = ..()
	wires = new /datum/wires/explosive/hypnotic(src)

/obj/item/grenade/hypnotic/prime(mob/living/lanced_by)
	. = ..()
	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return
	do_sparks(rand(5, 9), FALSE, src)
	playsound(flashbang_turf, 'sound/effects/screech.ogg', 100, TRUE, 8, 0.9)
	new /obj/effect/dummy/lighting_obj (flashbang_turf, LIGHT_COLOR_PURPLE, (flashbang_range + 2), 4, 2)
	for(var/mob/living/M in get_hearers_in_view(flashbang_range, flashbang_turf))
		bang(get_turf(M), M)
	qdel(src)

/obj/item/grenade/hypnotic/proc/bang(turf/T, mob/living/M)
	if(M.stat == DEAD)	//They're dead!
		return
	var/distance = max(0,get_dist(get_turf(src),T))

	//Bang
	var/hypno_sound = FALSE

	//Hearing protection check
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		var/list/reflist = list(1)
		SEND_SIGNAL(C, COMSIG_CARBON_SOUNDBANG, reflist)
		var/intensity = reflist[1]
		var/ear_safety = C.get_ear_protection()
		var/effect_amount = intensity - ear_safety
		if(effect_amount > 0)
			hypno_sound = TRUE

	if(!distance || loc == M || loc == M.loc)
		M.Paralyze(10)
		M.Knockdown(100)
		to_chat(M, "<span class='hypnophrase'>The sound echoes in your brain...</span>")
		M.hallucination += 50
	else
		if(distance <= 1)
			M.Paralyze(5)
			M.Knockdown(30)
		if(hypno_sound)
			to_chat(M, "<span class='hypnophrase'>The sound echoes in your brain...</span>")
			M.hallucination += 50

	//Flash
	if(M.flash_act(affect_silicon = 1))
		M.Paralyze(max(10/max(1,distance), 5))
		M.Knockdown(max(100/max(1,distance), 40))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(C.hypnosis_vulnerable()) //The sound causes the necessary conditions unless the target has mindshield or hearing protection
				C.apply_status_effect(/datum/status_effect/trance, 100, TRUE)
			else
				to_chat(C, "<span class='hypnophrase'>The light is so pretty...</span>")
				C.add_confusion(min(C.get_confusion() + 10, 20))
				C.dizziness += min(C.dizziness + 10, 20)
				C.drowsyness += min(C.drowsyness + 10, 20)

obj/item/grenade/hypnotic/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/assembly))
		wires.interact(user)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)


	else if(istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		if (C.use(1))
			det_time = 50 // In case the cable_coil was removed and readded.
			to_chat(user, "<span class='notice'>You rig the [initial(name)] assembly.</span>")
		else
			to_chat(user, "<span class='warning'>You need one length of coil to wire the assembly!</span>")
			return

	else if(I.tool_behaviour == TOOL_WIRECUTTER && !active)

	else if(I.tool_behaviour == TOOL_WRENCH)
		wires.detach_assembly(wires.get_wire(1))
		new /obj/item/stack/cable_coil(get_turf(src),1)
		to_chat(user, "<span class='notice'>You remove the activation mechanism from the [initial(name)] assembly.</span>")
	else
		return ..()
