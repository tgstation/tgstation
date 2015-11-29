#define FORWARD -1
#define BACKWARD 1

#define Co_KEY			"key"
#define Co_VIS_MSG		"vis_msg"
#define Co_START_MSG	"start_msg"
#define Co_AMOUNT		"amount"
#define Co_MAX_AMOUNT	"max_amount"
#define Co_DELAY		"delay"
#define Co_KEEP			"keep" //if permanence is set to 0, we can still store specific step items by including this in the step
#define Co_TAKE			"take" //if we want to actually have a stack or weldingtool in construction, rather than weld or add a stack, we can use this override
#define Co_DESC			"desc"

#define Co_NEXTSTEP		"nextstep"
#define Co_BACKSTEP		"backstep"

#define Co_CON_SPEED	"construct"		//For tools. See tools.dm
#define Co_DECON_SPEED	"deconstruct"	//For tools. See tools.dm

/datum/construction
	var/list/steps
	var/atom/holder
	var/result
	var/list/steps_desc
	var/taskpath = null // Path of job objective completed.
	var/assembling = 0 //if we're in a step, we won't be allowed to do another step
	var/permanence = 0
	var/list/used_atoms = list() //contains the stuff we add. Can be used in multiple-choice construction

/datum/construction/New(atom)
	..()
	holder = atom
	if(!holder) //don't want this without a holder
		spawn
			del src
	set_desc(steps.len)
	add_max_amounts()
	return

/datum/construction/proc/next_step(mob/user as mob)
	steps.len--
	if(!steps.len)
		spawn_result(user)
	else
		set_desc(steps.len)
	return

/datum/construction/proc/action(atom/used_atom,mob/user as mob)
	return

/datum/construction/proc/check_step(atom/used_atom,mob/user as mob) //check last step only
	var/valid_step = is_right_key(user,used_atom)
	if(valid_step)
		assembling = 1
		if(custom_action(steps[valid_step], used_atom, user))
			next_step(user)
			assembling = 0
			return 1
		assembling = 0
	return 0

/datum/construction/proc/is_right_key(mob/user as mob, atom/used_atom) // returns current step num if used_atom is of the right type.
	if(assembling) return 0
	var/list/L = steps[steps.len]
	if((istype(L[Co_KEY], /list) && is_type_in_list(used_atom, L[Co_KEY])) || istype(used_atom, L[Co_KEY]))
	//if our keys are in a list, we want to check them all
	//otherwise, sanity permits setting it as a single type and checking that
		if(!try_consume(user, used_atom, L))
			return 0
		return steps.len
	return 0

/datum/construction/proc/custom_action(step, used_atom, user)
	if(istype(used_atom, /obj/item/weapon/weldingtool))
		playsound(holder, 'sound/items/Welder2.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/wrench))
		playsound(holder, 'sound/items/Ratchet.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/screwdriver))
		playsound(holder, 'sound/items/Screwdriver.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/wirecutters))
		playsound(holder, 'sound/items/Wirecutter.ogg', 50, 1)

	construct_message(step, user)
	return 1


/datum/construction/proc/fixText(text,user,self=0)
	if(self)
		text = replacetext(text, "{s}", "")
		text = replacetext(text, "{USER}", "You")
	else
		text = replacetext(text, "{s}", "s")
		text = replacetext(text,"{USER}","[user]")
	text = replacetext(text,"{HOLDER}","[holder]")
	return text

/datum/construction/proc/construct_message(step, mob/user)
	if(Co_VIS_MSG in step)
		user.visible_message(fixText(step[Co_VIS_MSG],user), fixText(step[Co_VIS_MSG],user,1))

/datum/construction/proc/start_construct_message(step, mob/user, atom/movable/used_atom)
	if(Co_START_MSG in step)
		user.visible_message(fixText(step[Co_START_MSG],user), fixText(step[Co_START_MSG],user,1))

/datum/construction/proc/check_all_steps(atom/used_atom,mob/user as mob) //check all steps, remove matching one.
	for(var/i=1;i<=steps.len;i++)
		var/list/L = steps[i];
		if((islist(L[Co_KEY]) && is_type_in_list(used_atom, L[Co_KEY])) ||istype(used_atom, L[Co_KEY]))
			if(custom_action(L, used_atom, user))
				steps[i]=null;//stupid byond list from list removal...
				listclearnulls(steps);
				if(!steps.len)
					spawn_result(user)
				return 1
	return 0


/datum/construction/proc/spawn_result(mob/user as mob)
	if(result)
		testing("[user] finished a [result]!")

		new result(get_turf(holder))
		spawn()
			del holder
	return

/datum/construction/proc/set_desc(index as num)
	var/list/step = steps[index]
	holder.desc = step[Co_DESC]
	return

/datum/construction/proc/try_consume(mob/user as mob, atom/movable/used_atom, given_step)
	if(used_atom.construction_delay_mult && !used_atom.construction_delay_mult[Co_CON_SPEED])
		to_chat(user, "<span class='warning'>This tool only works for deconstruction!</span>")//It doesn't technically have to be a tool to cause this message, but it wouldn't make sense for anything else to do so.

		return 0

	if(!(Co_AMOUNT in given_step) && !(Co_DELAY in given_step))
		return 1


	var/delay = 0
	if(Co_DELAY in given_step)
		if(used_atom.construction_delay_mult)
			delay = given_step[Co_DELAY] * used_atom.construction_delay_mult[Co_CON_SPEED]
		else
			delay = given_step[Co_DELAY]
	if(delay > 0)
		start_construct_message(given_step, user, used_atom)
		if(!do_after(user, src.holder, delay, needhand = 1))
			return 0

	var/amount = 0
	if(Co_AMOUNT in given_step)
		amount = given_step[Co_AMOUNT]
	if(amount>0)
		// STACKS
		if(istype(used_atom,/obj/item/stack) && !(Co_TAKE in given_step))
			var/obj/item/stack/stack=used_atom
			if(stack.amount < amount)
				to_chat(user, "<span class='notice'>You start adding [stack] to \the [holder]. It still needs [amount - stack.amount] [stack.singular_name].</span>")
				given_step[Co_AMOUNT] -= stack.amount
				stack.use(stack.amount)
				return 0
			stack.use(amount)
		// WELDER
		else if(istype(used_atom,/obj/item/weapon/weldingtool) && !(Co_TAKE in given_step))
			var/obj/item/weapon/weldingtool/welder=used_atom
			if(!welder.isOn())
				to_chat(user, "<span class='notice'>You tap \the [holder] with your unlit welder.  [pick("Ding","Dong")].</span>")
				return 0
			if(!welder.remove_fuel(amount,user))
				to_chat(user, "<span class='warning'>You don't have enough fuel!</span>")
				return 0
		//generic things
		else
			var/atom_name = used_atom.name
			if(permanence || (Co_KEEP in given_step))
				user.drop_item(used_atom, holder)
				used_atoms.Add(list("[steps.Find(given_step)]" = used_atom))
			else
				qdel(used_atom)
			given_step[Co_AMOUNT]--
			if(given_step[Co_AMOUNT] > 0)
				to_chat(user, "<span class='notice'>You add \a [atom_name] to \the [holder]. It still needs [amount -1 ] [atom_name]\s.</span>")
				return 0
		given_step[Co_AMOUNT] = given_step[Co_MAX_AMOUNT]
	return 1

/datum/construction/proc/add_max_amounts()
	for(var/list/this_step in steps)
		if((Co_AMOUNT in this_step))
			this_step.Add(list(Co_MAX_AMOUNT = this_step[Co_AMOUNT])) //puts in something we can refer to when we reset the step

/datum/construction/reversible
	var/index

/datum/construction/reversible/New(atom)
	..()
	index = steps.len
	return

/datum/construction/reversible/proc/update_index(diff as num, mob/user as mob)
	index+=diff
	if(index==0)
		spawn_result(user)
	else
		set_desc(index)
	return

/datum/construction/reversible/is_right_key(mob/user as mob,atom/used_atom) // returns index step
	if(assembling) return 0
	assembling = 1
	var/list/step_next = get_forward_step(index)
	var/list/step_back = get_backward_step(index)
	if(step_next && ((islist(step_next[Co_KEY]) && is_type_in_list(used_atom, step_next[Co_KEY])) || istype(used_atom, step_next[Co_KEY])))
	//if our keys are in a list, we want to check them all
	//otherwise, sanity permits setting it as a single type and checking that
		if(!try_consume(user, used_atom, step_next, index, FORWARD))
			assembling = 0
			return 0
		return FORWARD //to the first step -> forward
	if(step_back && ((islist(step_back[Co_KEY]) && is_type_in_list(used_atom, step_back[Co_KEY])) || istype(used_atom, step_back[Co_KEY])))
		if(!try_consume(user, used_atom, step_back, index, BACKWARD))
			assembling = 0
			return 0
		return BACKWARD //to the last step -> backwards
	assembling = 0
	return 0

/datum/construction/reversible/check_step(atom/used_atom,mob/user as mob)
	var/diff = is_right_key(user,used_atom)
	if(diff)
		assembling = 1
		if(custom_action(index, diff, used_atom, user))
			update_index(diff,user)
			assembling = 0
			return 1
		assembling = 0
	return 0

/datum/construction/reversible/custom_action(index, diff, used_atom, user)
	. = ..(index,used_atom,user)

	if(.)
		construct_message(steps[index], user, diff, 1)

/datum/construction/reversible/construct_message(step, mob/user, diff, override)
	if(!override)
		return
	var/message_step
	if(diff == FORWARD && (Co_NEXTSTEP in step))
		message_step = step[Co_NEXTSTEP]
	else if (Co_BACKSTEP in step)
		message_step = step[Co_BACKSTEP]
	if(message_step)
		user.visible_message(fixText(message_step[Co_VIS_MSG],user), fixText(message_step[Co_VIS_MSG],user,1))

/datum/construction/reversible/start_construct_message(step, mob/user, atom/movable/used_atom)
	user.visible_message(fixText(step[Co_START_MSG],user), fixText(step[Co_START_MSG],user,1))

/datum/construction/reversible/add_max_amounts()
	for(var/i = 1; i <= steps.len; i++)
		var/list/dir_step = get_forward_step(i)
		if((Co_AMOUNT in dir_step))
			dir_step.Add(list(Co_MAX_AMOUNT = dir_step[Co_AMOUNT])) //puts in something we can refer to when we reset the step

		dir_step = get_backward_step(i)
		if((Co_AMOUNT in dir_step))
			dir_step.Add(list(Co_MAX_AMOUNT = dir_step[Co_AMOUNT]))

	//NOT IN PLACE: message segments like verbs can be written as {UN|forwardmessage|backwardmessage}. This formats that in selection
/datum/construction/reversible/fixText(message, mob/user, self = 0)
	return ..(message, user, self)
		/*
		while("{UN|" in text)
			var/start_bracket = findtext(text, "{")
			var/this_verb = copytext(text, start_bracket, findtext(text, "}", start_bracket + 1))
			to_chat(world, this_verb)
			var/marker = findtext(this_verb, "|")
			var/final_verb = ""
			if(diff == FORWARD)
				final_verb = copytext(this_verb, marker + 1, findtext(this_verb, "|", marker + 1))
			else
				final_verb = copytext(this_verb, findtext(this_verb, "|", marker + 1), findtext(text, "}", start_bracket + 1))
			to_chat(world, final_verb)
			replacetext(text, this_verb, final_verb)
		*/

/datum/construction/reversible/try_consume(mob/user as mob, atom/movable/used_atom, given_step, index, diff)
	//if we've made some progress on a step, we want to drop it
	var/current_step = (diff == BACKWARD ? get_forward_step(index) : get_backward_step(index))
	if(used_atom.construction_delay_mult && !used_atom.construction_delay_mult[diff == FORWARD ? Co_CON_SPEED : Co_DECON_SPEED])
		to_chat(user, "<span class='warning'>This tool only works for [diff == FORWARD ? "de" : ""]construction!</span>")//It doesn't technically have to be a tool to cause this message, but it wouldn't make sense for anything else to do so.

		return 0
	if(current_step && (Co_AMOUNT in current_step) && (Co_MAX_AMOUNT in current_step) && (current_step[Co_AMOUNT] < current_step[Co_MAX_AMOUNT]))
		var/obj/item/stack/S
		if(used_atoms["[index][diff == FORWARD ? "+" : "-"]"])
			for(var/atom/movable/A in used_atoms["[index][diff == FORWARD ? "+" : "-"]"])
				A.loc = holder.loc
			used_atoms.Remove("[index][diff == FORWARD ? "+" : "-"]")
		else
			var/working_type = (islist(current_step[Co_KEY]) ? pick(current_step[Co_KEY]) : current_step[Co_KEY])
			S = new working_type(holder.loc)
			if(istype(S) && !(Co_KEEP in current_step))
				S.amount = current_step[Co_MAX_AMOUNT] - current_step[Co_AMOUNT]
				S.update_icon()
			else
				for(var/i = 2; i <= current_step[Co_MAX_AMOUNT] - current_step[Co_AMOUNT]; i++)
					new working_type(holder.loc)
		current_step[Co_AMOUNT] = current_step[Co_MAX_AMOUNT]

	var/delay = 0
	if(Co_DELAY in given_step)
		if(used_atom.construction_delay_mult)
			delay = given_step[Co_DELAY] * used_atom.construction_delay_mult[diff == FORWARD ? Co_CON_SPEED : Co_DECON_SPEED]
		else
			delay = given_step[Co_DELAY]
	if(delay > 0)
		start_construct_message(given_step, user, used_atom)
		if(!do_after(user, src.holder, delay, needhand = 1))
			return 0

	var/amount = 0
	if(Co_AMOUNT in given_step)
		amount = given_step[Co_AMOUNT]
	if(amount > 0)
		// STACKS
		if(istype(used_atom,/obj/item/stack) && !(Co_TAKE in given_step))
			var/obj/item/stack/stack=used_atom
			if(stack.amount < amount)
				to_chat(user, "<span class='notice'>You start adding [stack] to \the [holder]. It still needs [amount - stack.amount] [stack.singular_name].</span>")
				given_step[Co_AMOUNT] -= stack.amount
				stack.use(stack.amount)
				return 0
			stack.use(amount)
		// WELDER
		else if(istype(used_atom,/obj/item/weapon/weldingtool) && !(Co_TAKE in given_step))
			var/obj/item/weapon/weldingtool/welder=used_atom
			if(!welder.isOn())
				to_chat(user, "<span class='notice'>You tap \the [holder] with your unlit welder.  [pick("Ding","Dong")].</span>")
				return 0
			if(!welder.remove_fuel(amount,user))
				to_chat(user, "<span class='rose'>You don't have enough fuel!</span>")
				return 0
		//generic things
		else
			var/atom_name = used_atom.name
			if(permanence || (Co_KEEP in given_step))
				user.drop_item(used_atom, holder)
				if(!("[index][diff == FORWARD ? "+" : "-"]" in used_atoms))
					used_atoms.Add(list("[index][diff == FORWARD ? "+" : "-"]" = list()))
				used_atoms["[index][diff == FORWARD ? "+" : "-"]"] += used_atom
			else
				qdel(used_atom)
			given_step[Co_AMOUNT]--
			if(given_step[Co_AMOUNT] > 0)
				to_chat(user, "<span class='notice'>You add \a [atom_name] to \the [holder]. It still needs [amount -1 ] [atom_name]\s.</span>")
				return 0
		given_step[Co_AMOUNT] = given_step[Co_MAX_AMOUNT]

	else
		var/list/spawn_step
		var/new_index = (diff == FORWARD ? index - 1 : index + 1)
		if(new_index == 0)
			message_admins("Holy shit [src]/([src.type]) is trying to set its new index to 0! how the fuck did this happen? I don't know, our direction is [diff==FORWARD?"forward":"backward"] old index was [index]. User is [formatPlayerPanel(user,user.ckey)], itemused [used_atom], step [given_step]")
			spawn_result(user)
			return 1
			//CRASH("Holy shit [src]/([src.type]) is trying to set its new index to 0! how the fuck did this happen? I don't know, our direction is [diff==FORWARD?"forward":"backward"] old index was [index]. User is [user], itemused [used_atom], step [given_step]")
		if(diff == FORWARD)
			spawn_step = get_backward_step(new_index)
		else if(diff == BACKWARD)
			spawn_step = get_forward_step(new_index)
		var/list/atom/movable/to_drop = list()

		if(("[new_index][diff == FORWARD ? "-" : "+"]" in used_atoms) && used_atoms["[new_index][diff == FORWARD ? "-" : "+"]"])
			to_drop = used_atoms["[new_index][diff == FORWARD ? "-" : "+"]"]
			used_atoms.Remove("[new_index][diff == FORWARD ? "-" : "+"]")

		else if(Co_AMOUNT in spawn_step)
			var/to_create = (islist(spawn_step[Co_KEY]) ? pick(spawn_step[Co_KEY]) : spawn_step[Co_KEY])
			var/test = new to_create
			if(istype(test, /obj/item/weapon/weldingtool) && !(Co_TAKE in spawn_step))
				qdel(test)
			else if(istype(test, /obj/item/stack) && !(Co_TAKE in spawn_step))
				var/obj/item/stack/S = test
				S.amount = spawn_step[Co_AMOUNT]
				to_drop.Add(S)
			else
				to_drop.Add(test)
				for(var/i = 1; i <= spawn_step[Co_AMOUNT] - 1; i++)
					to_drop.Add(new to_create)

		for(var/atom/movable/this_drop in to_drop)
			this_drop.loc = holder.loc
	return 1

/datum/construction/reversible/proc/get_forward_step(index)
	if(index < 0 || index > steps.len)
		return
	var/list/S = steps[index]
	if(Co_NEXTSTEP in S)
		return S[Co_NEXTSTEP]

/datum/construction/reversible/proc/get_backward_step(index)
	if(index < 0 || index > steps.len)
		return
	var/list/S = steps[index]
	if(Co_BACKSTEP in S)
		return S[Co_BACKSTEP]