/datum/uplink_item/role_restricted/minibible
	name = "Miniature Bible"
	desc = "We understand it can be difficult to carry out some of our missions. Here is some spiritual counsel in a small package."
	progression_minimum = 5 MINUTES
	cost = 1
	item = /obj/item/storage/book/bible/mini
	restricted_roles = list(JOB_CHAPLAIN, JOB_CLOWN)

/datum/uplink_item/role_restricted/reverse_bear_trap
	surplus = 60

/datum/uplink_item/role_restricted/modified_syringe_gun
	surplus = 50

/datum/uplink_item/role_restricted/hacked_linked_surgery
	name = "Syndicate Surgery Implant"
	desc = "A powerful brain implant, capable of uploading perfect, forbidden surgical knowledge to its users mind, \
		allowing them to do just about any surgery, anywhere, without making any (unintentional) mistakes. \
		Comes with a syndicate autosurgeon for immediate self-application."
	cost = 12
	item = /obj/item/autosurgeon/syndicate/hacked_linked_surgery
	restricted_roles = list(JOB_CHIEF_MEDICAL_OFFICER, JOB_MEDICAL_DOCTOR, JOB_PARAMEDIC, JOB_ROBOTICIST)
	surplus = 50
