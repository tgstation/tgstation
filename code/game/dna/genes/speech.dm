#define ACT_REPLACE      /datum/speech_filter_action/replace
#define ACT_PICK_REPLACE /datum/speech_filter_action/pick_replace

/datum/speech_filter
	// REGEX OH BOY
	// orig -> /datum/SFA
	var/list/expressions=list()

// Simple replacements. (ass -> butt) => s/ass/butt/
/datum/speech_filter/proc/addReplacement(var/orig,var/replacement, var/case_sensitive=0)
	orig        = replacetext(orig,       "/","\\/")
	replacement = replacetext(replacement,"/","\\/")
	return addExpression("/[orig]/[replacement]/[case_sensitive?"":"i"]g",ACT_REPLACE)

/datum/speech_filter/proc/addPickReplacement(var/orig,var/list/replacements, var/case_sensitive=0)
	orig        = replacetext(orig,"/","\\/")
	return addExpression("/[orig]/[case_sensitive?"":"i"]g",ACT_PICK_REPLACE,replacements)

/datum/speech_filter/proc/addWordReplacement(var/orig,var/replacement, var/case_sensitive=0)
	return addReplacement("\\b[orig]\\b",replacement, case_sensitive)

/datum/speech_filter/proc/addCallback(var/orig,var/callback,var/list/args)
	return addExpression(orig,callback,args)

/datum/speech_filter/proc/addExpression(var/orig,var/action,var/list/args)
	expressions[orig]=new action(orig,args)
	return orig

/datum/speech_filter/proc/rmExpression(var/key)
	expressions[key]=null

/datum/speech_filter/proc/FilterSpeech(var/msg)
	if(expressions.len)
		for(var/key in expressions)
			var/datum/speech_filter_action/SFA = expressions[key]
			if(SFA && !SFA.broken)
				msg = SFA.Run(msg)
	return msg

#undef ACT_REPLACE

/datum/speech_filter_action
	var/regex/expr
	var/str_expr
	var/broken = 0

/datum/speech_filter_action/New(var/orig,var/list/args)
	str_expr = orig
	expr = new(orig)
	if(expr.error)
		warning("Failed to compile expression [orig]: [expr.error]")
		broken = 1
		return

/datum/speech_filter_action/proc/Run(var/text)
	return "[type] has not overrode run()."

/////////////////////////////
// REPLACE ACTION
/////////////////////////////
/datum/speech_filter_action/replace

/datum/speech_filter_action/replace/Run(var/text)
	var/ret = expr.Replace(text)
	if(ret)
		return ret
	return text

/////////////////////////////
// PICK REPLACE ACTION
/////////////////////////////
/datum/speech_filter_action/pick_replace
	var/list/replacements

/datum/speech_filter_action/pick_replace/New(var/orig,var/list/args)
	..(orig,args)
	replacements = args

/datum/speech_filter_action/pick_replace/Run(var/text)
	if(expr.Find(text))
		var/o=""
		var/lastidx=1
		do
			o += copytext(text,lastidx,expr.match)
			//<b>[copytext(text,R.match,expr.index)]</b>
			o += pick(replacements)
			//copytext(text,expr.index)
			lastidx = expr.index // Move forwards
		while(expr.FindNext(text))
		o += copytext(text,expr.index)
		return o
	return text