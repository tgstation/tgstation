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
	icon = 'icons/obj/TODO.dmi'
	icon_state = "scanner_gate"
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	circuit = /obj/item/circuitboard/machine/scanner_gate
	
	var/locked = FALSE
	var/scangate_mode = SCANGATE_NONE
	var/disease_threshold = DISEASE_SEVERITY_MINOR
	var/detect_species = /datum/species/human
	var/reverse = FALSE //If true, signals if the scan returns false
	
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
	switch(scan_type)
		if(SCANGATE_NONE)
			return
		if(SCANGATE_WANTED)
			var/perpname = M.get_face_name(M.get_id_name())
			var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.security)
			if(!R || (R.fields["criminal"] == "*Arrest*"))
				beep = TRUE
		if(SCANGATE_MINDSHIELD)
			if(M.has_trait(TRAIT_MINDSHIELD))
				beep = TRUE
		if(SCANGATE_NANITES)
			if(SEND_SIGNAL(M, COMSIG_HAS_NANITES))
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
		if(SCANGATE_GUNS))
			for(var/I in M.get_contents())
				if(istype(I, /obj/item/gun))
					beep = TRUE
					break
	if(reverse)
		beep = !beep
	if(beep)
		alarm_beep()
		
/obj/machinery/scanner_gate/proc/alarm_beep()
	playsound(src, 'sound/machines/alarm.ogg', 100, 0)
	var/mutable_appearance/red_light = mutable_appearance(icon, "scanner_gate_alarm", ABOVE_LIGHTING_LAYER)
	add_overlay(red_light)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/cut_overlay, red_light),20)
	
/obj/machinery/scanner_gate/can_interact(mob/user)
	if(locked)
		return FALSE
	return ..()
	
/obj/machinery/scanner_gate/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "scanner_gate", name, 300, 500, master_ui, state)
		ui.open()	
	
/obj/machinery/scanner_gate/ui_data()
	var/list/data = list()
	data["scan_mode"] = scangate_mode
	data["reverse"] = reverse
	data["disease_treshold"] = disease_threshold
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
			var/new_threshold = input("Choose the scan mode","Scan Mode") as null|anything in list(DISEASE_SEVERITY_POSITIVE,
																								DISEASE_SEVERITY_NONTHREAT,
																								DISEASE_SEVERITY_MINOR,
																								DISEASE_SEVERITY_MEDIUM,
																								DISEASE_SEVERITY_HARMFUL,
																								DISEASE_SEVERITY_DANGEROUS,
																								DISEASE_SEVERITY_BIOHAZARD)
			if(new_threshold)
				disease_threshold = new_threshold
			. = TRUE
		//Some species are not scannable, like abductors (too unknown), androids (too artificial) or skeletons (too magic)
		if("set_target_species")
			var/new_species = input("Choose the scan mode","Scan Mode") as null|anything in list("Human",
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