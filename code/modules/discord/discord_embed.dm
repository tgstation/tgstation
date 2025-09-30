/// Documentation for the embed object and all of its variables can be found at
/// https://discord.com/developers/docs/resources/channel#embed-object
/// It is recommended to read the documentation on the discord website, as the information below could become outdated in the future.
/datum/discord_embed
	/// Title of the embed
	var/title
	/// The description
	var/description
	/// The URL that the title
	var/url
	/// The colour that appears on the top of the embed. This is an integer and is the color code of the embed.
	var/color
	/// The footer that appears on the embed
	var/footer
	/// String representing a link to an image
	var/image
	/// String representing a link to the thumbnail image
	var/thumbnail
	/// String representing a link to the video
	var/video
	/// String representing the name of the provider
	var/provider
	/// String representing the link of the provider
	var/provider_url
	/// Name of the author of the embed
	var/author
	/// A key-value string list of fields that should be displayed
	var/list/fields
	/// Any content that should appear above the embed
	var/content

/datum/discord_embed/proc/convert_to_list()
	if(color && !isnum(color))
		CRASH("Color on [type] is not a number! Expected a number, got [color] instead.")
	var/list/data_to_list = list()
	if(title)
		data_to_list["title"] = title
	if(description)
		var/new_desc = replacetext(replacetext(description, "\proper", ""), "\improper", "")
		new_desc = GLOB.has_discord_embeddable_links.Replace(replacetext(new_desc, "`", ""), " ```$1``` ")
		data_to_list["description"] = new_desc
	if(url)
		data_to_list["url"] = url
	if(color)
		data_to_list["color"] = color
	if(footer)
		data_to_list["footer"] = list(
			"text" = footer,
		)
	if(image)
		data_to_list["image"] = list(
			"url" = image,
		)
	if(thumbnail)
		data_to_list["thumbnail"] = list(
			"url" = thumbnail,
		)
	if(video)
		data_to_list["video"] = list(
			"url" = video,
		)
	if(provider)
		data_to_list["provider"] = list(
			"name" = provider,
			"url" = provider_url,
		)
	if(author)
		data_to_list["author"] = list(
			"author" = author,
		)
	if(fields)
		data_to_list["fields"] = list()
		for(var/data in fields)
			if(!fields[data])
				continue
			data_to_list["fields"] += list(list(
				"name" = data,
				"value" = GLOB.has_discord_embeddable_links.Replace(replacetext(fields[data], "`", ""), " ```$1``` "),
			))
	return data_to_list
