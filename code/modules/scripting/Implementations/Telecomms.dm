//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33


/* --- Traffic Control Scripting Language --- */
	// Nanotrasen TCS Language - Made by Doohl

/n_Interpreter/TCS_Interpreter
	var/datum/TCS_Compiler/Compiler

	HandleError(runtimeError/e)
		Compiler.Holder.add_entry(e.ToString(), "Execution Error")

/datum/TCS_Compiler
	var/n_Interpreter/TCS_Interpreter/interpreter
	var/obj/machinery/telecomms/server/Holder	// the server that is running the code
	var/ready = 1 // 1 if ready to run code

	/* -- Compile a raw block of text -- */

	proc/Compile(code as message)
		var/n_scriptOptions/nS_Options/options = new()
		var/n_Scanner/nS_Scanner/scanner       = new(code, options)
		var/list/tokens                        = scanner.Scan()
		var/n_Parser/nS_Parser/parser          = new(tokens, options)
		var/node/BlockDefinition/GlobalBlock/program   	 = parser.Parse()

		var/list/returnerrors = list()

		returnerrors += scanner.errors
		returnerrors += parser.errors

		if(returnerrors.len)
			return returnerrors

		interpreter 		= new(program)
		interpreter.persist	= 1
		interpreter.Compiler= src

		return returnerrors

	/* -- Execute the compiled code -- */

	proc/Run(var/datum/signal/signal)

		if(!ready)
			return

		if(!interpreter)
			return

		interpreter.container = src

		interpreter.SetVar("PI"		, 	3.141592653)	// value of pi
		interpreter.SetVar("E" 		, 	2.718281828)	// value of e
		interpreter.SetVar("SQURT2" , 	1.414213562)	// value of the square root of 2
		interpreter.SetVar("FALSE"  , 	0)				// boolean shortcut to 0
		interpreter.SetVar("TRUE"	,	1)				// boolean shortcut to 1

		interpreter.SetVar("NORTH" 	, 	NORTH)			// NORTH (1)
		interpreter.SetVar("SOUTH" 	, 	SOUTH)			// SOUTH (2)
		interpreter.SetVar("EAST" 	, 	EAST)			// EAST  (4)
		interpreter.SetVar("WEST" 	, 	WEST)			// WEST  (8)

		// Channel macros
		interpreter.SetVar("$common",	1459)
		interpreter.SetVar("$science",	1351)
		interpreter.SetVar("$command",	1353)
		interpreter.SetVar("$medical",	1355)
		interpreter.SetVar("$engineering",1357)
		interpreter.SetVar("$security",	1359)
		interpreter.SetVar("$mining",	1349)
		interpreter.SetVar("$cargo",	1347)

		// Signal data

		interpreter.SetVar("$content", 	signal.data["message"])
		interpreter.SetVar("$freq"   , 	signal.frequency)
		interpreter.SetVar("$source" , 	signal.data["name"])
		interpreter.SetVar("$job"    , 	signal.data["job"])
		interpreter.SetVar("$sign"   ,	signal)
		interpreter.SetVar("$pass"	 ,  !(signal.data["reject"])) // if the signal isn't rejected, pass = 1; if the signal IS rejected, pass = 0

		// Set up the script procs

		/*
			-> Send another signal to a server
					@format: broadcast(content, frequency, source, job)

					@param content:		Message to broadcast
					@param frequency:	Frequency to broadcast to
					@param source:		The name of the source you wish to imitate. Must be stored in stored_names list.
					@param job:			The name of the job.
		*/
		interpreter.SetProc("broadcast", "tcombroadcast", signal, list("message", "freq", "source", "job"))

		/*
			-> Store a value permanently to the server machine (not the actual game hosting machine, the ingame machine)
					@format: mem(address, value)

					@param address:		The memory address (string index) to store a value to
					@param value:		The value to store to the memory address
		*/
		interpreter.SetProc("mem", "mem", signal, list("address", "value"))

		/*
			-> Delay code for a given amount of deciseconds
					@format: sleep(time)

					@param time: 		time to sleep in deciseconds (1/10th second)
		*/
		interpreter.SetProc("sleep", /proc/delay)

		/*
			-> Replaces a string with another string
					@format: replace(string, substring, replacestring)

					@param string: 			the string to search for substrings (best used with $content$ constant)
					@param substring: 		the substring to search for
					@param replacestring: 	the string to replace the substring with

		*/
		interpreter.SetProc("replace", /proc/dd_replacetext)

		/*
			-> Locates an element/substring inside of a list or string
					@format: find(haystack, needle, start = 1, end = 0)

					@param haystack:	the container to search
					@param needle:		the element to search for
					@param start:		the position to start in
					@param end:			the position to end in

		*/
		interpreter.SetProc("find", /proc/smartfind)

		/*
			-> Finds the length of a string or list
					@format: length(container)

					@param container: the list or container to measure

		*/
		interpreter.SetProc("length", /proc/smartlength)

		/* -- Clone functions, carried from default BYOND procs --- */

		// vector namespace
		interpreter.SetProc("vector", /proc/n_list)
		interpreter.SetProc("at", /proc/n_listpos)
		interpreter.SetProc("copy", /proc/n_listcopy)
		interpreter.SetProc("push_back", /proc/n_listadd)
		interpreter.SetProc("remove", /proc/n_listremove)
		interpreter.SetProc("cut", /proc/n_listcut)
		interpreter.SetProc("swap", /proc/n_listswap)
		interpreter.SetProc("insert", /proc/n_listinsert)

		interpreter.SetProc("pick", /proc/n_pick)
		interpreter.SetProc("prob", /proc/prob_chance)
		interpreter.SetProc("substr", /proc/docopytext)

		// Donkie~
		// Strings
		interpreter.SetProc("lower", /proc/n_lower)
		interpreter.SetProc("upper", /proc/n_upper)
		interpreter.SetProc("explode", /proc/string_explode)
		interpreter.SetProc("repeat", /proc/n_repeat)
		interpreter.SetProc("reverse", /proc/n_reverse)
		interpreter.SetProc("tonum", /proc/n_str2num)

		// Numbers
		interpreter.SetProc("tostring", /proc/n_num2str)
		interpreter.SetProc("sqrt", /proc/n_sqrt)
		interpreter.SetProc("abs", /proc/n_abs)
		interpreter.SetProc("floor", /proc/n_floor)
		interpreter.SetProc("ceil", /proc/n_ceil)
		interpreter.SetProc("round", /proc/n_round)
		interpreter.SetProc("clamp", /proc/n_clamp)
		interpreter.SetProc("inrange", /proc/n_inrange)
		// End of Donkie~


		// Run the compiled code
		interpreter.Run()

		// Backwards-apply variables onto signal data
		/* sanitize EVERYTHING. fucking players can't be trusted with SHIT */

		signal.data["message"] 	= interpreter.GetVar("$content")
		signal.frequency 		= interpreter.GetVar("$freq")

		var/setname = ""
		var/obj/machinery/telecomms/server/S = signal.data["server"]
		if(interpreter.GetVar("$source") in S.stored_names)
			setname = interpreter.GetVar("$source")
		else
			setname = "<i>[interpreter.GetVar("$source")]</i>"

		if(signal.data["name"] != setname)
			signal.data["realname"] = setname
		signal.data["name"]		= setname
		signal.data["job"]		= interpreter.GetVar("$job")
		signal.data["reject"]	= !(interpreter.GetVar("$pass")) // set reject to the opposite of $pass

		// If the message is invalid, just don't broadcast it!
		if(signal.data["message"] == "" || !signal.data["message"])
			signal.data["reject"] = 1

/*  -- Actual language proc code --  */

datum/signal

	proc/mem(var/address, var/value)

		if(istext(address))
			var/obj/machinery/telecomms/server/S = data["server"]

			if(!value && value != 0)
				return S.memory[address]

			else
				S.memory[address] = value


	proc/tcombroadcast(var/message, var/freq, var/source, var/job)

		var/mob/living/carbon/human/H = new
		var/datum/signal/newsign = new
		var/obj/machinery/telecomms/server/S = data["server"]
		var/obj/item/device/radio/hradio

		if((!message || message == "") && message != 0)
			message = "*beep*"
		if(!source)
			source = "[html_encode(uppertext(S.id))]"
			hradio = new // sets the hradio as a radio intercom
		if(!freq)
			freq = 1459
		if(findtext(num2text(freq), ".")) // if the frequency has been set as a decimal
			freq *= 10 // shift the decimal one place

		if(!job)
			job = "?"

		newsign.data["mob"] = H
		newsign.data["mobtype"] = H.type
		if(source in S.stored_names)
			newsign.data["name"] = source
		else
			newsign.data["name"] = "<i>[html_encode(uppertext(source))]<i>"
		newsign.data["realname"] = newsign.data["name"]
		newsign.data["job"] = job
		newsign.data["compression"] = 0
		newsign.data["message"] = message
		newsign.data["type"] = 2 // artificial broadcast
		if(!isnum(freq))
			freq = text2num(freq)
		newsign.frequency = freq

		var/datum/radio_frequency/connection = radio_controller.return_frequency(freq)
		newsign.data["connection"] = connection

		// The radio is a radio headset!

		if(!hradio)
			hradio = new /obj/item/device/radio/headset

		newsign.data["radio"] = hradio
		newsign.data["vmessage"] = H.voice_message
		newsign.data["vname"] = H.voice_name
		newsign.data["vmask"] = 0

		S.relay_information(newsign, "/obj/machinery/telecomms/broadcaster") // send this simple message to broadcasters
		S.relay_information(newsign, "/obj/machinery/telecomms/hub")
