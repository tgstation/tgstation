import { Box, Button, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  details: string[];
  selected: string;
};

type Props = {
  category: string;
};

const UI_WARNINGS = [
  `HEY FUCKOS, these filters are based off VERY OLD and VERY FLAWED
  matrixes.`,
  `There is NO GOOD WAY to do proper color blind simulation in BYOND,
because we have no way to extract the gamma of a pixel without
iterating all pixels on the screen, which we need to do to properly
correct for the human eye.`,
  `Because of this, this simulation is very imperfect. You will notice
things are much more bright then they should be. This is a direct
result of not being able to correct for gamma.`,
  `This tool exists so we have at least some form of baseline for
accessability, it is nowhere near gospel.`,
  `If I find you being a dick to someone over this I will clobber you
with a crowbar`,
] as const;

export const ColorBlindTester = (props) => {
  const { data } = useBackend<Data>();
  const { details } = data;

  return (
    <Window title="Color Blindness Testing" width={600} height={515}>
      <Window.Content>
        <NoticeBox>
          {UI_WARNINGS.map((warning, index) => (
            <Box key={index}>{warning}</Box>
          ))}
        </NoticeBox>
        <Section>
          {Object.keys(details).map((category) => (
            <ColorBlindCategory category={category} key={category} />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

const ColorBlindCategory = (props: Props) => {
  const { act, data } = useBackend<Data>();
  const { category } = props;
  const { details, selected } = data;

  if (category !== selected) {
    return (
      <Section
        key={category}
        title={category}
        buttons={
          <Button
            icon="eye"
            content="Select"
            onClick={() =>
              act('set_matrix', {
                name: category,
              })
            }
          />
        }
      >
        {details[category]}
      </Section>
    );
  }
  return (
    <Section
      key={category}
      title={category}
      buttons={
        <Button
          icon="times"
          content="Clear"
          color="bad"
          onClick={() => act('clear_matrix')}
        />
      }
    >
      {details[category]}
    </Section>
  );
};
