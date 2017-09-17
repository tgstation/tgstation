//!

const CONFIG_DIR: &str = "data/voice";

const VOICE_HEAR: u8 = 1;
const VOICE_SPEAK: u8 = 2;

const VOICE_ALL: u8 = VOICE_HEAR | VOICE_SPEAK;

// Imports
extern crate discord;
extern crate toml;

use std::path::{Path, PathBuf};
use std::fs::{self, File};
use std::{env, process, io};
use std::sync::mpsc;
use std::collections::BTreeMap;

use discord::Discord;
use discord::model::{ServerId, UserId};

use toml::Value;

// Macros
macro_rules! fatal {
	($msg:expr) => {{
		println!(concat!("FATAL: ", $msg));
		process::exit(1);
	}};
	($msg:expr, $($rest:tt)*) => {{
		println!(concat!("FATAL: ", $msg), $($rest)*);
		process::exit(1);
	}}
}
macro_rules! try_fatal {
	($e:expr, $msg:expr) => {
		match $e {
			Ok(o) => o,
			Err(e) => fatal!(concat!($msg, "\n{fatal_}\n{fatal_:?}"), fatal_=e),
		}
	};
	($e:expr, $msg:expr, $($rest:tt)*) => {
		match $e {
			Ok(o) => o,
			Err(e) => fatal!(concat!($msg, "\n{fatal_}\n{fatal_:?}"), $($rest)*, fatal_=e),
		}
	}
}
macro_rules! opt_fatal {
	($e:expr, $msg:expr) => {
		match $e {
			Some(s) => s,
			None => fatal!($msg),
		}
	};
	($e:expr, $msg:expr, $($rest:tt)*) => {
		match $e {
			Some(s) => s,
			None => fatal!($msg, $($rest)*),
		}
	}
}

// Implementation
fn read(path: &Path) -> toml::Value {
	use std::io::Read;

	let mut f = try_fatal!(File::open(path), "couldn't open {}", path.display());
	let mut contents = String::new();
	try_fatal!(f.read_to_string(&mut contents), "couldn't read {}", path.display());
	try_fatal!(toml::from_str::<toml::Value>(&contents), "invalid toml in {}", path.display())
}

fn request_files() -> Vec<PathBuf> {
	let mut vec = Vec::new();
	for entry in try_fatal!(fs::read_dir(Path::new(CONFIG_DIR)), "couldn't list {}", CONFIG_DIR) {
		let entry = try_fatal!(entry, "couldn't list one of the entries");
		let fname = opt_fatal!(entry.file_name().into_string().ok(), "filename not UTF-8");
		if fname.starts_with("request_") && fname.ends_with(".txt") {
			vec.push(entry.path());
		}
	}
	vec.sort();
	vec
}

fn main() {
	println!("starting ...");

	// Move up until we find tgstation.dmb or tgstation.dme
	{
		let cwd = env::current_dir().unwrap();
		let mut cwd: &Path = cwd.as_ref();
		while !(cwd.join("tgstation.dmb").exists() || cwd.join("tgstation.dme").exists()) {
			cwd = opt_fatal!(cwd.parent(), "couldn't find server root");
		}
		env::set_current_dir(cwd).unwrap();
	}

	// Read the config
	let config_dir = Path::new(CONFIG_DIR);
	let config = read(&config_dir.join("config.toml"));
	let whois = read(&config_dir.join("whois.toml"));

	let server = opt_fatal!(
		opt_fatal!(config.get("server"), "config: 'server' missing").as_integer(),
		"config: 'server' not an integer");
	let token = opt_fatal!(
		opt_fatal!(config.get("token"), "config: 'token' missing").as_str(),
		"config: 'token' not a string");
	let server = discord::model::ServerId(server as u64);
	if token.len() < 10 {
		fatal!("token appears to be invalid: {:?}", token);
	}

	let mut current_state = BTreeMap::new();

	// Delete any leftover requests from an earlier time
	for file in request_files() {
		println!("deleting leftover {}", file.display());
		try_fatal!(fs::remove_file(&file), "couldn't delete");
	}

	// Log into Discord
	let discord = try_fatal!(discord::Discord::from_bot_token(token), "discord login failed");

	// Start up the stdin thread
	let (tx, rx) = mpsc::channel();
	std::thread::spawn(|| stdin_thread(tx));

	// Stand by for requests
	loop {
		match rx.try_recv() {
			Ok(_) => break,
			Err(mpsc::TryRecvError::Disconnected) => fatal!("stdin thread crashed"),
			Err(mpsc::TryRecvError::Empty) => {}
		}

		let files = request_files();
		if files.is_empty() {
			sleep(100);
			continue;
		}

		// Read requests
		let mut requests = Vec::new();
		for path in files {
			use std::io::BufRead;

			let f = try_fatal!(File::open(&path), "couldn't open {}", path.display());
			requests.extend(std::io::BufReader::new(f)
				.lines()
				.map(|l| try_fatal!(l, "couldn't read {}", path.display()))
				.filter(|l| !l.is_empty()));
			try_fatal!(fs::remove_file(&path), "couldn't delete");
		}

		// Deduplicate requests for the same user, taking the most recent
		let mut to_change = BTreeMap::new();
		for argument in requests.iter() {
			let mut split = argument.split("=");
			let username = split.next().unwrap();
			let bits = opt_fatal!(split.next(), "args: key without value: {}", username);
			let bits: u8 = try_fatal!(bits.parse(), "args: value not u8: {}", bits);

			to_change.insert(username, bits);
		}

		for (username, bits) in to_change {
			// perform username lookup
			let userid;
			match whois.get(username) {
				Some(&Value::Integer(n)) => { userid = discord::model::UserId(n as u64); }
				_ => {
					println!("unknown key: {}", username);
					continue;
				}
			}
			let userid_string = userid.to_string();

			// mask bits
			let deaf = (bits & VOICE_HEAR) == 0;
			let mute = (bits & VOICE_SPEAK) == 0;
			let bits = bits & VOICE_ALL; // utterly ignore bits we don't handle yet

			// perform state lookup
			let prev_bits = current_state.get(&userid).cloned().unwrap_or(VOICE_ALL);

			print!("{:20} {:>18} {} {} ... ",
				username,
				userid_string,
				if mute { "mt" } else { "--" },
				if deaf { "df" } else { "--" });
			if prev_bits != bits {
				print!("updating ... ");
				do_it(&discord, server, userid, mute, deaf);
				current_state.insert(userid, bits);
			} else {
				println!("no change");
			}
		}
	}

	println!("stopping ...");
	for (userid, bits) in current_state {
		print!("{:>18} ... ", userid);
		if bits != VOICE_ALL {
			print!("restoring ... ");
			do_it(&discord, server, userid, false, false);
		} else {
			println!("no change");
		}
	}
}

fn sleep(ms: u64) {
	std::thread::sleep(std::time::Duration::from_millis(ms))
}

fn stdin_thread(tx: mpsc::Sender<String>) {
	use std::io::BufRead;

	let stdin = io::stdin();
	let stdin = stdin.lock();
	for line in stdin.lines() {
		if tx.send(try_fatal!(line, "stdin error")).is_err() {
			return;
		}
	}
}

fn do_it(discord: &Discord, server: ServerId, user: UserId, mute: bool, deaf: bool) {
	use std::io::Write;
	let _ = io::stdout().flush();
	let now = std::time::Instant::now();
	try_fatal!(discord.edit_member(server, user, |m| m
		.mute(mute)
		.deaf(deaf)
	), "discord call failed");
	let diff = std::time::Instant::now() - now;
	println!("{}ms", diff.as_secs() * 1000 + diff.subsec_nanos() as u64 / 1_000_000);
}
