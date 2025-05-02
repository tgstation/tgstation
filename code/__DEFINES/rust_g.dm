// rust_g.dm - DM API for rust_g extension library
//
// To configure, create a `rust_g.config.dm` and set what you care about from
// the following options:
//
// #define RUST_G "path/to/rust_g"
// Override the .dll/.so detection logic with a fixed path or with detection
// logic of your own.
//
// #define RUSTG_OVERRIDE_BUILTINS
// Enable replacement rust-g functions for certain builtins. Off by default.

#ifndef RUST_G
// Default automatic RUST_G detection.
// On Windows, looks in the standard places for `rust_g.dll`.
// On Linux, looks in `.`, `$LD_LIBRARY_PATH`, and `~/.byond/bin` for either of
// `librust_g.so` (preferred) or `rust_g` (old).

/* This comment bypasses grep checks */ /var/__rust_g

/proc/__detect_rust_g()
	var/arch_suffix = null
	#ifdef OPENDREAM
	arch_suffix = "64"
	#endif
	if (world.system_type == UNIX)
		if (fexists("./librust_g[arch_suffix].so"))
			// No need for LD_LIBRARY_PATH badness.
			return __rust_g = "./librust_g[arch_suffix].so"
		else if (fexists("./rust_g[arch_suffix]"))
			// Old dumb filename.
			return __rust_g = "./rust_g[arch_suffix]"
		else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/rust_g[arch_suffix]"))
			// Old dumb filename in `~/.byond/bin`.
			return __rust_g = "rust_g[arch_suffix]"
		else
			// It's not in the current directory, so try others
			return __rust_g = "librust_g[arch_suffix].so"
	else
		return __rust_g = "rust_g[arch_suffix]"

#define RUST_G (__rust_g || __detect_rust_g())
#endif

// Handle 515 call() -> call_ext() changes
#if DM_VERSION >= 515
#define RUSTG_CALL call_ext
#else
#define RUSTG_CALL call
#endif

/// Gets the version of rust_g
/proc/rustg_get_version() return RUSTG_CALL(RUST_G, "get_version")()


/**
 * Sets up the Aho-Corasick automaton with its default options.
 *
 * The search patterns list and the replacements must be of the same length when replace is run, but an empty replacements list is allowed if replacements are supplied with the replace call
 * Arguments:
 * * key - The key for the automaton, to be used with subsequent rustg_acreplace/rustg_acreplace_with_replacements calls
 * * patterns - A non-associative list of strings to search for
 * * replacements - Default replacements for this automaton, used with rustg_acreplace
 */
#define rustg_setup_acreplace(key, patterns, replacements) RUSTG_CALL(RUST_G, "setup_acreplace")(key, json_encode(patterns), json_encode(replacements))

/**
 * Sets up the Aho-Corasick automaton using supplied options.
 *
 * The search patterns list and the replacements must be of the same length when replace is run, but an empty replacements list is allowed if replacements are supplied with the replace call
 * Arguments:
 * * key - The key for the automaton, to be used with subsequent rustg_acreplace/rustg_acreplace_with_replacements calls
 * * options - An associative list like list("anchored" = 0, "ascii_case_insensitive" = 0, "match_kind" = "Standard"). The values shown on the example are the defaults, and default values may be omitted. See the identically named methods at https://docs.rs/aho-corasick/latest/aho_corasick/struct.AhoCorasickBuilder.html to see what the options do.
 * * patterns - A non-associative list of strings to search for
 * * replacements - Default replacements for this automaton, used with rustg_acreplace
 */
#define rustg_setup_acreplace_with_options(key, options, patterns, replacements) RUSTG_CALL(RUST_G, "setup_acreplace")(key, json_encode(options), json_encode(patterns), json_encode(replacements))

/**
 * Run the specified replacement engine with the provided haystack text to replace, returning replaced text.
 *
 * Arguments:
 * * key - The key for the automaton
 * * text - Text to run replacements on
 */
#define rustg_acreplace(key, text) RUSTG_CALL(RUST_G, "acreplace")(key, text)

/**
 * Run the specified replacement engine with the provided haystack text to replace, returning replaced text.
 *
 * Arguments:
 * * key - The key for the automaton
 * * text - Text to run replacements on
 * * replacements - Replacements for this call. Must be the same length as the set-up patterns
 */
#define rustg_acreplace_with_replacements(key, text, replacements) RUSTG_CALL(RUST_G, "acreplace_with_replacements")(key, text, json_encode(replacements))

/**
 * This proc generates a cellular automata noise grid which can be used in procedural generation methods.
 *
 * Returns a single string that goes row by row, with values of 1 representing an alive cell, and a value of 0 representing a dead cell.
 *
 * Arguments:
 * * percentage: The chance of a turf starting closed
 * * smoothing_iterations: The amount of iterations the cellular automata simulates before returning the results
 * * birth_limit: If the number of neighboring cells is higher than this amount, a cell is born
 * * death_limit: If the number of neighboring cells is lower than this amount, a cell dies
 * * width: The width of the grid.
 * * height: The height of the grid.
 */
#define rustg_cnoise_generate(percentage, smoothing_iterations, birth_limit, death_limit, width, height) \
	RUSTG_CALL(RUST_G, "cnoise_generate")(percentage, smoothing_iterations, birth_limit, death_limit, width, height)

/**
 * This proc generates a grid of perlin-like noise
 *
 * Returns a single string that goes row by row, with values of 1 representing an turned on cell, and a value of 0 representing a turned off cell.
 *
 * Arguments:
 * * seed: seed for the function
 * * accuracy: how close this is to the original perlin noise, as accuracy approaches infinity, the noise becomes more and more perlin-like
 * * stamp_size: Size of a singular stamp used by the algorithm, think of this as the same stuff as frequency in perlin noise
 * * world_size: size of the returned grid.
 * * lower_range: lower bound of values selected for. (inclusive)
 * * upper_range: upper bound of values selected for. (exclusive)
 */
#define rustg_dbp_generate(seed, accuracy, stamp_size, world_size, lower_range, upper_range) \
	RUSTG_CALL(RUST_G, "dbp_generate")(seed, accuracy, stamp_size, world_size, lower_range, upper_range)


#define rustg_dmi_strip_metadata(fname) RUSTG_CALL(RUST_G, "dmi_strip_metadata")(fname)
#define rustg_dmi_create_png(path, width, height, data) RUSTG_CALL(RUST_G, "dmi_create_png")(path, width, height, data)
#define rustg_dmi_resize_png(path, width, height, resizetype) RUSTG_CALL(RUST_G, "dmi_resize_png")(path, width, height, resizetype)
/**
 * input: must be a path, not an /icon; you have to do your own handling if it is one, as icon objects can't be directly passed to rustg.
 *
 * output: json_encode'd list. json_decode to get a flat list with icon states in the order they're in inside the .dmi
 */
#define rustg_dmi_icon_states(fname) RUSTG_CALL(RUST_G, "dmi_icon_states")(fname)

#define rustg_file_read(fname) RUSTG_CALL(RUST_G, "file_read")(fname)
#define rustg_file_exists(fname) (RUSTG_CALL(RUST_G, "file_exists")(fname) == "true")
#define rustg_file_write(text, fname) RUSTG_CALL(RUST_G, "file_write")(text, fname)
#define rustg_file_append(text, fname) RUSTG_CALL(RUST_G, "file_append")(text, fname)
#define rustg_file_get_line_count(fname) text2num(RUSTG_CALL(RUST_G, "file_get_line_count")(fname))
#define rustg_file_seek_line(fname, line) RUSTG_CALL(RUST_G, "file_seek_line")(fname, "[line]")

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define file2text(fname) rustg_file_read("[fname]")
	#define text2file(text, fname) rustg_file_append(text, "[fname]")
#endif

/// Returns the git hash of the given revision, ex. "HEAD".
#define rustg_git_revparse(rev) RUSTG_CALL(RUST_G, "rg_git_revparse")(rev)

/**
 * Returns the date of the given revision using the provided format.
 * Defaults to returning %F which is YYYY-MM-DD.
 */
/proc/rustg_git_commit_date(rev, format = "%F")
	return RUSTG_CALL(RUST_G, "rg_git_commit_date")(rev, format)

/**
 * Returns the formatted datetime string of HEAD using the provided format.
 * Defaults to returning %F which is YYYY-MM-DD.
 * This is different to rustg_git_commit_date because it only needs the logs directory.
 */
/proc/rustg_git_commit_date_head(format = "%F")
	return RUSTG_CALL(RUST_G, "rg_git_commit_date_head")(format)

#define rustg_hash_string(algorithm, text) RUSTG_CALL(RUST_G, "hash_string")(algorithm, text)
#define rustg_hash_file(algorithm, fname) RUSTG_CALL(RUST_G, "hash_file")(algorithm, fname)
#define rustg_hash_generate_totp(seed) RUSTG_CALL(RUST_G, "generate_totp")(seed)
#define rustg_hash_generate_totp_tolerance(seed, tolerance) RUSTG_CALL(RUST_G, "generate_totp_tolerance")(seed, tolerance)

#define RUSTG_HASH_MD5 "md5"
#define RUSTG_HASH_SHA1 "sha1"
#define RUSTG_HASH_SHA256 "sha256"
#define RUSTG_HASH_SHA512 "sha512"
#define RUSTG_HASH_XXH64 "xxh64"
#define RUSTG_HASH_BASE64 "base64"

/// Encode a given string into base64
#define rustg_encode_base64(str) rustg_hash_string(RUSTG_HASH_BASE64, str)
/// Decode a given base64 string
#define rustg_decode_base64(str) RUSTG_CALL(RUST_G, "decode_base64")(str)

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define md5(thing) (isfile(thing) ? rustg_hash_file(RUSTG_HASH_MD5, "[thing]") : rustg_hash_string(RUSTG_HASH_MD5, thing))
#endif

#define RUSTG_HTTP_METHOD_GET "get"
#define RUSTG_HTTP_METHOD_PUT "put"
#define RUSTG_HTTP_METHOD_DELETE "delete"
#define RUSTG_HTTP_METHOD_PATCH "patch"
#define RUSTG_HTTP_METHOD_HEAD "head"
#define RUSTG_HTTP_METHOD_POST "post"
#define rustg_http_request_blocking(method, url, body, headers, options) RUSTG_CALL(RUST_G, "http_request_blocking")(method, url, body, headers, options)
#define rustg_http_request_async(method, url, body, headers, options) RUSTG_CALL(RUST_G, "http_request_async")(method, url, body, headers, options)
#define rustg_http_check_request(req_id) RUSTG_CALL(RUST_G, "http_check_request")(req_id)

/// Generates a spritesheet at: [file_path][spritesheet_name]_[size_id].png
/// The resulting spritesheet arranges icons in a random order, with the position being denoted in the "sprites" return value.
/// All icons have the same y coordinate, and their x coordinate is equal to `icon_width * position`.
///
/// hash_icons is a boolean (0 or 1), and determines if the generator will spend time creating hashes for the output field dmi_hashes.
/// These hashes can be heplful for 'smart' caching (see rustg_iconforge_cache_valid), but require extra computation.
///
/// Spritesheet will contain all sprites listed within "sprites".
/// "sprites" format:
/// list(
///     "sprite_name" = list( // <--- this list is a [SPRITE_OBJECT]
///         icon_file = 'icons/path_to/an_icon.dmi',
///         icon_state = "some_icon_state",
///         dir = SOUTH,
///         frame = 1,
///         transform = list([TRANSFORM_OBJECT], ...)
///     ),
///     ...,
/// )
/// TRANSFORM_OBJECT format:
/// list("type" = RUSTG_ICONFORGE_BLEND_COLOR, "color" = "#ff0000", "blend_mode" = ICON_MULTIPLY)
/// list("type" = RUSTG_ICONFORGE_BLEND_ICON, "icon" = [SPRITE_OBJECT], "blend_mode" = ICON_OVERLAY)
/// list("type" = RUSTG_ICONFORGE_SCALE, "width" = 32, "height" = 32)
/// list("type" = RUSTG_ICONFORGE_CROP, "x1" = 1, "y1" = 1, "x2" = 32, "y2" = 32) // (BYOND icons index from 1,1 to the upper bound, inclusive)
///
/// Returns a SpritesheetResult as JSON, containing fields:
/// list(
///     "sizes" = list("32x32", "64x64", ...),
///     "sprites" = list("sprite_name" = list("size_id" = "32x32", "position" = 0), ...),
///     "dmi_hashes" = list("icons/path_to/an_icon.dmi" = "d6325c5b4304fb03", ...),
///     "sprites_hash" = "a2015e5ff403fb5c", // This is the xxh64 hash of the INPUT field "sprites".
///     "error" = "[A string, empty if there were no errors.]"
/// )
/// In the case of an unrecoverable panic from within Rust, this function ONLY returns a string containing the error.
#define rustg_iconforge_generate(file_path, spritesheet_name, sprites, hash_icons) RUSTG_CALL(RUST_G, "iconforge_generate")(file_path, spritesheet_name, sprites, "[hash_icons]")
/// Returns a job_id for use with rustg_iconforge_check()
#define rustg_iconforge_generate_async(file_path, spritesheet_name, sprites, hash_icons) RUSTG_CALL(RUST_G, "iconforge_generate_async")(file_path, spritesheet_name, sprites, "[hash_icons]")
/// Returns the status of an async job_id, or its result if it is completed. See RUSTG_JOB DEFINEs.
#define rustg_iconforge_check(job_id) RUSTG_CALL(RUST_G, "iconforge_check")("[job_id]")
/// Clears all cached DMIs and images, freeing up memory.
/// This should be used after spritesheets are done being generated.
#define rustg_iconforge_cleanup RUSTG_CALL(RUST_G, "iconforge_cleanup")
/// Takes in a set of hashes, generate inputs, and DMI filepaths, and compares them to determine cache validity.
/// input_hash: xxh64 hash of "sprites" from the cache.
/// dmi_hashes: xxh64 hashes of the DMIs in a spritesheet, given by `rustg_iconforge_generate` with `hash_icons` enabled. From the cache.
/// sprites: The new input that will be passed to rustg_iconforge_generate().
/// Returns a CacheResult with the following structure: list(
///     "result": "1" (if cache is valid) or "0" (if cache is invalid)
///     "fail_reason": "" (emtpy string if valid, otherwise a string containing the invalidation reason or an error with ERROR: prefixed.)
/// )
/// In the case of an unrecoverable panic from within Rust, this function ONLY returns a string containing the error.
#define rustg_iconforge_cache_valid(input_hash, dmi_hashes, sprites) RUSTG_CALL(RUST_G, "iconforge_cache_valid")(input_hash, dmi_hashes, sprites)
/// Returns a job_id for use with rustg_iconforge_check()
#define rustg_iconforge_cache_valid_async(input_hash, dmi_hashes, sprites) RUSTG_CALL(RUST_G, "iconforge_cache_valid_async")(input_hash, dmi_hashes, sprites)
/// Provided a /datum/greyscale_config typepath, JSON string containing the greyscale config, and path to a DMI file containing the base icons,
/// Loads that config into memory for later use by rustg_iconforge_gags(). The config_path is the unique identifier used later.
/// JSON Config schema: https://hackmd.io/@tgstation/GAGS-Layer-Types
/// Unsupported features: color_matrix layer type, 'or' blend_mode. May not have BYOND parity with animated icons or varying dirs between layers.
/// Returns "OK" if successful, otherwise, returns a string containing the error.
#define rustg_iconforge_load_gags_config(config_path, config_json, config_icon_path) RUSTG_CALL(RUST_G, "iconforge_load_gags_config")("[config_path]", config_json, config_icon_path)
/// Given a config_path (previously loaded by rustg_iconforge_load_gags_config), and a string of hex colors formatted as "#ff00ff#ffaa00"
/// Outputs a DMI containing all of the states within the config JSON to output_dmi_path, creating any directories leading up to it if necessary.
/// Returns "OK" if successful, otherwise, returns a string containing the error.
#define rustg_iconforge_gags(config_path, colors, output_dmi_path) RUSTG_CALL(RUST_G, "iconforge_gags")("[config_path]", colors, output_dmi_path)
/// Returns a job_id for use with rustg_iconforge_check()
#define rustg_iconforge_load_gags_config_async(config_path, config_json, config_icon_path) RUSTG_CALL(RUST_G, "iconforge_load_gags_config_async")("[config_path]", config_json, config_icon_path)
/// Returns a job_id for use with rustg_iconforge_check()
#define rustg_iconforge_gags_async(config_path, colors, output_dmi_path) RUSTG_CALL(RUST_G, "iconforge_gags_async")("[config_path]", colors, output_dmi_path)

#define RUSTG_ICONFORGE_BLEND_COLOR "BlendColor"
#define RUSTG_ICONFORGE_BLEND_ICON "BlendIcon"
#define RUSTG_ICONFORGE_CROP "Crop"
#define RUSTG_ICONFORGE_SCALE "Scale"

#define RUSTG_JOB_NO_RESULTS_YET "NO RESULTS YET"
#define RUSTG_JOB_NO_SUCH_JOB "NO SUCH JOB"
#define RUSTG_JOB_ERROR "JOB PANICKED"

#define rustg_json_is_valid(text) (RUSTG_CALL(RUST_G, "json_is_valid")(text) == "true")

#define rustg_log_write(fname, text, format) RUSTG_CALL(RUST_G, "log_write")(fname, text, format)
/proc/rustg_log_close_all() return RUSTG_CALL(RUST_G, "log_close_all")()

#define rustg_noise_get_at_coordinates(seed, x, y) RUSTG_CALL(RUST_G, "noise_get_at_coordinates")(seed, x, y)

/**
 * Generates a 2D poisson disk distribution ('blue noise'), which is relatively uniform.
 *
 * params:
 * 	`seed`: str
 * 	`width`: int, width of the noisemap (see world.maxx)
 * 	`length`: int, height of the noisemap (see world.maxy)
 * 	`radius`: int, distance between points on the noisemap
 *
 * returns:
 * 	a width*length length string of 1s and 0s representing a 2D poisson sample collapsed into a 1D string
 */
#define rustg_noise_poisson_map(seed, width, length, radius) RUSTG_CALL(RUST_G, "noise_poisson_map")(seed, width, length, radius)

/*
 * Takes in a string and json_encode()"d lists to produce a sanitized string.
 * This function operates on whitelists, there is currently no way to blacklist.
 * Args:
 * * text: the string to sanitize.
 * * attribute_whitelist_json: a json_encode()'d list of HTML attributes to allow in the final string.
 * * tag_whitelist_json: a json_encode()'d list of HTML tags to allow in the final string.
 */
#define rustg_sanitize_html(text, attribute_whitelist_json, tag_whitelist_json) RUSTG_CALL(RUST_G, "sanitize_html")(text, attribute_whitelist_json, tag_whitelist_json)

/// Provided a static RSC file path or a raw text file path, returns the duration of the file in deciseconds as a float.
/proc/rustg_sound_length(file_path)
	var/static/list/sound_cache
	if(isnull(sound_cache))
		sound_cache = list()

	. = 0

	if(!istext(file_path))
		if(!isfile(file_path))
			CRASH("rustg_sound_length error: Passed non-text object")

		if(length("[file_path]")) // Runtime generated RSC references stringify into 0-length strings.
			file_path = "[file_path]"
		else
			CRASH("rustg_sound_length does not support non-static file refs.")

	var/cached_length = sound_cache[file_path]
	if(!isnull(cached_length))
		return cached_length

	var/ret = RUSTG_CALL(RUST_G, "sound_len")(file_path)
	var/as_num = text2num(ret)
	if(isnull(ret))
		. = 0
		CRASH("rustg_sound_length error: [ret]")

	sound_cache[file_path] = as_num
	return as_num


#define RUSTG_SOUNDLEN_SUCCESSES "successes"
#define RUSTG_SOUNDLEN_ERRORS "errors"
/**
 * Returns a nested key-value list containing "successes" and "errors"
 * The format is as follows:
 * list(
 *  RUSTG_SOUNDLEN_SUCCESES = list("sounds/test.ogg" = 25.34),
 *  RUSTG_SOUNDLEN_ERRORS = list("sound/bad.png" = "SoundLen: Unable to decode file."),
 *)
*/
#define rustg_sound_length_list(file_paths) json_decode(RUSTG_CALL(RUST_G, "sound_len_list")(json_encode(file_paths)))

#define rustg_sql_connect_pool(options) RUSTG_CALL(RUST_G, "sql_connect_pool")(options)
#define rustg_sql_query_async(handle, query, params) RUSTG_CALL(RUST_G, "sql_query_async")(handle, query, params)
#define rustg_sql_query_blocking(handle, query, params) RUSTG_CALL(RUST_G, "sql_query_blocking")(handle, query, params)
#define rustg_sql_connected(handle) RUSTG_CALL(RUST_G, "sql_connected")(handle)
#define rustg_sql_disconnect_pool(handle) RUSTG_CALL(RUST_G, "sql_disconnect_pool")(handle)
#define rustg_sql_check_query(job_id) RUSTG_CALL(RUST_G, "sql_check_query")("[job_id]")

#define rustg_time_microseconds(id) text2num(RUSTG_CALL(RUST_G, "time_microseconds")(id))
#define rustg_time_milliseconds(id) text2num(RUSTG_CALL(RUST_G, "time_milliseconds")(id))
#define rustg_time_reset(id) RUSTG_CALL(RUST_G, "time_reset")(id)

/// Returns the timestamp as a string
/proc/rustg_unix_timestamp()
	return RUSTG_CALL(RUST_G, "unix_timestamp")()

#define rustg_raw_read_toml_file(path) json_decode(RUSTG_CALL(RUST_G, "toml_file_to_json")(path) || "null")

/proc/rustg_read_toml_file(path)
	var/list/output = rustg_raw_read_toml_file(path)
	if (output["success"])
		return json_decode(output["content"])
	else
		CRASH(output["content"])

#define rustg_raw_toml_encode(value) json_decode(RUSTG_CALL(RUST_G, "toml_encode")(json_encode(value)))

/proc/rustg_toml_encode(value)
	var/list/output = rustg_raw_toml_encode(value)
	if (output["success"])
		return output["content"]
	else
		CRASH(output["content"])

#define rustg_url_encode(text) RUSTG_CALL(RUST_G, "url_encode")("[text]")
#define rustg_url_decode(text) RUSTG_CALL(RUST_G, "url_decode")(text)

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define url_encode(text) rustg_url_encode(text)
	#define url_decode(text) rustg_url_decode(text)
#endif

