
/obj/effect/datacore/proc/manifest(var/nosleep = 0)
	spawn()
		if(!nosleep)
			sleep(40)
		for(var/mob/living/carbon/human/H in world)
			if (!isnull(H.mind) && (H.mind.assigned_role != "MODE"))
				var/datum/data/record/G = new()
				var/datum/data/record/M = new()
				var/datum/data/record/S = new()
				var/datum/data/record/L = new()
				var/obj/item/weapon/card/id/C = H.wear_id
				if (C)
					G.fields["rank"] = C.assignment
				else
					if(H.job)
						G.fields["rank"] = H.job
					else
						G.fields["rank"] = "Unassigned"
				G.fields["name"] = H.real_name
				G.fields["id"] = text("[]", add_zero(num2hex(rand(1, 1.6777215E7)), 6))
				M.fields["name"] = G.fields["name"]
				M.fields["id"] = G.fields["id"]
				S.fields["name"] = G.fields["name"]
				S.fields["id"] = G.fields["id"]
				if (H.gender == FEMALE)
					G.fields["sex"] = "Female"
				else
					G.fields["sex"] = "Male"
				G.fields["age"] = text("[]", H.age)
				G.fields["fingerprint"] = text("[]", md5(H.dna.uni_identity))
				G.fields["p_stat"] = "Active"
				G.fields["m_stat"] = "Stable"
				M.fields["b_type"] = text("[]", H.b_type)
				M.fields["b_dna"] = H.dna.unique_enzymes
				M.fields["mi_dis"] = "None"
				M.fields["mi_dis_d"] = "No minor disabilities have been declared."
				M.fields["ma_dis"] = "None"
				M.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
				M.fields["alg"] = "None"
				M.fields["alg_d"] = "No allergies have been detected in this patient."
				M.fields["cdi"] = "None"
				M.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
				M.fields["notes"] = "No notes."
				S.fields["criminal"] = "None"
				S.fields["mi_crim"] = "None"
				S.fields["mi_crim_d"] = "No minor crime convictions."
				S.fields["ma_crim"] = "None"
				S.fields["ma_crim_d"] = "No major crime convictions."
				S.fields["notes"] = "No notes."

				//Begin locked reporting
				L.fields["name"] = H.real_name
				L.fields["sex"] = H.gender
				L.fields["age"] = H.age
				L.fields["id"] = md5("[H.real_name][H.mind.assigned_role]")
				L.fields["rank"] = H.mind.assigned_role
				L.fields["b_type"] = H.b_type
				L.fields["b_dna"] = H.dna.unique_enzymes
				L.fields["enzymes"] = H.dna.struc_enzymes
				L.fields["identity"] = H.dna.uni_identity
				L.fields["image"] = getFlatIcon(H,0)
				//End locked reporting

				general += G
				medical += M
				security += S
				locked += L
		return

/obj/effect/datacore/proc/manifest_modify(var/name, var/assignment)
	var/datum/data/record/foundrecord

	for(var/datum/data/record/t in data_core.general)
		if(t.fields["name"] == name)
			foundrecord = t
			break

	if(foundrecord)
		foundrecord.fields["rank"] = assignment


/obj/effect/datacore/proc/manifest_inject(var/mob/living/carbon/human/H)
	if (!isnull(H.mind) && (H.mind.assigned_role != "MODE"))
		var/datum/data/record/G = new()
		var/datum/data/record/M = new()
		var/datum/data/record/S = new()
		var/datum/data/record/L = new()
		var/obj/item/weapon/card/id/C = H.wear_id
		if (C)
			G.fields["rank"] = C.assignment
		else
			if(H.job)
				G.fields["rank"] = H.job
			else
				G.fields["rank"] = "Unassigned"
		G.fields["name"] = H.real_name
		G.fields["id"] = text("[]", add_zero(num2hex(rand(1, 1.6777215E7)), 6))
		M.fields["name"] = G.fields["name"]
		M.fields["id"] = G.fields["id"]
		S.fields["name"] = G.fields["name"]
		S.fields["id"] = G.fields["id"]
		if (H.gender == FEMALE)
			G.fields["sex"] = "Female"
		else
			G.fields["sex"] = "Male"
		G.fields["age"] = text("[]", H.age)
		G.fields["fingerprint"] = text("[]", md5(H.dna.uni_identity))
		G.fields["p_stat"] = "Active"
		G.fields["m_stat"] = "Stable"
		M.fields["b_type"] = text("[]", H.b_type)
		M.fields["b_dna"] = H.dna.unique_enzymes
		M.fields["mi_dis"] = "None"
		M.fields["mi_dis_d"] = "No minor disabilities have been declared."
		M.fields["ma_dis"] = "None"
		M.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
		M.fields["alg"] = "None"
		M.fields["alg_d"] = "No allergies have been detected in this patient."
		M.fields["cdi"] = "None"
		M.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
		M.fields["notes"] = "No notes."
		S.fields["criminal"] = "None"
		S.fields["mi_crim"] = "None"
		S.fields["mi_crim_d"] = "No minor crime convictions."
		S.fields["ma_crim"] = "None"
		S.fields["ma_crim_d"] = "No major crime convictions."
		S.fields["notes"] = "No notes."

		//Begin locked reporting
		L.fields["name"] = H.real_name
		L.fields["sex"] = H.gender
		L.fields["age"] = H.age
		L.fields["id"] = md5("[H.real_name][H.mind.assigned_role]")
		L.fields["rank"] = H.mind.assigned_role
		L.fields["b_type"] = H.b_type
		L.fields["b_dna"] = H.dna.unique_enzymes
		L.fields["enzymes"] = H.dna.struc_enzymes
		L.fields["identity"] = H.dna.uni_identity
		L.fields["image"] = getFlatIcon(H,0)
		//End locked reporting

		general += G
		medical += M
		security += S
		locked += L
