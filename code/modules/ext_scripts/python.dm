/proc/ext_python(var/script, var/args, var/scriptsprefix = 1)
	if(scriptsprefix) script = "scripts/" + script

	if(world.system_type == MS_WINDOWS)
		script = replacetext(script, "/", "\\")

	var/command = config.python_path + " " + script + " " + args

	return shell(command)
