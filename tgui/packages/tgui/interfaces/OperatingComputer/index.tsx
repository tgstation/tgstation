import '../../styles/interfaces/OperatingComputer.scss';

import { Section, Stack, Tabs } from 'tgui-core/components';
import { useFuzzySearch } from 'tgui-core/fuzzysearch';
import { useBackend, useSharedState } from '../../backend';
import { Window } from '../../layouts';
import { ExperimentView } from './ExperimentView';
import { PatientStateView } from './PatientStateView';
import { SurgeryProceduresView } from './SurgeryProceduresView';
import {
  ComputerTabs,
  type OperatingComputerData,
  type OperationData,
} from './types';

export const OperatingComputer = () => {
  const [tab, setTab] = useSharedState('tab', 1);
  const { data } = useBackend<OperatingComputerData>();
  const { surgeries } = data;

  const { query, setQuery, results } = useFuzzySearch({
    searchArray: surgeries,
    matchStrategy: 'aggressive',
    getSearchString: (item: OperationData) => `${item.name} ${item.tool_rec}`,
  });

  const [pinnedOperations, setPinnedOperations] = useSharedState<string[]>(
    'pinned_operation',
    [],
  );

  return (
    <Window
      width={tab === ComputerTabs.PatientState ? 350 : 430}
      height={610}
      theme="operating_computer"
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                selected={tab === ComputerTabs.PatientState}
                onClick={() => setTab(1)}
              >
                Patient State
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === ComputerTabs.OperationCatalog}
                onClick={() => setTab(2)}
              >
                Operation Catalog
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === ComputerTabs.Experiments}
                onClick={() => setTab(3)}
              >
                Experiments
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === ComputerTabs.PatientState && (
              <PatientStateView
                setTab={setTab}
                setSearchText={setQuery}
                pinnedOperations={pinnedOperations}
                setPinnedOperations={setPinnedOperations}
              />
            )}
            {tab === ComputerTabs.OperationCatalog && (
              <SurgeryProceduresView
                searchedSurgeries={results}
                searchText={query}
                setSearchText={setQuery}
                pinnedOperations={pinnedOperations}
                setPinnedOperations={setPinnedOperations}
              />
            )}
            {tab === ComputerTabs.Experiments && <ExperimentView />}
          </Stack.Item>
          <Stack.Item textAlign="right" color="label" fontSize="0.7em">
            <Section>
              DefOS 1.0 &copy; Nanotrasen-Deforest Corporation. All rights
              reserved.
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
