// TODO: Don't use prefs when spawned via admins
/mob/living/carbon/human/Login()
	. = ..()
	AddComponent(/datum/component/examine_panel)

/datum/dna/copy_dna(datum/dna/new_dna, transfer_flags = COPY_DNA_SE|COPY_DNA_SPECIES)
	. = ..()
	if(!iscarbon(new_dna.holder))
		return
	new_dna.holder.AddComponent(/datum/component/examine_panel)

/mob/living/silicon
	var/flavor_text

/mob/living/silicon/Login()
	. = ..()
	if(!flavor_text)
		flavor_text = client?.prefs.read_preference(/datum/preference/text/silicon_flavor_text)
	AddComponent(/datum/component/examine_panel)

/mob/living/proc/save_new_flavor_text(new_flavor_text)
	return

/mob/living/carbon/save_new_flavor_text(new_flavor_text)
	dna.features["flavor_text"] = new_flavor_text
	AddComponent(/datum/component/examine_panel)

/mob/living/silicon/save_new_flavor_text(new_flavor_text)
	flavor_text = new_flavor_text
	AddComponent(/datum/component/examine_panel)
