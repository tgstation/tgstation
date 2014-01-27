#if defined(USE_BYGEX) && (USE_BYGEX == "demo")

mob
	var/expression = ""
	var/format = ""

	var/datum/regex/results

	verb
		set_expression()
			set category = "bygex"
			var/t = input(usr,"Input Expression","title",expression) as text|null
			if(t != null)
				expression = t
				usr << "Expression set to:\t[html_encode(t)]"

		set_format()
			set category = "bygex"
			var/t = input(usr,"Input Formatter","title",format) as text|null
			if(t != null)
				format = t
				usr << "Format set to:\t[html_encode(t)]"

		compare_casesensitive(t as text)
			set category = "bygex"
			results = regEx_compare(t, expression)
			results.report()

		compare(t as text)
			set category = "bygex"
			results = regex_compare(t, expression)
			results.report()

		find_casesensitive(t as text)
			set category = "bygex"
			results = regEx_find(t, expression)
			results.report()

		find(t as text)
			set category = "bygex"
			results = regex_find(t, expression)
			results.report()

		replaceall_casesensitive(t as text)
			set category = "bygex"
			usr << regEx_replaceall(t, expression, format)

		replaceall(t as text)
			set category = "bygex"
			usr << regex_replaceall(t, expression, format)

		replace_casesensitive(t as text)
			set category = "bygex"
			usr << html_encode(regEx_replace(t, expression, format))

		replace(t as text)
			set category = "bygex"
			usr << regex_replace(t, expression, format)

		findall(t as text)
			set category = "bygex"
			results = regex_findall(t, expression)
			results.report()

		findall_casesensitive(t as text)
			set category = "bygex"
			results = regEx_findall(t, expression)
			results.report()

#endif