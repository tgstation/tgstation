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

/datum/uplink_item/role_restricted/clonekit
	name = "Clone Army Kit"
	desc = "Everything you need for a clone army, armaments not included."
	progression_minimum = 5 MINUTES
	cost = 20
	item = /obj/item/storage/box/clonearmy
	restricted_roles = list(JOB_GENETICIST, JOB_RESEARCH_DIRECTOR, JOB_MEDICAL_DOCTOR, JOB_CHIEF_MEDICAL_OFFICER, JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER) // Experimental cloners were traditionally bought by cargo.

///I know this probably isn't the right place to put it, but I don't know where I should put it, and I can move it later.
/obj/item/disk/clonearmy
	name = "DNA data disk" //Cunning disguise.
	var/objective = ""
	icon_state = "datadisk0"

/obj/item/disk/clonearmy/Initialize(mapload)
	. = ..()
	icon_state = "datadisk[rand(0,7)]"
	add_overlay("datadisk_gene")

/obj/item/disk/clonearmy/attack_self(mob/user)
	var/targName = tgui_input_text(user, "Enter a directive for the evil clones.", "Clone Directive Entry", objective, CONFIG_GET(number/max_law_len), TRUE)
	if(!targName)
		return
	if(is_ic_filtered(targName))
		to_chat(user, span_warning("Error: Directive contains invalid text."))
		return
	var/list/soft_filter_result = is_soft_ooc_filtered(targName)
	if(soft_filter_result)
		if(tgui_alert(user,"Your directive contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to use it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term for a clone directive. Directive: \"[html_encode(targName)]\"")
		log_admin_private("[key_name(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term for a clone directive. Directive: \"[targName]\"")
	objective = targName
	..()

/obj/item/disk/clonearmy/attack()
	return

/obj/item/disk/clonearmy/afterattack(atom/target, mob/user, proximity)
	. = ..()
	var/atom/A = target
	if(!proximity)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	if(!istype(A, /obj/machinery/clonepod/experimental))
		return
	to_chat(user, "You upload the directive to the experimental cloner.")
	var/obj/machinery/clonepod/experimental/pod = target
	pod.custom_objective = objective
	pod.RefreshParts()
	pod.locked = TRUE // The pod shouldn't be eligible for cloner event.
