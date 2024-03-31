const dir_num2str = (dir_num: 1 | 2 | 4 | 8) => {
  switch (dir_num) {
    case 1:
      return 'North';
    case 2:
      return 'South';
    case 4:
      return 'East';
    case 8:
      return 'West';
  }
};
