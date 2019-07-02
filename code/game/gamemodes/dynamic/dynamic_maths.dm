#define RULE_OF_THREE(a, b, x) ((a*x)/b)

/proc/exp_distribution(var/desired_mean)
	if (desired_mean <= 0)
		desired_mean = 1 // Let's not allow that to happen
	var/lambda = 1/desired_mean
	var/x = rand()
	while (x == 1)
		x = rand()
	. = -(1/lambda)*log(1-x)

/proc/lorentz_distribution(var/x0, var/s)
	var/x = rand()
	. = s*TAN(TODEGREES(PI*(x-0.5))) + x0

/proc/lorentz_cummulative_distribution(var/x, var/x0, var/s)
	. = (1/PI)*TORADIANS(arctan((x-x0)/s)) + 1/2

/proc/lorentz2threat(var/x)
	switch (x)
		if (-INFINITY to -20)
			return rand(0, 10)
		if (-20 to -10)
			return RULE_OF_THREE(-40, -20, x) + 50
		if (-10 to -5)
			return RULE_OF_THREE(-30, -10, x) + 50
		if (-5 to -2.5)
			return RULE_OF_THREE(-20, -5, x) + 50
		if (-2.5 to -0)
			return RULE_OF_THREE(-10, -2.5, x) + 50
		if (0 to 2.5)
			return RULE_OF_THREE(10, 2.5, x) + 50
		if (2.5 to 5)
			return RULE_OF_THREE(20, 5, x) + 50
		if (5 to 10)
			return RULE_OF_THREE(30, 10, x) + 50
		if (10 to 20)
			return RULE_OF_THREE(40, 20, x) + 50
		if (20 to INFINITY)
			return rand(90, 100)

#undef RULE_OF_THREE
