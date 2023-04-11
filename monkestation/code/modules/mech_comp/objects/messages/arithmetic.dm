#define ARITH_ADD "addition"
#define ARITH_SUB "subtraction"
#define ARITH_MULT "multiplication"
#define ARITH_DIV "division"
#define ARITH_MOD "modulo"
#define ARITH_RAND "random number generator"
#define ARITH_COMPARE_GT "comparison: greater than"
#define ARITH_COMPARE_LT "comparison: less than"
#define ARITH_COMPARE_GTE "comparison: greater than/equal to"
#define ARITH_COMPARE_LTE "comparison: less than/equal to"
#define ARITH_COMPARE_EQUAL "comparison: equal"
#define ARITH_COMPARE_NEQUAL "comparison: not equal"
#define ARITH_ROUND "round"

#define IS_SAFE(number) (!(isnull(number)))
/obj/item/mcobject/messaging/arithmetic
	name = "arithmetic component"
	base_icon_state = "comp_arith"
	icon_state = "comp_arith"

	var/A
	var/B
	var/mode = ARITH_ADD
	var/static/list/modes = list(
		ARITH_ADD,
		ARITH_SUB,
		ARITH_MULT,
		ARITH_DIV,
		ARITH_MOD,
		ARITH_COMPARE_GT,
		ARITH_COMPARE_LT,
		ARITH_COMPARE_GTE,
		ARITH_COMPARE_LTE,
		ARITH_COMPARE_EQUAL,
		ARITH_COMPARE_NEQUAL,
		ARITH_ROUND,
		ARITH_RAND,
	)

/obj/item/mcobject/messaging/arithmetic/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("set a", set_a)
	MC_ADD_INPUT("set b", set_b)
	MC_ADD_INPUT("evaluate", evaluate)
	MC_ADD_CONFIG("Set A", set_a_config)
	MC_ADD_CONFIG("Set B", set_b_config)
	MC_ADD_CONFIG("Set Arithmetic Mode", set_mode)

/obj/item/mcobject/messaging/arithmetic/proc/set_a(datum/mcmessage/input)
	var/buffer = text2num(input.cmd)
	if(!IS_SAFE(buffer))
		return
	A = buffer

/obj/item/mcobject/messaging/arithmetic/proc/set_a_config(mob/user, obj/item/tool)
	var/num = text2num(input(user, "Set \"A\" Number", "Configure Component"))
	if(IS_SAFE(num))
		return
	A = num

/obj/item/mcobject/messaging/arithmetic/proc/set_b(datum/mcmessage/input)
	var/buffer = text2num(input.cmd)
	if(!IS_SAFE(buffer))
		return
	B = buffer

/obj/item/mcobject/messaging/arithmetic/proc/set_b_config(mob/user, obj/item/tool)
	var/num = text2num(input(user, "Set \"B\" Number", "Configure Component"))
	if(IS_SAFE(num))
		return
	B = num

/obj/item/mcobject/messaging/arithmetic/proc/set_mode(mob/user, obj/item/tool)
	var/_mode = input(user, "Change evaluation mode", "Configure Component", mode) as null|anything in modes
	if(!_mode)
		return
	mode = _mode
	to_chat(user, span_notice("You set [src]'s evaluation mode to [mode]."))
	return TRUE

/obj/item/mcobject/messaging/arithmetic/proc/evaluate(datum/mcmessage/input)
	switch(mode)
		if(ARITH_ADD)
			. = A + B
		if(ARITH_SUB)
			. = A - B
		if(ARITH_MULT)
			. = A * B
		if(ARITH_DIV)
			try
				. = A / B
			catch
				. = num2text((~0)**(~0)) //Incase this ever changes
				spawn(0)
					say("ERROR, CANNOT INTERPRET VALUE")
					set_anchored(FALSE)
					throw_at(get_edge_target_turf(pick(GLOB.cardinals), 3, 1))
		if(ARITH_MOD)
			. = A % B
		if(ARITH_COMPARE_EQUAL)
			. = (A == B)
		if(ARITH_COMPARE_NEQUAL)
			. = !(A == B)
		if(ARITH_COMPARE_LT)
			. = (A < B)
		if(ARITH_COMPARE_GT)
			. = (A > B)
		if(ARITH_COMPARE_LTE)
			. = (A <= B)
		if(ARITH_COMPARE_GTE)
			. = (A >= B)
		if(ARITH_ROUND)
			. = round(A, B)
		if(ARITH_RAND)
			. = rand(A, B)

	if(!IS_SAFE(.))
		. = num2text((~0)**(~0))

	fire("[.]")

#undef IS_SAFE
#undef ARITH_ADD
#undef ARITH_SUB
#undef ARITH_MULT
#undef ARITH_DIV
#undef ARITH_MOD
#undef ARITH_RAND
#undef ARITH_COMPARE_GT
#undef ARITH_COMPARE_LT
#undef ARITH_COMPARE_GTE
#undef ARITH_COMPARE_LTE
#undef ARITH_COMPARE_EQUAL
#undef ARITH_COMPARE_NEQUAL
#undef ARITH_ROUND
