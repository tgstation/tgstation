/obj/item/sequence_scanner
	name = "genetic sequence scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "gene"
	inhand_icon_state = "healthanalyzer"
	worn_icon_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held scanner for analyzing someones gene sequence on the fly. Hold near a DNA console to update the internal database."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=200)
	var/list/discovered = list() //hit a dna console to update the scanners database
	var/list/buffer
	var/ready = TRUE
	var/cooldown = 200

/obj/item/sequence_scanner/attack(mob/living/M, mob/living/carbon/human/user)
	add_fingerprint(user)
	if (!HAS_TRAIT(M, TRAIT_GENELESS) && !HAS_TRAIT(M, TRAIT_BADDNA)) //no scanning if its a husk or DNA-less Species
		user.visible_message(span_notice("[user] analyzes [M]'s genetic sequence."), \
							span_notice("You analyze [M]'s genetic sequence."))
		gene_scan(M, user)

	else
		user.visible_message(span_notice("[user] fails to analyze [M]'s genetic sequence."), span_warning("[M] has no readable genetic sequence!"))

/obj/item/sequence_scanner/attack_self(mob/user)
	display_sequence(user)

/obj/item/sequence_scanner/attack_self_tk(mob/user)
	return

/obj/item/sequence_scanner/afterattack(obj/O, mob/user, proximity)
	. = ..()
	if(!istype(O) || !proximity)
		return

	if(istype(O, /obj/machinery/computer/scan_consolenew))
		var/obj/machinery/computer/scan_consolenew/C = O
		if(C.stored_research)
			to_chat(user, span_notice("[name] linked to central research database."))
			discovered = C.stored_research.discovered_mutations
		else
			to_chat(user,span_warning("No database to update from."))

/obj/item/sequence_scanner/proc/gene_scan(mob/living/carbon/C, mob/living/user)
	if(!iscarbon(C) || !C.has_dna())
		return
	buffer = C.dna.mutation_index
	to_chat(user, span_notice("Subject [C.name]'s DNA sequence has been saved to buffer."))
	if(LAZYLEN(buffer))
		for(var/A in buffer)
			to_chat(user, span_notice("[get_display_name(A)]"))


/obj/item/sequence_scanner/proc/display_sequence(mob/living/user)
	if(!LAZYLEN(buffer) || !ready)
		return
	var/list/options = list()
	for(var/A in buffer)
		options += get_display_name(A)

	var/answer = tgui_input_list(user, "Analyze Potential", "Sequence Analyzer", sort_list(options))
	if(isnull(answer))
		return
	if(ready && user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		var/sequence
		for(var/A in buffer) //this physically hurts but i dont know what anything else short of an assoc list
			if(get_display_name(A) == answer)
				sequence = buffer[A]
				break

		if(sequence)
			var/display
			for(var/i in 0 to length_char(sequence) / DNA_MUTATION_BLOCKS-1)
				if(i)
					display += "-"
				display += copytext_char(sequence, 1 + i*DNA_MUTATION_BLOCKS, DNA_MUTATION_BLOCKS*(1+i) + 1)

			to_chat(user, "[span_boldnotice("[display]")]<br>")

		ready = FALSE
		icon_state = "[icon_state]_recharging"
		addtimer(CALLBACK(src, .proc/recharge), cooldown, TIMER_UNIQUE)

/obj/item/sequence_scanner/proc/recharge()
	icon_state = initial(icon_state)
	ready = TRUE

/obj/item/sequence_scanner/proc/get_display_name(mutation)
	var/datum/mutation/human/HM = GET_INITIALIZED_MUTATION(mutation)
	if(!HM)
		return "ERROR"
	if(mutation in discovered)
		return  "[HM.name] ([HM.alias])"
	else
		return HM.alias
