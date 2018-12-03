#define SCANGATE_NONE 			"Off"
#define SCANGATE_MINDSHIELD 	"Mindshield"
#define SCANGATE_NANITES 		"Nanites"
#define SCANGATE_DISEASE 		"Disease"
#define SCANGATE_GUNS 			"Guns"
#define SCANGATE_WANTED			"Wanted"
#define SCANGATE_SPECIES		"Species"


/obj/machinery/scanner_gate
	name = "scanner gate"
	desc = "A gate able to perform mid-depth scans on any organisms who pass under it."
	icon = 'icons/obj/machines/scangate.dmi'
	icon_state = "scangate"
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	circuit = /obj/item/circuitboard/machine/scanner_gate
	var/scanline_timer
	var/next_beep = 0 //avoids spam

	var/locked = FALSE
	var/scangate_mode = SCANGATE_NONE
	var/disease_threshold = DISEASE_SEVERITY_MINOR
	var/nanite_cloud = 0
	var/datum/species/detect_species = /datum/species/human
	var/reverse = FALSE //If true, signals if the scan returns false

/obj/machinery/scanner_gate/Initialize()
	. = ..()
	set_scanline("passive")

/obj/machinery/scanner_gate/examine(mob/user)
	..()
	if(locked)
		to_chat(user, "<span class='notice'>The control panel is ID-locked. Swipe a valid ID to unlock it.</span>")
	else
		to_chat(user, "<span class='notice'>The control panel is unlocked. Swipe an ID to lock it.</span>")

/obj/machinery/scanner_gate/Crossed(atom/movable/AM)
	..()
	if(!(stat & (BROKEN|NOPOWER)) && isliving(AM))
		perform_scan(AM)

/obj/machinery/scanner_gate/proc/set_scanline(type, duration)
	cut_overlays()
	deltimer(scanline_timer)
	add_overlay(type)
	if(duration)
		scanline_timer = addtimer(CALLBACK(src, .proc/set_scanline, "passive"), duration, TIMER_STOPPABLE)

/obj/machinery/scanner_gate/attackby(obj/item/W, mob/user, params)
	var/obj/item/card/id/card = W.GetID()
	if(card)
		if(locked)
			if(allowed(user))
				locked = FALSE
				req_access = list()
				to_chat(user, "<span class='notice'>You unlock [src].</span>")
		else if(!(obj_flags & EMAGGED))
			to_chat(user, "<span class='notice'>You lock [src] with [W].</span>")
			var/list/access = W.GetAccess()
			req_access = access
			locked = TRUE
		else
			to_chat(user, "<span class='warning'>You try to lock [src] with [W], but nothing happens.</span>")
	else
		return ..()

/obj/machinery/scanner_gate/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	locked = FALSE
	req_access = list()
	obj_flags |= EMAGGED
	to_chat(user, "<span class='notice'>You fry the ID checking system.</span>")

/obj/machinery/scanner_gate/proc/perform_scan(mob/living/M)
	var/beep = FALSE
	switch(scangate_mode)
		if(SCANGATE_NONE)
			return
		if(SCANGATE_WANTED)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/perpname = H.get_face_name(H.get_id_name())
				var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.security)
				if(!R || (R.fields["criminal"] == "*Arrest*"))
					beep = TRUE
		if(SCANGATE_MINDSHIELD)
			if(M.has_trait(TRAIT_MINDSHIELD))
				beep = TRUE
		if(SCANGATE_NANITES)
			if(SEND_SIGNAL(M, COMSIG_HAS_NANITES))
				if(nanite_cloud)
					GET_COMPONENT_FROM(nanites, /datum/component/nanites, M)
					if(nanites && nanites.cloud_id == nanite_cloud)
						beep = TRUE
				else
					beep = TRUE
		if(SCANGATE_DISEASE)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(get_disease_severity_value(C.check_virus()) >= get_disease_severity_value(disease_threshold))
					beep = TRUE
		if(SCANGATE_SPECIES)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(is_species(H, detect_species))
					beep = TRUE
				if(detect_species == /datum/species/zombie) //Can detect dormant zombies
					if(H.getorganslot(ORGAN_SLOT_ZOMBIE))
						beep = TRUE
		if(SCANGATE_GUNS)
			for(var/I in M.get_contents())
				if(istype(I, /obj/item/gun))
					beep = TRUE
					break
	if(reverse)
		beep = !beep
	if(beep)
		alarm_beep()
	else
		set_scanline("scanning", 10)

/obj/machinery/scanner_gate/proc/alarm_beep()
	if(next_beep <= world.time)
		next_beep = world.time + 20
		playsound(src, 'sound/machines/scanbuzz.ogg', 100, 0)
	var/image/I = image(icon, src, "alarm_light", layer+1)
	flick_overlay_view(I, src, 20)
	set_scanline("alarm", 20)

/obj/machinery/scanner_gate/can_interact(mob/user)
	if(locked)
		return FALSE
	return ..()

/obj/machinery/scanner_gate/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "scanner_gate", name, 600, 400, master_ui, state)
		ui.open()

/obj/machinery/scanner_gate/ui_data()
	var/list/data = list()
	data["scan_mode"] = scangate_mode
	data["reverse"] = reverse
	data["nanite_cloud"] = nanite_cloud
	data["disease_threshold"] = disease_threshold
	data["target_species"] = initial(detect_species.name)
	return data

/obj/machinery/scanner_gate/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("set_mode")
			var/new_mode = input("Choose the scan mode","Scan Mode") as null|anything in list(SCANGATE_NONE,
																								SCANGATE_MINDSHIELD,
																								SCANGATE_NANITES,
																								SCANGATE_DISEASE,
																								SCANGATE_GUNS,
																								SCANGATE_WANTED,
																								SCANGATE_SPECIES)
			if(new_mode)
				scangate_mode = new_mode
			. = TRUE
		if("toggle_reverse")
			reverse = !reverse
			. = TRUE
		if("set_disease_threshold")
			var/new_threshold = input("Set disease threshold","Scan Mode") as null|anything in list(DISEASE_SEVERITY_POSITIVE,
																								DISEASE_SEVERITY_NONTHREAT,
																								DISEASE_SEVERITY_MINOR,
																								DISEASE_SEVERITY_MEDIUM,
																								DISEASE_SEVERITY_HARMFUL,
																								DISEASE_SEVERITY_DANGEROUS,
																								DISEASE_SEVERITY_BIOHAZARD)
			if(new_threshold)
				disease_threshold = new_threshold
			. = TRUE
		if("set_nanite_cloud")
			var/new_cloud = input("Set target nanite cloud","Scan Mode", nanite_cloud) as null|num
			if(!isnull(new_cloud))
				nanite_cloud = CLAMP(round(new_cloud, 1), 1, 100)
			. = TRUE
		//Some species are not scannable, like abductors (too unknown), androids (too artificial) or skeletons (too magic)
		if("set_target_species")
			var/new_species = input("Set target species","Scan Mode") as null|anything in list("Human",
																								"Lizardperson",
																								"Flyperson",
																								"Plasmaman",
																								"Mothmen",
																								"Jellyperson",
																								"Podperson",
																								"Golem",
																								"Zombie")
			if(new_species)
				switch(new_species)
					if("Human")
						detect_species = /datum/species/human
					if("Lizardperson")
						detect_species = /datum/species/lizard
					if("Flyperson")
						detect_species = /datum/species/fly
					if("Plasmaman")
						detect_species = /datum/species/plasmaman
					if("Mothmen")
						detect_species = /datum/species/moth
					if("Jellyperson")
						detect_species = /datum/species/jelly
					if("Podperson")
						detect_species = /datum/species/pod
					if("Golem")
						detect_species = /datum/species/golem
					if("Zombie")
						detect_species = /datum/species/zombie
			. = TRUE

#undef SCANGATE_NONE
#undef SCANGATE_MINDSHIELD
#undef SCANGATE_NANITES
#undef SCANGATE_DISEASE
#undef SCANGATE_GUNS
#undef SCANGATE_WANTED
#undef SCANGATE_SPECIES