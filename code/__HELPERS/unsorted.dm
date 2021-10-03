/*
 * A large number of misc global procs.
 */

///Picks a string of symbols to display as the law number for hacked or ion laws
/proc/ion_num() //! is at the start to prevent us from changing say modes via get_message_mode()
	return "![pick("!","@","#","$","%","^","&")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")]"

/proc/format_text(text)
	return replacetext(replacetext(text,"\proper ",""),"\improper ","")

/proc/is_valid_src(datum/source_datum)
	if(istype(source_datum))
		return !QDELETED(source_datum)
	return 0

//gives us the stack trace from CRASH() without ending the current proc.
/proc/stack_trace(msg)
	CRASH(msg)

/datum/proc/stack_trace(msg)
	CRASH(msg)

GLOBAL_REAL_VAR(list/stack_trace_storage)
/proc/gib_stack_trace()
	stack_trace_storage = list()
	stack_trace()
	stack_trace_storage.Cut(1, min(3,stack_trace_storage.len))
	. = stack_trace_storage
	stack_trace_storage = null

///Returns a string for a random nuke code
/proc/random_nukecode()
	var/val = rand(0, 99999)
	var/str = "[val]"
	while(length(str) < 5)
		str = "0" + str
	. = str

///Returns a string based on the weight class define used as argument
/proc/weight_class_to_text(w_class)
	switch(w_class)
		if(WEIGHT_CLASS_TINY)
			. = "tiny"
		if(WEIGHT_CLASS_SMALL)
			. = "small"
		if(WEIGHT_CLASS_NORMAL)
			. = "normal-sized"
		if(WEIGHT_CLASS_BULKY)
			. = "bulky"
		if(WEIGHT_CLASS_HUGE)
			. = "huge"
		if(WEIGHT_CLASS_GIGANTIC)
			. = "gigantic"
		else
			. = ""

/proc/pass(...)
	return

/**
 * returns a GUID like identifier (using a mostly made up record format)
 * guids are not on their own suitable for access or security tokens, as most of their bits are predictable.
 * (But may make a nice salt to one)
**/
/proc/GUID()
	var/const/GUID_VERSION = "b"
	var/const/GUID_VARIANT = "d"
	var/node_id = copytext_char(md5("[rand()*rand(1,9999999)][world.name][world.hub][world.hub_password][world.internet_address][world.address][world.contents.len][world.status][world.port][rand()*rand(1,9999999)]"), 1, 13)

	var/time_high = "[num2hex(text2num(time2text(world.realtime,"YYYY")), 2)][num2hex(world.realtime, 6)]"

	var/time_mid = num2hex(world.timeofday, 4)

	var/time_low = num2hex(world.time, 3)

	var/time_clock = num2hex(TICK_DELTA_TO_MS(world.tick_usage), 3)

	return "{[time_high]-[time_mid]-[GUID_VERSION][time_low]-[GUID_VARIANT][time_clock]-[node_id]}"

/**
 * \ref behaviour got changed in 512 so this is necesary to replicate old behaviour.
 * If it ever becomes necesary to get a more performant REF(), this lies here in wait
 * #define REF(thing) (thing && istype(thing, /datum) && (thing:datum_flags & DF_USE_TAG) && thing:tag ? "[thing:tag]" : "\ref[thing]")
**/
/proc/REF(input)
	if(istype(input, /datum))
		var/datum/thing = input
		if(thing.datum_flags & DF_USE_TAG)
			if(!thing.tag)
				stack_trace("A ref was requested of an object with DF_USE_TAG set but no tag: [thing]")
				thing.datum_flags &= ~DF_USE_TAG
			else
				return "\[[url_encode(thing.tag)]\]"
	return "\ref[input]"

///Makes a call in the context of a different usr. Use sparingly
/world/proc/PushUsr(mob/M, datum/callback/CB, ...)
	var/temp = usr
	usr = M
	if (length(args) > 2)
		. = CB.Invoke(arglist(args.Copy(3)))
	else
		. = CB.Invoke()
	usr = temp

///datum may be null, but it does need to be a typed var
#define NAMEOF(datum, X) (#X || ##datum.##X)

#define VARSET_LIST_CALLBACK(target, var_name, var_value) CALLBACK(GLOBAL_PROC, /proc/___callbackvarset, ##target, ##var_name, ##var_value)
//dupe code because dm can't handle 3 level deep macros
#define VARSET_CALLBACK(datum, var, var_value) CALLBACK(GLOBAL_PROC, /proc/___callbackvarset, ##datum, NAMEOF(##datum, ##var), ##var_value)

/proc/___callbackvarset(list_or_datum, var_name, var_value)
	if(length(list_or_datum))
		list_or_datum[var_name] = var_value
		return
	var/datum/D = list_or_datum
	if(IsAdminAdvancedProcCall())
		D.vv_edit_var(var_name, var_value) //same result generally, unless badmemes
	else
		D.vars[var_name] = var_value

///Get a random food item exluding the blocked ones
/proc/get_random_food()
	var/list/blocked = list(/obj/item/food/bread,
		/obj/item/food/breadslice,
		/obj/item/food/cake,
		/obj/item/food/cakeslice,
		/obj/item/food/pie,
		/obj/item/food/pieslice,
		/obj/item/food/kebab,
		/obj/item/food/pizza,
		/obj/item/food/pizzaslice,
		/obj/item/food/salad,
		/obj/item/food/meat,
		/obj/item/food/meat/slab,
		/obj/item/food/soup,
		/obj/item/food/grown,
		/obj/item/food/grown/mushroom,
		/obj/item/food/deepfryholder,
		/obj/item/food/clothing,
		/obj/item/food/meat/slab/human/mutant,
		/obj/item/food/grown/ash_flora,
		/obj/item/food/grown/nettle,
		/obj/item/food/grown/shell
		)

	return pick(subtypesof(/obj/item/food) - blocked)

///Gets a random drink excluding the blocked type
/proc/get_random_drink()
	var/list/blocked = list(
		/obj/item/reagent_containers/food/drinks/soda_cans,
		/obj/item/reagent_containers/food/drinks/bottle
		)
	return pick(subtypesof(/obj/item/reagent_containers/food/drinks) - blocked)

/proc/special_list_filter(list/L, datum/callback/condition)
	if(!islist(L) || !length(L) || !istype(condition))
		return list()
	. = list()
	for(var/i in L)
		if(condition.Invoke(i))
			. |= i

/proc/CallAsync(datum/source, proctype, list/arguments)
	set waitfor = FALSE
	return call(source, proctype)(arglist(arguments))

/**
 * One proc for easy spawning of pods in the code to drop off items before whizzling (please don't proc call this in game, it will destroy you)
 *
 * Arguments:
 * * specifications: special mods to the pod, see non var edit specifications for details on what you should fill this with
 * Non var edit specifications:
 * * target = where you want the pod to drop
 * * path = a special specific pod path if you want, this can save you a lot of var edits
 * * style = style of the pod, defaults to the normal pod
 * * spawn = spawned path or a list of the paths spawned, what you're sending basically
 * Returns the pod spawned, in case you want to spawn items yourself and modify them before putting them in.
 */
/proc/podspawn(specifications)
	//get non var edit specifications
	var/turf/landing_location = specifications["target"]
	var/spawn_type = specifications["path"]
	var/style = specifications["style"]
	var/list/paths_to_spawn = specifications["spawn"]

	//setup pod, add contents
	if(!isturf(landing_location))
		landing_location = get_turf(landing_location)
	if(!spawn_type)
		spawn_type = /obj/structure/closet/supplypod/podspawn
	var/obj/structure/closet/supplypod/podspawn/pod = new spawn_type(null, style)
	if(paths_to_spawn && !islist(paths_to_spawn))
		paths_to_spawn = list(paths_to_spawn)
	for(var/atom/path as anything in paths_to_spawn)
		path = new path(pod)

	//remove non var edits from specifications
	specifications -= "target"
	specifications -= "style"
	specifications -= "path"
	specifications -= "spawn" //list, we remove the key

	//rest of specificiations are edits on the pod
	for(var/variable_name in specifications)
		var/variable_value = specifications[variable_name]
		if(!pod.vv_edit_var(variable_name, variable_value))
			stack_trace("WARNING! podspawn vareditting \"[variable_name]\" to \"[variable_value]\" was rejected by the pod!")
	new /obj/effect/pod_landingzone(landing_location, pod)
	return pod
