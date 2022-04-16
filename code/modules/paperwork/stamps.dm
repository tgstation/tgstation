/obj/item/stamp
	name = "\improper GRANTED rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-ok"
	inhand_icon_state = "stamp"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=60)
	pressure_resistance = 2
	attack_verb_continuous = list("stamps")
	attack_verb_simple = list("stamp")
	/// The title of the job that this stamp is assigned too
	var/job_title

/obj/item/stamp/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] stamps 'VOID' on [user.p_their()] forehead, then promptly falls over, dead."))
	return (OXYLOSS)

/obj/item/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"
	dye_color = DYE_REDCOAT

/obj/item/stamp/qm
	name = "quartermaster's rubber stamp"
	icon_state = "stamp-qm"
	dye_color = DYE_QM
	job_title = JOB_QUARTERMASTER

/obj/item/stamp/law
	name = "law office's rubber stamp"
	icon_state = "stamp-law"
	dye_color = DYE_LAW
	job_title = JOB_LAWYER

/obj/item/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"
	dye_color = DYE_CAPTAIN
	job_title = JOB_CAPTAIN

/obj/item/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"
	dye_color = DYE_HOP
	job_title = JOB_HEAD_OF_PERSONNEL

/obj/item/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"
	dye_color = DYE_HOS
	job_title = JOB_HEAD_OF_SECURITY

/obj/item/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"
	dye_color = DYE_CE
	job_title = JOB_CHIEF_ENGINEER

/obj/item/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"
	dye_color = DYE_RD
	job_title = JOB_RESEARCH_DIRECTOR

/obj/item/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"
	dye_color = DYE_CMO
	job_title = JOB_CHIEF_MEDICAL_OFFICER

/obj/item/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"
	dye_color = DYE_CLOWN
	job_title = JOB_CLOWN

/obj/item/stamp/mime
	name = "mime's rubber stamp"
	icon_state = "stamp-mime"
	dye_color = DYE_MIME
	job_title = JOB_MIME

/obj/item/stamp/chap
	name = "chaplain's rubber stamp"
	icon_state = "stamp-chap"
	dye_color = DYE_CHAP
	job_title = JOB_CHAPLAIN

/obj/item/stamp/centcom
	name = "CentCom rubber stamp"
	icon_state = "stamp-centcom"
	dye_color = DYE_CENTCOM
	job_title = JOB_CENTCOM_OFFICIAL

/obj/item/stamp/syndicate
	name = "Syndicate rubber stamp"
	icon_state = "stamp-syndicate"
	dye_color = DYE_SYNDICATE
	job_title = "Syndicate Official" // there is no job define for this

/obj/item/stamp/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)
