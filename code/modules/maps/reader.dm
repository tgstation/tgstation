dmm_suite
	load_map(var/dmm_file as file, var/z_offset as num)
		if(!z_offset)
			z_offset = world.maxz+1
		var/quote = ascii2text(34)
		var/tfile = file2text(dmm_file)
		var/tfile_len = length(tfile)
		var/list/grid_models[0]
		var/key_len = length(copytext(tfile,2,findtext(tfile,quote,2,0)))
		for(var/lpos=1;lpos<tfile_len;lpos=findtext(tfile,"\n",lpos,0)+1)
			var/tline = copytext(tfile,lpos,findtext(tfile,"\n",lpos,0))
			if(copytext(tline,1,2)!=quote)
				break
			var/model_key = copytext(tline,2,findtext(tfile,quote,2,0))
			var/model_contents = copytext(tline,findtext(tfile,"=")+3,length(tline))
			grid_models[model_key] = model_contents
			sleep(-1)
		var/zcrd=-1
		var/ycrd=0
		var/xcrd=0
		for(var/zpos=findtext(tfile,"\n(1,1,");TRUE;zpos=findtext(tfile,"\n(1,1,",zpos+1,0))
			zcrd++
			world.maxz = max(world.maxz, zcrd+z_offset)
			ycrd=0
			var/zgrid = copytext(tfile,findtext(tfile,quote+"\n",zpos,0)+2,findtext(tfile,"\n"+quote,zpos,0)+1)
			for(var/gpos=1;gpos!=0;gpos=findtext(zgrid,"\n",gpos,0)+1)
				var/grid_line = copytext(zgrid,gpos,findtext(zgrid,"\n",gpos,0)+1)
				var/y_depth = length(zgrid)/(length(grid_line))
				if(world.maxy<y_depth)
					world.maxy=y_depth
				grid_line=copytext(grid_line,1,length(grid_line))
				if(!ycrd)
					ycrd = y_depth
				else
					ycrd--
				xcrd=0
				for(var/mpos=1;mpos<=length(grid_line);mpos+=key_len)
					xcrd++
					if(world.maxx<xcrd)
						world.maxx=xcrd
					var/model_key = copytext(grid_line,mpos,mpos+key_len)
					parse_grid(grid_models[model_key],xcrd,ycrd,zcrd+z_offset)
				if(gpos+length(grid_line)+1>length(zgrid))
					break
				sleep(-1)
			if(findtext(tfile,quote+"}",zpos,0)+2==tfile_len)
				break
			sleep(-1)
	proc
		parse_grid(var/model as text,var/xcrd as num,var/ycrd as num,var/zcrd as num)
			/*Method parse_grid()
				- Accepts a text string containing a comma separated list of type paths of the
					same construction as those contained in a .dmm file, and instantiates them.
				*/
			var/list/text_strings[0]
			for(var/index=1;findtext(model,quote);index++)
				/*Loop: Stores quoted portions of text in text_strings, and replaces them with an
					index to that list.
					- Each iteration represents one quoted section of text.
					*/
				text_strings.len=index
				text_strings[index] = copytext(model,findtext(model,quote)+1,findtext(model,quote,findtext(model,quote)+1,0))
				model = copytext(model,1,findtext(model,quote))+"~[index]"+copytext(model,findtext(model,quote,findtext(model,quote)+1,0)+1,0)
				sleep(-1)
			var/list/old_turf_underlays[0]
			var/old_turf_density
			var/old_turf_opacity
			/*The old_turf variables store information about turfs instantiated in this location/iteration.
				This is done to approximate the layered turf effect of DM's map editor.
				An image of each turf is stored in old_turf_underlays[], and is later added to the new turf's underlays.
				*/
			for(var/dpos=1;dpos!=0;dpos=findtext(model,",",dpos,0)+1)
				/*Loop: Identifies each object's data, instantiates it, and reconstitues it's fields.
					- Each iteration represents one object's data, including type path and field values.
					*/
				var/full_def = copytext(model,dpos,findtext(model,",",dpos,0))
				var/atom_def = text2path(copytext(full_def,1,findtext(full_def,"{")))
				var/list/attributes[0]
				if(findtext(full_def,"{"))
					full_def = copytext(full_def,1,length(full_def))
					for(var/apos=findtext(full_def,"{")+1;apos!=0;apos=findtext(full_def,";",apos,0)+1)
						//Loop: Identifies each attribute/value pair, and stores it in attributes[].
						attributes.Add(copytext(full_def,apos,findtext(full_def,";",apos,0)))
						if(!findtext(copytext(full_def,apos,0),";"))
							break
						sleep(-1)
				//Construct attributes associative list
				var/list/fields = new(0)
				for(var/index=1;index<=attributes.len;index++)
					var/trim_left = trim_text(copytext(attributes[index],1,findtext(attributes[index],"=")))
					var/trim_right = trim_text(copytext(attributes[index],findtext(attributes[index],"=")+1,0))
					//Check for string
					if(findtext(trim_right,"~"))
						var/reference_index = copytext(trim_right,findtext(trim_right,"~")+1,0)
						trim_right=text_strings[text2num(reference_index)]
					//Check for number
					else if(isnum(text2num(trim_right)))
						trim_right = text2num(trim_right)
					//Check for file
					else if(copytext(trim_right,1,2) == "'")
						trim_right = file(copytext(trim_right,2,length(trim_right)))
					fields[trim_left] = trim_right
					//End construction


				//Begin Instanciation
				var/atom/instance
				var/dmm_suite/preloader/_preloader = new(fields)
				if(ispath(atom_def,/area))
					instance = locate(atom_def)
					instance.contents.Add(locate(xcrd,ycrd,zcrd))
				else if(ispath(atom_def,/turf))
					var/turf/old_turf = locate(xcrd,ycrd,zcrd)
					if(old_turf.density){old_turf_density = 1}
					if(old_turf.opacity){old_turf_opacity = 1}
					if(old_turf.icon)
						var/image/old_turf_image = image(old_turf.icon,null,old_turf.icon_state,old_turf.layer,old_turf.dir)
						old_turf_underlays.Add(old_turf_image)
					instance = new atom_def(old_turf, _preloader)
					for(var/inverse_index=old_turf_underlays.len;inverse_index;inverse_index--)
						var/image/image_underlay = old_turf_underlays[inverse_index]
						image_underlay.loc = instance
						instance.underlays.Add(image_underlay)
					if(!instance.density)
						instance.density = old_turf_density
					if(!instance.opacity)
						instance.opacity = old_turf_opacity

				if(_preloader && instance)
					_preloader.load(instance)
					//End Instanciation
				if(!findtext(copytext(model,dpos,0),","))
					break
				sleep(-1)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			for(var/dpos=1;dpos!=0;dpos=findtext(model,",",dpos,0)+1)
				/*Loop: Identifies each object's data, instantiates it, and reconstitues it's fields.
					- Each iteration represents one object's data, including type path and field values.
					*/
				var/full_def = copytext(model,dpos,findtext(model,",",dpos,0))
				var/atom_def = text2path(copytext(full_def,1,findtext(full_def,"{")))
				var/list/attributes[0]
				if(findtext(full_def,"{"))
					full_def = copytext(full_def,1,length(full_def))
					for(var/apos=findtext(full_def,"{")+1;apos!=0;apos=findtext(full_def,";",apos,0)+1)
						//Loop: Identifies each attribute/value pair, and stores it in attributes[].
						attributes.Add(copytext(full_def,apos,findtext(full_def,";",apos,0)))
						if(!findtext(copytext(full_def,apos,0),";"))
							break
						sleep(-1)
				//Construct attributes associative list
				var/list/fields = new(0)
				for(var/index=1;index<=attributes.len;index++)
					var/trim_left = trim_text(copytext(attributes[index],1,findtext(attributes[index],"=")))
					var/trim_right = trim_text(copytext(attributes[index],findtext(attributes[index],"=")+1,0))
					//Check for string
					if(findtext(trim_right,"~"))
						var/reference_index = copytext(trim_right,findtext(trim_right,"~")+1,0)
						trim_right=text_strings[text2num(reference_index)]
					//Check for number
					else if(isnum(text2num(trim_right)))
						trim_right = text2num(trim_right)
					//Check for file
					else if(copytext(trim_right,1,2) == "'")
						trim_right = file(copytext(trim_right,2,length(trim_right)))
					fields[trim_left] = trim_right
					//End construction


				//Begin Instanciation
				var/atom/instance
				var/dmm_suite/preloader/_preloader = new(fields)
				if(!ispath(atom_def,/area) && !ispath(atom_def,/turf))
					instance = new atom_def(locate(xcrd,ycrd,zcrd), _preloader)


				if(_preloader && instance)
					_preloader.load(instance)
					//End Instanciation
				if(!findtext(copytext(model,dpos,0),","))
					break
				sleep(-1)



		trim_text(var/what as text)
			while(length(what) && findtext(what," ",1,2))
				what=copytext(what,2,0)
			while(length(what) && findtext(what," ",length(what),0))
				what=copytext(what,1,length(what))
			return what
atom/New(atom/loc, dmm_suite/preloader/_dmm_preloader)
	if(istype(_dmm_preloader, /dmm_suite/preloader))
		_dmm_preloader.load(src)
	. = ..()

dmm_suite
	preloader
		parent_type = /datum
		var
			list/attributes
		New(list/the_attributes)
			.=..()
			if(!the_attributes.len)
				Del()
			attributes = the_attributes
		proc
			load(atom/what)
				for(var/attribute in attributes)
					what.vars[attribute] = attributes[attribute]
				Del()

