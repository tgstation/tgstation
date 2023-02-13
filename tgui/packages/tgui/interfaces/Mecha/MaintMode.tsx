import { MaintData } from './data';
import { useBackend, useLocalState } from '../../backend';
import { Stack, Button, Box } from '../../components';

const MECHA_MAINT_PANELS = {
  main: {
    returnfluff: '',
    component: () => MainPanel,
  },
  stockparts: {
    returnfluff: 'Close stock parts panel',
    component: () => StockPartsPanel,
  },
  access: {
    returnfluff: 'Close permissions panel',
    component: () => AccessPanel,
  },
};

export const MaintMode = (props, context) => {
  const [screen, setPanel] = useLocalState(
    context,
    'screen',
    MECHA_MAINT_PANELS.main
  );
  const Component = screen.component();
  return (
    <Stack fill vertical>
      <Stack.Item>
        {screen.returnfluff ? (
          <Button
            fluid
            bold
            content={screen.returnfluff}
            textAlign="center"
            fontSize="200%"
            lineHeight={1.25}
            className="Mecha__Button"
            onClick={() => setPanel(MECHA_MAINT_PANELS.main)}
          />
        ) : null}
      </Stack.Item>
      <Stack.Item>
        <Component />
      </Stack.Item>
    </Stack>
  );
};

const MainPanel = (props, context) => {
  const { act, data } = useBackend<MaintData>(context);
  const [screen, setPanel] = useLocalState(
    context,
    'screen',
    MECHA_MAINT_PANELS.main
  );
  const { mecha_flags, mechflag_keys } = data;
  return (
    <Stack fill vertical>
      {mecha_flags & mechflag_keys['ADDING_MAINT_ACCESS_POSSIBLE'] ? (
        <MaintEnabled />
      ) : null}
      <Stack.Item>
        {mecha_flags & mechflag_keys['ADDING_ACCESS_POSSIBLE'] ? (
          <Button
            fluid
            bold
            content={'Open Access Panel'}
            textAlign="center"
            fontSize="200%"
            lineHeight={1.25}
            className="Mecha__Button"
            onClick={() => setPanel(MECHA_MAINT_PANELS.access)}
          />
        ) : null}
      </Stack.Item>
    </Stack>
  );
};

const MaintEnabled = (props, context) => {
  const { act, data } = useBackend<MaintData>(context);
  const [screen, setPanel] = useLocalState(
    context,
    'screen',
    MECHA_MAINT_PANELS.main
  );
  return (
    <>
      <Stack.Item>
        <Button
          fluid
          bold
          content={'Disable Maintenance'}
          textAlign="center"
          fontSize="200%"
          lineHeight={1.25}
          className="Mecha__ButtonDanger"
          onClick={() => act('stopmaint')}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          bold
          content={'Manage Stock Parts'}
          textAlign="center"
          fontSize="200%"
          lineHeight={1.25}
          className="Mecha__Button"
          onClick={() => setPanel(MECHA_MAINT_PANELS.stockparts)}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          bold
          content={'Set cabin pressure'}
          textAlign="center"
          fontSize="200%"
          lineHeight={1.25}
          className="Mecha__Button"
          onClick={() => act('set_pressure')}
        />
      </Stack.Item>
    </>
  );
};

const StockPartsPanel = (props, context) => {
  const { act, data } = useBackend<MaintData>(context);
  const { cell, scanning, capacitor } = data;
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Button
          fluid
          bold
          content={'Toggle part replacement'}
          textAlign="center"
          fontSize="200%"
          lineHeight={1.25}
          className="Mecha__ButtonDanger"
          onClick={() => act('togglemaint')}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          bold
          content={'Eject cell - ' + cell}
          textAlign="center"
          fontSize="200%"
          lineHeight={1.25}
          className="Mecha__Button"
          onClick={() => act('drop_cell')}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          bold
          content={'Eject scanning - ' + scanning}
          textAlign="center"
          fontSize="200%"
          lineHeight={1.25}
          className="Mecha__Button"
          onClick={() => act('drop_scanning')}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          bold
          content={'Eject capacitor - ' + capacitor}
          textAlign="center"
          fontSize="200%"
          lineHeight={1.25}
          className="Mecha__Button"
          onClick={() => act('drop_capacitor')}
        />
      </Stack.Item>
    </Stack>
  );
};

const AccessPanel = (props, context) => {
  const { act, data } = useBackend<MaintData>(context);
  const { idcard_access, operation_req_access } = data;
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Button
          fluid
          bold
          content={'Lock permissions panel'}
          textAlign="center"
          fontSize="200%"
          lineHeight={1.25}
          className="Mecha__ButtonDanger"
          onClick={() => act('lock_req_edit')}
        />
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <Stack.Item grow={1}>
            <Button
              fluid
              bold
              content="Remove requirements"
              textAlign="center"
              fontSize="200%"
              lineHeight={1.25}
              className="Mecha__Button"
              onClick={() => act('del_req_access', { removed_access: 'all' })}
            />
          </Stack.Item>
          <Stack.Item grow={1}>
            <Button
              fluid
              bold
              content="Add all from ID"
              textAlign="center"
              fontSize="200%"
              lineHeight={1.25}
              className="Mecha__Button"
              onClick={() => act('add_req_access', { added_access: 'all' })}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      {operation_req_access.map((code, i) => (
        <Stack.Item key={code.name}>
          <Stack fill>
            <Stack.Item grow={1}>
              <Box className="Mecha__displayBoxRed">{code.name}</Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                bold
                content="Del"
                textAlign="center"
                fontSize="200%"
                lineHeight={1.25}
                className="Mecha__ButtonDanger"
                onClick={() =>
                  act('del_req_access', { removed_access: code.number })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
      {idcard_access.map((code, i) => (
        <Stack.Item key={code.name}>
          <Stack fill>
            <Stack.Item grow={1}>
              <Box className="Mecha__displayBox">{code.name}</Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                bold
                content="Add"
                textAlign="center"
                fontSize="200%"
                lineHeight={1.25}
                className="Mecha__Button"
                onClick={() =>
                  act('add_req_access', { added_access: code.number })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  );
};
