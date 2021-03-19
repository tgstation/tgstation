import { useBackend } from "../backend";
import { Box, Button, Icon, Stack } from "../components";
import { Window } from "../layouts";

const ROWS = 5;
const COLUMNS = 6;

const BUTTON_DIMENSIONS = "50px";

// MOTHBLOCKS TODO: L/R text for pockets and hands

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

const ALTERNATE_ACTION_HEIGHT = "14px";

const SLOTS_TO_GRID: Record<string, GridSpotKey> = {
  eyes: getGridSpotKey([0, 1]),
  head: getGridSpotKey([0, 2]),
  neck: getGridSpotKey([1, 1]),
  mask: getGridSpotKey([1, 2]),
  ears: getGridSpotKey([1, 3]),
  jumpsuit: getGridSpotKey([2, 1]),
  suit: getGridSpotKey([2, 2]),
  gloves: getGridSpotKey([2, 3]),
  left_hand: getGridSpotKey([2, 4]),
  right_hand: getGridSpotKey([2, 5]),
  shoes: getGridSpotKey([3, 2]),
  suit_storage: getGridSpotKey([4, 0]),
  id: getGridSpotKey([4, 1]),
  belt: getGridSpotKey([4, 2]),
  back: getGridSpotKey([4, 3]),
  left_pocket: getGridSpotKey([4, 4]),
  right_pocket: getGridSpotKey([4, 5]),
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
  items: Record<keyof typeof SLOTS_TO_GRID, StripMenuItem>;
};

type GridSpotKey = string;

function getGridSpotKey(spot: [number, number]): GridSpotKey {
  return `${spot[0]}/${spot[1]}`;
}

export const StripMenu = (props, context) => {
  let { act, data: untypedData } = useBackend(context);
  let data = untypedData as StripMenuData;

  const gridSpots = new Map<GridSpotKey, string>();
  for (const key of Object.keys(data.items)) {
    gridSpots.set(SLOTS_TO_GRID[key], key);
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
      let alternateAction: AlternateAction | undefined;

      let content;
      let tooltip;

      if (item === null) {
        content = (
          <Icon
            name="times"
            size={3}
            ml={0}
            mt={1.3}
            style={{
              textAlign: "center",
              height: "100%",
              width: "100%",
            }}
          />
        );
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

      let innerButton = (
        <Button
          onClick={() => {
            act("use", {
              key: keyAtSpot,
            });
          }}
          fluid
          tooltip={tooltip}
          style={{
            width: "100%",
            height: "100%",
            padding: 0,
          }}
        >
          {content}
        </Button>
      );

      if (alternateAction !== undefined) {
        innerButton = (
          <Box
            style={{
              position: "relative",
            }}
          >
            {innerButton}

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
          </Box>
        );
      }

      buttons.push(
        <Stack.Item
          style={{
            width: BUTTON_DIMENSIONS,
            height: BUTTON_DIMENSIONS,
          }}
        >
          {innerButton}
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
