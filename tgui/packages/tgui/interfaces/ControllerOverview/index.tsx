import { useReducer } from 'react';

import { Button, Dropdown, Input, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { FilterAction, filterReducer } from './filters';
import { OverviewSection } from './OverviewSection';
import { SubsystemViews } from './SubsystemViews';
import { SubsystemSortBy } from './types';

export function ControllerOverview(props) {
  return (
    <Window title="Controller Overview" height={600} width={500}>
      <Window.Content>
        <ControllerContent />
      </Window.Content>
    </Window>
  );
}

export function ControllerContent(props) {
  const [state, dispatch] = useReducer(filterReducer, {
    ascending: true,
    inactive: false,
    name: '',
    smallValues: false,
    sortType: SubsystemSortBy.NAME,
  });

  return (
    <Stack fill vertical>
      <Stack.Item height="15%">
        <OverviewSection />
      </Stack.Item>
      <Stack.Item height="12%">
        <Section fill>
          <Stack justify="space-between">
            <Stack.Item grow mb={4}>
              <Stack fill vertical>
                <Stack.Item>
                  <Input
                    onInput={(e, value) =>
                      dispatch({ type: FilterAction.Name, payload: value })
                    }
                    placeholder="By name"
                    value={state.name}
                    width="85%"
                  />
                  <Button
                    icon="trash"
                    tooltip="Reset filter"
                    onClick={() =>
                      dispatch({ type: FilterAction.Name, payload: '' })
                    }
                    disabled={!state.name}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    selected={state.smallValues}
                    tooltip="Hide small values"
                    icon={state.smallValues ? 'eye-slash' : 'eye'}
                    onClick={() =>
                      dispatch({
                        type: FilterAction.SmallValues,
                        payload: !state.smallValues,
                      })
                    }
                  >
                    Small
                  </Button>
                  <Button
                    icon={state.inactive ? 'eye-slash' : 'eye'}
                    tooltip="Hide inactive"
                    selected={state.inactive}
                    onClick={() =>
                      dispatch({
                        type: FilterAction.Inactive,
                        payload: !state.inactive,
                      })
                    }
                  >
                    Inactive
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack vertical>
                <Stack.Item>
                  <Dropdown
                    options={Object.values(SubsystemSortBy)}
                    selected={state.sortType}
                    onSelected={(value) =>
                      dispatch({
                        type: FilterAction.SortType,
                        payload: value,
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    selected={state.ascending}
                    onClick={() =>
                      dispatch({
                        type: FilterAction.Ascending,
                        payload: !state.ascending,
                      })
                    }
                  >
                    Ascending
                  </Button>
                  <Button
                    selected={!state.ascending}
                    onClick={() =>
                      dispatch({
                        type: FilterAction.Ascending,
                        payload: !state.ascending,
                      })
                    }
                  >
                    Descending
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <SubsystemViews filterOpts={state} />
      </Stack.Item>
    </Stack>
  );
}
