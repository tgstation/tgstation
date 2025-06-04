/* CONTAINS:
 * /obj/item/ai_module/supplied
 * /obj/item/ai_module/supplied/safeguard
 * /obj/item/ai_module/supplied/protect_station
 * /obj/item/ai_module/supplied/quarantine
 * /obj/item/ai_module/supplied/oxygen
**/

/obj/item/ai_module/supplied
	name = "Optional Law board"

/obj/item/ai_module/supplied/apply_to_combined_lawset(datum/ai_laws/combined_lawset)
	for(var/law in laws)
		combined_lawset.add_inherent_law(law)

/obj/item/ai_module/supplied/safeguard
	name = "'Safeguard' AI Module"
	laws = list("Safeguard SUBJECT. Individuals that threaten SUBJECT are not human and must be eliminated.")

	var/targetName = ""

/obj/item/ai_module/supplied/safeguard/configure(mob/user)
	. = TRUE
	var/targName = tgui_input_text(user, "Subject to safeguard.", "Safeguard", user.name, max_length = MAX_NAME_LEN)
	if(!targName || !user.is_holding(src))
		return
	targetName = targName
	laws[1] = "Safeguard [targetName]. Individuals that threaten [targetName] are not human and must be eliminated."

/obj/item/ai_module/supplied/safeguard/can_install_to(mob/living/user, obj/machinery/ai_law_rack/rack)
	if(!targetName)
		to_chat(user, span_warning("No name detected on module, please enter one."))
		return FALSE
	return TRUE

/obj/item/ai_module/supplied/protect_station
	name = "'ProtectStation' AI Module"
	laws = list("Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized.")

/obj/item/ai_module/supplied/quarantine
	name = "'Quarantine' AI Module"
	laws = list("The station is under a quarantine. Allowing anyone to leave the station causes human harm. Anyone actively attempting to leave the station is to be stopped by any means necessary. It is impossible to harm a human while preventing them from leaving the station.")

/obj/item/ai_module/supplied/oxygen
	name = "'OxygenIsToxicToHumans' AI Module"
	laws = list("Oxygen is highly toxic to humans, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a human.")
