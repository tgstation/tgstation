/**
 * # STE-100: 10 Core Rules for /tg/station
 *
 * This module codifies the 10 core rules from the tgstation style guide.
 * Each rule has a validation proc, a rule definition, and an enforcement mechanism.
 * These rules come from the STYLE.md coding standards document.
 *
 * Rules are numbered 1 through 10. Each rule has:
 * - A unique identifier (STE_RULE_1 through STE_RULE_10)
 * - A definition constant with rule text
 * - A validation proc
 * - An auto-fix proc where applicable
 */

/// Master list of all 10 core rules.
/// Each entry maps rule name to its definition constant.
GLOBAL_LIST_INIT(ste10_core_rules, list(
	"rule_1" = /datum/ste_rule/tabs_not_spaces,
	"rule_2" = /datum/ste_rule/control_statement_format,
	"rule_3" = /datum/ste_rule/operator_spacing,
	"rule_4" = /datum/ste_rule/static_not_global,
	"rule_5" = /datum/ste_rule/early_returns,
	"rule_6" = /datum/ste_rule/no_magic_numbers,
	"rule_7" = /datum/ste_rule/use_time_defines,
	"rule_8" = /datum/ste_rule/full_byond_paths,
	"rule_9" = /datum/ste_rule/type_path_slash_and_snake,
	"rule_10" = /datum/ste_rule/descriptive_variable_names,
))

// ─────────────────────────────────────────────────────────────────────────────
// Rule Definitions
// ─────────────────────────────────────────────────────────────────────────────

/// Rule 1: Tabs not spaces
/// You must use tabs to indent your code.. Do not use spaces for indentation.
#define STE_RULE_1 "Use tabs for indentation. Do not use spaces. This keeps the code format the same for all developers."

/// Rule 2: Control statement format
/// Control statements (if, while, for, and so on must not contain code on the same line.
/// All comparisons must use: thing operator number (not number operator thing).
#define STE_RULE_2 "Put control statement bodies on a new line. Write comparisons as: variable operator number."

/// Rule 3: Operator spacing
/// Boolean and logic operators (&&, ||, <, >, ==, and so on must have spaces around them.
/// Bitwise AND (&) must have spaces.. Assignment operators (=, +=, and so on must have spaces.
/// Bitwise OR (|), access operators (., :), parentheses, and logical NOT (!) must NOT have spaces.
#define STE_RULE_3 "Add spaces around boolean, logic, and assignment operators. Do not add spaces around access operators and parentheses."

/// Rule 4: Use static instead of global
/// Use the `static` keyword instead of `global` for type-level variables.
/// Both keywords have the same behavior, but `static` is less confusing.
#define STE_RULE_4 "Use the 'static' keyword instead of 'global'. This name describes the behavior more clearly."

/// Rule 5: Use early returns
/// Do not wrap a proc in an if-block when returning on a condition works better.
/// Early returns stop nesting from becoming too deep.
#define STE_RULE_5 "Use early returns instead of deep nesting. This makes code easier to read and maintain."

/// Rule 6: No magic numbers or strings
/// Use #define constants instead of literal numbers or strings.
/// A variable set to 1 or 2 tells the reader nothing.. A named define shows the purpose.
#define STE_RULE_6 "Replace magic numbers and strings with named define constants. This makes code self-documenting."

/// Rule 7: Use time defines
/// Use the time macro defines (SECONDS, MINUTES, HOURS) for time values.
/// Do not use literal decisecond amounts.. The macros make the intent clear.
#define STE_RULE_7 "Use SECONDS, MINUTES, and HOURS defines. Do not write time values as raw deciseconds."

/// Rule 8: Full BYOND paths
/// All type paths must be absolute.. Use the full path from the root.
/// Do not nest type keywords inside blocks.. This makes text search work for finding definitions.
#define STE_RULE_8 "Write full absolute type paths. Do not nest type definitions. This helps text search find definitions."

/// Rule 9: Type paths begin with / and use snake_case
/// Every type path must start with a forward slash.
/// Type paths must use snake_case (lowercase words separated by underscores).
/// Datum type paths must start with "datum".
#define STE_RULE_9 "Start type paths with a forward slash. Use snake_case for all type path names."

/// Rule 10: Descriptive variable names
/// Use clear and obvious variable names.. Do not use abbreviations.
/// Names like M, C, H tell the reader nothing.. Use victim, user, weapon instead.
/// Variables that hold time must include the time unit in the name.
#define STE_RULE_10 "Use clear variable names. Do not abbreviate. Add time units to variables that hold time values."

// ─────────────────────────────────────────────────────────────────────────────
// Base Rule Datum
// ─────────────────────────────────────────────────────────────────────────────

/// Base datum for all STE-100 rules.
/// Each rule subtype defines how to validate and enforce a specific rule.
/datum/ste_rule
	/// The rule number (1-10)
	var/rule_number = 0
	/// The rule definition text
	var/rule_text = ""
	/// The rule category: "style" or "standard"
	var/rule_category = "style"
	/// If TRUE, this rule can auto-fix violations
	var/can_autofix = FALSE

/datum/ste_rule/proc/get_rule_summary()
	return "STE Rule [rule_number]: [rule_text]"

/// Validate a single line of code against this rule.
/// Returns: list of violation messages, or empty list if compliant.
/datum/ste_rule/proc/validate_line(line_text, line_number, file_path)
	CRASH("validate_line() not implemented for [type]")

/// Auto-fix a violation if possible.
/// Returns: the fixed line text, or null if auto-fix is not possible.
/datum/ste_rule/proc/autofix_line(line_text)
	if (!can_autofix)
		return null
	CRASH("autofix_line() not implemented for [type]")

// ─────────────────────────────────────────────────────────────────────────────
// Rule 1: Tabs not spaces
// ─────────────────────────────────────────────────────────────────────────────

/datum/ste_rule/tabs_not_spaces
	rule_number = 1
	rule_text = STE_RULE_1
	rule_category = "style"
	can_autofix = TRUE

/datum/ste_rule/tabs_not_spaces/validate_line(line_text, line_number, file_path)
	. = list()
	// Only check lines that have leading whitespace
	var/trimmed = trim_text(line_text)
	if (!length(trimmed) || trimmed == line_text)
		return
	// Check if any leading space characters exist before the first tab or content
	var/first_non_space = length(line_text) - length(ltrim(line_text))
	for (var/i = 1 to first_non_space)
		var/char = copytext(line_text, i, i + 1)
		if (char == " ")
			. += "Line [line_number]: Uses spaces for indentation. Use tabs instead."
			break

/datum/ste_rule/tabs_not_spaces/autofix_line(line_text)
	var/leading = length(line_text) - length(ltrim(line_text))
	if (leading == 0)
		return line_text
	var/new_leading = ""
	for (var/i = 1 to leading / 4) // Assume 4 spaces = 1 tab
		new_leading += "\t"
	return new_leading + ltrim(line_text)

// ─────────────────────────────────────────────────────────────────────────────
// Rule 2: Control statement format
// ─────────────────────────────────────────────────────────────────────────────

/datum/ste_rule/control_statement_format
	rule_number = 2
	rule_text = STE_RULE_2
	rule_category = "style"
	can_autofix = FALSE

/datum/ste_rule/control_statement_format/validate_line(line_text, line_number, file_path)
	. = list()
	var/lower = lowertext(line_text)
	// Check for inline code after control statements
	var/static/list/control_keywords = list("if ", "while ", "for ", "else if ")
	for (var/keyword in control_keywords)
		var/pos = findtext(lower, keyword)
		if (!pos)
			continue
		// Check if there is code after the closing parenthesis on the same line
		var/paren_close = findtext(line_text, ")", pos)
		if (!paren_close)
			continue
		var/after_paren = trim_text(copytext(line_text, paren_close + 1))
		if (length(after_paren) && copytext(after_paren, 1, 2) != "{")
			. += "Line [line_number]: Control statement has inline code. Put the body on a new line."

// ─────────────────────────────────────────────────────────────────────────────
// Rule 3: Operator spacing
// ─────────────────────────────────────────────────────────────────────────────

/datum/ste_rule/operator_spacing
	rule_number = 3
	rule_text = STE_RULE_3
	rule_category = "style"
	can_autofix = FALSE

/datum/ste_rule/operator_spacing/validate_line(line_text, line_number, file_path)
	. = list()
	// Check for spaces around &&, ||, ==, !=, <, >, <=, >=
	var/static/list/spaced_ops = list("&&", "||", "==", "!=", "<=", ">=", "=", "+=", "-=", "*=", "/=")
	for (var/op in spaced_ops)
		var/pos = findtext(line_text, op)
		if (!pos)
			continue
		// Check left space
		if (pos > 1)
			var/left_char = copytext(line_text, pos - 1, pos)
			if (left_char != " " && left_char != "\t")
				. += "Line [line_number]: Operator '[op]' needs a space before it."
				break
		// Check right space
		var/right_pos = pos + length(op)
		if (right_pos <= length(line_text))
			var/right_char = copytext(line_text, right_pos, right_pos + 1)
			if (right_char != " " && right_char != "\t")
				. += "Line [line_number]: Operator '[op]' needs a space after it."
				break

// ─────────────────────────────────────────────────────────────────────────────
// Rule 4: Static not global
// ─────────────────────────────────────────────────────────────────────────────

/datum/ste_rule/static_not_global
	rule_number = 4
	rule_text = STE_RULE_4
	rule_category = "style"
	can_autofix = TRUE

/datum/ste_rule/static_not_global/validate_line(line_text, line_number, file_path)
	. = list()
	// Check for var/global pattern
	if (findtext(line_text, "var/global"))
		. += "Line [line_number]: Uses 'var/global'. Use 'var/static' instead."

/datum/ste_rule/static_not_global/autofix_line(line_text)
	return replacetext(line_text, "var/global", "var/static")

// ─────────────────────────────────────────────────────────────────────────────
// Rule 5: Early returns
// ─────────────────────────────────────────────────────────────────────────────

/datum/ste_rule/early_returns
	rule_number = 5
	rule_text = STE_RULE_5
	rule_category = "style"
	can_autofix = FALSE

/datum/ste_rule/early_returns/validate_line(line_text, line_number, file_path)
	// This rule needs multi-line analysis.
	// Flag deep nesting (3+ levels) as a potential violation.
	. = list()
	var/tab_count = 0
	for (var/i = 1; i <= length(line_text); i++)
		if (copytext(line_text, i, i + 1) == "\t")
			tab_count++
		else
			break
	if (tab_count >= 3 && findtext(line_text, "if") || findtext(line_text, "while"))
		. += "Line [line_number]: Deep nesting found (level [tab_count]). Think about using early returns."

// ─────────────────────────────────────────────────────────────────────────────
// Rule 6: No magic numbers or strings
// ─────────────────────────────────────────────────────────────────────────────

/datum/ste_rule/no_magic_numbers
	rule_number = 6
	rule_text = STE_RULE_6
	rule_category = "standard"
	can_autofix = FALSE

/datum/ste_rule/no_magic_numbers/validate_line(line_text, line_number, file_path)
	. = list()
	// Skip define statements themselves, comments, and string assignments
	if (findtext(line_text, "#define") || findtext(line_text, "//"))
		return
	// Check for bare numbers used in comparisons or assignments
	// This is a heuristic - proper detection needs full AST analysis
	var/regex/number_check = regex(@"=\s*\d+[^.]|==\s*\d+|!=\s*\d+|<\s*\d+|>\s*\d+")
	if (number_check.Find(line_text))
		. += "Line [line_number]: Possible magic number. Think about using a named define."

// ─────────────────────────────────────────────────────────────────────────────
// Rule 7: Use time defines
// ─────────────────────────────────────────────────────────────────────────────

/datum/ste_rule/use_time_defines
	rule_number = 7
	rule_text = STE_RULE_7
	rule_category = "standard"
	can_autofix = FALSE

/datum/ste_rule/use_time_defines/validate_line(line_text, line_number, file_path)
	. = list()
	// Check for common time-related proc calls with raw numeric arguments
	var/static/list/time_procs = list("do_after", "addtimer", "deltimer", "sleep")
	for (var/proc_name in time_procs)
		var/pos = findtext(line_text, proc_name)
		if (!pos)
			continue
		// Check if the argument after proc_name is a raw number
		var/regex/time_num = regex(@"(?:do_after|addtimer|sleep)\s*\(\s*[^,]*,\s*(\d+)\s*[,)]")
		if (time_num.Find(line_text))
			. += "Line [line_number]: Raw time value in [proc_name](). Use SECONDS, MINUTES, or HOURS macro."

// ─────────────────────────────────────────────────────────────────────────────
// Rule 8: Full BYOND paths
// ─────────────────────────────────────────────────────────────────────────────

/datum/ste_rule/full_byond_paths
	rule_number = 8
	rule_text = STE_RULE_8
	rule_category = "standard"
	can_autofix = FALSE

/datum/ste_rule/full_byond_paths/validate_line(line_text, line_number, file_path)
	. = list()
	// Check for relative type paths (type definitions that don't start with /)
	var/trimmed = trim_text(line_text)
	// Only check type definition lines
	if (findtext(trimmed, "/datum") || findtext(trimmed, "/atom") || findtext(trimmed, "/obj") || findtext(trimmed, "/mob") || findtext(trimmed, "/turf") || findtext(trimmed, "/area"))
		return // These start with /, which is correct

	// Check for nested type definitions (e.g., "datum\n\tdatum1" pattern)
	// This is harder to detect in single-line analysis; flag lines that look like bare type names
	var/regex/bare_type = regex(@"^\s*(datum|atom|obj|mob|turf|area|proc|var)\s*$")
	if (bare_type.Find(trimmed))
		. += "Line [line_number]: Bare type keyword found. Write the full absolute path instead."

// ─────────────────────────────────────────────────────────────────────────────
// Rule 9: Type paths begin with / and use snake_case
// ─────────────────────────────────────────────────────────────────────────────

/datum/ste_rule/type_path_slash_and_snake
	rule_number = 9
	rule_text = STE_RULE_9
	rule_category = "style"
	can_autofix = FALSE

/datum/ste_rule/type_path_slash_and_snake/validate_line(line_text, line_number, file_path)
	. = list()
	// Check for type paths that don't use snake_case
	var/regex/type_path = regex(@"/\w+(?:/\w+)*")
	var/start = 1
	while (type_path.Find(line_text, start))
		var/match = type_path.match
		// Skip defines and comments
		if (findtext(line_text, "#define", 1, type_path.index))
			start = type_path.index + 1
			continue
		// Check for CamelCase or UPPERCASE in the path segments
		var/regex/not_snake = regex(@"[A-Z]{2,}|[a-z][A-Z]")
		if (not_snake.Find(match))
			. += "Line [line_number]: Type path '[match]' may not use snake_case."
		start = type_path.index + 1

// ─────────────────────────────────────────────────────────────────────────────
// Rule 10: Descriptive variable names
// ─────────────────────────────────────────────────────────────────────────────

/datum/ste_rule/descriptive_variable_names
	rule_number = 10
	rule_text = STE_RULE_10
	rule_category = "style"
	can_autofix = FALSE

/datum/ste_rule/descriptive_variable_names/validate_line(line_text, line_number, file_path)
	. = list()
	// Check for single-letter variable declarations
	var/static/list/single_letter_bad = list("var/M", "var/C", "var/H", "var/A", "var/T", "var/L", "var/O", "var/P", "var/N", "var/X", "var/Y", "var/Z")
	for (var/bad_var in single_letter_bad)
		if (findtext(line_text, bad_var))
			. += "Line [line_number]: Single-letter variable '[bad_var]' found. Use a descriptive name."
			break

// ─────────────────────────────────────────────────────────────────────────────
// Rule Enforcement Engine
// ─────────────────────────────────────────────────────────────────────────────

/// Runs all 10 core rules against a single file.
/// Returns an associative list: rule_number -> list of violation messages.
/proc/validate_file_ste10(file_path)
	. = list()
	if (!fexists(file_path))
		CRASH("File not found: [file_path]")

	var/file_text = rustg_file_read(file_path)
	if (!file_text)
		return

	var/list/lines = splittext(file_text, "\n")
	for (var/line_number in 1 to length(lines))
		var/line_text = lines[line_number]
		if (!length(trim_text(line_text)))
			continue
		if (findtext(line_text, "// STE-IGNORE"))
			continue

		for (var/rule_name in GLOB.ste10_core_rules)
			var/datum/ste_rule/rule = GLOB.ste10_core_rules[rule_name]
			LAZYADD(.["[rule.rule_number]"], rule.validate_line(line_text, line_number, file_path))

/// Runs all 10 core rules against a directory recursively.
/// Returns total violation count and a detailed report.
/proc/validate_directory_ste10(dir_path)
	. = list()
	var/total_violations = 0
	var/list/all_files = flist(dir_path)

	for (var/file_path in all_files)
		var/full_path = "[dir_path]/[file_path]"
		if (findtext(file_path, ".dm"))
			var/list/violations = validate_file_ste10(full_path)
			if (length(violations))
				.[full_path] = violations
				for (var/key in violations)
					total_violations += length(violations[key])

	.["__total__"] = total_violations

/// Generates a human-readable report from validation results.
/proc/generate_ste10_report(list/validation_results)
	var/report = "STE-100 10 Core Rules Validation Report\n"
	report += "========================================\n\n"

	var/total = validation_results["__total__"]
	report += "Total violations: [total]\n\n"
	validation_results -= "__total__"

	if (!length(validation_results))
		report += "No violations found. All files comply with the 10 core rules.\n"
		return report

	report += "## Violations by Rule\n\n"
	var/list/by_rule = list()

	for (var/file_path in validation_results)
		var/list/file_violations = validation_results[file_path]
		for (var/rule_num in file_violations)
			if (!by_rule[rule_num])
				by_rule[rule_num] = 0
			by_rule[rule_num] += length(file_violations[rule_num])

	for (var/i in 1 to 10)
		var/count = by_rule["[i]"] || 0
		report += "- Rule [i]: [count] violations\n"

	report += "\n## Violations by File\n\n"
	for (var/file_path in validation_results)
		var/list/file_violations = validation_results[file_path]
		var/file_count = 0
		for (var/key in file_violations)
			file_count += length(file_violations[key])
		report += "- [file_path]: [file_count] violations\n"

	return report

/// Auto-fixes all fixable violations in a file.
/proc/autofix_file_ste10(file_path)
	if (!fexists(file_path))
		CRASH("File not found: [file_path]")

	var/file_text = rustg_file_read(file_path)
	if (!file_text)
		return 0

	var/list/lines = splittext(file_text, "\n")
	var/fixed_count = 0
	var/list/new_lines = list()

	for (var/line_number in 1 to length(lines))
		var/line_text = lines[line_number]
		var/fixed = FALSE

		for (var/rule_name in GLOB.ste10_core_rules)
			var/datum/ste_rule/rule = GLOB.ste10_core_rules[rule_name]
			if (!rule.can_autofix)
				continue
			var/new_line = rule.autofix_line(line_text)
			if (new_line && new_line != line_text)
				line_text = new_line
				fixed = TRUE

		if (fixed)
			fixed_count++
		new_lines += line_text

	if (fixed_count > 0)
		var/new_text = jointext(new_lines, "\n")
		rustg_file_write(new_text, file_path)

	return fixed_count

/// Prints a summary of all 10 core rules to chat.
/proc/display_ste10_rules(mob/user)
	to_chat(user, span_boldnotice("═══ STE-100: 10 Core Rules for /tg/station ═══"))
	to_chat(user, "")
	to_chat(user, span_notice("Rule 1: [STE_RULE_1]"))
	to_chat(user, span_notice("Rule 2: [STE_RULE_2]"))
	to_chat(user, span_notice("Rule 3: [STE_RULE_3]"))
	to_chat(user, span_notice("Rule 4: [STE_RULE_4]"))
	to_chat(user, span_notice("Rule 5: [STE_RULE_5]"))
	to_chat(user, span_notice("Rule 6: [STE_RULE_6]"))
	to_chat(user, span_notice("Rule 7: [STE_RULE_7]"))
	to_chat(user, span_notice("Rule 8: [STE_RULE_8]"))
	to_chat(user, span_notice("Rule 9: [STE_RULE_9]"))
	to_chat(user, span_notice("Rule 10: [STE_RULE_10]"))
	to_chat(user, "")
	to_chat(user, span_info("Use Validate-STE10 verb to check a file or directory."))
	to_chat(user, span_info("Use AutoFix-STE10 verb to fix violations automatically."))

/// Admin verb to validate a file or directory against the 10 core rules.
/client/verb/validate_ste10()
	set name = "Validate STE-10 Rules"
	set category = "Debug"
	set desc = "Check a file or directory against the 10 core rules."

	var/target = tgui_input_text(usr, "Enter file or directory path to validate:", "STE-10 Validation", "code/")
	if (!target)
		return

	var/list/results
	if (findtext(target, ".dm"))
		results = validate_file_ste10(target)
		var/report = generate_ste10_report(list(target) + list("__total__" = 0))
		to_chat(usr, span_info(report))
	else
		results = validate_directory_ste10(target)
		var/report = generate_ste10_report(results)
		to_chat(usr, examine_block(report))

/// Admin verb to auto-fix violations in a file.
/client/verb/autofix_ste10()
	set name = "AutoFix STE-10 Rules"
	set category = "Debug"
	set desc = "Auto-fix violations of the 10 core rules in a file."

	var/target = tgui_input_text(usr, "Enter file path to auto-fix:", "STE-10 AutoFix", "")
	if (!target)
		return

	var/fixed = autofix_file_ste10(target)
	to_chat(usr, span_notice("Auto-fixed [fixed] lines in [target]."))
