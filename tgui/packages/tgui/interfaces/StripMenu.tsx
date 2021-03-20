import { resolveAsset } from "../assets";
import { useBackend } from "../backend";
import { Box, Button, Icon, Stack } from "../components";
import { Window } from "../layouts";

const ROWS = 5;
const COLUMNS = 6;

const BUTTON_DIMENSIONS = "50px";

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
};

const SLOTS: Record<
  string,
  {
    gridSpot: GridSpotKey;
    image: string;
    additionalComponent?: JSX.Element;
  }
> = {
  eyes: {
    gridSpot: getGridSpotKey([0, 1]),
    image: "inventory-glasses.png",
  },

  head: {
    gridSpot: getGridSpotKey([0, 2]),
    image: "inventory-head.png",
  },

  neck: {
    gridSpot: getGridSpotKey([1, 1]),
    image: "inventory-neck.png",
  },

  mask: {
    gridSpot: getGridSpotKey([1, 2]),
    image: "inventory-mask.png",
  },

  ears: {
    gridSpot: getGridSpotKey([1, 3]),
    image: "inventory-ears.png",
  },

  jumpsuit: {
    gridSpot: getGridSpotKey([2, 1]),
    image: "inventory-uniform.png",
  },

  suit: {
    gridSpot: getGridSpotKey([2, 2]),
    image: "inventory-suit.png",
  },

  gloves: {
    gridSpot: getGridSpotKey([2, 3]),
    image: "inventory-gloves.png",
  },

  right_hand: {
    gridSpot: getGridSpotKey([2, 4]),
    image: "inventory-hand_r.png",
    additionalComponent: <CornerText align="left">R</CornerText>,
  },

  left_hand: {
    gridSpot: getGridSpotKey([2, 5]),
    image: "inventory-hand_l.png",
    additionalComponent: <CornerText align="right">L</CornerText>,
  },

  shoes: {
    gridSpot: getGridSpotKey([3, 2]),
    image: "inventory-shoes.png",
  },

  suit_storage: {
    gridSpot: getGridSpotKey([4, 0]),
    image: "inventory-suit_storage.png",
  },

  id: {
    gridSpot: getGridSpotKey([4, 1]),
    image: "inventory-id.png",
  },

  belt: {
    gridSpot: getGridSpotKey([4, 2]),
    image: "inventory-belt.png",
  },

  back: {
    gridSpot: getGridSpotKey([4, 3]),
    image: "inventory-back.png",
  },

  left_pocket: {
    gridSpot: getGridSpotKey([4, 4]),
    image: "inventory-pocket.png",
  },

  right_pocket: {
    gridSpot: getGridSpotKey([4, 5]),
    image: "inventory-pocket.png",
  },
};

type StripMenuItem =
  | null
  | {
      icon: string;
      name: string;
      alternate?: string;
    }
  | {
      obscured: true;
    };

type StripMenuData = {
  items: Record<keyof typeof SLOTS, StripMenuItem>;
};

type GridSpotKey = string;

function getGridSpotKey(spot: [number, number]): GridSpotKey {
  return `${spot[0]}/${spot[1]}`;
}

function CornerText(props: {
  align: "left" | "right";
  children: string;
}): JSX.Element {
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
}

export const StripMenu = (props, context) => {
  let { act, data } = useBackend<StripMenuData>(context);

  const gridSpots = new Map<GridSpotKey, string>();
  for (const key of Object.keys(data.items)) {
    gridSpots.set(SLOTS[key].gridSpot, key);
  }

  const grid = [];

  for (let rowIndex = 0; rowIndex < ROWS; rowIndex++) {
    const buttons = [];

    for (let columnIndex = 0; columnIndex < COLUMNS; columnIndex++) {
      const keyAtSpot = gridSpots.get(getGridSpotKey([rowIndex, columnIndex]));
      if (!keyAtSpot) {
        buttons.push(
          <Stack.Item
            style={{
              width: BUTTON_DIMENSIONS,
              height: BUTTON_DIMENSIONS,
            }}
          />
        );
        continue;
      }

      const item = data.items[keyAtSpot];
      const slot = SLOTS[keyAtSpot];

      let alternateAction: AlternateAction | undefined;

      let content;
      let tooltip;

      if (item === null) {
        tooltip = "TODO: NAME GOES HERE";
      } else if ("name" in item) {
        alternateAction = ALTERNATE_ACTIONS[item.alternate];

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
            name="ban"
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

        tooltip = `Obscured TODO: PUT NAME HERE`;
      }

      buttons.push(
        <Stack.Item
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
                position: "relative",
                width: "100%",
                height: "100%",
                padding: 0,
              }}
            >
              <Box
                as="img"
                src={resolveAsset(slot.image)}
                opacity={0.7}
                style={{
                  position: "absolute",
                  width: "32px",
                  height: "32px",
                  left: "50%",
                  top: "50%",
                  transform: "translateX(-50%) translateY(-50%) scale(0.8)",
                }}
              />

              <Box style={{ position: "relative" }}>{content}</Box>

              {slot.additionalComponent}
            </Button>

            {alternateAction !== undefined && (
              <Button
                onClick={() => {
                  act("alt", {
                    key: keyAtSpot,
                  });
                }}
                icon={alternateAction.icon}
                tooltip={alternateAction.text}
                style={{
                  background: "rgba(0, 0, 0, 0.6)",
                  position: "absolute",
                  bottom: 0,
                  right: 0,
                  "z-index": 2,
                }}
              />
            )}
          </Box>
        </Stack.Item>
      );
    }

    grid.push(
      <Stack.Item>
        <Stack fill>{buttons}</Stack>
      </Stack.Item>
    );
  }

  return (
    <Window title="Stripping NAME HERE" width={400} height={500}>
      <Window.Content scrollable>
        <Stack fill vertical>
          {grid}
        </Stack>
      </Window.Content>
    </Window>
  );
};
