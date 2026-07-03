import { COLORS } from '../../constants';
import type { CrewSensor } from './types';

export const STAT_LIVING = 0;
export const STAT_DEAD = 4;

export const HEALTH_COLOR_BY_LEVEL = [
  '#17d568',
  '#c4cf2d',
  '#e67e22',
  '#ed5100',
  '#e74c3c',
  '#801308',
];

export const jobIsHead = (jobId: number) => jobId % 10 === 0;
export const jobToColor = (jobId: number) => {
  if (jobId === 0) {
    return COLORS.department.captain;
  }
  if (jobId >= 10 && jobId < 20) {
    return COLORS.department.security;
  }
  if (jobId >= 20 && jobId < 30) {
    return COLORS.department.medbay;
  }
  if (jobId >= 30 && jobId < 40) {
    return COLORS.department.science;
  }
  if (jobId >= 40 && jobId < 50) {
    return COLORS.department.engineering;
  }
  if (jobId >= 50 && jobId < 60) {
    return COLORS.department.cargo;
  }
  if (jobId >= 60 && jobId < 200) {
    return COLORS.department.service;
  }
  if (jobId >= 200 && jobId < 230) {
    return COLORS.department.centcom;
  }
  return COLORS.department.other;
};

export const statToIcon = (life_status: number) => {
  switch (life_status) {
    case STAT_LIVING:
      return 'heart';
    case STAT_DEAD:
      return 'skull';
  }
  return 'heartbeat';
};

export const healthToAttribute = (
  sensor: CrewSensor,
  attributeList: string[],
) => {
  const { oxydam, toxdam, burndam, brutedam } = sensor;
  const healthSum = oxydam + toxdam + burndam + brutedam;
  const level = Math.min(Math.max(Math.ceil(healthSum / 25), 0), 5);
  return attributeList[level];
};

export const areaSort = (a: CrewSensor, b: CrewSensor) => {
  const areaA = a.position?.area ?? '~';
  const areaB = b.position?.area ?? '~';
  if (areaA < areaB) return -1;
  if (areaA > areaB) return 1;
  return 0;
};

export const headSort = (a: CrewSensor, b: CrewSensor) => {
  if (a.ijob % 10 === 0 && b.ijob % 10 !== 0) return -1;
  else if (a.ijob % 10 !== 0 && b.ijob % 10 === 0) return 1;
  else return a.ijob - b.ijob;
};

export const healthSort = (a: CrewSensor, b: CrewSensor) => {
  if (a.life_status > b.life_status) return -1;
  if (a.life_status < b.life_status) return 1;
  if (a.health < b.health) return -1;
  if (a.health > b.health) return 1;
  return 0;
};

export const sortTypes = {
  Name: (a, b) => (a.name > b.name ? 1 : -1),
  Job: (a, b) => a.ijob - b.ijob,
  Head: (a, b) => headSort(a, b),
  Health: (a, b) => healthSort(a, b),
  Area: (a, b) => areaSort(a, b),
};
