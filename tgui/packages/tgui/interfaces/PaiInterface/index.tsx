import { useLocalState } from 'tgui/backend';
import { Stack, Tabs } from 'tgui/components';
import { Window } from 'tgui/layouts';
import { PAI_TAB } from './constants';
import { AvailableDisplay } from './Available';
import { DirectiveDisplay } from './Directives';
import { InstalledDisplay } from './Installed';
import { SystemDisplay } from './System';

export const PaiInterface = (props, context) => {
  const [tab] = useLocalState(context, 'tab', PAI_TAB.System);

  return (
    <Window title="pAI Software Interface v2.5" width={380} height={480}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            {tab === PAI_TAB.System && <SystemDisplay />}
            {tab === PAI_TAB.Directive && <DirectiveDisplay />}
            {tab === PAI_TAB.Installed && <InstalledDisplay />}
            {tab === PAI_TAB.Available && <AvailableDisplay />}
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
  const [tab, setTab] = useLocalState(context, 'tab', PAI_TAB.System);

  return (
    <Tabs fluid>
      <Tabs.Tab
        icon="list"
        onClick={() => setTab(PAI_TAB.System)}
        selected={tab === PAI_TAB.System}>
        System
      </Tabs.Tab>
      <Tabs.Tab
        icon="list"
        onClick={() => setTab(PAI_TAB.Directive)}
        selected={tab === PAI_TAB.Directive}>
        Directives
      </Tabs.Tab>
      <Tabs.Tab
        icon="list"
        onClick={() => setTab(PAI_TAB.Installed)}
        selected={tab === PAI_TAB.Installed}>
        Installed
      </Tabs.Tab>
      <Tabs.Tab
        icon="list"
        onClick={() => setTab(PAI_TAB.Available)}
        selected={tab === PAI_TAB.Available}>
        Download
      </Tabs.Tab>
    </Tabs>
  );
};
