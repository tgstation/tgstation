import { useState } from 'react';
import { Stack, Tabs } from 'tgui/components';
import { Window } from 'tgui/layouts';

import { AvailableDisplay } from './Available';
import { PAI_TAB } from './constants';
import { DirectiveDisplay } from './Directives';
import { InstalledDisplay } from './Installed';
import { SystemDisplay } from './System';

export function PaiInterface(props) {
  const [tab, setTab] = useState(PAI_TAB.System);

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
            <Tabs fluid>
              <Tabs.Tab
                icon="list"
                onClick={() => setTab(PAI_TAB.System)}
                selected={tab === PAI_TAB.System}
              >
                System
              </Tabs.Tab>
              <Tabs.Tab
                icon="list"
                onClick={() => setTab(PAI_TAB.Directive)}
                selected={tab === PAI_TAB.Directive}
              >
                Directives
              </Tabs.Tab>
              <Tabs.Tab
                icon="list"
                onClick={() => setTab(PAI_TAB.Installed)}
                selected={tab === PAI_TAB.Installed}
              >
                Installed
              </Tabs.Tab>
              <Tabs.Tab
                icon="list"
                onClick={() => setTab(PAI_TAB.Available)}
                selected={tab === PAI_TAB.Available}
              >
                Download
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
