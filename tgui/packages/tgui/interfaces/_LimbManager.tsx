import { Component, createRef } from 'react';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { BlockQuote, Button, Image, Section, Stack } from '../components';
import { Connections } from './common/Connections';

const makeCategoryReadable = (cat: string | null): string | null => {
  switch (cat) {
    case 'chest':
      return 'Chest';
    case 'head':
      return 'Head';
    case 'l_arm':
      return 'Left Arm';
    case 'r_arm':
      return 'Right Arm';
    case 'l_leg':
      return 'Left Leg';
    case 'r_leg':
      return 'Right Leg';
    default:
      return null;
  }
};

const findCatInXYRange = (x: number, y: number): string | null => {
  if (y <= 72) {
    if (x >= 70 && x <= 150) {
      return 'head';
    }
  } else if (y <= 163) {
    if (x >= 47 && x <= 80) {
      return 'r_arm';
    } else if (x >= 81 && x <= 139) {
      return 'chest';
    } else if (x >= 140 && x <= 175) {
      return 'l_arm';
    }
  } else if (x >= 60 && x <= 109) {
    return 'r_leg';
  } else if (x >= 110 && x <= 159) {
    return 'l_leg';
  }
  return null;
};

const listPos = { x: 240, y: 50 };

const catToPos = (cat: string | null): { x: number; y: number } => {
  switch (cat) {
    case 'chest':
      return { x: 115, y: 110 };
    case 'head':
      return { x: 115, y: 50 };
    case 'l_arm':
      return { x: 165, y: 120 };
    case 'r_arm':
      return { x: 65, y: 120 };
    case 'l_leg':
      return { x: 130, y: 190 };
    case 'r_leg':
      return { x: 95, y: 190 };
    default:
      return { x: -1, y: -1 };
  }
};

const getActiveCategory = (
  limbs: LimbCategory[],
  cat: string | null,
): LimbCategory | null => {
  if (!cat) {
    return null;
  }
  for (const limb_category of limbs) {
    if (limb_category.category_name === cat) {
      return limb_category;
    }
  }
  return null;
};

type Data = {
  limbs: LimbCategory[];
  selected_limbs: string[] | null;
  preview_flat_icon: string;
};

type LimbCategory = {
  category_name: string;
  category_data: Limb[];
};

type Limb = {
  name: string;
  tooltip: string;
  path: string;
};

const LimbSelectButton = (props: {
  select_limb: Limb;
  selected_limbs: string[] | null;
}) => {
  const { act, data } = useBackend<Limb>();
  const { select_limb, selected_limbs } = props;
  const is_active = selected_limbs?.includes(select_limb.path);
  return (
    <Button.Checkbox
      checked={is_active}
      content={select_limb.name}
      tooltip={select_limb.tooltip}
      tooltipPosition="right"
      onClick={() =>
        act(is_active ? 'deselect_path' : 'select_path', {
          path_to_use: select_limb.path,
        })
      }
    />
  );
};

const DisplayLimbs = (props: {
  selected_limbs: string[] | null;
  limbs: LimbCategory[];
  current_selection: string | null;
}) => {
  const { data } = useBackend<LimbCategory>();
  const { selected_limbs, limbs, current_selection } = props;

  const limb_category = getActiveCategory(limbs, current_selection);

  return (
    <Stack vertical fill>
      {limb_category ? (
        <Stack.Item>
          <Section title={makeCategoryReadable(limb_category.category_name)}>
            <Stack vertical>
              {limb_category.category_data.length ? (
                limb_category.category_data.map((limb, index) => (
                  <Stack.Item key={index}>
                    <LimbSelectButton
                      select_limb={limb}
                      selected_limbs={selected_limbs}
                    />
                  </Stack.Item>
                ))
              ) : (
                <Stack.Item>
                  <BlockQuote>No limbs available for this bodypart.</BlockQuote>
                </Stack.Item>
              )}
            </Stack>
          </Section>
        </Stack.Item>
      ) : (
        <Stack.Item>
          {' '}
          <BlockQuote>Click on a body part to select it.</BlockQuote>{' '}
        </Stack.Item>
      )}
    </Stack>
  );
};

type PreviewProps = {
  preview_flat_icon: string;
  selected: string | null;
  onSelect?: (selected: string | null) => void;
};

type PreviewState = {
  mouseX: number;
  mouseY: number;
};

class LimbPreview extends Component<PreviewProps, PreviewState> {
  ref = createRef<HTMLDivElement>();
  state: PreviewState = {
    mouseX: -1,
    mouseY: -1,
  };

  render() {
    const { mouseX, mouseY } = this.state;
    const { preview_flat_icon, selected, onSelect } = this.props;

    const current_cat = findCatInXYRange(mouseX, mouseY);

    const width = '224px';
    const height = '224px';

    const updateXYState = (event) => {
      const rect = this.ref.current?.getBoundingClientRect();
      if (!rect) {
        return { x: -1, y: -1 };
      }
      const newX = event.clientX - rect.left;
      const newY = event.clientY - rect.top;
      this.setState({
        mouseX: newX,
        mouseY: newY,
      });

      return { x: newX, y: newY };
    };

    return (
      <Stack vertical fill>
        <Stack.Item grow>
          <div
            ref={this.ref}
            style={{
              width: '100%',
              height: '100%',
              position: 'relative',
              zIndex: 1,
            }}
          >
            <Image
              m={1}
              src={`data:image/jpeg;base64,${preview_flat_icon}`}
              height={width}
              width={height}
              style={{
                position: 'absolute',
                zIndex: '1',
              }}
              onClick={(event) => {
                const { x, y } = updateXYState(event);
                if (onSelect) {
                  onSelect(findCatInXYRange(x, y));
                }
              }}
              onMouseMove={(event) => {
                updateXYState(event);
              }}
            />
            {selected && (
              <Image
                m={1}
                src={resolveAsset(`body_zones.${selected}.png`)}
                height={width}
                width={height}
                style={{
                  pointerEvents: 'none',
                  position: 'absolute',
                  zIndex: '3',
                }}
              />
            )}
            {current_cat && current_cat !== selected && (
              <Image
                m={1}
                src={resolveAsset(`body_zones.${current_cat}.png`)}
                height={width}
                width={height}
                style={{
                  pointerEvents: 'none',
                  position: 'absolute',
                  zIndex: '2',
                  opacity: '0.5',
                }}
              />
            )}
          </div>
        </Stack.Item>
      </Stack>
    );
  }
}

type LimbManagerInnerProps = {
  limbs: LimbCategory[];
  selected_limbs: string[] | null;
  preview_flat_icon: string;
};

type LimbManagerInnerState = {
  current_selection: string | null;
};

type ConnectionType = {
  // This should be removed when upstream happens
  color?: string;
  from: { x: number; y: number };
  to: { x: number; y: number };
};

class LimbManagerInner extends Component<
  LimbManagerInnerProps,
  LimbManagerInnerState
> {
  ref = createRef<HTMLDivElement>();
  state: LimbManagerInnerState = {
    current_selection: null,
  };

  render() {
    const { current_selection } = this.state;
    const { limbs, selected_limbs, preview_flat_icon } = this.props;

    const connections: ConnectionType[] = [];
    if (current_selection) {
      const newPos = catToPos(current_selection);
      newPos.x = newPos.x + 8;
      newPos.y = newPos.y + 48;
      const newConnection: ConnectionType = {
        color: 'red',
        from: newPos,
        to: listPos,
      };

      connections.push(newConnection);
    }

    return (
      <>
        <Connections connections={connections} zLayer={4} lineWidth={4} />
        <Stack height="300px">
          <Stack.Item width={20}>
            <Section title="Preview" fill align="center">
              <LimbPreview
                preview_flat_icon={preview_flat_icon}
                selected={current_selection}
                onSelect={(new_selection) =>
                  this.setState({ current_selection: new_selection })
                }
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section title="Augments" fill scrollable>
              <DisplayLimbs
                current_selection={current_selection}
                limbs={limbs}
                selected_limbs={selected_limbs}
              />
            </Section>
          </Stack.Item>
        </Stack>
      </>
    );
  }
}

export const LimbManagerPage = (props) => {
  const { act, data } = useBackend<Data>();
  const { limbs, selected_limbs, preview_flat_icon } = data;

  return (
    <LimbManagerInner
      limbs={limbs}
      selected_limbs={selected_limbs}
      preview_flat_icon={preview_flat_icon}
    />
  );
};
