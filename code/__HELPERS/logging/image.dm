/proc/log_image(text, list/data)
	logger.Log(LOG_CATEGORY_IMAGE, text, data)
	logger.Log(LOG_CATEGORY_COMPAT_GAME, "IMAGE: [text]")

/// Log the creation of an image by a player
/proc/log_player_image_creation(message, mob/author = usr, icon/created_icon)
	if(!CONFIG_GET(flag/log_image))
		return
	GLOB.sprite_auditor.add_entry(created_icon, author)
	var/datum/log_category/category = logger.log_categories[/datum/log_category/image]
	var/output_directory
	if(category.secret)
		output_directory = "[GLOB.log_directory]/secret/[category.category]"
	else
		output_directory = "[GLOB.log_directory]/[category.category]"
	var/filename = "[copytext(md5("\icon[created_icon]"), 1, 6)].dmi"
	fcopy(created_icon, "[output_directory]/[filename]")
	log_image(message, list(
		"ckey" = author.ckey,
		"file_name" = filename,
	))
