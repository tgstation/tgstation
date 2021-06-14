/proc/cmp_epsilon_less_than(a,b,epsilon = MAXIMUM_ERROR_GAS_REMOVAL)
	return (a < (b + epsilon))

/proc/cmp_epsilon_greater_than(a,b,epsilon = MAXIMUM_ERROR_GAS_REMOVAL)
	return ((a + epsilon) > b)

/proc/cmp_epsilon_equals(a,b,epsilon = MAXIMUM_ERROR_GAS_REMOVAL)
	return (((a + epsilon) > b) && ((a - epsilon) < b))
