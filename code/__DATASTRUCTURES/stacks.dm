
//Both count as failures, and they don't equate to each other
//this lets us do if(pop()) without having to specifically check for underflow
//same for if(push()) and overflow
#define STACK_OVERFLOW	""
#define STACK_UNDERFLOW	null


/datum/stack
	var/list/stack = list()
	var/max_elements = 0

/datum/stack/New(list/elements,max)
	..()
	if(elements)
		stack = elements.Copy()
	if(max)
		max_elements = max

/datum/stack/proc/pop()
	if(is_empty())
		return STACK_UNDERFLOW
	. = stack[stack.len]
	stack.Cut(stack.len,0)

/datum/stack/proc/push(element)
	if(max_elements && (stack.len+1 > max_elements))
		return STACK_OVERFLOW
	stack += element

/datum/stack/proc/peek()
	if(is_empty())
		return STACK_UNDERFLOW
	. = stack[stack.len]

/datum/stack/proc/is_empty()
	. = stack.len ? 0 : 1

//Rotate entire stack left with the leftmost looping around to the right
/datum/stack/proc/rotate_left()
	if(is_empty())
		return 0
	. = stack[1]
	stack.Cut(1,2)
	push(.)

//Rotate entire stack to the right with the rightmost looping around to the left
/datum/stack/proc/rotate_right()
	if(is_empty())
		return 0
	. = stack[stack.len]
	stack.Cut(stack.len,0)
	stack.Insert(1,.)


