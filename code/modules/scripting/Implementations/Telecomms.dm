//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33


/* --- Traffic Control Scripting Language --- */
	// Nanotrasen TCS Language - Made by Doohl

/n_Interpreter/TCS_Interpreter
	var/datum/TCS_Compiler/Compiler

	HandleError(runtimeError/e)
		Compiler.Holder.add_entry(e.ToString(), "Execution Error")

	GC()
		..()
		Compiler = null


/datum/TCS_Compiler

	var/n_Interpreter/TCS_Interpreter/interpreter
	var/obj/machinery/telecomms/server/Holder	// the server that is running the code
	var/ready = 1 // 1 if ready to run code

	/* -- Set ourselves to Garbage Collect -- */

	proc/GC()

		Holder = null
		if(interpreter)
			interpreter.GC()


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
		interpreter.SetVar("false"  , 	0)				// boolean shortcut to 0
		interpreter.SetVar("TRUE"	,	1)				// boolean shortcut to 1
		interpreter.SetVar("true"	,	1)				// boolean shortcut to 1

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
		interpreter.SetVar("$supply",	1347)
		interpreter.SetVar("$service",	1349)

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
			-> Send a code signal.
					@format: signal(frequency, code)

					@param frequency:		Frequency to send the signal to
					@param code:			Encryption code to send the signal with
		*/
		interpreter.SetProc("signal", "signaler", signal, list("freq", "code"))

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
		interpreter.SetProc("replace", /proc/string_replacetext)

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
		interpreter.SetProc("rand", /proc/rand_chance)
		// End of Donkie~

		// Time
		interpreter.SetProc("time", /proc/time)
		interpreter.SetProc("timestamp", /proc/timestamp)

		// Run the compiled code
		interpreter.Run()

		// Backwards-apply variables onto signal data
		/* sanitize EVERYTHING. fucking players can't be trusted with SHIT */

		signal.data["message"] 	= interpreter.GetCleanVar("$content", signal.data["message"])
		signal.frequency 		= interpreter.GetCleanVar("$freq", signal.frequency)

		var/setname = interpreter.GetCleanVar("$source", signal.data["name"])

		if(signal.data["name"] != setname)
			signal.data["realname"] = setname
		signal.data["name"]		= setname
		signal.data["job"]		= interpreter.GetCleanVar("$job", signal.data["job"])
		signal.data["reject"]	= !(interpreter.GetCleanVar("$pass")) // set reject to the opposite of $pass

		// If the message is invalid, just don't broadcast it!
		if(signal.data["message"] == "" || !signal.data["message"])
			signal.data["reject"] = 1

/*  -- Actual language proc code --  */

var/const/SIGNAL_COOLDOWN = 20 // 2 seconds

datum/signal

	proc/mem(var/address, var/value)

		if(istext(address))
			var/obj/machinery/telecomms/server/S = data["server"]

			if(!value && value != 0)
				return S.memory[address]

			else
				S.memory[address] = value


	proc/signaler(var/freq = 1459, var/code = 30)

		if(isnum(freq) && isnum(code))

			var/obj/machinery/telecomms/server/S = data["server"]

			if(S.last_signal + SIGNAL_COOLDOWN > world.timeofday && S.last_signal < MIDNIGHT_ROLLOVER)
				return
			S.last_signal = world.timeofday

			var/datum/radio_frequency/connection = radio_controller.return_frequency(freq)

			if(findtext(num2text(freq), ".")) // if the frequency has been set as a decimal
				freq *= 10 // shift the decimal one place

			freq = sanitize_frequency(freq)

			code = round(code)
			code = Clamp(code, 0, 100)

			var/datum/signal/signal = new
			signal.source = S
			signal.encryption = code
			signal.data["message"] = "ACTIVATE"

			connection.post_signal(S, signal)

			var/time = time2text(world.realtime,"hh:mm:ss")
			lastsignalers.Add("[time] <B>:</B> [S.id] sent a signal command, which was triggered by NTSL.<B>:</B> [format_frequency(freq)]/[code]")


	proc/tcombroadcast(var/message, var/freq, var/source, var/job)

		var/datum/signal/newsign = new
		var/obj/machinery/telecomms/server/S = data["server"]
		var/obj/item/device/radio/hradio = S.server_radio

		if(!hradio)
			error("[src] has no radio.")
			return

		if((!message || message == "") && message != 0)
			message = "*beep*"
		if(!source)
			source = "[html_encode(uppertext(S.id))]"
			hradio = new // sets the hradio as a radio intercom
		if(!freq || (!isnum(freq) && text2num(freq) == null))
			freq = 1459
		if(findtext(num2text(freq), ".")) // if the frequency has been set as a decimal
			freq *= 10 // shift the decimal one place

		if(!job)
			job = "?"

		newsign.data["mob"] = null
		newsign.data["mobtype"] = /mob/living/carbon/human
		newsign.data["name"] = source
		newsign.data["realname"] = newsign.data["name"]
		newsign.data["job"] = "[job]"
		newsign.data["compression"] = 0
		newsign.data["message"] = message
		newsign.data["type"] = 2 // artificial broadcast
		if(!isnum(freq))
			freq = text2num(freq)
		newsign.frequency = freq

		var/datum/radio_frequency/connection = radio_controller.return_frequency(freq)
		newsign.data["connection"] = connection


		newsign.data["radio"] = hradio
		newsign.data["vmessage"] = message
		newsign.data["vname"] = source
		newsign.data["vmask"] = 0
		newsign.data["level"] = list()

		newsign.sanitize_data()

		var/pass = S.relay_information(newsign, "/obj/machinery/telecomms/hub")
		if(!pass)
			S.relay_information(newsign, "/obj/machinery/telecomms/broadcaster") // send this simple message to broadcasters

