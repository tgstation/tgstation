import { sortBy } from 'es-toolkit';
import { Component } from 'react';
import { Button, KeyListener, Stack } from 'tgui-core/components';
import { KEY_DOWN, KEY_ENTER, KEY_UP } from 'tgui-core/keycodes';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type BodyZone, BodyZoneSelector } from './common/BodyZoneSelector';

type Surgery = {
  name: string;
  blocked?: BooleanLike;
};

type SurgeryInitiatorData = {
  selected_zone: BodyZone;
  surgeries: Surgery[];
  target_name: string;
};

const sortSurgeries = (array: Surgery[]) =>
  sortBy(array, [(surgery) => surgery.name]);

type SurgeryInitiatorInnerState = {
  selectedSurgeryIndex: number;
};

class SurgeryInitiatorInner extends Component<
  SurgeryInitiatorData,
  SurgeryInitiatorInnerState
> {
  state = {
    selectedSurgeryIndex: 0,
  };

  componentDidMount() {
    this.updateSelectedSurgeryIndexState();
  }

  componentDidUpdate(prevProps: SurgeryInitiatorData) {
    if (prevProps.selected_zone !== this.props.selected_zone) {
      this.updateSelectedSurgeryIndexState();
    }
  }

  updateSelectedSurgeryIndexState() {
    this.setState({
      selectedSurgeryIndex: this.findSelectedSurgeryAfter(-1) || 0,
    });
  }

  findSelectedSurgeryAfter(after: number): number | undefined {
    const foundIndex = this.props.surgeries.findIndex(
      (surgery, index) => index > after && !surgery.blocked,
    );

    return foundIndex === -1 ? undefined : foundIndex;
  }

  findSelectedSurgeryBefore(before: number): number | undefined {
    for (let index = before; index >= 0; index--) {
      const surgery = this.props.surgeries[index];
      if (!surgery.blocked) {
        return index;
      }
    }

    return undefined;
  }

  render() {
    const { act } = useBackend<SurgeryInitiatorData>();
    const { selected_zone, surgeries, target_name } = this.props;

    return (
      <Window width={400} height={350} title={`Surgery on ${target_name}`}>
        <Window.Content scrollable>
          <Stack fill height="100%">
            <Stack.Item width="30%">
              <BodyZoneSelector
                onClick={(zone) => act('change_zone', { new_zone: zone })}
                selectedZone={selected_zone}
              />
            </Stack.Item>

            <Stack.Item width="95%">
              <Stack vertical height="100%">
                {surgeries.map((surgery, index) => (
                  <Button
                    onClick={() => {
                      act('start_surgery', {
                        surgery_name: surgery.name,
                      });
                    }}
                    disabled={surgery.blocked}
                    selected={index === this.state.selectedSurgeryIndex}
                    tooltip={
                      surgery.blocked ? 'Their body is covered!' : undefined
                    }
                    key={surgery.name}
                    fluid
                  >
                    {surgery.name}
                  </Button>
                ))}
              </Stack>
            </Stack.Item>
          </Stack>

          <KeyListener
            onKeyDown={(event) => {
              const keyCode = event.code;
              const surgery = surgeries[this.state.selectedSurgeryIndex];

              switch (keyCode) {
                case KEY_DOWN:
                  this.setState((state) => {
                    return {
                      selectedSurgeryIndex:
                        this.findSelectedSurgeryAfter(
                          state.selectedSurgeryIndex,
                        ) ||
                        this.findSelectedSurgeryAfter(-1) ||
                        0,
                    };
                  });

                  break;
                case KEY_UP:
                  this.setState((state) => {
                    return {
                      selectedSurgeryIndex:
                        this.findSelectedSurgeryBefore(
                          state.selectedSurgeryIndex - 1,
                        ) ??
                        this.findSelectedSurgeryBefore(
                          this.props.surgeries.length - 1,
                        ) ??
                        0,
                    };
                  });

                  break;
                case KEY_ENTER:
                  if (surgery) {
                    act('start_surgery', {
                      surgery_name: surgery.name,
                    });
                  }

                  break;
              }
            }}
          />
        </Window.Content>
      </Window>
    );
  }
}

export const SurgeryInitiator = (props) => {
  const { data } = useBackend<SurgeryInitiatorData>();

  return (
    <SurgeryInitiatorInner
      selected_zone={data.selected_zone}
      surgeries={sortSurgeries(data.surgeries)}
      target_name={data.target_name}
    />
  );
};
