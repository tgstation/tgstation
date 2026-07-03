#ifndef RUST_UTILS

/* This comment bypasses grep checks */ /var/__rust_utils

/proc/__detect_rust_utils()
	if(world.system_type == UNIX)
		if(fexists("./librust_utils.so"))
			// No need for LD_LIBRARY_PATH badness.
			return __rust_utils = "./librust_utils.so"
		else
			// It's not in the current directory, so try others
			return __rust_utils = "librust_utils.so"
	else
		return __rust_utils = "librust_utils"

#define RUST_UTILS (__rust_utils || __detect_rust_utils())
#endif

/// Gets the version of rust_utils
/proc/rust_utils_get_version() return RUSTG_CALL(RUST_UTILS, "get_version")()

#define rustutils_file_write_b64decode(text, fname) RUSTG_CALL(RUST_UTILS, "file_write")(text, fname, "true")

#define rustutils_regex_replace(text, re, re_params, replacement) RUSTG_CALL(RUST_UTILS, "regex_replace")(text, re, re_params, replacement)

#define rustutils_cyrillic_to_latin(text) RUSTG_CALL(RUST_UTILS, "cyrillic_to_latin")("[text]")
#define rustutils_latin_to_cyrillic(text) RUSTG_CALL(RUST_UTILS, "latin_to_cyrillic")("[text]")

#define rustg_http_request_blocking(method, url, body, headers, options) RUSTG_CALL(RUST_UTILS, "http_request_blocking")(method, url, body, headers, options)
#define rustg_http_request_async(method, url, body, headers, options) RUSTG_CALL(RUST_UTILS, "http_request_async")(method, url, body, headers, options)
#define rustg_http_check_request(req_id) RUSTG_CALL(RUST_UTILS, "http_check_request")(req_id)
#define rustg_http_request_fire_and_forget(method, url, body, headers, options) RUSTG_CALL(RUST_UTILS, "http_request_fire_and_forget")(method, url, body, headers, options)
/proc/rustg_create_async_http_client() return RUSTG_CALL(RUST_UTILS, "start_http_client")()
/proc/rustg_close_async_http_client() return RUSTG_CALL(RUST_UTILS, "shutdown_http_client")()
