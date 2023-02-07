import { Box, Flex } from '../../components';

export const calculateProgression = (progression_points: number) => {
  return Math.round(progression_points / 6) / 10;
};

const badGradient = 'reputation-bad';
const normalGradient = 'reputation-normal';
const goodGradient = 'reputation-good';
const veryGoodGradient = 'reputation-very-good';
const ultraGoodGradient = 'reputation-super-good';
const bestGradient = 'reputation-best';

export type Rank = {
  minutesLessThan: number;
  title: string;
  gradient: string;
};

export const ranks: Rank[] = [
  {
    minutesLessThan: 5,
    title: 'Obscure',
    gradient: badGradient,
  },
  {
    minutesLessThan: 10,
    title: 'Insignificant',
    gradient: normalGradient,
  },
  {
    minutesLessThan: 20,
    title: 'Noteworthy',
    gradient: normalGradient,
  },
  {
    minutesLessThan: 30,
    title: 'Reputable',
    gradient: goodGradient,
  },
  {
    minutesLessThan: 50,
    title: 'Well-known',
    gradient: goodGradient,
  },
  {
    minutesLessThan: 70,
    title: 'Significant',
    gradient: veryGoodGradient,
  },
  {
    minutesLessThan: 90,
    title: 'Famous',
    gradient: veryGoodGradient,
  },
  {
    minutesLessThan: 110,
    title: 'Glorious',
    gradient: ultraGoodGradient,
  },
  {
    minutesLessThan: 140,
    title: 'Fabled',
    gradient: ultraGoodGradient,
  },
  {
    minutesLessThan: -1,
    title: 'Legendary',
    gradient: bestGradient,
  },
];

export const reputationDefault = 50 * 600;

let lastMinutesThan = -1;
export const reputationLevelsTooltip = (
  <Box preserveWhitespace>
    <Flex direction="column" mt={1}>
      {ranks.map((value) => {
        if (lastMinutesThan === -1) {
          lastMinutesThan = 0;
        }
        const progression = calculateProgression(lastMinutesThan * 600);
        const text = `${value.title} (${progression})`;

        lastMinutesThan = value.minutesLessThan;
        return (
          <Flex.Item key={value.minutesLessThan} mt={0.1}>
            <Box
              color="white"
              className={value.gradient}
              style={{
                'border-radius': '5px',
                'display': 'inline-block',
              }}
              px={0.8}
              py={0.6}>
              {text}
            </Box>
          </Flex.Item>
        );
      })}
    </Flex>
  </Box>
);

export const getReputation = (progression_points: number) => {
  const minutes = progression_points / 600;

  for (let index = 0; index < ranks.length; index++) {
    const rank = ranks[index];
    if (minutes < rank.minutesLessThan) {
      return rank;
    }
  }

  return ranks[ranks.length - 1];
};

export const calculateReputationLevel = (
  progression_points: number,
  textOnly: boolean
) => {
  const minutes = progression_points / 600;
  const displayedProgression = calculateProgression(progression_points);
  const reputation = getReputation(progression_points);
  if (textOnly) {
    return (
      <Box as="span">
        {reputation.title} ({displayedProgression})
      </Box>
    );
  }
  return (
    <Box
      color="white"
      className={reputation.gradient}
      style={{
        'border-radius': '5px',
        'display': 'inline-block',
      }}
      px={0.8}
      py={0.6}>
      {reputation.title} ({displayedProgression})
    </Box>
  );
};
