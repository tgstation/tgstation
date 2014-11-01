///////////////////////////////////////////////////////////////
//SS13 Optimized Map loader
//////////////////////////////////////////////////////////////


/**
 * Construct the model map and control the loading process
 *
 * WORKING :
 *
 * 1) Makes an associative mapping of model_keys with model
 *		e.g aa = /turf/unsimulated/wall{icon_state = "rock"}
 * 2) Read the map line by line, parsing the result (using parse_grid)
 *
 */
/dmm_suite/load_map(var/dmm_file as file, var/z_offset as num)
	if(!z_offset)//what z_level we are creating the map on
		z_offset = world.maxz+1

	var/quote = ascii2text(34)
	var/tfile = file2text(dmm_file)//the map file we're creating
	var/tfile_len = length(tfile)
	var/lpos = 1 // the models definition index

	///////////////////////////////////////////////////////////////////////////////////////
	//first let's map model keys (e.g "aa") to their contents (e.g /turf/space{variables})
	///////////////////////////////////////////////////////////////////////////////////////
	var/list/grid_models = list()
	var/key_len = length(copytext(tfile,2,findtext(tfile,quote,2,0)))//the length of the model key (e.g "aa" or "aba")

	//proceed line by line
	for(lpos=1; lpos<tfile_len; lpos=findtext(tfile,"\n",lpos,0)+1)
		var/tline = copytext(tfile,lpos,findtext(tfile,"\n",lpos,0))
		if(copytext(tline,1,2) != quote)//we reached the map "layout"
			break
		var/model_key = copytext(tline,2,2+key_len)
		var/model_contents = copytext(tline,findtext(tfile,"=")+3,length(tline))
		grid_models[model_key] = model_contents
		sleep(-1)

	///////////////////////////////////////////////////////////////////////////////////////
	//now let's fill the map with turf and objects using the constructed model map
	///////////////////////////////////////////////////////////////////////////////////////

	//position of the currently processed square
	var/zcrd=-1
	var/ycrd=0
	var/xcrd=0

	for(var/zpos=findtext(tfile,"\n(1,1,",lpos,0);zpos!=0;zpos=findtext(tfile,"\n(1,1,",zpos+1,0))	//in case there's several maps to load

		zcrd++
		world.maxz = max(world.maxz, zcrd+z_offset)//create a new z_level if needed

		var/zgrid = copytext(tfile,findtext(tfile,quote+"\n",zpos,0)+2,findtext(tfile,"\n"+quote,zpos,0)+1) //copy the whole map grid
		var/z_depth = length(zgrid)

		//if exceeding the world max x or y, increase it
		var/x_depth = length(copytext(zgrid,1,findtext(zgrid,"\n",2,0)))
		if(world.maxx<x_depth)
			world.maxx=x_depth

		var/y_depth = z_depth / (x_depth+1)//x_depth + 1 because we're counting the '\n' characters in z_depth
		if(world.maxy<y_depth)
			world.maxy=y_depth

		//then proceed it line by line, starting from top
		ycrd = y_depth

		for(var/gpos=1;gpos!=0;gpos=findtext(zgrid,"\n",gpos,0)+1)
			var/grid_line = copytext(zgrid,gpos,findtext(zgrid,"\n",gpos,0))

			//fill the current square using the model map
			xcrd=0
			for(var/mpos=1;mpos<=x_depth;mpos+=key_len)
				xcrd++
				var/model_key = copytext(grid_line,mpos,mpos+key_len)
				parse_grid(grid_models[model_key],xcrd,ycrd,zcrd+z_offset)

			//reached end of current map
			if(gpos+x_depth+1>z_depth)
				break

			ycrd--

			sleep(-1)

		//reached End Of File
		if(findtext(tfile,quote+"}",zpos,0)+2==tfile_len)
			break
		sleep(-1)

/**
 * Fill a given tile with its area/turf/objects/mobs
 * Variable model is one full map line (e.g /turf/unsimulated/wall{icon_state = "rock"},/area/mine/explored)
 *
 * WORKING :
 *
 * 1) Read the model string, member by member (delimiter is ',')
 *
 * 2) Get the path of the atom and store it into a list
 *
 * 3) a) Check if the member has variables (text within '{' and '}')
 *
 * 3) b) Construct an associative list with found variables, if any (the atom index in members is the same as its variables in members_attributes)
 *
 * 4) Instanciates the atom with its variables
 *
 */
/dmm_suite/proc/parse_grid(var/model as text,var/xcrd as num,var/ycrd as num,var/zcrd as num)
	/*Method parse_grid()
	- Accepts a text string containing a comma separated list of type paths of the
		same construction as those contained in a .dmm file, and instantiates them.
	*/

	var/list/members = list()//will contain all members (paths) in model (in our example : /turf/unsimulated/wall and /area/mine/explored)
	var/list/members_attributes = list()//will contain lists filled with corresponding variables, if any (in our example : list(icon_state = "rock") and list())


	/////////////////////////////////////////////////////////
	//Constructing members and corresponding variables lists
	////////////////////////////////////////////////////////

	var/index=1
	var/old_position = 1
	var/dpos

	do
		//finding next member (e.g /turf/unsimulated/wall{icon_state = "rock"} or /area/mine/explored)
		dpos= find_next_delimiter_position(model,old_position,",","{","}")//find next delimiter (comma here) that's not within {...}

		var/full_def = copytext(model,old_position,dpos)//full definition, e.g : /obj/foo/bar{variables=derp}
		var/atom_def = text2path(copytext(full_def,1,findtext(full_def,"{")))//path definition, e.g /obj/foo/bar
		members.Add(atom_def)
		old_position = dpos + 1

		//transform the variables in text format into a list (e.g {var1="derp"; var2; var3=7} => list(var1="derp", var2, var3=7))
		var/list/fields = list()

		var/variables_start = findtext(full_def,"{")
		if(variables_start)//if there's any variable
			full_def = copytext(full_def,variables_start+1,length(full_def))//removing the last '}'
			fields = text2list(full_def,";")

		//then fill the members_attributes list with the corresponding variables
		members_attributes.len++
		members_attributes[index++] = fields

		sleep(-1)
	while(dpos != 0)


	////////////////
	//Instanciation
	////////////////

	//The next part of the code assumes there's ALWAYS an /area AND a /turf on a given tile

	//first instance the /area and remove it from the members list
	var/length = members.len
	var/atom/instance
	var/dmm_suite/preloader/_preloader = new(members_attributes[length])//preloader for assigning  set variables on atom creation

	instance = locate(members[length])
	instance.contents.Add(locate(xcrd,ycrd,zcrd))

	if(_preloader && instance)
		_preloader.load(instance)

	members.Remove(members[length])

	//then instance the /turf and remove it from the members list
	length = members.len

	instance_atom(members[length],members_attributes[length],xcrd,ycrd,zcrd)
	members.Remove(members[length])

	//Replace the previous part of the code with this if it's unsafe to assume tiles have ALWAYS an /area AND a /turf
	/*while(members.len > 0)
		var/length = members.len
		var/member = members[length]

		if(ispath(member,/area))
			var/atom/instance
			var/dmm_suite/preloader/_preloader = new(members_attributes[length])

			instance = locate(member)
			instance.contents.Add(locate(xcrd,ycrd,zcrd))

			if(_preloader && instance)
				_preloader.load(instance)

			members.Remove(member)
			continue

		else if(ispath(member,/turf))
			instance_atom(member,members_attributes[length],xcrd,ycrd,zcrd)
			members.Remove(member)
			continue

		else
			break
		*/

	//finally instance all remainings objects/mobs
	for(var/k=1,k<=members.len,k++)
		instance_atom(members[k],members_attributes[k],xcrd,ycrd,zcrd)

////////////////
//Helpers procs
////////////////

//Instance an atom at (x,y,z) and gives it the variables in attributes
/dmm_suite/proc/instance_atom(var/path,var/list/attributes, var/x, var/y, var/z)
	var/atom/instance
	var/dmm_suite/preloader/_preloader = new(attributes)

	instance = new path (locate(x,y,z), _preloader)//first preloader pass

	if(_preloader && instance)//second preloader pass, as some variables may have been reset/changed by New()
		_preloader.load(instance)

//text trimming (both directions) helper proc
//optionally removes quotes before and after the text (for variable name)
/dmm_suite/proc/trim_text(var/what as text,var/trim_quotes=0)
	while(length(what) && (findtext(what," ",1,2)))// || findtext(what,quote,1,2)))
		what=copytext(what,2,0)
	while(length(what) && (findtext(what," ",length(what),0)))// || findtext(what,quote,length(what),0)))
		what=copytext(what,1,length(what))
	if(trim_quotes)
		while(length(what) && (findtext(what,quote,1,2)))
			what=copytext(what,2,0)
		while(length(what) && (findtext(what,quote,length(what),0)))
			what=copytext(what,1,length(what))
	return what

//find the position of the next delimiter,skipping whatever is comprised between opening_escape and closing_escape
//returns 0 if reached the last delimiter
/dmm_suite/proc/find_next_delimiter_position(var/text as text,var/initial_position as num, var/delimiter=",",var/opening_escape=quote,var/closing_escape=quote)
	var/position = initial_position
	var/next_delimiter = findtext(text,delimiter,position,0)
	var/next_opening = findtext(text,opening_escape,position,0)

	while((next_opening != 0) && (next_opening < next_delimiter))
		position = findtext(text,closing_escape,next_opening + 1,0)+1
		next_delimiter = findtext(text,delimiter,position,0)
		next_opening = findtext(text,opening_escape,position,0)

	return next_delimiter


//build a list from variables in text form (e.g {var1="derp"; var2; var3=7} => list(var1="derp", var2, var3=7))
//return the filled list
/dmm_suite/proc/text2list(var/text as text,var/delimiter=",")

	var/list/to_return = list()

	var/position
	var/old_position = 1

	do
		//find next delimiter that is not within  "..."
		position = find_next_delimiter_position(text,old_position,delimiter)

		//check if this is a simple variable (as in list(var1, var2)) or an associative one (as in list(var1="foo",var2=7))
		var/equal_position = findtext(text,"=",old_position, position)

		var/trim_left = trim_text(copytext(text,old_position,equal_position),1)//the name of the variable, must trim quotes to build a BYOND compliant associatives list
		old_position = position + 1

		if(equal_position)//associative var, so do the association
			var/trim_right = trim_text(copytext(text,equal_position+1,position))//the content of the variable

			//Check for string
			if(findtext(trim_right,quote,1,2))
				trim_right = copytext(trim_right,2,findtext(trim_right,quote,3,0))

			//Check for number
			else if(isnum(text2num(trim_right)))
				trim_right = text2num(trim_right)

			//Check for file
			else if(copytext(trim_right,1,2) == "'")
				trim_right = file(copytext(trim_right,2,length(trim_right)))

			//Check for list
			else if(copytext(trim_right,1,5) == "list")
				trim_right = text2list(copytext(trim_right,6,length(trim_right)))

			to_return[trim_left] = trim_right

		else//simple var
			to_return[trim_left] = null

	while(position != 0)

	return to_return

//atom creation method that preloads variables before creation
atom/New(atom/loc, dmm_suite/preloader/_dmm_preloader)
	if(istype(_dmm_preloader, /dmm_suite/preloader))
		_dmm_preloader.load(src)
	. = ..()

//////////////////
//Preloader datum
//////////////////

/dmm_suite/preloader
	parent_type = /datum
	var/list/attributes

/dmm_suite/preloader/New(list/the_attributes)
	.=..()
	if(!the_attributes.len)
		Del()
	attributes = the_attributes

/dmm_suite/preloader/proc/load(atom/what)
	for(var/attribute in attributes)
		what.vars[attribute] = attributes[attribute]
	Del()