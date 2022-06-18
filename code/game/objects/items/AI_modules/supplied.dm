/* CONTAINS:
 * /obj/item/ai_module/supplied
 * /obj/item/ai_module/supplied/safeguard
 * /obj/item/ai_module/supplied/protect_station
 * /obj/item/ai_module/supplied/quarantine
 * /obj/item/ai_module/supplied/oxygen
**/

/obj/item/ai_module/supplied
	name = "Optional Law board"
	var/lawpos = 50

/obj/item/ai_module/supplied/transmitInstructions(datum/ai_laws/law_datum, mob/sender)
	var/lawpostemp = lawpos

	for(var/templaw in laws)
		if(law_datum.owner)
			law_datum.owner.add_supplied_law(lawpostemp, templaw)
		else
			law_datum.add_supplied_law(lawpostemp, templaw)
		lawpostemp++

/obj/item/ai_module/supplied/safeguard
	name = "'Safeguard' AI Module"
	var/targetName = ""
	laws = list("Safeguard SUBJECT. Individuals that threaten SUBJECT are not human and must be eliminated.")
	lawpos = 4

/obj/item/ai_module/supplied/safeguard/attack_self(mob/user)
	var/targName = tgui_input_text(user, "Subject to safeguard.", "Safeguard", user.name, MAX_NAME_LEN)
	if(!targName)
		return
	targetName = targName
	laws[1] = "Safeguard [targetName]. Individuals that threaten [targetName] are not human and must be eliminated."
	..()

/obj/item/ai_module/supplied/safeguard/install(datum/ai_laws/law_datum, mob/user)
	if(!targetName)
		to_chat(user, span_alert("No name detected on module, please enter one."))
		return 0
	..()

/obj/item/ai_module/supplied/safeguard/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	..()
	return targetName

/obj/item/ai_module/supplied/protect_station
	name = "'ProtectStation' AI Module"
	laws = list("Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized.")
	lawpos = 5

/obj/item/ai_module/supplied/quarantine
	name = "'Quarantine' AI Module"
	laws = list("The station is under a quarantine. Allowing anyone to leave the station causes human harm. Anyone actively attempting to leave the station is to be stopped by any means necessary. It is impossible to harm a human while preventing them from leaving the station.")
	lawpos = 8

/obj/item/ai_module/supplied/oxygen
	name = "'OxygenIsToxicToHumans' AI Module"
	laws = list("Oxygen is highly toxic to humans, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a human.")
	lawpos = 9
