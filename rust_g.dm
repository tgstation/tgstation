// rust_g.dm - DM API for rust_g extension library
#define RUST_G "rust_g"

#define rustg_dmi_strip_metadata(fname) call(RUST_G, "dmi_strip_metadata")(fname)

#define rustg_file_read(fname) call(RUST_G, "file_read")(fname)
#define rustg_file_write(text, fname) call(RUST_G, "file_write")(text, fname)
#define rustg_file_append(text, fname) call(RUST_G, "file_append")(text, fname)

#ifdef RUSTG_OVERRIDE_BUILTINS
#define file2text(fname) rustg_file_read(fname)
#define text2file(text, fname) rustg_file_append(text, fname)
#endif

#define rustg_git_revparse(rev) call(RUST_G, "rg_git_revparse")(rev)
#define rustg_git_commit_date(rev) call(RUST_G, "rg_git_commit_date")(rev)

#define rustg_log_write(fname, text) call(RUST_G, "log_write")(fname, text)
/proc/rustg_log_close_all() return call(RUST_G, "log_close_all")()

#define rustg_url_encode(text) call(RUST_G, "url_encode")(text)
#define rustg_url_decode(text) call(RUST_G, "url_decode")(text)

#ifdef RUSTG_OVERRIDE_BUILTINS
#define url_encode(text) rustg_url_encode(text)
#define url_decode(text) rustg_url_decode(text)
#endif
