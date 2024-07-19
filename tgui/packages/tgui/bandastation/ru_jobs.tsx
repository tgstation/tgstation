export const JOBS_RU = {
  Assistant: 'Гражданский',
  Prisoner: 'Заключенный',
  Captain: 'Капитан',
  'Head of Personnel': 'Глава персонала',
  'Head of Security': 'Глава службы безопасности',
  'Research Director': 'Директор исследований',
  'Chief Engineer': 'Главный инженер',
  'Chief Medical Officer': 'Главный врач',
  AI: 'ИИ',
  Cyborg: 'Киборг',
  'Personal AI': 'Персональный ИИ',
  'Human AI': 'Большой брат',
  Warden: 'Смотритель',
  Detective: 'Детектив',
  'Security Officer': 'Офицер',
  'Security Officer (Cargo)': 'Офицер (Снабжение)',
  'Security Officer (Engineering)': 'Офицер (Инженерия)',
  'Security Officer (Medical)': 'Офицер (Медицина)',
  'Security Officer (Science)': 'Офицер (Исследование)',
  'Station Engineer': 'Станционный инженер',
  'Atmospheric Technician': 'Атмосферный техник',
  Coroner: 'Коронер',
  'Medical Doctor': 'Врач',
  Paramedic: 'Парамедик',
  Chemist: 'Химик',
  Scientist: 'Ученый',
  Roboticist: 'Робототехник',
  Geneticist: 'Генетик',
  Quartermaster: 'Квартирмейстер',
  'Cargo Technician': 'Грузчик',
  'Shaft Miner': 'Шахтер',
  Bitrunner: 'Битраннер',
  Bartender: 'Бармен',
  Botanist: 'Ботаник',
  Cook: 'Повар',
  Chef: 'Шеф',
  Janitor: 'Уборщик',
  Clown: 'Клоун',
  Mime: 'Мим',
  Curator: 'Куратор',
  Lawyer: 'Адвокат',
  Chaplain: 'Священник',
  Psychologist: 'Психолог',
};

const REVERSED_JOBS_RU = Object.entries(JOBS_RU).reduce(
  (reversed_jobs, [key, value]) => {
    reversed_jobs[value] = key;
    return reversed_jobs;
  },
  {},
);

export function ReverseJobsRu(value: string) {
  return REVERSED_JOBS_RU[value] || value;
}

export const DEPARTMENTS_RU = {
  Command: 'Командование',
  Security: 'Безопасность',
  Service: 'Обслуживание',
  Cargo: 'Снабжение',
  Science: 'Исследование',
  Medical: 'Медицина',
  Silicon: 'Синтетики',
  Engineering: 'Инженерия',
  'No Department': 'Без отдела',
};
