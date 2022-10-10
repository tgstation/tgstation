import { useLocalState } from 'tgui/backend';
import { Stack, Tabs } from 'tgui/components';
import { Window } from 'tgui/layouts';
import { TAB } from './constants';
import { AvailableDisplay } from './Available';
import { DirectiveDisplay } from './Directives';
import { InstalledDisplay } from './Installed';
import { SystemDisplay } from './System';
import { Data } from './types';

export const PaiInterface = (props, context: Data) => {
  const [tab, setTab] = useLocalState(context, 'tab', TAB.System);

  return (
    <Window title="pAI Software Interface v2.5" width={380} height={480}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            {tab === TAB.System && <SystemDisplay />}
            {tab === TAB.Directive && <DirectiveDisplay />}
            {tab === TAB.Installed && <InstalledDisplay />}
            {tab === TAB.Available && <AvailableDisplay />}
          </Stack.Item>
          <Stack.Item>
            <TabDisplay />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/**
 * Tabs at bottom of screen. YES THIS IS INTENTIONAL. It's a phone screen
 * and the buttons are on the bottom. Android!
 */
const TabDisplay = (props, context) => {
  const [tab, setTab] = useLocalState(context, 'tab', TAB.System);

  return (
    <Tabs fluid>
      <Tabs.Tab
        icon="list"
        onClick={() => setTab(TAB.System)}
        selected={tab === TAB.System}>
        System
      </Tabs.Tab>
      <Tabs.Tab
        icon="list"
        onClick={() => setTab(TAB.Directive)}
        selected={tab === TAB.Directive}>
        Directives
      </Tabs.Tab>
      <Tabs.Tab
        icon="list"
        onClick={() => setTab(TAB.Installed)}
        selected={tab === TAB.Installed}>
        Installed
      </Tabs.Tab>
      <Tabs.Tab
        icon="list"
        onClick={() => setTab(TAB.Available)}
        selected={tab === TAB.Available}>
        Download
      </Tabs.Tab>
    </Tabs>
  );
};
