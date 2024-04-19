import { useEffect, useMemo, useState } from 'react';

import { useBackend } from '../../backend';
import { Button, Section, Stack } from '../../components';
import { SORTING_TYPES } from './contants';
import { FilterState } from './filters';
import { SubsystemBar } from './SubsystemBar';
import { SubsystemCollapsible } from './SubsystemCollapsible';
import { ControllerData } from './types';

type Props = {
  filterOpts: FilterState;
};

export function SubsystemViews(props: Props) {
  const { data } = useBackend<ControllerData>();
  const { subsystems } = data;

  const { filterOpts } = props;
  const { ascending, inactive, query, smallValues, sortType } = filterOpts;
  const { propName, inDeciseconds } = SORTING_TYPES[sortType];

  const [bars, setBars] = useState(inDeciseconds);

  // Subsystems sorted and filtered if applicable
  const toDisplay = useMemo(() => {
    const subsystemsToSort = subsystems
      // Why not use the collections functions?
      // They dont work in reverse and thus lose their performance benefit
      // It also ends up looking insane

      .filter((subsystem) => {
        const nameMatchesQuery = subsystem.name
          .toLowerCase()
          .includes(query?.toLowerCase());

        if (inactive && !!subsystem.doesnt_fire) {
          return false;
        }

        if (smallValues && subsystem[propName] < 1) {
          return false;
        }

        return nameMatchesQuery;
      })
      .sort((a, b) => {
        if (ascending) {
          return a[propName] - b[propName];
        } else {
          return b[propName] - a[propName];
        }
      });

    return subsystemsToSort;
  }, [filterOpts]);

  // Gets our totals for bar display
  const totals: number[] = [];
  let currentMax = 0;
  let sum = 0;
  if (inDeciseconds) {
    for (let i = 0; i < toDisplay.length; i++) {
      let value = toDisplay[i][propName];
      if (typeof value !== 'number') {
        continue;
      }

      sum += value;
      totals.push(value);
    }

    let max = Math.max(...totals);
    if (max !== sum) {
      currentMax = max;
    }
  }

  useEffect(() => {
    if (inDeciseconds && !bars) {
      setBars(true);
    } else if (!inDeciseconds && bars) {
      setBars(false);
    }
  }, [inDeciseconds]);

  return (
    <Section
      fill
      scrollable
      title="Subsystem Overview"
      buttons={
        <Stack align="center">
          <Stack.Item color="label">
            ({toDisplay.length} / {subsystems.length})
          </Stack.Item>
          <Stack.Item>
            <Button
              disabled={!inDeciseconds}
              icon="bars"
              onClick={() => setBars(!bars)}
              selected={bars}
            >
              Bars
            </Button>
          </Stack.Item>
        </Stack>
      }
    >
      {toDisplay.map((subsystem) => {
        if (bars && inDeciseconds) {
          return (
            <SubsystemBar
              key={subsystem.ref}
              max={currentMax}
              subsystem={subsystem}
              value={subsystem[propName]}
            />
          );
        }
        return (
          <SubsystemCollapsible key={subsystem.ref} subsystem={subsystem} />
        );
      })}
    </Section>
  );
}
