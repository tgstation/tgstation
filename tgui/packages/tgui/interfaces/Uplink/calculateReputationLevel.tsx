import { multiline } from 'common/string';
import { Box, Flex } from '../../components';

const calculateProgression = (progression_points: number) => {
  return Math.round(progression_points / 6) / 10;
};

const badGradient = "linear-gradient(to right, #9c1e1e, rgba(108, 40, 40, 255), #9c1e1e);";
const normalGradient = "linear-gradient(to right, #5d5041, #40372d, #5d5041)";
const goodGradient = "linear-gradient(to right, #515d6c, #252a30, #515d6c)";
const veryGoodGradient = "linear-gradient(to right, #977949, #534328, #977949)";
const ultraGoodGradient = "linear-gradient(to right, #9d9948, #777437, #9d9948)";
const bestGradient = "linear-gradient(to right, #9d486b, #57283c, #9d486b)";

const ranks = [
  {
    minutesLessThan: 5,
    title: "Obscure",
    gradient: badGradient,
  },
  {
    minutesLessThan: 10,
    title: "Insignificant",
    gradient: normalGradient,
  },
  {
    minutesLessThan: 20,
    title: "Noteworthy",
    gradient: normalGradient,
  },
  {
    minutesLessThan: 30,
    title: "Reputable",
    gradient: goodGradient,
  },
  {
    minutesLessThan: 50,
    title: "Well-known",
    gradient: goodGradient,
  },
  {
    minutesLessThan: 70,
    title: "Significant",
    gradient: veryGoodGradient,
  },
  {
    minutesLessThan: 90,
    title: "Famous",
    gradient: veryGoodGradient,
  },
  {
    minutesLessThan: 110,
    title: "Glorious",
    gradient: ultraGoodGradient,
  },
  {
    minutesLessThan: 130,
    title: "Fabled",
    gradient: ultraGoodGradient,
  },
  {
    minutesLessThan: -1,
    title: "Legendary",
    gradient: bestGradient,
  },
];

export const reputationDefault = 50*600;

let lastMinutesThan = -1;
export const reputationLevelsTooltip = (
  <Box preserveWhitespace>
    {multiline`
Your current level of reputation. \
Reputation determines what quality of objective \
you get and what items you can purchase.\
`}
    <Flex direction="column" mt={1}>
      {ranks.map(value => {
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
              style={{
                "background": value.gradient,
                "border-radius": "5px",
                "display": "inline-block",
              }}
              px={0.8}
              py={0.6}
            >
              {text}
            </Box>
          </Flex.Item>
        );
      })}
    </Flex>
  </Box>
);

export const calculateReputationLevel = (
  progression_points: number,
  textOnly: boolean
) => {
  const minutes = progression_points / 600;
  const displayedProgression = calculateProgression(progression_points);
  let gradient;
  let title;
  for (let index = 0; index < ranks.length; index++) {
    const rank = ranks[index];
    if (minutes < rank.minutesLessThan) {
      gradient = rank.gradient;
      title = rank.title;
      break;
    }
  }
  if (textOnly) {
    return (<Box as="span">{title} ({displayedProgression})</Box>);
  }
  return (
    <Box
      color="white"
      style={{
        "background": gradient,
        "border-radius": "5px",
        "display": "inline-block",
      }}
      px={0.8}
      py={0.6}
    >
      {title} ({displayedProgression})
    </Box>
  );
};
