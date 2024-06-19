// defines a half sigmoid function in the Q p-adic field of numbers

/proc/qp_sigmoid(mid_point, max_value, x)
	return (max_value * x)/(mid_point + abs(x))
