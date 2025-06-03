/* CONTAINS:
 * /obj/item/ai_module/core/freeformcore
 * /obj/item/ai_module/supplied/freeform
**/

/obj/item/ai_module/core/freeformcore
	name = "'Freeform' Core AI Module"
	laws = list("")

/obj/item/ai_module/core/freeformcore/configure(mob/user)
	. = TRUE
	var/targName = tgui_input_text(user, "Enter a new core law for the AI.", "Freeform Law Entry", laws[1], max_length = CONFIG_GET(number/max_law_len), multiline = TRUE)
	if(!targName || !user.is_holding(src))
		return
	if(is_ic_filtered(targName))
		to_chat(user, span_warning("Error: Law contains invalid text."))
		return
	var/list/soft_filter_result = is_soft_ooc_filtered(targName)
	if(soft_filter_result)
		if(tgui_alert(user,"Your law contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to use it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term for an AI law. Law: \"[html_encode(targName)]\"")
		log_admin_private("[key_name(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term for an AI law. Law: \"[targName]\"")
	laws[1] = targName

/obj/item/ai_module/supplied/freeform
	name = "'Freeform' AI Module"
	laws = list("")

/obj/item/ai_module/supplied/freeform/configure(mob/user)
	. = TRUE
	var/targName = tgui_input_text(user, "Enter a new law for the AI.", "Freeform Law Entry", laws[1], max_length = CONFIG_GET(number/max_law_len), multiline = TRUE)
	if(!targName || !user.is_holding(src))
		return
	if(is_ic_filtered(targName))
		to_chat(user, span_warning("Error: Law contains invalid text.")) // AI LAW 2 SAY U W U WITHOUT THE SPACES
		return
	var/list/soft_filter_result = is_soft_ooc_filtered(targName)
	if(soft_filter_result)
		if(tgui_alert(user,"Your law contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to use it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term for an AI law. Law: \"[html_encode(targName)]\"")
		log_admin_private("[key_name(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term for an AI law. Law: \"[targName]\"")
	laws[1] = targName
