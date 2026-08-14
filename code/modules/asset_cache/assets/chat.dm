/datum/asset/spritesheet_batched/chat
	name = "chat"
	/// Default file for language icons
	var/default_language_file = 'icons/ui/chat/language.dmi'

/datum/asset/spritesheet_batched/chat/create_spritesheets()
	insert_all_icons("emoji", EMOJI_SET)
	// pre-loading all lanugage icons also helps to avoid meta
	insert_all_icons("language", default_language_file)
	// catch languages which are pulling icons from another file
	for(var/datum/language/lang_type as anything in subtypesof(/datum/language))
		var/icon = initial(lang_type.icon)
		var/icon_state = initial(lang_type.icon_state)
		if (icon != default_language_file)
			insert_icon("language-[icon_state]", uni_icon(icon, icon_state))

		var/datum/universal_icon/partial_icon = uni_icon(icon, icon_state)
		partial_icon.blend_icon(uni_icon(default_language_file, "unknown"), ICON_OVERLAY)
		insert_icon("language-[icon_state]-partial", partial_icon)

	var/datum/universal_icon/byond_member = uni_icon('icons/ui/chat/member_content.dmi', "blag")
	byond_member.scale(16, 16)
	insert_icon("byond_member", byond_member)
