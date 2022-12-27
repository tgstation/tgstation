import { useBackend } from '../backend';
import { Button, Section, Icon, Stack, LabeledList, Box, NoticeBox } from '../components';
import { Window } from '../layouts';

type CellularEmporiumContext = {
  abilities: Ability[];
  can_readapt: boolean;
  genetic_points_remaining: number;
};

type Ability = {
  name: string;
  desc: string;
  path: string;
  dna_cost: number;
  helptext: string;
  owned: boolean;
  can_purchase: boolean;
};

export const CellularEmporium = (props, context) => {
  const { act, data } = useBackend<CellularEmporiumContext>(context);
  const { can_readapt, genetic_points_remaining } = data;
  return (
    <Window width={900} height={480}>
      <Window.Content>
        <Section
          fill
          scrollable
          title={'Genetic Points'}
          buttons={
            <Stack>
              <Stack.Item fontSize="16px">
                {genetic_points_remaining && genetic_points_remaining}{' '}
                <Icon name="dna" color="#DD66DD" />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="undo"
                  content="Readapt"
                  disabled={!can_readapt}
                  onClick={() => act('readapt')}
                />
              </Stack.Item>
            </Stack>
          }>
          <AbilityList />
        </Section>
      </Window.Content>
    </Window>
  );
};

const AbilityList = (props, context) => {
  const { act, data } = useBackend<CellularEmporiumContext>(context);
  const { abilities, genetic_points_remaining } = data;

  if (!abilities) {
    return <NoticeBox>None</NoticeBox>;
  } else {
    return (
      <LabeledList>
        {abilities.map((ability) => (
          <LabeledList.Item
            key={ability.name}
            className="candystripe"
            label={ability.name}
            buttons={
              <Stack>
                <Stack.Item>{ability.dna_cost}</Stack.Item>
                <Stack.Item>
                  <Icon name="dna" color={ability.owned ? '#DD66DD' : 'gray'} />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    content={'Evolve'}
                    disabled={
                      ability.owned ||
                      ability.dna_cost > genetic_points_remaining ||
                      !ability.can_purchase
                    }
                    onClick={() =>
                      act('evolve', {
                        path: ability.path,
                      })
                    }
                  />
                </Stack.Item>
              </Stack>
            }>
            {ability.desc}
            <Box color="good">{ability.helptext}</Box>
          </LabeledList.Item>
        ))}
      </LabeledList>
    );
  }
};
