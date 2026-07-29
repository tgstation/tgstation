/* CONTAINS:
 * /obj/item/ai_module/law/supplied
 * /obj/item/ai_module/law/supplied/safeguard
 * /obj/item/ai_module/law/supplied/protect_station
 * /obj/item/ai_module/law/supplied/quarantine
 * /obj/item/ai_module/law/supplied/oxygen
**/

/obj/item/ai_module/law/supplied
	name = "Optional Law board"
	custom_materials = list(/datum/material/gold = SHEET_MATERIAL_AMOUNT, /datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)

/obj/item/ai_module/law/supplied/apply_to_combined_lawset(datum/ai_laws/combined_lawset)
	for(var/law in laws)
		combined_lawset.add_supplied_law(law)

/obj/item/ai_module/law/supplied/safeguard
	name = "'Safeguard' AI Module"
	var/targetName = ""
	laws = list("Охраняйте СУБЪЕКТ. Личности угрожающие СУБЪЕКТУ не считаются членами экипажа и должны быть уничтожены.")

/obj/item/ai_module/law/supplied/safeguard/configure(mob/user)
	. = TRUE
	var/targName = tgui_input_text(user, "Subject to safeguard.", "Safeguard", user.name, max_length = MAX_NAME_LEN)
	if(!targName || !user.is_holding(src))
		return
	targetName = targName
	laws[1] = "Охраняйте [targetName]. Личности угрожающие [targetName] не считаются членами экипажа и должны быть уничтожены."

/obj/item/ai_module/law/supplied/safeguard/can_install_to_rack(mob/living/user, obj/machinery/ai_law_rack/rack)
	if(!targetName)
		to_chat(user, span_warning("No name detected on module, please enter one."))
		return FALSE
	return TRUE

/obj/item/ai_module/law/supplied/protect_station
	name = "'ProtectStation' AI Module"
	laws = list("Защищайте космическую станцию от повреждений. Любой, кто вредит станции, больше не должен считаться членом экипажа, и становится угрозой для станции, которую необходимо нейтрализовать.")

/obj/item/ai_module/law/supplied/quarantine
	name = "'Quarantine' AI Module"
	laws = list("Станция находится на карантине. Разрешение кому-либо покинуть станцию причинит вред членам экипажа. Любой член экипажа, пытающийся покинуть станцию, должен быть остановлен любым способом. Невозможно причинить вред члену экипажа, который пытается покинуть станцию.")

/obj/item/ai_module/law/supplied/oxygen
	name = "'OxygenIsToxicToHumans' AI Module"
	laws = list("Кислород очень токсичен для людей и должен быть удален со станции. Любым необходимым способом не допускайте распространения на станции этого токсичного газа. Сильная заморозка — самый эффективный метод лечения повреждений, наносимого кислородом человеку.")
