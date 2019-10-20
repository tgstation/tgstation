import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, Section, Box } from '../components';

export const CellularEmporium = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const { abilities } = data;
  return (
    <Fragment>
      <Section>
        <LabeledList>
          <LabeledList.Item
            label="Genetic Points"
            buttons={(
              <Button
                icon="undo"
                content="Readapt"
                disabled={!data.can_readapt}
                onClick={() => act(ref, 'readapt')}
              />
            )}>
            {data.genetic_points_remaining}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section>
        <LabeledList>
          {abilities.map(ability => (
            <LabeledList.Item
              key={ability.name}
              className="candystripe"
              label={ability.name}
              buttons={(
                <Fragment>
                  {ability.dna_cost}
                  {' '}
                  <Button
                    content={ability.owned ? 'Evolved' : 'Evolve'}
                    selected={ability.owned}
                    onClick={() => act(ref, 'evolve', {name: ability.name})}
                  />
                </Fragment>
              )}>
              {ability.desc}
              <Box color="good">
                {ability.helptext}
              </Box>
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Section>
    </Fragment>
  );
};
