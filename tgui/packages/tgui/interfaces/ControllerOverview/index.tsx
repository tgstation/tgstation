import { useEffect, useReducer } from 'react';

import { Button, Dropdown, Input, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { SORTING_TYPES } from './contants';
import { FilterAction, filterReducer } from './filters';
import { OverviewSection } from './OverviewSection';
import { SubsystemViews } from './SubsystemViews';
import { SortType } from './types';

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
    query: '',
    smallValues: false,
    sortType: SortType.Name,
  });

  const selected = SORTING_TYPES?.[state.sortType] || SORTING_TYPES[0];
  const { label, useBars } = selected;

  useEffect(() => {
    if (useBars && state.ascending) {
      dispatch({ type: FilterAction.Ascending, payload: false });
    } else if (!useBars && !state.ascending) {
      dispatch({ type: FilterAction.Ascending, payload: true });
    }
  }, [state.sortType]);

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
                      dispatch({ type: FilterAction.Query, payload: value })
                    }
                    placeholder="By name"
                    value={state.query}
                    width="85%"
                  />
                  <Button
                    icon="trash"
                    tooltip="Reset filter"
                    onClick={() =>
                      dispatch({ type: FilterAction.Query, payload: '' })
                    }
                    disabled={!state.query}
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
                    options={SORTING_TYPES.map((type) => type.label)}
                    selected={label}
                    displayText={label}
                    onSelected={(value) =>
                      dispatch({
                        type: FilterAction.SortType,
                        payload: SORTING_TYPES.findIndex(
                          (type) => type.label === value,
                        ),
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
