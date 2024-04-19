import { createSearch } from 'common/string';
import { useEffect, useMemo, useState } from 'react';

import { useBackend } from '../../backend';
import { Button, Section } from '../../components';
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

  const { propName, useBars } = SORTING_TYPES[filterOpts.sortType];

  const [bars, setBars] = useState(useBars);

  // Subsystems sorted and filtered if applicable
  const toDisplay = useMemo(() => {
    const subsystemsToSort = subsystems
      .filter(createSearch(filterOpts.query, (subsystem) => subsystem.name))
      .sort((a, b) => {
        if (filterOpts.ascending) {
          return a[propName] - b[propName];
        } else {
          return b[propName] - a[propName];
        }
      });

    return subsystemsToSort;
  }, [filterOpts.ascending, filterOpts.query, filterOpts.sortType]);

  // Gets our totals for bar display
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
        if (filterOpts.inactive && subsystem.doesnt_fire) return;

        if (bars && useBars) {
          return (
            <SubsystemBar
              key={subsystem.ref}
              max={currentMax}
              subsystem={subsystem}
              value={subsystem[propName]}
              filterSmall={filterOpts.smallValues}
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
