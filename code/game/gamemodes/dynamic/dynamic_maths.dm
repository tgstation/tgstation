#define RULE_OF_THREE(a, b, x) ((a*x)/b)

/proc/exp_distribution(var/desired_mean)
	if (desired_mean <= 0)
		desired_mean = 1 // Let's not allow that to happen
	var/lambda = 1/desired_mean
	var/x = rand()
	while (x == 1)
		x = rand()
	var/y = -(1/lambda)*log(1-x)
	return y

/proc/lorentz_distribution(var/x0, var/s)
	var/x = rand()
	var/y = s*TAN(TODEGREES(PI*(x-0.5))) + x0
	return y

/proc/lorentz_cummulative_distribution(var/x, var/x0, var/s)
	var/y = (1/PI)*TORADIANS(arctan((x-x0)/s)) + 1/2
	return y

/proc/lorentz2threat(var/x)
	var/y
	switch (x)
		if (-INFINITY to -20)
			y = rand(0, 10)
		if (-20 to -10)
			y = RULE_OF_THREE(-40, -20, x) + 50
		if (-10 to -5)
			y = RULE_OF_THREE(-30, -10, x) + 50
		if (-5 to -2.5)
			y = RULE_OF_THREE(-20, -5, x) + 50
		if (-2.5 to -0)
			y = RULE_OF_THREE(-10, -2.5, x) + 50
		if (0 to 2.5)
			y = RULE_OF_THREE(10, 2.5, x) + 50
		if (2.5 to 5)
			y = RULE_OF_THREE(20, 5, x) + 50
		if (5 to 10)
			y = RULE_OF_THREE(30, 10, x) + 50
		if (10 to 20)
			y = RULE_OF_THREE(40, 20, x) + 50
		if (20 to INFINITY)
			y = rand(90, 100)
	
	return y

#undef RULE_OF_THREE
