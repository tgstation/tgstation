//Helpers for potential and wisdom.

//Returns true if the potential is greater than or equal to a set amount, and false otherwise.
/proc/has_clockwork_potential(amt)
	return GLOB.clockwork_potential >= amt

//Adjusts the global potential by a set amount.
/proc/adjust_clockwork_potential(amt)
	GLOB.clockwork_potential = max(0, GLOB.clockwork_potential + amt)
	return TRUE

//Returns true if the wisdom is greater than or equal to a set amount, and false otherwise.
/proc/has_clockwork_wisdom(amt)
	return GLOB.clockwork_wisdom >= amt

//Adjusts the global wisdom by a set amount.
/proc/adjust_clockwork_wisdom(amt)
	GLOB.clockwork_wisdom = max(0, min(GLOB.max_clockwork_wisdom, GLOB.clockwork_wisdom + amt))
	return TRUE
