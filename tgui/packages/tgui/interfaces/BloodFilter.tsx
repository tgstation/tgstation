import { useBackend } from '../backend';
import { Stack } from '../components';
import { Window } from '../layouts';
import { ChemFilterPane } from './ChemFilter';

type Data = {
  whitelist: string[];
};

export const BloodFilter = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { whitelist = [] } = data;

  return (
    <Window width={500} height={300}>
      <Window.Content scrollable>
        <Stack>
          <Stack.Item grow>
            <ChemFilterPane
              title="Whitelist"
              list={whitelist}
              btitle="Blood White List"
              bcolor="red"
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
