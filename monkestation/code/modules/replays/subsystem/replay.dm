/datum/config_entry/flag/demos_enabled

/datum/config_entry/string/replay_password
	default = "mrhouse101"

SUBSYSTEM_DEF(demo)
	name = "Demo"
	wait = 1
	flags = SS_TICKER | SS_BACKGROUND
	init_order = INIT_ORDER_REPLAYS
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	var/list/pre_init_lines = list() // stuff like chat before the init
	var/list/icon_cache = list()
	var/list/icon_state_caches = list()
	var/list/name_cache = list()

	var/list/marked_dirty = list()
	var/list/marked_new = list()
	var/list/marked_turfs = list()
	var/list/del_list = list()

	var/last_written_time = null
	var/last_chat_message = null

	// stats stuff
	var/last_queued = 0
	var/last_completed = 0

/datum/controller/subsystem/demo/proc/write_time()
	var/new_time = world.time
	if(last_written_time != new_time)
		if(initialized)
			WRITE_LOG_NO_FORMAT(GLOB.demo_log, "time [new_time]\n")
		else
			pre_init_lines += "time [new_time]"
	last_written_time = new_time

/datum/controller/subsystem/demo/proc/write_event_line(line)
	write_time()
	if(initialized)
		WRITE_LOG_NO_FORMAT(GLOB.demo_log, "[line]\n")
	else
		pre_init_lines += line

/datum/controller/subsystem/demo/proc/write_chat(target, text)
	var/target_text = ""
	if(target == GLOB.clients)
		target_text = "world"
	else if(islist(target))
		var/list/target_keys = list()
		for(var/T in target)
			var/client/C = CLIENT_FROM_VAR(T)
			if(C)
				target_keys += C.ckey
		if(!target_keys.len)
			return
		target_text = jointext(target_keys, ",")
	else
		var/client/C = CLIENT_FROM_VAR(target)
		if(C)
			target_text = C.ckey
		else
			return
	write_event_line("chat [target_text] [last_chat_message == text ? "=" : json_encode(text)]")
	last_chat_message = text

/datum/controller/subsystem/demo/Initialize()
	if(!CONFIG_GET(flag/demos_enabled))
		flags |= SS_NO_FIRE
		marked_dirty.Cut()
		marked_new.Cut()
		marked_turfs.Cut()
		return SS_INIT_NO_NEED

	var/rounder = file("[GLOB.demo_directory]/round_number.txt")
	fdel(rounder)
	WRITE_FILE(rounder, "[GLOB.round_id]")

	WRITE_LOG_NO_FORMAT(GLOB.demo_log, "demo version 1\n") // increment this if you change the format
	if(GLOB.revdata)
		WRITE_LOG_NO_FORMAT(GLOB.demo_log, "commit [GLOB.revdata.originmastercommit || GLOB.revdata.commit]\n")

	// write a "snapshot" of the world at this point.
	// start with turfs
	log_world("Writing turfs...")
	WRITE_LOG_NO_FORMAT(GLOB.demo_log, "init [world.maxx] [world.maxy] [world.maxz]\n")
	marked_turfs.Cut()
	for(var/z in 1 to world.maxz)
		var/row_list = list()
		var/last_appearance
		var/rle_count = 1
		for(var/y in 1 to world.maxy)
			for(var/x in 1 to world.maxx)
				var/turf/T = locate(x,y,z)
				T.demo_last_appearance = T.appearance
				var/this_appearance
				// space turfs are difficult to RLE otherwise, because they all
				// have different appearances despite being the same thing.
				if(T.type == /turf/open/space || T.type == /turf/open/space/basic)
					this_appearance = "s" // save the bytes
				else if(istype(T, /turf/open/space/transit))
					this_appearance = "t[T.dir]"
				else
					this_appearance = T.appearance
				if(this_appearance == last_appearance)
					rle_count++
				else
					if(rle_count > 1)
						row_list += rle_count
					rle_count = 1
					if(istext(this_appearance))
						row_list += this_appearance
					else
						// do a diff with the previous turf to save those bytes
						row_list += encode_appearance(this_appearance, istext(last_appearance) ? null : last_appearance)
				last_appearance = this_appearance
		if(rle_count > 1)
			row_list += rle_count
		WRITE_LOG_NO_FORMAT(GLOB.demo_log, jointext(row_list, ",") + "\n")
	CHECK_TICK
	// then do objects
	log_world("Writing objects")
	marked_new.Cut()
	marked_dirty.Cut()
	for(var/z in 1 to world.maxz)
		var/spacing = 0
		var/row_list = list()
		for(var/y in 1 to world.maxy)
			for(var/x in 1 to world.maxx)
				var/turf/T = locate(x,y,z)
				var/list/turf_list = list()
				for(var/C in T.contents)
					var/atom/movable/as_movable = C
					if(as_movable.loc != T)
						continue
					if(isobj(C) || ismob(C))
						turf_list += encode_init_obj(C)
				if(turf_list.len)
					if(spacing)
						row_list += spacing
						spacing = 0
					row_list += turf_list
				spacing++
			CHECK_TICK // This is a bit risky because something might change but meh, its not a big deal.
		WRITE_LOG_NO_FORMAT(GLOB.demo_log, jointext(row_list, ",") + "\n")

	// track objects that exist in nullspace
	var/nullspace_list = list()
	for(var/M in world)
		if(!isobj(M) && !ismob(M))
			continue
		var/atom/movable/AM = M
		if(AM.loc != null)
			continue
		nullspace_list += encode_init_obj(AM)
		CHECK_TICK
	WRITE_LOG_NO_FORMAT(GLOB.demo_log, jointext(nullspace_list, ",") + "\n")

	for(var/line in pre_init_lines)
		WRITE_LOG_NO_FORMAT(GLOB.demo_log, "[line]\n")

	return SS_INIT_SUCCESS

/datum/controller/subsystem/demo/fire()
	var/marked_new_len = length(src.marked_new)
	var/marked_dirty_len = length(src.marked_dirty)
	var/marked_turfs_len = length(src.marked_turfs)
	var/del_list_len = length(del_list)
	if(!marked_new_len && !marked_dirty_len && !marked_turfs_len && !del_list_len)
		return // nothing to do

	last_queued = marked_new_len + marked_dirty_len + marked_turfs_len
	last_completed = 0

	write_time()
	if(del_list_len)
		var/s = "del [jointext(src.del_list, ",")]\n" // if I don't do it like this I get "incorrect number of macro arguments" because byond is stupid and sucks
		WRITE_LOG_NO_FORMAT(GLOB.demo_log, s)
	src.del_list.Cut()

	var/canceled = FALSE

	var/list/marked_dirty = src.marked_dirty
	var/list/dirty_updates = list()
	while(length(marked_dirty))
		last_completed++
		var/atom/movable/M = marked_dirty[length(marked_dirty)]
		marked_dirty.len--
		if(QDELETED(M))
			continue
		if(M.loc == M.demo_last_loc)
			continue
		var/loc_string = "="
		if(M.loc != M.demo_last_loc)
			loc_string = "null"
			if(isturf(M.loc))
				loc_string = "[M.x],[M.y],[M.z]"
			else if(ismovable(M.loc))
				loc_string = "\ref[M.loc]"
			M.demo_last_loc = M.loc
		var/appearance_string = "="
		if(ismob(M))
			appearance_string = encode_appearance(M.appearance, target = M)
			M.demo_last_appearance = M.appearance
		else if(M.appearance != M.demo_last_appearance)
			appearance_string = encode_appearance(M.appearance, M.demo_last_appearance, target = M)
			M.demo_last_appearance = M.appearance
		dirty_updates += "\ref[M] [loc_string] [appearance_string]"
		if(MC_TICK_CHECK)
			canceled = TRUE
			break
	if(length(dirty_updates))
		var/s = "update [jointext(dirty_updates, ",")]\n"
		WRITE_LOG_NO_FORMAT(GLOB.demo_log, s)
	if(canceled)
		return


	var/list/marked_new = src.marked_new
	var/list/new_updates = list()
	while(length(marked_new))
		last_completed++
		var/atom/movable/M = marked_new[length(marked_new)]
		marked_new.len--
		if(QDELETED(M))
			continue
		var/loc_string = "null"
		if(isturf(M.loc))
			loc_string = "[M.x],[M.y],[M.z]"
		else if(ismovable(M.loc))
			loc_string = "\ref[M.loc]"
		M.demo_last_appearance = M.appearance
		new_updates += "\ref[M] [loc_string] [encode_appearance(M.appearance, target = M)]"
		if(MC_TICK_CHECK)
			canceled = TRUE
			break
	if(length(new_updates))
		var/s = "new [jointext(new_updates, ",")]\n"
		WRITE_LOG_NO_FORMAT(GLOB.demo_log, s)
	if(canceled)
		return


	var/list/marked_turfs = src.marked_turfs
	var/list/turf_updates = list()
	while(length(marked_turfs))
		last_completed++
		var/turf/T = marked_turfs[length(marked_turfs)]
		marked_turfs.len--
		if(T && T.appearance != T.demo_last_appearance)
			turf_updates += "([T.x],[T.y],[T.z])=[encode_appearance(T.appearance, T.demo_last_appearance)]"
			T.demo_last_appearance = T.appearance
			if(MC_TICK_CHECK)
				canceled = TRUE
				break
	if(length(turf_updates))
		var/s = "turf [jointext(turf_updates, ",")]\n"
		WRITE_LOG_NO_FORMAT(GLOB.demo_log, s)
	if(canceled)
		return

/datum/controller/subsystem/demo/proc/encode_init_obj(atom/movable/M)
	M.demo_last_loc = M.loc
	M.demo_last_appearance = M.appearance
	var/encoded_appearance = encode_appearance(M.appearance, target = M)
	var/list/encoded_contents = list()
	for(var/C in M.contents)
		if(isobj(C) || ismob(C))
			encoded_contents += encode_init_obj(C)
	return "\ref[M]=[encoded_appearance][(encoded_contents.len ? "([jointext(encoded_contents, ",")])" : "")]"

// please make sure the order you call this function in is the same as the order you write
/datum/controller/subsystem/demo/proc/encode_appearance(image/appearance, image/diff_appearance, diff_remove_overlays = FALSE, atom/movable/target)
	if(appearance == null)
		return "n"
	if(appearance == diff_appearance)
		return "="

	var/icon_txt = "[appearance.icon]"
	var/cached_icon = icon_cache[icon_txt] || icon_txt
	var/list/icon_state_cache
	if(!isnum(cached_icon))
		icon_cache[icon_txt] = icon_cache.len + 1
		icon_state_cache = (icon_state_caches[++icon_state_caches.len] = list())
	else
		icon_state_cache = icon_state_caches[cached_icon]

	var/list/cached_icon_state = icon_state_cache[appearance.icon_state] || appearance.icon_state
	if(!isnum(cached_icon_state))
		icon_state_cache[appearance.icon_state] = icon_state_cache.len + 1

	var/cached_name = name_cache[appearance.name] || appearance.name
	if(!isnum(cached_name))
		name_cache[appearance.name] = name_cache.len + 1

	var/color_string = appearance.color || "w"
	if(islist(color_string))
		var/list/old_list = appearance.color
		var/list/inted = list()
		inted.len = old_list.len
		for(var/i in 1 to old_list.len)
			inted[i] += round(old_list[i] * 255)
		color_string = jointext(inted, ",")
	var/overlays_string = "\[]"
	if(appearance.overlays.len)
		var/list/overlays_list = list()
		for(var/i in 1 to appearance.overlays.len)
			var/image/overlay = appearance.overlays[i]
			overlays_list += encode_appearance(overlay, appearance, TRUE, target = target)
		overlays_string = "\[[jointext(overlays_list, ",")]]"

	var/underlays_string = "\[]"
	if(appearance.underlays.len)
		var/list/underlays_list = list()
		for(var/i in 1 to appearance.underlays.len)
			var/image/underlay = appearance.underlays[i]
			underlays_list += encode_appearance(underlay, appearance, TRUE, target = target)
		underlays_string = "\[[jointext(underlays_list, ",")]]"

	var/appearance_transform_string = "i"
	if(appearance.transform)
		var/matrix/M = appearance.transform
		appearance_transform_string = "[M.a],[M.b],[M.c],[M.d],[M.e],[M.f]"
		if(appearance_transform_string == "1,0,0,0,1,0")
			appearance_transform_string = "i"

	var/tmp_dir = appearance.dir

	if(target)
		//message_admins("demo target is [target] \nappearance dir: [appearance.dir] and target dir: [target.dir]")
		tmp_dir = target.dir

	var/list/appearance_list = list(
		json_encode(cached_icon),
		json_encode(cached_icon_state),
		json_encode(cached_name),
		appearance.appearance_flags,
		appearance.layer,
		appearance.plane == -32767 ? "" : appearance.plane,
		tmp_dir == 2 ? "" : tmp_dir,
		appearance.color ? color_string : "",
		appearance.alpha == 255 ? "" : appearance.alpha,
		appearance.pixel_x == 0 ? "" : appearance.pixel_x,
		appearance.pixel_y == 0 ? "" : appearance.pixel_y,
		appearance.blend_mode <= 1 ? "" : appearance.blend_mode,
		appearance_transform_string != "i" ? appearance_transform_string : "",
		appearance:invisibility == 0 ? "" : appearance:invisibility, // colon because dreamchecker is dumb
		appearance.pixel_w == 0 ? "" : appearance.pixel_w,
		appearance.pixel_z == 0 ? "" : appearance.pixel_z,
		appearance.overlays.len ? overlays_string : "",
		appearance.underlays.len ? underlays_string : ""
		)
	while(appearance_list[appearance_list.len] == "" && appearance_list.len > 0)
		appearance_list.len--

	var/undiffed_string = "{[jointext(appearance_list, ";")]}"

	if(diff_appearance)
		var/overlays_identical = TRUE
		if(diff_remove_overlays)
			overlays_identical = (appearance.overlays.len == 0)
		else if(appearance.overlays.len != diff_appearance.overlays.len)
			overlays_identical = FALSE
		else
			for(var/i in 1 to appearance.overlays.len)
				if(appearance.overlays[i] != diff_appearance.overlays[i])
					overlays_identical = FALSE
					break

		var/underlays_identical = TRUE
		if(diff_remove_overlays)
			underlays_identical = (appearance.underlays.len == 0)
		else if(appearance.underlays.len != diff_appearance.underlays.len)
			underlays_identical = FALSE
		else
			for(var/i in 1 to appearance.underlays.len)
				if(appearance.underlays[i] != diff_appearance.underlays[i])
					underlays_identical = FALSE
					break

		var/diff_transform_string = "i"
		if(diff_appearance.transform)
			var/matrix/M = diff_appearance.transform
			diff_transform_string = "[M.a],[M.b],[M.c],[M.d],[M.e],[M.f]"
			if(diff_transform_string == "1,0,0,0,1,0")
				diff_transform_string = "i"

		var/list/diffed_appearance_list = list(
			json_encode(cached_icon),
			json_encode(cached_icon_state),
			json_encode(cached_name),
			appearance.appearance_flags == diff_appearance.appearance_flags ? "" : appearance.appearance_flags,
			appearance.layer == diff_appearance.layer ? "" : appearance.layer,
			appearance.plane == diff_appearance.plane ? "" : appearance.plane,
			appearance.dir == diff_appearance.dir ? "" : appearance.dir,
			appearance.color == diff_appearance.color ? "" : color_string,
			appearance.alpha == diff_appearance.alpha ? "" : appearance.alpha,
			appearance.pixel_x == diff_appearance.pixel_x ? "" : appearance.pixel_x,
			appearance.pixel_y == diff_appearance.pixel_y ? "" : appearance.pixel_y,
			appearance.blend_mode == diff_appearance.blend_mode ? "" : appearance.blend_mode,
			appearance_transform_string == diff_transform_string ? "" : appearance_transform_string,
			appearance:invisibility == diff_appearance:invisibility ? "" : appearance:invisibility, // colon because dreamchecker is too dumb
			appearance.pixel_w == diff_appearance.pixel_w ? "" : appearance.pixel_w,
			appearance.pixel_z == diff_appearance.pixel_z ? "" : appearance.pixel_z,
			overlays_identical ? "" : overlays_string,
			underlays_identical ? "" :underlays_string
			)
		while(diffed_appearance_list[diffed_appearance_list.len] == "" && diffed_appearance_list.len > 0)
			diffed_appearance_list.len--

		var/diffed_string = "~{[jointext(diffed_appearance_list, ";")]}"
		if(length(diffed_string) < length(undiffed_string))
			return diffed_string
	return undiffed_string

/datum/controller/subsystem/demo/stat_entry(msg)
	msg += "Remaining: {"
	msg += "Trf:[marked_turfs.len]|"
	msg += "New:[marked_new.len]|"
	msg += "Upd:[marked_dirty.len]|"
	msg += "Del:[del_list.len]"
	msg += "}"
	return ..()

/datum/controller/subsystem/demo/proc/mark_turf(turf/turf)
	if(!can_fire)
		return
	if(isturf(turf))
		return
	marked_turfs[turf] = TRUE

/datum/controller/subsystem/demo/proc/mark_multiple_turfs(list/turf/turf_list)
	if(!can_fire)
		return
	if(!islist(turf_list))
		return
	for(var/turf in turf_list)
		if(!isturf(turf))
			continue
		marked_turfs[turf] = TRUE

/datum/controller/subsystem/demo/proc/mark_new(atom/movable/M)
	if(!can_fire)
		return
	if(!isobj(M) && !ismob(M))
		return
	if(QDELING(M))
		return
	marked_new[M] = TRUE
	if(marked_dirty[M])
		marked_dirty -= M

/datum/controller/subsystem/demo/proc/mark_multiple_new(list/atom/atom_list)
	if(!can_fire)
		return
	for(var/atom/atom as anything in atom_list)
		if(!isobj(atom) && !ismob(atom))
			continue
		if(QDELING(atom))
			continue
		marked_new[atom] = TRUE
		if(marked_dirty[atom])
			marked_dirty -= atom

// I can't wait for when TG ports this and they make this a #define macro.
/datum/controller/subsystem/demo/proc/mark_dirty(atom/movable/M)
	if(!can_fire)
		return
	if(!isobj(M) && !ismob(M))
		return
	if(QDELING(M))
		return
	if(!marked_new[M])
		marked_dirty[M] = TRUE

/datum/controller/subsystem/demo/proc/mark_multiple_dirty(list/atom/movable/dirty_list)
	if(!can_fire)
		return
	for(var/atom/movable/dirty as anything in dirty_list)
		if(!isobj(dirty) && !ismob(dirty))
			continue
		if(QDELING(dirty))
			continue
		if(!marked_new[dirty])
			marked_dirty[dirty] = TRUE

/datum/controller/subsystem/demo/proc/mark_destroyed(atom/movable/M)
	if(!can_fire)
		return
	if(!isobj(M) && !ismob(M))
		return
	if(marked_new[M])
		marked_new -= M
	if(marked_dirty[M])
		marked_dirty -= M
	if(initialized)
		del_list["\ref[M]"] = 1
