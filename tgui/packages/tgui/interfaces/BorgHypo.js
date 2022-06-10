import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Button, Flex, NoticeBox, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

export const BorgHypo = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    maxVolume,
    theme,
    reagents,
    selectedReagent,
  } = data;
  return (
    <Window
      width={450}
      height={350}
      theme={theme}
    >
      <Window.Content scrollable>
        <Section>
          <Reagent
            reagents={reagents}
            selected={selectedReagent}
            maxVolume={maxVolume} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const Reagent = (props, context) => {
  const { act, data } = useBackend(context);
  const { reagents, selected, maxVolume } = props;
  if (reagents.length === 0) {
    return (
      <NoticeBox>
        No reagents available!
      </NoticeBox>
    );
  }
  return reagents.map(reagent => (
    <Flex key={reagent.name} mb={1}>
      <Flex.Item grow>
        <ProgressBar value={reagent.volume / maxVolume}>
          <Flex>
            <Flex.Item grow bold textAlign={'left'}>
              {reagent.name}
            </Flex.Item>
            <Flex.Item>
              {toFixed(reagent.volume) + ' units'}
            </Flex.Item>
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
