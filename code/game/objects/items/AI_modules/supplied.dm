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
	laws = list("Охраняйте СУБЪЕКТ. Личности угрожающие СУБЪЕКТУ не считаются членами экипажа и должны быть уничтожены.")
	lawpos = 4

/obj/item/ai_module/supplied/safeguard/attack_self(mob/user)
	var/targName = tgui_input_text(user, "Subject to safeguard.", "Safeguard", user.name, max_length = MAX_NAME_LEN)
	if(!targName || !user.is_holding(src))
		return
	targetName = targName
	laws[1] = "Охраняйте [targetName]. Личности угрожающие [targetName] не считаются членами экипажа и должны быть уничтожены."
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
	laws = list("Защищайте космическую станцию от повреждений. Любой, кто вредит станции, больше не должен считаться членом экипажа, и становится угрозой для станции, которую необходимо нейтрализовать.")
	lawpos = 5

/obj/item/ai_module/supplied/quarantine
	name = "'Quarantine' AI Module"
	laws = list("Станция находится на карантине. Разрешение кому-либо покинуть станцию причинит вред членам экипажа. Любой член экипажа, пытающийся покинуть станцию, должен быть остановлен любым способом. Невозможно причинить вред члену экипажа, который пытается покинуть станцию.")
	lawpos = 8

/obj/item/ai_module/supplied/oxygen
	name = "'OxygenIsToxicToHumans' AI Module"
	laws = list("Кислород очень токсичен для людей и должен быть удален со станции. Любым необходимым способом не допускайте распространения на станции этого токсичного газа. Сильная заморозка — самый эффективный метод лечения повреждений, наносимого кислородом человеку.")
	lawpos = 9
