/obj/item/nanite_scanner
	name = "nanite scanner"
	icon = 'monkestation/icons/obj/device.dmi'
	icon_state = "nanite_scanner"
	worn_icon_state = "electronic"
	desc = "A hand-held body scanner able to detect nanites and their programming."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=200)

/obj/item/nanite_scanner/attack(mob/living/M, mob/living/carbon/human/user)
	user.visible_message(span_notice("[user] analyzes [M]'s nanites."), \
						span_notice("You analyze [M]'s nanites."))

	add_fingerprint(user)

	var/response = SEND_SIGNAL(M, COMSIG_NANITE_SCAN, user, TRUE)
	if(!response)
		to_chat(user, span_info("No nanites detected in the subject."))

/obj/item/extrapolator
	name = "virus extrapolator"
	icon = 'monkestation/icons/obj/device.dmi'
	icon_state = "extrapolator_scan"
	desc = "A scanning device, used to extract genetic material of potential pathogens"
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_TINY
	var/using = FALSE
	var/scan = TRUE
	var/cooldown
	var/obj/item/stock_parts/scanning_module/scanner //used for upgrading!

/obj/item/extrapolator/Initialize(mapload)
	. = ..()
	scanner = new(src)

/obj/item/extrapolator/Destroy()
	qdel(scanner)
	scanner = null
	return ..()

/obj/item/extrapolator/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/scanning_module))
		if(!scanner)
			if(!user.transferItemToLoc(W, src))
				return
			scanner = W
			to_chat(user, "<span class='notice'>You install a [scanner.name] in [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] already has a scanner installed.</span>")

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(scanner)
			to_chat(user, "<span class='notice'>You remove the [scanner.name] from \the [src].</span>")
			scanner.forceMove(drop_location())
			scanner = null
	else
		return ..()

/obj/item/extrapolator/attack_self(mob/user)
	. = ..()
	playsound(src, 'sound/machines/click.ogg', 50, 1)
	if(scan)
		icon_state = "extrapolator_sample"
		scan = FALSE
		to_chat(user, "<span class='notice'>You remove the probe from the device and set it to EXTRACT</span>")
	else
		icon_state = "extrapolator_scan"
		scan = TRUE
		to_chat(user, "<span class='notice'>You put the probe back in the device and set it to SCAN</span>")

/obj/item/extrapolator/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		if(!scanner)
			. += "<span class='notice'>The scanner is missing.</span>"
		else
			. += "<span class='notice'>A class <b>[scanner.rating]</b> scanning module is installed. It is <i>screwed</i> in place.</span>"


/obj/item/extrapolator/attack(atom/AM, mob/living/user)
	return

/obj/item/extrapolator/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag && !scan)
		return
	if(scanner)
		if(!target.extrapolator_act(user, src, scan))

			if(locate(/datum/component/infective) in target._datum_components)
				return //so the failure message does not show when we can actually extrapolate from a component
			if(scan)
				to_chat(user, "<span class='notice'>the extrapolator fails to return any data</span>")
			else
				to_chat(user, "<span class='notice'>the extrapolator's probe detects no diseases</span>")
	else
		to_chat(user, "<span class='warning'>the extrapolator has no scanner installed</span>")

/obj/item/extrapolator/proc/scan(atom/AM, list/diseases = list(), mob/user)
	to_chat(user, "<span class='notice'><b>[src] detects the following diseases:</b></span>")
	for(var/datum/disease/D in diseases)
		if(istype(D, /datum/disease/advance))
			var/datum/disease/advance/A = D
			//if(A.stealth >= (2 + scanner.rating)) //the extrapolator can detect diseases of higher stealth than a normal scanner
			//	continue
			//if(A.dormant)
			//	to_chat(user, "<span class='info'><font color='A19D9C'><b>[A.name]</b>, dormant virus</font></span>")
			//	to_chat(user, "<span class='info'><font color='BAB9B9'><b>[A] has the following symptoms:</b></font></span>")
			//	for(var/datum/symptom/S in A.symptoms)
			//		to_chat(user, "<span class='info'><font color='BAB9B9'>[S.name]</font></span>")
			//else
			to_chat(user, "<span class='info'><font color='green'><b>[A.name]</b>, stage [A.stage]/5</font></span>")
			to_chat(user, "<span class='info'><b>[A] has the following symptoms:</b></span>")
			for(var/datum/symptom/S in A.symptoms)
				to_chat(user, "<span class='info'>[S.name]</span>")
		else
			to_chat(user, "<span class='info'><font color='green'><b>[D.name]</b>, stage [D.stage]/[D.max_stages].</font></span>")

/obj/item/extrapolator/proc/extrapolate(atom/AM, list/diseases = list(), mob/user, isolate = FALSE, timer = 100)
	var/list/advancediseases = list()
	var/list/symptoms = list()
	if(using)
		to_chat(user, "<span class='warning'>The extrapolator is already in use.</span>")
		return
	for(var/datum/disease/advance/cantidate in diseases)
		advancediseases += cantidate
	if(!LAZYLEN(advancediseases))
		to_chat(user, "<span class='warning'>There are no valid diseases to make a culture from.</span>")
		return
	if(cooldown > world.time - (10))
		to_chat(user, "<span class='warning'>The extrapolator is still recharging!</span>")
		return
	var/datum/disease/advance/A = input(user,"What disease do you wish to extract") in null|advancediseases
	if(isolate)
		using = TRUE
		for(var/datum/symptom/S in A.symptoms)
			if(S.level <= 6 + scanner.rating)
				symptoms += S
			continue
		var/datum/symptom/chosen = input(user,"What symptom do you wish to isolate") in null|symptoms
		var/datum/disease/advance/symptomholder = new
		if(!symptoms.len || !chosen)
			using = FALSE
			to_chat(user, "<span class='warning'>There are no valid diseases to isolate a symptom from.</span>")
			return
		symptomholder.name = chosen.name
		symptomholder.symptoms += chosen
		//symptomholder.Finalize()
		symptomholder.Refresh()
		to_chat(user, "<span class='warning'>you begin isolating [chosen].</span>")
		if(do_after(user, (120 / (scanner.rating + 1)), target = AM))
			create_culture(symptomholder, user, AM)
	else
		using = TRUE
		if(do_after(user, (timer / (scanner.rating + 1)), target = AM))
			create_culture(A, user, AM)
	using = FALSE

/obj/item/extrapolator/proc/create_culture(datum/disease/advance/A, mob/user)
	if(cooldown > world.time - (10))
		to_chat(user, "<span class='warning'>The extrapolator is still recharging!</span>")
		return
	var/list/data = list("viruses" = list(A))
	var/obj/item/reagent_containers/cup/bottle/B = new(user.loc)
	cooldown = world.time
	if(!(user.get_item_for_held_index(user.active_hand_index) == src))
		to_chat(user, "<span class='warning'>The extrapolator must be held in your active hand to work!</span>")
		return FALSE
	B.name = "[A.name] culture bottle"
	B.desc = "A small bottle. Contains [A.agent] culture in synthblood medium."
	B.reagents.add_reagent(/datum/reagent/blood, 20, data)
	user.put_in_hands(B)
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	return TRUE
