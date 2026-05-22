// File Labels
//
// Add a label based on if a file is modified in the diff
//
// You can optionally set add_only to make the label one-way -
// if the edit to the file is removed in a later commit,
// the label will not be removed
export const file_labels = {
	'GitHub': {
		filepaths: ['.github/'],
	},
	'SQL': {
		filepaths: ['SQL/'],
	},
	'Rust': {
		filepaths: ['rust/'],
	},
	'Map Edit': {
		filepaths: ['_maps/'],
		file_extensions: ['.dmm'],
	},
	'Tools': {
		filepaths: ['tools/', '.vscode/', '.bin/', '.gemini/'],
	},
  "Config Update": {
    filepaths: ["config/", "code/controllers/configuration/entries/", "modular_nemesis/master_files/code/controllers/configuration/entries/"],
    add_only: true,
  },
	'Sprites': {
		filepaths: ['icons/'],
		file_extensions: ['.dmi'],
		add_only: true,
	},
	'Sound': {
		filepaths: ['sound/'],
		file_extensions: ['.ogg'],
		add_only: true,
	},
	'TGUI': {
		filepaths: ['tgui/'],
		add_only: true,
	},
	'Documentation': {
		file_extensions: ['.md'],
	},
};

// Title Labels
//
// Add a label based on keywords in the title
export const title_labels = {
  'Logging': {
    keywords: ["log", "logging", "логирование"],
  },
	'Removal': {
		keywords: ['remove', 'delete', 'удаляет', 'удалил'],
	},
	'Refactor': {
		keywords: ['refactor', 'рефактор'],
	},
	'Localization': {
		keywords: ['local', 'локализация', 'перевод'],
	},
  'Unit Tests': {
    keywords: ["unit test", 'юнит тест'],
  },
  'April Fools': {
    keywords: ["[april fools]"],
  },
  'Do Not Merge': {
    keywords: ["[dnm]", "[do not merge]"],
  },
  'GBP: No Update': {
    keywords: ["[no gbp]"],
  },
  'Test Merge Only': {
    keywords: ["[tm only]", "[test merge only]"],
  },
};

// Changelog Labels
//
// Adds labels based on keywords in the changelog
// TODO use the existing changelog parser
export const changelog_labels = {
	'Fix': {
		default_text: 'Исправлен какой-то баг.',
		keywords: ['fix', 'fixes', 'bugfix'],
	},
	'Quality of Life': {
		default_text: 'Сделано что-то более простым в использовании.',
		keywords: ['qol', 'tweak'],
	},
	'Feature': {
		default_text: 'Добавлены новые механики или изменения в игровом процессе.',
		alt_default_text: 'Добавлено что-то новое.',
		keywords: ['add', 'adds', 'rscadd'],
	},
	'Removal': {
		default_text: 'Удалено что-то старое.',
		keywords: ['del', 'dels', 'rscdel'],
	},
	'Balance': {
		default_text: 'Произошёл ребаланс.',
		keywords: ['balance'],
	},
	'Code Improvement': {
		default_text: 'Изменён какой-то код.',
		keywords: ['code_imp', 'code'],
	},
	'Refactor': {
		default_text: 'Отрефакторен какой-то код.',
		keywords: ['refactor'],
	},
	'Administration': {
		default_text: 'Изменено что-то связанное с администрацией.',
		keywords: ['admin'],
	},
	'Sound': {
		default_text:
			'Добавлены/изменены/удалены какие-то аудио или звуковые эффекты.',
		keywords: ['sound'],
	},
	'Sprites': {
		default_text:
			'Добавлены/изменены/удалены какие-то спрайты или изображения.',
		keywords: ['image'],
	},
	'Localization': {
		default_text: 'Исправлена какая-то очепятка.',
		alt_default_text: 'Произошла локализация на русский язык.',
		keywords: ['typo', 'spellcheck', 'local'],
	},
	'Config Update': {
		default_text: 'Изменены какие-то настройки в конфиге.',
		keywords: ['config'],
	},
};
