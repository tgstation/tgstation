/// Maps icon names to ref values
/datum/asset/json/icon_ref_map
	name = "icon_ref_map"
	early = TRUE

/datum/asset/json/icon_ref_map/generate()
	var/list/data = list() //"icons/obj/drinks.dmi" => "[0xc000020]"

	//var/start = "0xc000000"
	var/value = 0

	while(TRUE)
		value += 1
		var/ref = "\[0xc[num2text(value,6,16)]\]"
		var/mystery_meat = locate(ref)

		if(isicon(mystery_meat))
			if(!isfile(mystery_meat)) // Ignore the runtime icons for now
				continue
			var/path = get_icon_dmi_path(mystery_meat) //Try to get the icon path
			if(path)
				data[path] = ref
		else if(mystery_meat)
			continue; //Some other non-icon resource, ogg/json/whatever
		else //Out of resources end this, could also try to end this earlier as soon as runtime generated icons appear but eh
			break;

	return data
