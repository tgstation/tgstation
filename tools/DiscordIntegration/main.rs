//!

const CONFIG_DIR: &str = "data/voice";

// Imports
extern crate discord;
extern crate toml;

use std::path::Path;
use std::fs::File;
use std::{env, process};

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

fn main() {
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

	let server = opt_fatal!(
		opt_fatal!(config.get("server"), "config: 'server' missing").as_integer(),
		"config: 'server' not an integer");
	let token = opt_fatal!(
		opt_fatal!(config.get("token"), "config: 'token' missing").as_str(),
		"config: 'token' not a string");

	let server = discord::model::ServerId(server as u64);

	// TODO: Read the state

	// Log into Discord
	let discord = try_fatal!(discord::Discord::from_bot_token(token), "discord login failed");

	// TODO: Apply changes according to the arguments
}
