import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Button, Flex, NoticeBox, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

type BorgHypoContext = {
  maxVolume: number;
  theme: string;
  reagents: Reagent[];
  selectedReagent: string;
};

type Reagent = {
  name: string;
  volume: number;
  description: string;
};

export const BorgHypo = (props, context) => {
  const { data } = useBackend<BorgHypoContext>(context);
  const { maxVolume, theme, reagents, selectedReagent } = data;

  const dynamicHeight = reagents.length * 25 + 60;

  return (
    <Window width={400} height={dynamicHeight} theme={theme}>
      <Window.Content>
        <Section>
          <ReagentDisplay
            reagents={reagents}
            selected={selectedReagent}
            maxVolume={maxVolume}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};

const ReagentDisplay = (props, context) => {
  const { act } = useBackend(context);
  const { reagents, selected, maxVolume } = props;
  if (reagents.length === 0) {
    return <NoticeBox>No reagents available!</NoticeBox>;
  }
  return reagents.map((reagent) => (
    <Flex key={reagent.name} m={0.5}>
      <Flex.Item grow>
        <ProgressBar value={reagent.volume / maxVolume}>
          <Flex>
            <Flex.Item grow textAlign={'left'}>
              {reagent.name}
            </Flex.Item>
            <Flex.Item>{toFixed(reagent.volume) + 'u'}</Flex.Item>
          </Flex>
        </ProgressBar>
      </Flex.Item>
      <Flex.Item mx={1}>
        <Button
          icon={'info-circle'}
          textAlign={'center'}
          tooltip={reagent.description}
        />
      </Flex.Item>
      <Flex.Item textAlign={'right'}>
        <Button
          icon={'syringe'}
          color={reagent.name === selected ? 'green' : 'default'}
          content={'Select'}
          textAlign={'center'}
          onClick={() => act(reagent.name)}
        />
      </Flex.Item>
    </Flex>
  ));
};
