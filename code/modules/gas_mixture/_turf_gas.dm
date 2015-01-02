/var/list/static_gas = list()
/var/list/static_gas_list = list()

/turf
	var/init_gas = ""

/proc/get_static_gas(gas_str)
	. = static_gas[gas_str]
	if(isnull(.))
		register_static_gas(gas_str)
		. = static_gas[gas_str]

/proc/get_static_gas_list(gas_str)
	. = static_gas_list[gas_str]
	if(isnull(.))
		register_static_gas(gas_str)
		. = static_gas_list[gas_str]

/proc/register_static_gas(gas_str)
	var/list/gas_list = params2list(gas_str)

	for(var/gasid in gas_list)
		gas_list[gasid] = text2num(gas_list[gasid])

	static_gas[gas_str] = new /datum/gas_mixture(gas_list)
	static_gas_list[gas_str] = gas_list
