import { useLocalState } from 'tgui/backend';
import { Stack, Tabs } from 'tgui/components';
import { Window } from 'tgui/layouts';
import { AvailableDisplay } from './Available';
import { DirectiveDisplay } from './Directives';
import { InstalledDisplay } from './Installed';
import { SystemDisplay } from './System';
import { PaiTab } from './types';

/**
 * Parent component. Yes tabs are INTENTIONALLY at the bottom. It's an
 * android phone screen!
 */
export const PaiInterface = (props, context) => {
  const [tab, setTab] = useLocalState<PaiTab>(context, 'tab', 'System');

  return (
    <Window title="pAI Software Interface v2.5" width={380} height={480}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            {tab === 'System' && <SystemDisplay />}
            {tab === 'Directive' && <DirectiveDisplay />}
            {tab === 'Installed' && <InstalledDisplay />}
            {tab === 'Available' && <AvailableDisplay />}
          </Stack.Item>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="list"
                onClick={() => setTab('System')}
                selected={tab === 'System'}>
                System
              </Tabs.Tab>
              <Tabs.Tab
                icon="list"
                onClick={() => setTab('Directive')}
                selected={tab === 'Directive'}>
                Directives
              </Tabs.Tab>
              <Tabs.Tab
                icon="list"
                onClick={() => setTab('Installed')}
                selected={tab === 'Installed'}>
                Installed
              </Tabs.Tab>
              <Tabs.Tab
                icon="list"
                onClick={() => setTab('Available')}
                selected={tab === 'Available'}>
                Download
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
