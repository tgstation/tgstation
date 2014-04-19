var/global/list/moneytypes=list(
	/obj/item/weapon/spacecash/c1000 = 1000,
	/obj/item/weapon/spacecash/c500  = 500, // Might get rid of this.
	/obj/item/weapon/spacecash/c100  = 100,
	/obj/item/weapon/spacecash/c10   = 10,
	/obj/item/weapon/spacecash       = 1,
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
	var/worth = 1 // Per chip
	var/amount = 1 // number of chips
	var/stack_color = "#4E054F"

/obj/item/weapon/spacecash/New(var/new_loc,var/new_amount=1)
	loc = new_loc
	name = "[worth] credit chip"
	amount = new_amount
	update_icon()

/obj/item/weapon/spacecash/examine()
	if(amount>1)
		usr << "\icon[src] This is a stack of [amount] [src]s."
	else
		usr << "\icon[src] This is \a [src]s."
	usr << "It's worth [worth*amount] credits."

/obj/item/weapon/spacecash/update_icon()
	icon_state = "cash[worth]"
	// Up to 100 items per stack.
	overlays = 0
	var/stacksize=round(amount/25)
	pixel_x=rand(-7,7)
	pixel_y=rand(-14,14)
	if(stacksize)
		// 0 = single
		// 1 = 1/4 stack
		// 2 = 1/2 stack
		// 3 = 3/4 stack
		// 4 = full stack
		var/image/stack = image(icon,icon_state="cashstack[stacksize]")
		stack.color=stack_color
		overlays += stack

/obj/item/weapon/spacecash/c10
	icon_state = "cash10"
	worth = 10
	stack_color = "#663200"

/obj/item/weapon/spacecash/c100
	icon_state = "cash100"
	worth = 100
	stack_color = "#663200"

/obj/item/weapon/spacecash/c500
	icon_state = "cash500"
	worth = 500
	stack_color = "#663200"

/obj/item/weapon/spacecash/c1000
	icon_state = "cash1000"
	worth = 1000
	stack_color = "#333333"

/proc/dispense_cash(var/amount, var/loc)
	for(var/cashtype in moneytypes)
		var/slice = moneytypes[cashtype]
		var/dispense_count = Floor(amount/slice)
		amount = amount % slice
		while(dispense_count>0)
			var/dispense_this_time = min(dispense_count,100)
			if(dispense_this_time > 0)
				new cashtype(loc,dispense_this_time)
				dispense_count -= dispense_this_time

/proc/count_cash(var/list/cash)
	. = 0
	for(var/obj/item/weapon/spacecash/C in cash)
		. += C.amount * C.worth