export const NEW_ACCOUNT_AGE = 7;
export const NEW_ACCOUNT_NOTICE = 'Аккаунт создан недавно';

export const sortTypes = {
  'По-умолчанию': (a, b) => a.key.localeCompare(b.key),
  Состояние: (a, b) => a?.status?.state.localeCompare(b?.status?.state),
  Пинг: (a, b) => a.ping.avgPing - b.ping.avgPing,
  'Возраст аккаунта': (a, b) => a.accountAge - b.accountAge,
  'Версия BYOND': (a, b) => a.byondVersion.localeCompare(b.byondVersion),
};
