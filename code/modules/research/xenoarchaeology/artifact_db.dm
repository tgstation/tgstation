
/datum/catalogued_artifact
	var/trigger = "touch"      // What activates it?
	var/effecttype = "healing" // What does it do?
	var/effectmode = "aura"    // How does it carry out the effect?
	var/display_id = ""        // Artifact ID to display once successfully scanned
	var/origin = ""

/obj/machinery/computer/artifact_database
	name = "Artifact Database"
	icon_state = "rdcomp"
	var/list/catalogued_artifacts

/obj/machinery/computer/artifact_database/New()
	..()
	catalogued_artifacts = new/list

/obj/machinery/computer/artifact_database/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/artifact_database/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/computer/artifact_database/Topic(href, href_list)
	..()
	if( href_list["close"] )
		usr << browse(null, "window=artifact_db")
		usr.machine = null
	updateDialog()

/obj/machinery/computer/artifact_database/process()
	..()
	updateDialog()

/obj/machinery/computer/artifact_database/proc/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.machine = null
			user << browse(null, "window=artifact_db")
			return
	var/t = "<B>Artifact Database</B><BR>"
	t += "<hr>"
	for(var/datum/catalogued_artifact/CA in catalogued_artifacts)
		t += "<B>Artifact ID:</B> [CA.display_id] (determined from unique energy emission signatures)<BR>"
		t += "<B>Artifact Origin:</B> [CA.origin]<BR>"
		t += "<B>Activation Trigger:</B> [CA.trigger]<BR>"
		t += "<B>Artifact Function:</B> [CA.effecttype]<BR>"
		t += "<B>Artifact Range:</B> [CA.effectmode]<BR><BR>"
	t += "<hr>"
	t += "<A href='?src=\ref[src];refresh=1'>Refresh</A> <A href='?src=\ref[src];close=1'>Close</A><BR>"
	user << browse(t, "window=artifact_db;size=500x800")
	user.machine = src

/*
/datum/artifact_effect
	var/origin = null          // Used in the randomisation/research of the artifact.
	var/trigger = "touch"      // What activates it?
	var/triggerX = "none"      // Used for more varied triggers
	var/effecttype = "healing" // What does it do?
	var/effectmode = "aura"    // How does it carry out the effect?
	var/aurarange = 4          // How far the artifact will extend an aura effect.
	var/display_id = ""        // Artifact ID to display once successfully scanned
	var/list/created_field
*/