// --- DISTRIBUTION MODES ---
// -- READ ME --

// -- Default mode is Lorentz

// - Lorentz     : Lorentz distribution of parameters (heavily centrered but does allow extreme value)
// - Gauss       : Gaussian distribution (wider and less likely to get extreme values)
// - Dirac       : Forced threat level (chosen by an admin roundstart)
// - Exponential : Biased towards more peaceful rounds
// - Uniform     : All levels have the same chance to happen

// Transforms a curve-bell centered on zero with a number between 0 and 100.

// Lorentz distribution

#define RULE_OF_THREE(a, b, x) ((a*x)/b)

/proc/lorentz_distribution(var/x0, var/s)
	var/x = rand()
	var/y = s*TAN(TODEGREES(PI*(x-0.5))) + x0
	return y

// -- Returns the Lorentz cummulative distribution of the real x.

/proc/lorentz_cummulative_distribution(var/x, var/x0, var/s)
	var/y = (1/PI)*TORADIANS(arctan((x-x0)/s)) + 1/2
	return y

// -- Returns an exponentially-distributed number.
// -- The probability density function has mean lambda

/proc/exp_distribution(var/lambda)
	if (lambda <= 0)
		lambda = 1 // Let's not allow that to happen
	var/x = rand()
	while (x == 1)
		x = rand()
	var/y = -(1/lambda)*log(1-x)
	return y
	
// -- Returns the Lorentz cummulative distribution of the real x, with mean lambda

/proc/exp_cummulative_distribution(var/x, var/lambda)
	var/y = 1 - NUM_E**(lambda*x)
	return y


/proc/lorentz2threat(var/x)
	var/y
	switch (x)
		// Left end of the tail, the lowest bound is -inf.
		// 0 to 10.
		if (-INFINITY to -20)
			y = rand(0, 10)
		// Porportional conversion from the lorentz variable to the threat.

		// First, we use a rule of three to get a number from -40 to -30.
		// Then we shift it by 50 to get a number from 10 to 20. 
		// The same process is done for other intervalls.
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

		// Right end of the tail, higher bound is +inf.

		if (20 to INFINITY)
			y = rand(90, 100)
	
	return y

// Same as above, but for a Gaussian law, which has much shorter tails.
/proc/Gauss2threat(var/x)
	var/y
	switch (x)
		// Left end of the tail, the lowest bound is -inf.
		// 0 to 10.
		if (-INFINITY to -5)
			y = rand(0, 10)
		// Porportional conversion from the gaussian variable to the threat.
		if (-5 to -4)
			y = RULE_OF_THREE(-40, -5, x) + 50
		if (-4 to -3)
			y = RULE_OF_THREE(-30, -4, x) + 50
		if (-3 to -2)
			y = RULE_OF_THREE(-20, -3, x) + 50
		if (-2 to 0)
			y = RULE_OF_THREE(-10, -2, x) + 50
		if (0 to 2)
			y = RULE_OF_THREE(10, 2, x) + 50
		if (2 to 3)
			y = RULE_OF_THREE(20, 3, x) + 50
		if (3 to 4)
			y = RULE_OF_THREE(30, 4, x) + 50
		if (4 to 5)
			y = RULE_OF_THREE(40, 5, x) + 50

		// Right end of the tail, higher bound is +inf.

		if (20 to INFINITY)
			y = rand(90, 100)
	
	return y

// Exp gives us something between 0 and 5 ; we just convert it to something between 0 and 100.
// 2.5 is 50 in that case.
/proc/exp2threat(var/x)
	var/y
	y = RULE_OF_THREE(50, 2.5, x)
	if (y > 100)
		y = 100
	return y

proc/GaussRand(var/sigma)
	var/x,y,rsq
	do
		x=2*rand()-1
		y=2*rand()-1
		rsq=x*x+y*y
	while(rsq>1 || !rsq)
	return sigma*y*sqrt(-2*log(rsq)/rsq)

/datum/game_mode/dynamic/proc/generate_threat()
	message_admins("Generating threat ; mode is [distribution_mode]")
	switch (distribution_mode)
	// Old equation.
	//threat_level = rand(1,100)*0.6 + rand(1,100)*0.4//https://docs.google.com/spreadsheets/d/1QLN_OBHqeL4cm9zTLEtxlnaJHHUu0IUPzPbsI-DFFmc/edit#gid=499381388

	// New equation : https://docs.google.com/spreadsheets/d/1qnQm5hDdwZoyVmBCtf6-jwwHKEaCnYa3ljmYPs7gkSE/edit#gid=0
		if (LORENTZ)
			relative_threat = lorentz_distribution(dynamic_curve_centre, dynamic_curve_width)
			threat_level = lorentz2threat(relative_threat)
			threat = round(threat, 0.1)

			curve_centre_of_round = dynamic_curve_centre
			curve_width_of_round = dynamic_curve_width

			peaceful_percentage = round(lorentz_cummulative_distribution(relative_threat, curve_centre_of_round, curve_width_of_round), 0.01)*100

			threat = threat_level
			starting_threat = threat_level

		if (GAUSS)
			relative_threat = dynamic_curve_centre + GaussRand(dynamic_curve_width)
			threat_level = Gauss2threat(relative_threat)
			threat = round(threat, 0.1)
			peaceful_percentage = "Undefined" // No analytical form for this one

			curve_centre_of_round = dynamic_curve_centre
			curve_width_of_round = dynamic_curve_width

			threat = threat_level
			starting_threat = threat_level

		if (DIRAC)
			threat = dynamic_curve_centre
			threat_level = dynamic_curve_centre
			starting_threat = threat_level
			peaceful_percentage = "Undefined"

		if (EXPONENTIAL)
			relative_threat = exp_distribution(dynamic_curve_centre)
			threat_level = exp2threat(relative_threat)
			threat = round(threat, 0.1)

			curve_centre_of_round = dynamic_curve_centre

			peaceful_percentage = round(exp_cummulative_distribution(relative_threat, curve_centre_of_round), 0.01)*100

			threat = threat_level
			starting_threat = threat_level

		if (UNIFORM)
			threat_level = rand(1, 100)
			threat = threat_level
			starting_threat = threat_level
			peaceful_percentage = "Undefined"

#undef RULE_OF_THREE
