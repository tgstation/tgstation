var/global/list/moneytypes = list(
	/obj/item/weapon/spacecash/c1000 = 1000,
	/obj/item/weapon/spacecash/c100  = 100,
	/obj/item/weapon/spacecash/c10   = 10,
	/obj/item/weapon/spacecash       = 1,
	// /obj/item/weapon/coin/plasma       = 0.1,
	// /obj/item/weapon/coin/iron       = 0.01,
)

/obj/item/weapon/spacecash
	name = "credit chip"
	desc = "Money money money."
	gender = PLURAL
	icon = 'icons/obj/money.dmi'
	icon_state = "cash1"
	opacity = 0
	density = 0
	anchored = 0.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 1
	throw_range = 2
	w_class = 1.0
	var/access = list()
	access = access_crate_cash
	var/worth = 1 //Per chip
	var/amount = 1 //Number of chips
	var/stack_color = "#4E054F"
	autoignition_temperature=AUTOIGNITION_PAPER

/obj/item/weapon/spacecash/New(var/new_loc,var/new_amount=1)
	. = ..(new_loc)
	name = "[worth] credit chip"
	amount = new_amount
	update_icon()

/obj/item/weapon/spacecash/attack_hand(mob/user as mob)
	if (user.get_inactive_hand() == src)
		var/obj/item/weapon/spacecash/C = new src.type(user, new_amount=1)
		C.copy_evidences(src)
		user.put_in_hands(C)
		src.add_fingerprint(user)
		C.add_fingerprint(user)
		amount--
		if(amount<=0)
			qdel(src)
		else
			update_icon()
	else
		return ..()

/obj/item/weapon/spacecash/proc/copy_evidences(obj/item/stack/from as obj)
	src.blood_DNA = from.blood_DNA
	src.fingerprints  = from.fingerprints
	src.fingerprintshidden  = from.fingerprintshidden
	src.fingerprintslast  = from.fingerprintslast

/obj/item/weapon/spacecash/proc/can_stack_with(obj/item/other_stack)
	return src.type == other_stack.type

/obj/item/weapon/spacecash/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if (!proximity_flag)
		return 0

	if (can_stack_with(target))
		var/obj/item/weapon/spacecash/S = target
		if (amount >= 10)
			to_chat(user, "\The [src] cannot hold anymore chips.")
			return 1
		var/to_transfer = 1
		if (user.get_inactive_hand()!=S)
			to_transfer = min(S.amount, 10-amount)
		amount+=to_transfer
		to_chat(user, "You add [to_transfer] chip\s to the stack. It now contains [amount] chips, worth [amount*worth] credits.")
		S.amount-=to_transfer
		if(S.amount<=0)
			qdel(S)
		else
			S.update_icon()
		update_icon()
		return 1
	return ..()

/obj/item/weapon/spacecash/examine(mob/user)
	if(amount > 1)
		setGender(PLURAL)
		..()
		to_chat(user, "It's a stack holding [amount] chips.")
		to_chat(user, "<span class='info'>It's worth [worth*amount] credits.</span>")
	else
		setGender(NEUTER)
		..()

/obj/item/weapon/spacecash/update_icon()
	icon_state = "cash[worth]"
	//Up to 100 items per stack.
	overlays = 0
	var/stacksize=round(amount/2.5)
	pixel_x = rand(-7, 7)
	pixel_y = rand(-14, 14)
	if(stacksize)
		// 0 = single
		// 1 = 1/4 stack
		// 2 = 1/2 stack
		// 3 = 3/4 stack
		// 4 = full stack
		var/image/stack = image(icon,icon_state="cashstack[stacksize]")
		stack.color=stack_color
		overlays += stack

/obj/item/weapon/spacecash/proc/collect_from(var/obj/item/weapon/spacecash/cash)
	if(cash.worth == src.worth)
		var/taking = min(10-src.amount,cash.amount)
		cash.amount -= taking
		src.amount += taking
		if(cash.amount <= 0)
			qdel(cash)
		return taking
	return 0

/obj/item/weapon/spacecash/afterattack(atom/A as mob|obj, mob/user as mob)
	if(istype(A, /obj/item/weapon/spacecash))
		var/obj/item/weapon/spacecash/cash = A
		var/collected = src.collect_from(cash)
		if(collected)
			update_icon()
			to_chat(user, "<span class='notice'>You add [collected] [src.name][amount > 1 ? "s":""] to your stack of cash.</span>")

/obj/item/weapon/spacecash/c10
	icon_state = "cash10"
	worth = 10
	stack_color = "#663200"

/obj/item/weapon/spacecash/c100
	icon_state = "cash100"
	worth = 100
	stack_color = "#084407"

/obj/item/weapon/spacecash/c1000
	icon_state = "cash1000"
	worth = 1000
	stack_color = "#333333"

/obj/structure/closet/cash_closet/New()
	var/list/types = typesof(/obj/item/weapon/spacecash)
	for(var/i = 1 to rand(3,10))
		var/typepath = pick(types)
		new typepath(src)

/proc/dispense_cash(var/amount, var/loc)
	for(var/cashtype in moneytypes)
		var/slice = moneytypes[cashtype]
		var/dispense_count = Floor(amount/slice)
		amount = amount % slice
		while(dispense_count>0)
			var/dispense_this_time = min(dispense_count,10)
			if(dispense_this_time > 0)
				new cashtype(loc,dispense_this_time)
				dispense_count -= dispense_this_time

/proc/count_cash(var/list/cash)
	. = 0
	for(var/obj/item/weapon/spacecash/C in cash)
		. += C.amount * C.worth
