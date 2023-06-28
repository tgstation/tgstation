/datum/tgs_message_content/proc/_interop_serialize()
	return list("text" = text, "embed" = embed?._interop_serialize())

/datum/tgs_chat_embed/proc/_interop_serialize()
	CRASH("Base /proc/interop_serialize called on [type]!")

/datum/tgs_chat_embed/structure/_interop_serialize()
	var/list/serialized_fields
	if(islist(fields))
		serialized_fields = list()
		for(var/datum/tgs_chat_embed/field/field as anything in fields)
			serialized_fields += list(field._interop_serialize())
	return list(
		"title" = title,
		"description" = description,
		"url" = url,
		"timestamp" = timestamp,
		"colour" = colour,
		"image" = image?._interop_serialize(),
		"thumbnail" = thumbnail?._interop_serialize(),
		"video" = video?._interop_serialize(),
		"footer" = footer?._interop_serialize(),
		"provider" = provider?._interop_serialize(),
		"author" = author?._interop_serialize(),
		"fields" = serialized_fields
	)

/datum/tgs_chat_embed/media/_interop_serialize()
	return list(
		"url" = url,
		"width" = width,
		"height" = height,
		"proxyUrl" = proxy_url
	)

/datum/tgs_chat_embed/provider/_interop_serialize()
	return list(
		"url" = url,
		"name" = name
	)

/datum/tgs_chat_embed/provider/author/_interop_serialize()
	. = ..()
	.["iconUrl"] = icon_url
	.["proxyIconUrl"] = proxy_icon_url
	
/datum/tgs_chat_embed/footer/_interop_serialize()
	return list(
		"text" = text,
		"iconUrl" = icon_url,
		"proxyIconUrl" = proxy_icon_url
	)

/datum/tgs_chat_embed/field/_interop_serialize()
	return list(
		"name" = name,
		"value" = value,
		"isInline" = is_inline
	)
