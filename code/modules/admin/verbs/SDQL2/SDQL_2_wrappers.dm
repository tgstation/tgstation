// Wrappers for BYOND default procs which can't directly be called by call().

/proc/_abs(A)
	return abs(A)

/proc/_animate(atom/target, set_vars, time = 10, loop = 1, easing = LINEAR_EASING, flags = null)
	if(target)
		animate(target, appearance = set_vars, time, loop, easing, flags)
	else
		animate(appearance = set_vars, time, easing = easing, flags)

/proc/_arccos(A)
	return arccos(A)

/proc/_arcsin(A)
	return arcsin(A)

/proc/_ascii2text(A)
	return ascii2text(A)

/proc/_block(Start, End)
	return block(Start, End)

/proc/_ckey(Key)
	return ckey(Key)

/proc/_ckeyEx(Key)
	return ckeyEx(Key)

/proc/_copytext(T, Start = 1, End = 0)
	return copytext(T, Start, End)

/proc/_cos(X)
	return cos(X)

/proc/_findtext(Haystack, Needle, Start = 1, End = 0)
	return findtext(Haystack, Needle, Start, End)

/proc/_findtextEx(Haystack, Needle, Start = 1, End = 0)
	return findtextEx(Haystack, Needle, Start, End)

/proc/_flick(Icon, Object)
	flick(Icon, Object)

/proc/_get_dir(Loc1, Loc2)
	return get_dir(Loc1, Loc2)

/proc/_get_dist(Loc1, Loc2)
	return get_dist(Loc1, Loc2)

/proc/_get_step(Ref, Dir)
	return get_step(Ref, Dir)

/proc/_hearers(Depth = world.view, Center = usr)
	return hearers(Depth, Center)

/proc/_image(icon, loc, icon_state, layer, dir)
	return image(icon, loc, icon_state, layer, dir)

/proc/_istype(object, type)
	return istype(object, type)

/proc/_ispath(path, type)
	return ispath(path, type)

/proc/_length(E)
	return length(E)

/proc/_link(thing, url)
	thing << link(url)

/proc/_locate(X, Y, Z)
	if (isnull(Y)) // Assuming that it's only a single-argument call.
		// direct ref locate
		var/datum/D = locate(X)
		// &&'s to last value
		return istype(D) && D.can_vv_mark() && D

	return locate(X, Y, Z)

/proc/_log(X, Y)
	return log(X, Y)

/proc/_LOWER_TEXT(T)
	return LOWER_TEXT(T)

/proc/_matrix(a, b, c, d, e, f)
	return matrix(a, b, c, d, e, f)

/proc/_max(...)
	return max(arglist(args))

/proc/_md5(T)
	return md5(T)

/proc/_min(...)
	return min(arglist(args))

/proc/_new(type, arguments)
	var/datum/result

	if(!length(arguments))
		result = new type()
	else
		result = new type(arglist(arguments))

	if(istype(result))
		result.datum_flags |= DF_VAR_EDITED
	return result

/proc/_num2text(N, SigFig = 6)
	return num2text(N, SigFig)

/proc/_text2num(T)
	return text2num(T)

/proc/_ohearers(Dist, Center = usr)
	return ohearers(Dist, Center)

/proc/_orange(Dist, Center = usr)
	return orange(Dist, Center)

/proc/_output(thing, msg, control)
	thing << output(msg, control)

/proc/_oview(Dist, Center = usr)
	return oview(Dist, Center)

/proc/_oviewers(Dist, Center = usr)
	return oviewers(Dist, Center)

/proc/_params2list(Params)
	return params2list(Params)

/proc/_pick(...)
	return pick(arglist(args))

/// Allow me to explain
/// for some reason, if pick() is passed arglist(args) directly and args contains only one list
/// it considers it to be a list of lists
/// this means something like _pick(list) would fail
/// need to do this instead
///
/// I hate this timeline
/proc/_pick_list(list/pick_from)
	return pick(pick_from)

/proc/_prob(P)
	return prob(P)

/proc/_rand(L = 0, H = 1)
	return rand(L, H)

/proc/_range(Dist, Center = usr)
	return range(Dist, Center)

/proc/_rect_turfs(H_Radius = 0, V_Radius = 0, atom/Center)
	return RECT_TURFS(H_Radius, V_Radius, Center)

/proc/_regex(pattern, flags)
	return regex(pattern, flags)

/proc/_REGEX_QUOTE(text)
	return REGEX_QUOTE(text)

/proc/_REGEX_QUOTE_REPLACEMENT(text)
	return REGEX_QUOTE_REPLACEMENT(text)

/proc/_replacetext(Haystack, Needle, Replacement, Start = 1,End = 0)
	return replacetext(Haystack, Needle, Replacement, Start, End)

/proc/_replacetextEx(Haystack, Needle, Replacement, Start = 1,End = 0)
	return replacetextEx(Haystack, Needle, Replacement, Start, End)

/proc/_rgb(R, G, B)
	return rgb(R, G, B)

/proc/_rgba(R, G, B, A)
	return rgb(R, G, B, A)

/proc/_roll(dice)
	return roll(dice)

/proc/_round(A, B = 1)
	return round(A, B)

/proc/_sin(X)
	return sin(X)

/proc/_list_add(list/L, ...)
	if (args.len < 2)
		return
	L += args.Copy(2)

/proc/_list_copy(list/L, Start = 1, End = 0)
	return L.Copy(Start, End)

/proc/_list_cut(list/L, Start = 1, End = 0)
	L.Cut(Start, End)

/proc/_list_find(list/L, Elem, Start = 1, End = 0)
	return L.Find(Elem, Start, End)

/proc/_list_insert(list/L, Index, Item)
	return L.Insert(Index, Item)

/proc/_list_join(list/L, Glue, Start = 0, End = 1)
	return L.Join(Glue, Start, End)

/proc/_list_remove(list/L, ...)
	if (args.len < 2)
		return
	L -= args.Copy(2)

/proc/_list_set(list/L, key, value)
	L[key] = value

/proc/_list_get(list/L, key)
	return L[key]

/proc/_list_numerical_add(L, key, num)
	L[key] += num

/proc/_list_swap(list/L, Index1, Index2)
	L.Swap(Index1, Index2)

/proc/_walk(ref, dir, lag)
	walk(ref, dir, lag)

/proc/_walk_towards(ref, trg, lag)
	walk_towards(ref, trg, lag)

/proc/_walk_to(ref, trg, min, lag)
	walk_to(ref, trg, min, lag)

/proc/_walk_away(ref, trg, max, lag)
	walk_away(ref, trg, max, lag)

/proc/_walk_rand(ref, lag)
	walk_rand(ref, lag)

/proc/_step(ref, dir)
	step(ref, dir)

/proc/_step_rand(ref)
	step_rand(ref)

/proc/_step_to(ref, trg, min)
	step_to(ref, trg, min)

/proc/_step_towards(ref, trg)
	step_towards(ref, trg)

/proc/_step_away(ref, trg, max)
	step_away(ref, trg, max)

/proc/_has_trait(datum/thing, trait)
	return HAS_TRAIT(thing, trait)

/proc/_add_trait(datum/thing, trait, source)
	ADD_TRAIT(thing, trait, source)

/proc/_remove_trait(datum/thing, trait, source)
	REMOVE_TRAIT(thing, trait, source)

/proc/_winset(player, control_id, params)
	winset(player, control_id, params)

/proc/_winget(player, control_id, params)
	winget(player, control_id, params)

/proc/_text2path(text)
	return text2path(text)

/proc/_turn(dir, angle)
	return turn(dir, angle)

/proc/_view(Dist, Center = usr)
	return view(Dist, Center)

/proc/_viewers(Dist, Center = usr)
	return viewers(Dist, Center)

/// Auxtools REALLY doesn't know how to handle filters as values;
/// when passed as arguments to auxtools-called procs, they aren't simply treated as nulls -
/// they don't even count towards the length of args.
/// For example, calling some_proc([a filter], foo, bar) from auxtools
/// is equivalent to calling some_proc(foo, bar). Thus, we can't use _animate directly on filters.
/// Use this to perform animation steps on a filter. Consecutive steps on the same filter can be
/// achieved by calling _animate with no target.
/proc/_animate_filter(atom/target, filter_index, set_vars, time = 10, loop = 1, easing = LINEAR_EASING, flags = null)
	if(!istype(target))
		return
	if(!filter_index || filter_index < 1 || filter_index > length(target.filters))
		return
	animate(target.filters[filter_index], appearance = set_vars, time, loop, easing, flags)
