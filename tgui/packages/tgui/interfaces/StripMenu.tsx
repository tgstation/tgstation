import { range } from "common/collections";
import { BooleanLike } from "common/react";
import { resolveAsset } from "../assets";
import { useBackend } from "../backend";
import { Box, Button, Icon, Stack } from "../components";
import { Window } from "../layouts";

const ROWS = 5;
const COLUMNS = 6;

const BUTTON_DIMENSIONS = "50px";

type GridSpotKey = string;

const getGridSpotKey = (spot: [number, number]): GridSpotKey => {
  return `${spot[0]}/${spot[1]}`;
};

const CornerText = (props: {
  align: "left" | "right";
  children: string;
}): JSX.Element => {
  const { align, children } = props;

  return (
    <Box
      style={{
        position: "relative",
        left: align === "left" ? "2px" : "-2px",
        "text-align": align,
        "text-shadow": "1px 1px 1px #555",
      }}
    >
      {children}
    </Box>
  );
};

type AlternateAction = {
  icon: string;
  text: string;
};

const ALTERNATE_ACTIONS: Record<string, AlternateAction> = {
  knot: {
    icon: "shoe-prints",
    text: "Knot",
  },

  untie: {
    icon: "shoe-prints",
    text: "Untie",
  },

  unknot: {
    icon: "shoe-prints",
    text: "Unknot",
  },

  enable_internals: {
    icon: "tg-air-tank",
    text: "Enable internals",
  },

  disable_internals: {
    icon: "tg-air-tank-slash",
    text: "Disable internals",
  },

  adjust_jumpsuit: {
    icon: "tshirt",
    text: "Adjust jumpsuit",
  },
};

const SLOTS: Record<
  string,
  {
    displayName: string;
    gridSpot: GridSpotKey;
    image?: string;
    additionalComponent?: JSX.Element;
  }
> = {
  eyes: {
    displayName: "eyewear",
    gridSpot: getGridSpotKey([0, 1]),
    image: "inventory-glasses.png",
  },

  head: {
    displayName: "headwear",
    gridSpot: getGridSpotKey([0, 2]),
    image: "inventory-head.png",
  },

  neck: {
    displayName: "neckwear",
    gridSpot: getGridSpotKey([1, 1]),
    image: "inventory-neck.png",
  },

  mask: {
    displayName: "mask",
    gridSpot: getGridSpotKey([1, 2]),
    image: "inventory-mask.png",
  },

  corgi_collar: {
    displayName: "collar",
    gridSpot: getGridSpotKey([1, 2]),
    image: "inventory-collar.png",
  },

  ears: {
    displayName: "earwear",
    gridSpot: getGridSpotKey([1, 3]),
    image: "inventory-ears.png",
  },

  parrot_headset: {
    displayName: "headset",
    gridSpot: getGridSpotKey([1, 3]),
    image: "inventory-ears.png",
  },

  handcuffs: {
    displayName: "handcuffs",
    gridSpot: getGridSpotKey([1, 4]),
  },

  legcuffs: {
    displayName: "legcuffs",
    gridSpot: getGridSpotKey([1, 5]),
  },

  jumpsuit: {
    displayName: "uniform",
    gridSpot: getGridSpotKey([2, 1]),
    image: "inventory-uniform.png",
  },

  suit: {
    displayName: "suit",
    gridSpot: getGridSpotKey([2, 2]),
    image: "inventory-suit.png",
  },

  gloves: {
    displayName: "gloves",
    gridSpot: getGridSpotKey([2, 3]),
    image: "inventory-gloves.png",
  },

  right_hand: {
    displayName: "right hand",
    gridSpot: getGridSpotKey([2, 4]),
    image: "inventory-hand_r.png",
    additionalComponent: <CornerText align="left">R</CornerText>,
  },

  left_hand: {
    displayName: "left hand",
    gridSpot: getGridSpotKey([2, 5]),
    image: "inventory-hand_l.png",
    additionalComponent: <CornerText align="right">L</CornerText>,
  },

  shoes: {
    displayName: "shoes",
    gridSpot: getGridSpotKey([3, 2]),
    image: "inventory-shoes.png",
  },

  suit_storage: {
    displayName: "suit storage item",
    gridSpot: getGridSpotKey([4, 0]),
    image: "inventory-suit_storage.png",
  },

  id: {
    displayName: "ID",
    gridSpot: getGridSpotKey([4, 1]),
    image: "inventory-id.png",
  },

  belt: {
    displayName: "belt",
    gridSpot: getGridSpotKey([4, 2]),
    image: "inventory-belt.png",
  },

  back: {
    displayName: "backpack",
    gridSpot: getGridSpotKey([4, 3]),
    image: "inventory-back.png",
  },

  left_pocket: {
    displayName: "left pocket",
    gridSpot: getGridSpotKey([4, 4]),
    image: "inventory-pocket.png",
  },

  right_pocket: {
    displayName: "right pocket",
    gridSpot: getGridSpotKey([4, 5]),
    image: "inventory-pocket.png",
  },
};

enum ObscuringLevel {
  Completely = 1,
  Hidden = 2,
}

type Interactable = {
  interacting: BooleanLike;
};

/**
 * Some possible options:
 *
 * null - No interactions, no item, but is an available slot
 * { interacting: 1 } - No item, but we're interacting with it
 * { icon: icon, name: name } - An item with no alternate actions
 *   that we're not interacting with.
 * { icon, name, interacting: 1 } - An item with no alternate actions
 *   that we're interacting with.
 */
type StripMenuItem =
  | null
  | Interactable
  | ((
      | {
          icon: string;
          name: string;
          alternate?: string;
        }
      | {
          obscured: ObscuringLevel;
        }
    ) &
      Partial<Interactable>);

type StripMenuData = {
  items: Record<keyof typeof SLOTS, StripMenuItem>;
  name: string;
};

export const StripMenu = (props, context) => {
  const { act, data } = useBackend<StripMenuData>(context);

  const gridSpots = new Map<GridSpotKey, string>();
  for (const key of Object.keys(data.items)) {
    gridSpots.set(SLOTS[key].gridSpot, key);
  }

  return (
    <Window title={`Stripping ${data.name}`} width={400} height={400}>
      <Window.Content>
        <Stack fill vertical>
          {range(0, ROWS).map(row => (
            <Stack.Item key={row}>
              <Stack fill>
                {range(0, COLUMNS).map(column => {
                  const key = getGridSpotKey([row, column]);
                  const keyAtSpot = gridSpots.get(key);

                  if (!keyAtSpot) {
                    return (
                      <Stack.Item
                        key={key}
                        style={{
                          width: BUTTON_DIMENSIONS,
                          height: BUTTON_DIMENSIONS,
                        }}
                      />
                    );
                  }

                  const item = data.items[keyAtSpot];
                  const slot = SLOTS[keyAtSpot];

                  let alternateAction: AlternateAction | undefined;

                  let content;
                  let tooltip;

                  if (item === null) {
                    tooltip = slot.displayName;
                  } else if ("name" in item) {
                    if (item.alternate) {
                      alternateAction = ALTERNATE_ACTIONS[item.alternate];
                    }

                    content = (
                      <Box
                        as="img"
                        src={`data:image/jpeg;base64,${item.icon}`}
                        height="100%"
                        width="100%"
                        style={{
                          "-ms-interpolation-mode": "nearest-neighbor",
                          "vertical-align": "middle",
                        }}
                      />
                    );

                    tooltip = item.name;
                  } else if ("obscured" in item) {
                    content = (
                      <Icon
                        name={
                          item.obscured === ObscuringLevel.Completely
                            ? "ban"
                            : "eye-slash"
                        }
                        size={3}
                        ml={0}
                        mt={1.3}
                        style={{
                          "text-align": "center",
                          height: "100%",
                          width: "100%",
                        }}
                      />
                    );

                    tooltip = `obscured ${slot.displayName}`;
                  }

                  return (
                    <Stack.Item
                      key={key}
                      style={{
                        width: BUTTON_DIMENSIONS,
                        height: BUTTON_DIMENSIONS,
                      }}
                    >
                      <Box
                        style={{
                          position: "relative",
                          width: "100%",
                          height: "100%",
                        }}
                      >
                        <Button
                          onClick={() => {
                            act("use", {
                              key: keyAtSpot,
                            });
                          }}
                          fluid
                          tooltip={tooltip}
                          style={{
                            background: item?.interacting
                              ? "hsl(39, 73%, 30%)"
                              : undefined,
                            position: "relative",
                            width: "100%",
                            height: "100%",
                            padding: 0,
                          }}
                        >
                          {slot.image && (
                            <Box
                              as="img"
                              className="centered-image"
                              src={resolveAsset(slot.image)}
                              opacity={0.7}
                            />
                          )}

                          <Box style={{ position: "relative" }}>
                            {content}
                          </Box>

                          {slot.additionalComponent}
                        </Button>

                        {alternateAction !== undefined && (
                          <Button
                            onClick={() => {
                              act("alt", {
                                key: keyAtSpot,
                              });
                            }}
                            tooltip={alternateAction.text}
                            style={{
                              background: "rgba(0, 0, 0, 0.6)",
                              position: "absolute",
                              bottom: 0,
                              right: 0,
                              "z-index": 2,
                            }}
                          >
                            <Icon name={alternateAction.icon} />
                          </Button>
                        )}
                      </Box>
                    </Stack.Item>
                  );
                })}
              </Stack>
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
