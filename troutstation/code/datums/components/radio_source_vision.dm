/// Component to grant any mob with it the ability to see active radios in their field of vision, including those in mobs.
/datum/component/radio_source_vision
	dupe_mode = COMPONENT_DUPE_SOURCES
	var/vision_distance = 9
	var/list/radio_images = list()

/datum/component/radio_source_vision/Initialize()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/radio_source_vision/RegisterWithParent()
	START_PROCESSING(SSobj, src)

/datum/component/radio_source_vision/UnregisterFromParent()
	STOP_PROCESSING(SSobj, src)

/datum/component/radio_source_vision/process()
	// show to our holder
	radio_source_scan(parent, vision_distance)
	// show to anyone directly observing
	var/mob/mob_parent = parent
	if(length(mob_parent.observers))
		for(var/mob/dead/observe as anything in mob_parent.observers)
			if(observe.client && observe.client.eye == mob_parent)
				if(length(radio_images))
					for(var/image/existing in radio_images)
						add_image_to_client(existing, observe.client)
			else
				if(length(radio_images))
					for(var/image/existing in radio_images)
						remove_image_from_client(existing, observe.client)
				mob_parent.observers -= observe
				if(!mob_parent.observers.len)
					mob_parent.observers = null
					break


/datum/component/radio_source_vision/proc/radio_source_scan(mob/viewer, distance = 3)
	if(!ismob(viewer) || !viewer.client)
		return

	// clean out old images
	if(!ismob(viewer) || !viewer.client)
		return
	if(length(radio_images))
		for(var/image/existing in radio_images)
			remove_image_from_client(existing, viewer.client)
	radio_images = list()

	// make new ones
	var/image/I
	var/list/radios = get_radios_nearby(viewer, distance)
	for(var/obj/item/radio/radio in radios)
		if(!radio.is_on())
			continue
		var/atom/location = radio.loc
		if(isturf(location))
			I = radio_source_make_overlay_image(radio, radio)
		else
			I = radio_source_make_overlay_image(location, radio)
		radio_images += I
		add_image_to_client(I, viewer.client)

/datum/component/radio_source_vision/proc/radio_source_make_overlay_image(atom/source, obj/item/radio/radio)
	var/radio_mode = "on"
	if(radio.get_broadcasting() && radio.get_listening())
		radio_mode = "both"
	else if(radio.get_broadcasting())
		radio_mode = "broadcasting"
	else if(radio.get_listening())
		radio_mode = "listening"
	var/image/I = new(loc = source)
	var/mutable_appearance/MA = mutable_appearance('troutstation/icons/mob/hud/hud.dmi', icon_state = "radio_[radio_mode]")
	MA.alpha = 192
	MA.dir = radio.dir
	I.appearance = MA
	SET_PLANE(I, ABOVE_LIGHTING_PLANE, source)
	return I
