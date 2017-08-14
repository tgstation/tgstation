/* Stack type objects!
 * Contains:
 * 		Stacks
 *		Recipe datum
 */

/*
 * Stacks
 */
/obj/item/stack
	origin_tech = "materials=1"
	gender = PLURAL
	var/list/datum/stack_recipe/recipes
	var/singular_name
	var/amount = 1
	var/max_amount = 50 //also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount
	var/is_cyborg = 0 // It's 1 if module is used by a cyborg, and uses its storage
	var/datum/robot_energy_storage/source
	var/cost = 1 // How much energy from storage it costs
	var/merge_type = null // This path and its children should merge with this stack, defaults to src.type
	var/full_w_class = WEIGHT_CLASS_NORMAL //The weight class the stack should have at amount > 2/3rds max_amount
	var/novariants = TRUE //Determines whether the item should update it's sprites based on amount.

/obj/item/stack/Initialize(mapload, new_amount=null , merge = TRUE)
	. = ..()
	if(new_amount)
		amount = new_amount
	if(!merge_type)
		merge_type = type
	if(merge)
		for(var/obj/item/stack/S in loc)
			if(S.merge_type == merge_type)
				merge(S)
	update_weight()
	update_icon()

/obj/item/stack/proc/update_weight()
	if(amount <= (max_amount * (1/3)))
		w_class = Clamp(full_w_class-2, WEIGHT_CLASS_TINY, full_w_class)
	else if (amount <= (max_amount * (2/3)))
		w_class = Clamp(full_w_class-1, WEIGHT_CLASS_TINY, full_w_class)
	else
		w_class = full_w_class

/obj/item/stack/update_icon()
	if(novariants)
		return ..()
	if(amount <= (max_amount * (1/3)))
		icon_state = initial(icon_state)
	else if (amount <= (max_amount * (2/3)))
		icon_state = "[initial(icon_state)]_2"
	else
		icon_state = "[initial(icon_state)]_3"
	..()


/obj/item/stack/Destroy()
	if (usr && usr.machine==src)
		usr << browse(null, "window=stack")
	. = ..()

/obj/item/stack/examine(mob/user)
	..()
	if (is_cyborg)
		if(src.singular_name)
			to_chat(user, "There is enough energy for [src.get_amount()] [src.singular_name]\s.")
		else
			to_chat(user, "There is enough energy for [src.get_amount()].")
		return
	if(src.singular_name)
		if(src.get_amount()>1)
			to_chat(user, "There are [src.get_amount()] [src.singular_name]\s in the stack.")
		else
			to_chat(user, "There is [src.get_amount()] [src.singular_name] in the stack.")
	else if(src.get_amount()>1)
		to_chat(user, "There are [src.get_amount()] in the stack.")
	else
		to_chat(user, "There is [src.get_amount()] in the stack.")

/obj/item/stack/proc/get_amount()
	if(is_cyborg)
		. = round(source.energy / cost)
	else
		. = (amount)

/obj/item/stack/attack_self(mob/user)
	interact(user)

/obj/item/stack/interact(mob/user)
	if (!recipes)
		return
	if (!src || get_amount() <= 0)
		user << browse(null, "window=stack")
		return
	user.set_machine(src) //for correct work of onclose
	var/t1 = text("<HTML><HEAD><title>Constructions from []</title></HEAD><body><TT>Amount Left: []<br>", src, src.get_amount())
	for(var/i=1;i<=recipes.len,i++)
		var/datum/stack_recipe/R = recipes[i]
		if (isnull(R))
			t1 += "<hr>"
			continue
		if (i>1 && !isnull(recipes[i-1]))
			t1+="<br>"
		var/max_multiplier = round(src.get_amount() / R.req_amount)
		var/title as text
		var/can_build = 1
		can_build = can_build && (max_multiplier>0)
		if (R.res_amount>1)
			title+= "[R.res_amount]x [R.title]\s"
		else
			title+= "[R.title]"
		title+= " ([R.req_amount] [src.singular_name]\s)"
		if (can_build)
			t1 += text("<A href='?src=\ref[];make=[];multiplier=1'>[]</A>  ", src, i, title)
		else
			t1 += text("[]", title)
			continue
		if (R.max_res_amount>1 && max_multiplier>1)
			max_multiplier = min(max_multiplier, round(R.max_res_amount/R.res_amount))
			t1 += " |"
			var/list/multipliers = list(5,10,25)
			for (var/n in multipliers)
				if (max_multiplier>=n)
					t1 += " <A href='?src=\ref[src];make=[i];multiplier=[n]'>[n*R.res_amount]x</A>"
			if (!(max_multiplier in multipliers))
				t1 += " <A href='?src=\ref[src];make=[i];multiplier=[max_multiplier]'>[max_multiplier*R.res_amount]x</A>"

	t1 += "</TT></body></HTML>"
	user << browse(t1, "window=stack")
	onclose(user, "stack")

/obj/item/stack/Topic(href, href_list)
	..()
	if (usr.restrained() || usr.stat || usr.get_active_held_item() != src)
		return
	if (href_list["make"])
		if (src.get_amount() < 1) qdel(src) //Never should happen

		var/datum/stack_recipe/R = recipes[text2num(href_list["make"])]
		var/multiplier = text2num(href_list["multiplier"])
		if (!multiplier ||(multiplier <= 0)) //href protection
			return
		if(!building_checks(R, multiplier))
			return
		if (R.time)
			usr.visible_message("<span class='notice'>[usr] starts building [R.title].</span>", "<span class='notice'>You start building [R.title]...</span>")
			if (!do_after(usr, R.time, target = usr))
				return
			if(!building_checks(R, multiplier))
				return

		var/atom/O = new R.result_type( usr.loc )
		O.setDir(usr.dir)
		use(R.req_amount * multiplier)

		//START: oh fuck i'm so sorry
		if(istype(O, /obj/structure/windoor_assembly))
			var/obj/structure/windoor_assembly/W = O
			W.ini_dir = W.dir
		else if(istype(O, /obj/structure/window))
			var/obj/structure/window/W = O
			W.ini_dir = W.dir
		//END: oh fuck i'm so sorry

		//is it a stack ?
		if (R.max_res_amount > 1)
			var/obj/item/stack/new_item = O
			new_item.amount = R.res_amount*multiplier
			new_item.update_icon()

			if(new_item.amount <= 0)//if the stack is empty, i.e it has been merged with an existing stack and has been garbage collected
				return

		if (isitem(O))
			usr.put_in_hands(O)
		O.add_fingerprint(usr)

		//BubbleWrap - so newly formed boxes are empty
		if ( istype(O, /obj/item/weapon/storage) )
			for (var/obj/item/I in O)
				qdel(I)
		//BubbleWrap END

	if (src && usr.machine==src) //do not reopen closed window
		addtimer(CALLBACK(src, /atom/.proc/interact, usr), 0)

/obj/item/stack/proc/building_checks(datum/stack_recipe/R, multiplier)
	if (src.get_amount() < R.req_amount*multiplier)
		if (R.req_amount*multiplier>1)
			to_chat(usr, "<span class='warning'>You haven't got enough [src] to build \the [R.req_amount*multiplier] [R.title]\s!</span>")
		else
			to_chat(usr, "<span class='warning'>You haven't got enough [src] to build \the [R.title]!</span>")
		return 0
	if(R.window_checks && !valid_window_location(usr.loc, usr.dir))
		to_chat(usr, "<span class='warning'>The [R.title] won't fit here!</span>")
		return 0
	if(R.one_per_turf && (locate(R.result_type) in usr.loc))
		to_chat(usr, "<span class='warning'>There is another [R.title] here!</span>")
		return 0
	if(R.on_floor && !isfloorturf(usr.loc))
		to_chat(usr, "<span class='warning'>\The [R.title] must be constructed on the floor!</span>")
		return 0
	return 1

/obj/item/stack/proc/use(used, transfer = FALSE) // return 0 = borked; return 1 = had enough
	if(zero_amount())
		return 0
	if (is_cyborg)
		return source.use_charge(used * cost)
	if (amount < used)
		return 0
	amount -= used
	zero_amount()
	update_icon()
	update_weight()
	return 1

/obj/item/stack/proc/zero_amount()
	if(is_cyborg)
		return source.energy < cost
	if(amount < 1)
		qdel(src)
		return 1
	return 0

/obj/item/stack/proc/add(amount)
	if (is_cyborg)
		source.add_charge(amount * cost)
	else
		src.amount += amount
	update_icon()
	update_weight()

/obj/item/stack/proc/merge(obj/item/stack/S) //Merge src into S, as much as possible
	if(QDELETED(S) || QDELETED(src) || S == src) //amusingly this can cause a stack to consume itself, let's not allow that.
		return
	var/transfer = get_amount()
	if(S.is_cyborg)
		transfer = min(transfer, round((S.source.max_energy - S.source.energy) / S.cost))
	else
		transfer = min(transfer, S.max_amount - S.amount)
	if(pulledby)
		pulledby.start_pulling(S)
	S.copy_evidences(src)
	use(transfer, TRUE)
	S.add(transfer)

/obj/item/stack/Crossed(obj/o)
	if(istype(o, merge_type) && !o.throwing)
		merge(o)
	. = ..()

/obj/item/stack/hitby(atom/movable/AM, skip, hitpush)
	if(istype(AM, merge_type))
		merge(AM)
	. = ..()

/obj/item/stack/attack_hand(mob/user)
	if (user.get_inactive_held_item() == src)
		if(zero_amount())
			return
		change_stack(user,1)
	else
		..()

/obj/item/stack/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	if(is_cyborg)
		return
	else
		if(zero_amount())
			return
		//get amount from user
		var/min = 0
		var/max = src.get_amount()
		var/stackmaterial = round(input(user,"How many sheets do you wish to take out of this stack? (Maximum  [max])") as num)
		if(stackmaterial == null || stackmaterial <= min || stackmaterial >= src.get_amount())
			return
		else
			change_stack(user,stackmaterial)
			to_chat(user, "<span class='notice'>You take [stackmaterial] sheets out of the stack</span>")

/obj/item/stack/proc/change_stack(mob/user,amount)
	var/obj/item/stack/F = new type(user, amount, FALSE)
	. = F
	F.copy_evidences(src)
	user.put_in_hands(F)
	add_fingerprint(user)
	F.add_fingerprint(user)
	use(amount, TRUE)



/obj/item/stack/attackby(obj/item/W, mob/user, params)
	if(istype(W, merge_type))
		var/obj/item/stack/S = W
		merge(S)
		to_chat(user, "<span class='notice'>Your [S.name] stack now contains [S.get_amount()] [S.singular_name]\s.</span>")
	else
		. = ..()

/obj/item/stack/proc/copy_evidences(obj/item/stack/from as obj)
	src.blood_DNA = from.blood_DNA
	src.fingerprints  = from.fingerprints
	src.fingerprintshidden  = from.fingerprintshidden
	src.fingerprintslast  = from.fingerprintslast
	//TODO bloody overlay

/obj/item/stack/microwave_act(obj/machinery/microwave/M)
	if(M && M.dirty < 100)
		M.dirty += amount

/*
 * Recipe datum
 */
/datum/stack_recipe
	var/title = "ERROR"
	var/result_type
	var/req_amount = 1
	var/res_amount = 1
	var/max_res_amount = 1
	var/time = 0
	var/one_per_turf = FALSE
	var/on_floor = FALSE
	var/window_checks = FALSE

/datum/stack_recipe/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, one_per_turf = FALSE, on_floor = FALSE, window_checks = FALSE)
	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.one_per_turf = one_per_turf
	src.on_floor = on_floor
	src.window_checks = window_checks
