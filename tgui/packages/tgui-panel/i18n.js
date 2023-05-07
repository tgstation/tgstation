export const LANGUAGES = {
  English: 'EN',
  Russian: 'RU',
};

export const i18n = (translations) => {
  const fallbackLang = LANGUAGES.English;
  let currentLang = LANGUAGES.Russian;

  const changeLanguage = (newLang) => {
    currentLang = newLang;
  };

  const t = (stringName, values = {}) => {
    const rawString = translations[stringName][currentLang] || translations[stringName][fallbackLang];
    return fillStringValues(rawString, values);
  };

  const plural = (stringName, values = {}) => {
    const validLanguage = translations[stringName][currentLang] ? currentLang : fallbackLang;

    if (typeof translations[stringName][currentLang] === 'string' || !values) {
      return t(stringName);
    }

    let rawString;
    switch (validLanguage) {
      case LANGUAGES.Russian:
        rawString = russianPlural(translations[stringName][validLanguage], values.n);
        break;
      case LANGUAGES.English:
      default: {
        rawString = englishPlural(translations[stringName][validLanguage], values.n);
      }
    }

    return fillStringValues(rawString, values);
  };

  const fillStringValues = (string, values) => {
    let editedString = string;
    Object.entries(values).forEach(([key, value]) => {
      editedString = editedString.replace(RegExp(`{${key}}`, "g"), String(value));
    });
    return editedString;
  };

  const englishPlural = (translation, n) => {
    switch (n) {
      case 0:
        return translation.zero;
      case 1:
        return translation.one;
      default:
        return translation.other;
    }
  };

  const russianPlural = (translation, n) => {
    switch (n % 10) {
      case 1:
        return translation.one;
      case 2:
      case 3:
      case 4:
        return translation.few;
      default:
        return translation.other;
    }
  };

  return {
    changeLanguage,
    t,
    plural,
  };
};
