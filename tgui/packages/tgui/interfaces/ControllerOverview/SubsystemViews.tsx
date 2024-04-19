import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { createSearch } from 'common/string';
import { useEffect, useMemo, useState } from 'react';

import { useBackend } from '../../backend';
import { Button, Section } from '../../components';
import { SORTING_TYPES } from './contants';
import { FilterState } from './filters';
import { SubsystemBar } from './SubsystemBar';
import { SubsystemCollapsible } from './SubsystemCollapsible';
import { ControllerData, SubsystemData } from './types';

type Props = {
  filterOpts: FilterState;
};

export function SubsystemViews(props: Props) {
  const { data } = useBackend<ControllerData>();
  const { subsystems } = data;
  const { filterOpts } = props;

  const selected = SORTING_TYPES[filterOpts.sortType];
  const { propName, useBars } = selected;

  const [bars, setBars] = useState(useBars);

  // Filter and sort subsystems
  const toDisplay = useMemo(() => {
    const subsystemsToSort = flow([
      (toFilter) =>
        filterOpts.query &&
        filter(
          subsystems,
          createSearch(
            filterOpts.query,
            (subsystem: SubsystemData) => subsystem.name,
          ),
        ),
      (toSort) => sortBy(toSort, (input: SubsystemData) => input[propName]),
    ])(subsystems);

    if (!filterOpts.ascending) {
      subsystemsToSort.reverse();
    }

    return subsystemsToSort;
  }, [filterOpts.ascending, filterOpts.query, filterOpts.sortType]);

  const totals: number[] = [];
  let currentMax = 0;
  if (useBars) {
    for (let i = 0; i < toDisplay.length; i++) {
      const value = toDisplay[i][propName];
      if (typeof value !== 'number') {
        continue;
      }
      totals.push(value);
    }

    currentMax = Math.max(...totals);
  }

  useEffect(() => {
    if (useBars && !bars) {
      setBars(true);
    } else if (!useBars && bars) {
      setBars(false);
    }
  }, [useBars]);

  return (
    <Section
      fill
      scrollable
      title="Subsystem Overview"
      buttons={
        <Button
          disabled={!useBars}
          icon="bars"
          onClick={() => setBars(!bars)}
          selected={bars}
        >
          Bars
        </Button>
      }
    >
      {toDisplay.map((subsystem) => {
        if (bars && useBars) {
          return (
            <SubsystemBar
              filterInactive={filterOpts.inactive}
              filterSmall={filterOpts.smallValues}
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
