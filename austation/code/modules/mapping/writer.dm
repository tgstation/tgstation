///////////////////////////////////////////////////////////////
//SS13 Optimized Map loader
//////////////////////////////////////////////////////////////
#define DMM_IGNORE_AREAS 1
#define DMM_IGNORE_TURFS 2
#define DMM_IGNORE_OBJS 4
#define DMM_IGNORE_NPCS 8
#define DMM_IGNORE_PLAYERS 16
#define DMM_IGNORE_MOBS 24

/datum/map_writer_vars
	var/static/quote = "\""
	var/static/list/letter_digits = list(
		"a","b","c","d","e",
		"f","g","h","i","j",
		"k","l","m","n","o",
		"p","q","r","s","t",
		"u","v","w","x","y",
		"z",
		"A","B","C","D","E",
		"F","G","H","I","J",
		"K","L","M","N","O",
		"P","Q","R","S","T",
		"U","V","W","X","Y",
		"Z"
	)

/proc/write_map(minx as num, miny as num, minz as num, maxx as num, maxy as num, maxz as num, var/flags as num)
	var/datum/map_writer_vars/vars = new()
	var/list/templates[0]
	var/template_buffer = {""}
	var/dmm_text = {""}
	for(var/pos_z in minz to maxz)
		for(var/pos_y = maxy; pos_y >= miny; pos_y--)
			for(var/pos_x in minx to maxx)
				var/turf/test_turf = locate(pos_x,pos_y,pos_z)
				var/test_template = make_template(test_turf, flags)
				var/template_number = templates.Find(test_template)
				if(!template_number)
					templates.Add(test_template)
					template_number = templates.len
				template_buffer += "[template_number],"
				sleep(0)
			template_buffer += ";"
			sleep(0)
		template_buffer += "."
		sleep(0)
	var/key_length = round/*floor*/(log(vars.letter_digits.len,templates.len-1)+1)
	var/list/keys[templates.len]
	for(var/key_pos in 1 to templates.len)
		keys[key_pos] = get_model_key(key_pos,key_length)
		dmm_text += {""[keys[key_pos]]" = ([templates[key_pos]])\n"}
		sleep(0)
	var/z_level = 0
	for(var/z_pos=1;TRUE;z_pos=findtext(template_buffer,".",z_pos)+1)
		if(z_pos>=length(template_buffer)){break}
		if(z_level){dmm_text+={"\n"}}
		dmm_text += {"\n(1,1,[++z_level]) = {"\n"}
		var/z_block = copytext(template_buffer,z_pos,findtext(template_buffer,".",z_pos))
		for(var/y_pos=1;TRUE;y_pos=findtext(z_block,";",y_pos)+1){
			if(y_pos>=length(z_block)){break}
			var/y_block = copytext(z_block,y_pos,findtext(z_block,";",y_pos))
			for(var/x_pos=1;TRUE;x_pos=findtext(y_block,",",x_pos)+1){
				if(x_pos>=length(y_block)){break}
				var/x_block = copytext(y_block,x_pos,findtext(y_block,",",x_pos))
				var/key_number = text2num(x_block)
				var/temp_key = keys[key_number]
				dmm_text += temp_key
				sleep(0)
				}
			dmm_text += {"\n"}
			sleep(0)
			}
		dmm_text += {"\"}"}
		sleep(0)
	return dmm_text

/proc/make_template(var/turf/model as turf, var/flags as num)
	var/template = ""
	var/obj_template = ""
	var/mob_template = ""
	var/turf_template = ""
	if(!(flags & DMM_IGNORE_TURFS))
		turf_template = "[model.type][check_attributes(model)],"
	else
		turf_template = "[world.turf],"
	var/area_template = ""
	if(!(flags & DMM_IGNORE_OBJS))
		for(var/obj/O in model.contents)
			sleep(0)
			if(istype(O,/obj/effect))
				continue
			obj_template += "[O.type][check_attributes(O)],"
	for(var/mob/M in model.contents)
		sleep(0)
		if(M.client)
			if(!(flags & DMM_IGNORE_PLAYERS))
				mob_template += "[M.type][check_attributes(M)],"
		else
			if(!(flags & DMM_IGNORE_NPCS))
				mob_template += "[M.type][check_attributes(M)],"
	if(!(flags & DMM_IGNORE_AREAS))
		var/area/m_area = model.loc
		area_template = "[m_area.type][check_attributes(m_area)]"
	else
		area_template = "[world.area]"
	template = "[obj_template][mob_template][turf_template][area_template]"
	return template

/proc/check_attributes(var/atom/A)
	var/list/allowed_vars = list("pixel_x", "pixel_y", "dir", "name", "req_access", "req_access_txt", "piping_layer", "color", "icon_state", "pipe_color")
	var/attributes_text = {"{"}
	for(var/V in A.vars)
		sleep(0)
		if(!(V in allowed_vars))
			continue
		if((!issaved(A.vars[V])) || (A.vars[V]==initial(A.vars[V]))){continue}

		var/value = A.vars[V]

		if(V == "icon_state" && value == "")
			continue
		if(istext(value))
			attributes_text += {"[V] = "[value]""}
		else if(isnum(value)||ispath(value))
			attributes_text += {"[V] = [value]"}
		else if(isicon(value)||isfile(value))
			attributes_text += {"[V] = '[value]'"}
		else
			continue
		if(attributes_text != {"{"})
			attributes_text+={"; "}
	if(attributes_text=={"{"})
		return
	if(copytext(attributes_text, length(attributes_text)-1, 0) == {"; "})
		attributes_text = copytext(attributes_text, 1, length(attributes_text)-1)
	attributes_text += {"}"}
	return attributes_text

/proc/get_model_key(var/which as num, var/key_length as num)
	var/datum/map_writer_vars/vars = new()
	var/key = ""
	var/working_digit = which-1
	for(var/digit_pos in key_length to 1 step -1)
		sleep(0)
		var/place_value = round/*floor*/(working_digit/(vars.letter_digits.len**(digit_pos-1)))
		working_digit-=place_value*(vars.letter_digits.len**(digit_pos-1))
		key = "[key][vars.letter_digits[place_value+1]]"
	return key
