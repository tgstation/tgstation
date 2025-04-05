import { useLayoutEffect, useMemo, useRef, useState } from 'react';
import { Box, InfinitePlane, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Connection, Connections, ConnectionStyle } from './common/Connections';
import { ABSOLUTE_Y_OFFSET } from './IntegratedCircuit/constants';

type Coord = {
  x: number;
  y: number;
};

type SubsystemData = {
  name: string;
  dependents: string[];
};

type Subsystem = {
  name: string;
  dependents: Subsystem[];
};

type DependencyData = {
  subsystems: SubsystemData[];
};

function getPosition(el: HTMLElement | null): Coord {
  let xPos = 0;
  let yPos = 0;

  while (el !== null) {
    xPos += el.offsetLeft;
    yPos += el.offsetTop;
    el = el.offsetParent as HTMLElement | null;
  }

  return {
    x: xPos,
    y: yPos + ABSOLUTE_Y_OFFSET,
  };
}

type GraphNodeProps = {
  name: string;
  x: number;
  y: number;
  inputRef: (element: HTMLElement) => void;
  outputRef: (element: HTMLElement) => void;
};

function GraphNode(props: GraphNodeProps) {
  const { name, inputRef, outputRef, x, y } = props;

  return (
    <Box
      style={{
        borderRadius: '0px 0px 0px 0px',
        backgroundColor: 'rgba(0, 0, 0, 0.3)',
        msUserSelect: 'none',
        userSelect: 'none',
      }}
      width="200px"
      height="40px"
      position="absolute"
      left={`${(x - 1) * 500}px`}
      p={1}
      top={`${y * 50}px`}
    >
      <Stack align="center" fill>
        <Stack.Item>
          <Box
            className={classes(['ObjectComponent__Port'])}
            textAlign="center"
          >
            <svg
              style={{
                width: '100%',
                height: '100%',
                position: 'absolute',
              }}
              viewBox="0, 0, 100, 100"
            >
              <circle
                stroke={'blue'}
                strokeDasharray={`${100 * Math.PI}`}
                strokeDashoffset={-100 * Math.PI}
                className={`color-stroke-blue`}
                strokeWidth="50px"
                cx="50"
                cy="50"
                r="50"
                fillOpacity="0"
                transform="rotate(90, 50, 50)"
              />
              <circle cx="50" cy="50" r="50" className={`color-fill-blue`} />
            </svg>
            <span ref={inputRef} className="ObjectComponent__PortPos" />
          </Box>
        </Stack.Item>
        <Stack.Item grow>{name}</Stack.Item>
        <Stack.Item>
          <Box
            className={classes(['ObjectComponent__Port'])}
            textAlign="center"
          >
            <svg
              style={{
                width: '100%',
                height: '100%',
                position: 'absolute',
              }}
              viewBox="0, 0, 100, 100"
            >
              <circle
                stroke={'blue'}
                strokeDasharray={`${100 * Math.PI}`}
                strokeDashoffset={-100 * Math.PI}
                className={`color-stroke-blue`}
                strokeWidth="50px"
                cx="50"
                cy="50"
                r="50"
                fillOpacity="0"
                transform="rotate(90, 50, 50)"
              />
              <circle cx="50" cy="50" r="50" className={`color-fill-blue`} />
            </svg>
            <span ref={outputRef} className="ObjectComponent__PortPos" />
          </Box>
        </Stack.Item>
        <Stack.Item />
      </Stack>
    </Box>
  );
}

type SubsystemRef = {
  input?: HTMLElement;
  output?: HTMLElement;
};

type ConnectionRef = Record<string, SubsystemRef>;

type SubsystemCoord = {
  input: Coord;
  output: Coord;
};

type ConnectionData = Record<string, SubsystemCoord>;

type SubsystemLayer = Record<string, number>;

type SubsystemMap = Record<string, Subsystem>;

function evaluateSubsystemLayer(
  subsystem: Subsystem,
  depth: number,
  data: SubsystemLayer,
) {
  data[subsystem.name] = Math.max(depth, data[subsystem.name] || 0);
  for (let i = 0; i < subsystem.dependents.length; i++) {
    evaluateSubsystemLayer(subsystem.dependents[i], depth + 1, data);
  }
}

export function MCDependencyDebug(props) {
  const { data } = useBackend<DependencyData>();
  const { subsystems } = data;
  const connectionDom = useRef<ConnectionRef>({});
  const [connectionData, setConnectionData] = useState<ConnectionData>({});

  useLayoutEffect(() => {
    const doms = connectionDom.current;
    const newConnectionData: ConnectionData = {};
    for (let i = 0; i < subsystems.length; i++) {
      const subsystem = subsystems[i];
      const domElements = doms[subsystem.name];
      if (domElements.input === undefined || domElements.output === undefined) {
        continue;
      }
      newConnectionData[subsystem.name] = {
        input: getPosition(domElements.input),
        output: getPosition(domElements.output),
      };
    }
    setConnectionData(newConnectionData);
  }, [subsystems]);

  const subsystemsLayered = useMemo(() => {
    const namesToSubsystem: SubsystemMap = {};
    const subsystemsGraph: Subsystem[] = [];

    for (let i = 0; i < subsystems.length; i++) {
      const subsystem = subsystems[i];
      const subsystemNode = {
        name: subsystem.name,
        dependents: [],
      };
      namesToSubsystem[subsystem.name] = subsystemNode;
      subsystemsGraph.push(subsystemNode);
    }

    for (let i = 0; i < subsystems.length; i++) {
      const subsystem = subsystems[i];
      subsystemsGraph[i].dependents = subsystem.dependents.map(
        (val) => namesToSubsystem[val],
      );
    }

    const subsystemLayer: SubsystemLayer = {};
    for (let i = 0; i < subsystemsGraph.length; i++) {
      const subsystem = subsystemsGraph[i];
      evaluateSubsystemLayer(subsystem, 1, subsystemLayer);
    }
    return subsystemLayer;
  }, [subsystems]);

  const connections: Connection[] = [];
  for (let i = 0; i < subsystems.length; i++) {
    const subsystem = subsystems[i];
    const from = connectionData[subsystem.name];
    if (from === undefined) {
      continue;
    }
    for (let j = 0; j < subsystem.dependents.length; j++) {
      const outputSubsystem = subsystem.dependents[j];
      const target = connectionData[outputSubsystem];
      if (target === undefined) {
        continue;
      }

      connections.push({
        from: from.output,
        to: target.input,
        style: ConnectionStyle.SUBWAY_SHARP,
        index: i,
        color: `hsl(${60 + 5 * (i % 30)}, 50%, ${50 + (i % 30)}%)`,
      });
    }
  }

  return (
    <Window width={1200} height={800} title="Subsystem Dependency Graph">
      <Window.Content
        style={{
          backgroundImage: 'none',
        }}
      >
        <InfinitePlane
          width="100%"
          height="100%"
          backgroundImage={resolveAsset('grid_background.png')}
          imageWidth={900}
          initialLeft={0}
          initialTop={0}
        >
          <Box position={'absolute'} left={'-30px'} top={0}>
            First
          </Box>
          {subsystems.map((subsystem, y) => (
            <GraphNode
              key={subsystem.name}
              name={subsystem.name}
              x={subsystemsLayered[subsystem.name]}
              y={y}
              inputRef={(element) => {
                if (connectionDom.current[subsystem.name] === undefined) {
                  connectionDom.current[subsystem.name] = {};
                }
                connectionDom.current[subsystem.name].input = element;
              }}
              outputRef={(element) => {
                if (connectionDom.current[subsystem.name] === undefined) {
                  connectionDom.current[subsystem.name] = {};
                }
                connectionDom.current[subsystem.name].output = element;
              }}
            />
          ))}
          <Box
            position={'absolute'}
            left={'-30px'}
            top={`${(subsystems.length - 1) * 50}px`}
          >
            Last
          </Box>
          <Connections connections={connections} />
        </InfinitePlane>
      </Window.Content>
    </Window>
  );
}
