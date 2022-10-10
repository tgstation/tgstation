import { useBackend, useLocalState } from '../backend';
import { Stack } from '../components';
import { Window } from '../layouts';
import { ChemFilterPane } from './ChemFilter';

type Data = {
  whitelist: string[];
};

export const BloodFilter = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { whitelist = [] } = data;
  const [chemName, setChemName] = useLocalState(context, 'chemName', '');

  return (
    <Window width={500} height={300}>
      <Window.Content scrollable>
        <Stack>
          <Stack.Item grow>
            <ChemFilterPane
              title="Whitelist"
              list={whitelist}
              reagentName={chemName}
              onReagentInput={(value) => setChemName(value)}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
