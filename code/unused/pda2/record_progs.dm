//CONTENTS:
//Generic records
//Security records
//Medical records


/datum/computer/file/pda_program/records
	var/mode = 0
	var/datum/data/record/active1 = null //General
	var/datum/data/record/active2 = null //Security/Medical/Whatever

//To-do: editing arrest status/etc from pda.
/datum/computer/file/pda_program/records/security
	name = "Security Records"
	size = 12.0

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		switch(src.mode)
			if(0)
				dat += "<h4>Security Record List</h4>"

				for (var/datum/data/record/R in data_core.general)
					dat += "<a href='byond://?src=\ref[src];select_rec=\ref[R]'>[R.fields["id"]]: [R.fields["name"]]<br>"

				dat += "<br>"

			if(1)

				dat += "<h4>Security Record</h4>"

				dat += "<a href='byond://?src=\ref[src];mode=0'>Back</a><br>"

				if (istype(src.active1, /datum/data/record) && data_core.general.Find(src.active1))
					dat += "Name: [src.active1.fields["name"]] ID: [src.active1.fields["id"]]<br>"
					dat += "Sex: [src.active1.fields["sex"]]<br>"
					dat += "Age: [src.active1.fields["age"]]<br>"
					dat += "Fingerprint: [src.active1.fields["fingerprint"]]<br>"
					dat += "Physical Status: [src.active1.fields["p_stat"]]<br>"
					dat += "Mental Status: [src.active1.fields["m_stat"]]<br>"
				else
					dat += "<b>Record Lost!</b><br>"

				dat += "<br>"

				dat += "<h4>Security Data</h4>"
				if (istype(src.active2, /datum/data/record) && data_core.security.Find(src.active2))
					dat += "Criminal Status: [src.active2.fields["criminal"]]<br>"

					dat += "Minor Crimes: [src.active2.fields["mi_crim"]]<br>"
					dat += "Details: [src.active2.fields["mi_crim"]]<br><br>"

					dat += "Major Crimes: [src.active2.fields["ma_crim"]]<br>"
					dat += "Details: [src.active2.fields["ma_crim_d"]]<br><br>"

					dat += "Important Notes:<br>"
					dat += "[src.active2.fields["notes"]]"
				else
					dat += "<b>Record Lost!</b><br>"

				dat += "<br>"

		return dat

	Topic(href, href_list)
		if(..())
			return

		if(href_list["mode"])
			var/newmode = text2num(href_list["mode"])
			src.mode = max(newmode, 0)

		else if(href_list["select_rec"])
			var/datum/data/record/R = locate(href_list["select_rec"])
			var/datum/data/record/S = locate(href_list["select_rec"])

			if (data_core.general.Find(R))
				for (var/datum/data/record/E in data_core.security)
					if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						S = E
						break

				src.active1 = R
				src.active2 = S

				src.mode = 1

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

/datum/computer/file/pda_program/records/medical
	name = "Medical Records"
	size = 8.0

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()

		switch(src.mode)
			if(0)

				dat += "<h4>Medical Record List</h4>"
				for (var/datum/data/record/R in data_core.general)
					dat += "<a href='byond://?src=\ref[src];select_rec=\ref[R]'>[R.fields["id"]]: [R.fields["name"]]<br>"
				dat += "<br>"

			if(1)

				dat += "<h4>Medical Record</h4>"

				dat += "<a href='byond://?src=\ref[src];mode=0'>Back</a><br>"

				if (istype(src.active1, /datum/data/record) && data_core.general.Find(src.active1))
					dat += "Name: [src.active1.fields["name"]] ID: [src.active1.fields["id"]]<br>"
					dat += "Sex: [src.active1.fields["sex"]]<br>"
					dat += "Age: [src.active1.fields["age"]]<br>"
					dat += "Fingerprint: [src.active1.fields["fingerprint"]]<br>"
					dat += "Physical Status: [src.active1.fields["p_stat"]]<br>"
					dat += "Mental Status: [src.active1.fields["m_stat"]]<br>"
				else
					dat += "<b>Record Lost!</b><br>"

				dat += "<br>"

				dat += "<h4>Medical Data</h4>"
				if (istype(src.active2, /datum/data/record) && data_core.medical.Find(src.active2))
					dat += "Blood Type: [src.active2.fields["b_type"]]<br><br>"

					dat += "Minor Disabilities: [src.active2.fields["mi_dis"]]<br>"
					dat += "Details: [src.active2.fields["mi_dis_d"]]<br><br>"

					dat += "Major Disabilities: [src.active2.fields["ma_dis"]]<br>"
					dat += "Details: [src.active2.fields["ma_dis_d"]]<br><br>"

					dat += "Allergies: [src.active2.fields["alg"]]<br>"
					dat += "Details: [src.active2.fields["alg_d"]]<br><br>"

					dat += "Current Diseases: [src.active2.fields["cdi"]]<br>"
					dat += "Details: [src.active2.fields["cdi_d"]]<br><br>"

					dat += "Important Notes: [src.active2.fields["notes"]]<br>"
				else
					dat += "<b>Record Lost!</b><br>"

				dat += "<br>"

		return dat

	Topic(href, href_list)
		if(..())
			return

		if(href_list["mode"])
			var/newmode = text2num(href_list["mode"])
			src.mode = max(newmode, 0)

		else if(href_list["select_rec"])
			var/datum/data/record/R = locate(href_list["select_rec"])
			var/datum/data/record/M = locate(href_list["select_rec"])

			if (data_core.general.Find(R))
				for (var/datum/data/record/E in data_core.medical)
					if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						M = E
						break

				src.active1 = R
				src.active2 = M

				src.mode = 1

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return