export function getConditionColor(condition) {
  switch (condition) {
    case 'В лобби':
      return 'teal';
    case 'Живой':
      return 'green';
    case 'Без сознания':
      return 'yellow';
    case 'В крите':
      return 'orange';
    case 'Мёртв':
      return 'red';
    case 'Наблюдает':
      return 'grey';
    default:
      return '';
  }
}

export function getPingColor(ping) {
  switch (true) {
    case ping < 100:
      return 'green';
    case ping > 100:
      return 'orange';
    case ping > 220:
      return 'red';
    default:
      return '';
  }
}

export function numberToDays(num) {
  const number = num.toLocaleString('ru-RU');
  const mod10 = num % 10;
  const mod100 = num % 100;
  if (mod10 === 1 && mod100 !== 11) {
    return `${number} день`;
  }
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
    return `${number} дня`;
  }
  return `${number} дней`;
}
