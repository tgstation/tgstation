
/obj/item/device/antibody_scanner
	name = "immunity scanner"
	desc = "A hand-held body scanner able to evaluate the immune system of the subject."
	icon = 'monkestation/code/modules/virology/icons/items.dmi'
	icon_state = "antibody"
	inhand_icon_state = "healthanalyzer"
	worn_icon_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	siemens_coefficient = 1
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 5
	custom_materials = list(/datum/material/iron=200)


/obj/item/device/antibody_scanner/attack(mob/living/carbon/L, mob/living/carbon/human/user)
	if(!istype(L))
		//to_chat(user, span_notice("Incompatible object, scan aborted."))
		return

	if (issilicon(L))
		to_chat(user, span_warning("Incompatible with silicon lifeforms, scan aborted."))
		return

	playsound(user, 'sound/items/weeoo1.ogg', 50, 1)
	var/info = ""
	var/icon/scan = icon('monkestation/code/modules/virology/icons/virology_bg.dmi',"immunitybg")
	var/display_width = scan.Width()

	var/list/antigens_that_matter = list()
	if (L.immune_system)
		finding_antigens:
			for (var/antibody in L.immune_system.antibodies)
				if (L.immune_system.antibodies[antibody] > 0)
					antigens_that_matter += antibody
					continue
				if (length(L.diseases))
					for (var/datum/disease/advanced/D as anything in L.diseases)
						var/ID = "[D.uniqueID]-[D.subID]"
						if(ID in GLOB.virusDB)
							if (antibody in D.antigen)
								antigens_that_matter += antibody
								continue finding_antigens

	var/bar_spacing = round(display_width/antigens_that_matter.len)
	var/bar_width = round(bar_spacing/2)
	var/bar_offset = round(bar_width/4)
	var/x_adjustment = 5//Sometimes you have to adjust things manually so they look good. This var moves all the gauges and graduations on the x axis.

	if (L.immune_system)
		var/immune_system = L.immune_system.GetImmunity()
		var/immune_str = immune_system[1]
		var/list/antibodies = immune_system[2]

		info += "Immune System Status: <b>[round(immune_str*100)]%</b>"
		info += "<br>Antibody Concentrations:"

		var/i = 0
		for (var/antibody in antigens_that_matter)
			var/rgb = "#FFFFFF"
			switch (antibody)
				if ("O","A","B","Rh")
					rgb = "#80DEFF"
				if ("Q","U","V")
					rgb = "#81FF9F"
				if ("M","N","P")
					rgb = "#E6FF81"
				if ("X","Y","Z")
					rgb = "#FF9681"
				if ("C")
					rgb = "#F54B4B"
				//add colors for new special antigens here
			scan.DrawBox(rgb,i*bar_spacing+bar_offset+x_adjustment,6,i*bar_spacing+bar_width+bar_offset+x_adjustment,6+antibodies[antibody]*3)
			i++

	if (length(L.diseases))
		for (var/datum/disease/advanced/D as anything in L.diseases)
			var/ID = "[D.uniqueID]-[D.subID]"
			scan.DrawBox("#FF0000",6,6+D.strength*3,display_width-5,6+D.strength*3)
			if(ID in GLOB.virusDB)
				var/subdivision = (D.strength - ((D.robustness * D.strength) / 100)) / D.max_stages
				var/i = 0
				for (var/antigen in antigens_that_matter)
					if (antigen in D.antigen)
						var/box_size = 3
						scan.DrawBox("#FF0000",bar_width-box_size+bar_spacing*i,6+D.strength*3-3,bar_width+box_size+bar_spacing*i,6+D.strength*3+3)
						scan.DrawBox("#FF0000",bar_width+bar_spacing*i,6+D.strength*3,bar_width+bar_spacing*i,6+round(D.strength - D.max_stages * subdivision)*3)
						var/stick_out = 6//how far the graduations go left and right of the gauge
						for (var/j = 1 to D.max_stages)
							var/alt = round(D.strength - j * subdivision)
							scan.DrawBox("#FF0000",i*bar_spacing+bar_offset-stick_out+x_adjustment,6+alt*3,i*bar_spacing+bar_offset+bar_width+stick_out+x_adjustment,6+alt*3)
					i++

	info += "<br><img src='data:image/png;base64,[icon2base64(scan)]'/>"
	info += "<br>"
	info += "<table style='table-layout:fixed;width:560px;text-align:center'>"
	info += "<tr>"
	if (L.immune_system)
		for (var/antibody in antigens_that_matter)
			info += "<th>[antibody]</th>"
	info += "</tr>"
	info += "<tr>"
	if (L.immune_system)
		for (var/antibody in antigens_that_matter)
			info += "<td>[round(L.immune_system.antibodies[antibody])]%</th>"
	info += "</tr>"
	info += "</table>"

	if (length(L.diseases))
		for (var/datum/disease/advanced/D as anything in L.diseases)
			var/ID = "[D.uniqueID]-[D.subID]"
			if(ID in GLOB.virusDB)
				var/datum/data/record/V = GLOB.virusDB[ID]
				info += "<br><i>[V.fields["name"]][V.fields["nickname"] ? " \"[V.fields["nickname"]]\"" : ""] detected. Strength: [D.strength]. Robustness: [D.robustness]. Antigen: [D.get_antigen_string()]</i>"
				for(var/datum/symptom/e in D.symptoms)
					info += "<br><b>Stage [e.stage] - [e.name]</b> (Danger: [e.badness]): <i>[e.desc]</i>"
			else
				info += "<br><i>Unknown [D.form] detected. Strength: [D.strength]</i>"

	var/datum/browser/popup = new(user, "\ref[src]", name, 600, 600, src)
	popup.set_content(info)
	popup.open()

/obj/item/device/antibody_scanner/pre_attack(atom/A, mob/living/user, params)
	if(!Adjacent(A))
		return
	if (isitem(A))
		var/obj/item/I = A
		playsound(user, 'sound/items/weeoo1.ogg', 50, 1)
		var/span = "warning"
		if(I.sterility <= 0)
			span = "danger"
		else if (I.sterility >= 100)
			span = "notice"
		to_chat(user,"<span class='[span]'>Scanning \the [I]...sterility level = [I.sterility]%</span>")
		if (istype(I,/obj/item/weapon/virusdish))
			var/obj/item/weapon/virusdish/dish = I
			if (dish.open && dish.contained_virus)
				to_chat(user,span_danger("However, since its lid has been opened, unprotected contact with the dish can result in infection."))

	. = ..()
