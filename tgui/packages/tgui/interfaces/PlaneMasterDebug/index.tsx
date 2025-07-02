import { useLayoutEffect, useMemo, useRef, useState } from 'react';
import {
  Button,
  Dropdown,
  InfinitePlane,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Connection, Connections, Position } from './../common/Connections';
import { ABSOLUTE_Y_OFFSET } from './../IntegratedCircuit/constants';
import { PlaneEditor } from './PlaneEditor';
import { PlaneMaster } from './PlaneMaster';
import { PlaneMenus } from './PlaneMenus';
import {
  Filter,
  Plane,
  PlaneConnectionsMap,
  PlaneConnectorElement,
  PlaneConnectorsMap,
  PlaneData,
  PlaneDebugData,
  PlaneHighlight,
  PlaneMap,
  PlaneTargetMap,
  Relay,
} from './types';
import { PlaneDebugContext } from './usePlaneDebug';

function getPosition(el: HTMLElement | null): Position {
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

function isDefined<T>(x: T | undefined): x is T {
  return x !== undefined;
}

function evaluatePlaneDepth(plane: Plane, depth: number) {
  let checkDepth = 0;
  let toCheck = (plane.outgoing_filters as (Filter | Relay)[])
    .concat(plane.outgoing_relays)
    .map((connection: Filter | Relay) => connection.target);
  const allElems: Plane[] = [];
  let foundChild = false;
  while (checkDepth <= 2) {
    let newCheck: Plane[] = [];
    for (let i = 0; i < toCheck.length; i++) {
      const checkElem = toCheck[i];
      if (checkElem === undefined) {
        continue;
      }

      if (allElems.includes(checkElem)) {
        foundChild = true;
        break;
      }

      allElems.push(checkElem);
      newCheck = newCheck.concat(
        ((checkElem as Plane).outgoing_filters as (Filter | Relay)[])
          .concat(checkElem.outgoing_relays)
          .map((connection: Filter | Relay) => connection.target)
          .filter(isDefined),
      );
    }

    if (foundChild) {
      break;
    }

    toCheck = newCheck;
    checkDepth++;
  }

  // If our plane has at least 2 children over 2 degrees of separation away
  // from each other, give them a bump in depth to split them from other
  // parents of those planes visually a bit
  if (checkDepth) {
    depth += 1;
  }

  plane.depth = Math.max(depth, plane.depth);
  for (let i = 0; i < plane.parents.length; i++) {
    evaluatePlaneDepth(plane.parents[i], depth + 1);
  }
}

// Stolen wholesale from fontcode
function textWidth(text: string, font: string, fontsize: number) {
  // default font height is 12 in tgui
  font = `${fontsize}px ${font}`;
  const c = document.createElement('canvas');
  const ctx = c.getContext('2d') as CanvasRenderingContext2D;
  ctx.font = font;
  return ctx.measureText(text).width;
}

function getPlaneHeight(plane: Plane) {
  return (
    45 +
    19 *
      Math.max(
        plane.incoming_filters.length + plane.incoming_relays.length,
        plane.outgoing_filters.length + plane.outgoing_relays.length + 1,
      ) +
    15
  );
}

function getDesiredPlanePosition(
  plane: Plane,
  curStack: number,
  tallestStack: number,
) {
  const dependents: Plane[] = (
    curStack > tallestStack
      ? (plane.outgoing_filters as (Filter | Relay)[]).concat(
          plane.outgoing_relays,
        )
      : (plane.incoming_filters as (Filter | Relay)[]).concat(
          plane.incoming_relays,
        )
  )
    .map((connection: Filter | Relay) =>
      curStack > tallestStack ? connection.target : connection.source,
    )
    .filter(isDefined);

  const avgY =
    dependents
      .map((x) => x.position.y + getPlaneHeight(x) / 2)
      .reduce((a, b) => a + b, 0) / dependents.length;

  return avgY - getPlaneHeight(plane) / 2;
}

function mapPlanes(planes: PlaneData[]) {
  const planeGraph: PlaneMap = {};
  const planeTargets: PlaneTargetMap = {};

  for (let i = 0; i < planes.length; i++) {
    const planeInfo = planes[i];
    const plane: Plane = {
      name: planeInfo.name,
      documentation: planeInfo.documentation,
      plane: planeInfo.plane,
      offset: planeInfo.offset,
      real_plane: planeInfo.real_plane,
      renders_onto: [],
      blend_mode: planeInfo.blend_mode,
      color: planeInfo.color,
      alpha: planeInfo.alpha,
      render_target: planeInfo.render_target,
      force_hidden: !!planeInfo.force_hidden,
      incoming_relays: [],
      incoming_filters: [],
      outgoing_relays: [],
      outgoing_filters: [],
      position: { x: 0, y: 0 },
      parents: [],
      depth: 0,
    };

    planeGraph[planeInfo.plane] = plane;
    if (planeInfo.render_target) {
      planeTargets[planeInfo.render_target] = plane;
    }
  }

  for (let i = 0; i < planes.length; i++) {
    const planeInfo = planes[i];
    const plane = planeGraph[planeInfo.plane];

    for (let j = 0; j < planeInfo.relays.length; j++) {
      const relayInfo = planeInfo.relays[j];
      const targetPlane = planeGraph[relayInfo.target];
      const relay: Relay = {
        name: relayInfo.name,
        source: plane,
        target: targetPlane,
        layer: relayInfo.layer,
        blend_mode: relayInfo.blend_mode,
        our_ref: relayInfo.our_ref,
        node_color: 'blue',
      };

      plane.outgoing_relays.push(relay);
      if (targetPlane !== undefined) {
        targetPlane.incoming_relays.push(relay);
        targetPlane.parents.push(plane);
      }
    }

    for (let j = 0; j < planeInfo.filters.length; j++) {
      const filterInfo = planeInfo.filters[j];
      const sourcePlane = planeTargets[filterInfo.render_source];
      const filter: Filter = {
        name: filterInfo.name,
        target: plane,
        source: sourcePlane,
        type: filterInfo.type,
        our_ref: filterInfo.our_ref,
        blend_mode: filterInfo.blend_mode,
        node_color: 'purple',
      };

      plane.incoming_filters.push(filter);
      if (sourcePlane !== undefined) {
        plane.parents.push(sourcePlane);
        sourcePlane.outgoing_filters.push(filter);
      }
    }
  }

  // Calculate plane depths to sort them out
  for (const key in planeGraph) {
    const plane = planeGraph[key];
    // Don't recursively evaluate nodes that we know will have some child
    // to call this on them anyways
    if (
      plane.outgoing_filters.length === 0 &&
      plane.outgoing_relays.length === 0
    ) {
      evaluatePlaneDepth(plane, 1);
    }
  }

  const widthPerDepth: Record<number, number> = {};
  const heightPerDepth: Record<number, number> = {};
  const planeStacks: Record<number, Plane[]> = {};
  let maxHeight = 0;
  let tallestStack = 0;
  for (const key in planeGraph) {
    const plane = planeGraph[key];
    widthPerDepth[plane.depth] = Math.max(
      widthPerDepth[plane.depth] || 0,
      textWidth(plane.name, 'Verdana, Geneva', 12) + 30,
    );

    const newHeight =
      (heightPerDepth[plane.depth] || 0) + getPlaneHeight(plane);

    heightPerDepth[plane.depth] = newHeight;
    if (newHeight > maxHeight) {
      maxHeight = newHeight;
      tallestStack = plane.depth;
    }

    if (planeStacks[plane.depth] === undefined) {
      planeStacks[plane.depth] = [];
    }

    planeStacks[plane.depth].push(plane);
  }

  // We sort stacks based on planes that the plane bundle renders onto
  // and the numerical plane value within the actual bundle
  for (const key in planeStacks) {
    let stack: Plane[] = planeStacks[key];
    stack = stack.sort((first, second) => {
      const firstChildren: Plane[] = (
        first.outgoing_filters as (Filter | Relay)[]
      )
        .concat(first.outgoing_relays)
        .map((connection: Filter | Relay) => connection.target)
        .filter(isDefined)
        .sort((a, b) => a.plane - b.plane);

      const secondChildren: Plane[] = (
        second.outgoing_filters as (Filter | Relay)[]
      )
        .concat(second.outgoing_relays)
        .map((connection: Filter | Relay) => connection.target)
        .filter(isDefined)
        .sort((a, b) => a.plane - b.plane);

      // We have same children or none at all, sort ourselves based on our real planes
      if (
        firstChildren.length === 0 ||
        secondChildren.length === 0 ||
        firstChildren.map((x) => x.plane).join('-') ===
          secondChildren.map((x) => x.plane).join('-')
      ) {
        return first.plane - second.plane;
      }

      // planeStacks is a Record and thus automatically sorts itself
      // so we can always assume that our children have already been sorted
      const firstAvg =
        firstChildren
          .map((x) => planeStacks[x.depth].indexOf(x) || 0)
          .reduce((a, b) => a + b, 0) / firstChildren.length;

      const secondAvg =
        secondChildren
          .map((x) => planeStacks[x.depth].indexOf(x) || 0)
          .reduce((a, b) => a + b, 0) / secondChildren.length;

      if (firstAvg !== secondAvg) {
        return firstAvg - secondAvg;
      }

      // In a scenario where averages of our children's vertical positions match
      // we want to keep all planes leading to same children grouped together
      for (
        let i = 0;
        i < Math.min(firstChildren.length, secondChildren.length);
        i++
      ) {
        const firstChild: Plane = firstChildren[i] as Plane;
        const secondChild: Plane = secondChildren[i] as Plane;

        if (firstChild.plane !== secondChild.plane) {
          return firstChild.plane - secondChild.plane;
        }
      }

      return 0;
    });

    planeStacks[key] = stack;
  }

  let baseX = 0;
  for (const key in planeStacks) {
    const stack: Plane[] = planeStacks[key];
    for (let i = 0; i < stack.length; i++) {
      const plane: Plane = stack[i];
      plane.position.x = baseX;
    }

    baseX -= widthPerDepth[key] + 150;
  }

  const stackKeys = Object.keys(planeStacks).sort(
    (a, b) => Math.abs(+a - tallestStack) - Math.abs(+b - tallestStack),
  );

  for (let k = 0; k < stackKeys.length; k++) {
    const key: number = +stackKeys[k];
    const stack: Plane[] = planeStacks[key];

    let stackHeight = 0;
    for (let i = 0; i < stack.length; i++) {
      const plane: Plane = stack[i];
      const height = getPlaneHeight(plane);

      if (key === tallestStack) {
        plane.position.y = stackHeight;
        stackHeight += height;
        continue;
      }

      const desiredPos = getDesiredPlanePosition(plane, +key, tallestStack);

      if (i === 0 && desiredPos < stackHeight) {
        stackHeight = desiredPos;
      } else if (desiredPos > stackHeight) {
        let curBottom = desiredPos + height;
        let pushedPosition = 0;

        if (i < stack.length - 1) {
          for (let j = i + 1; j < stack.length; j++) {
            const otherPlane: Plane = stack[j];
            const otherPos = getDesiredPlanePosition(
              otherPlane,
              +key,
              tallestStack,
            );

            if (Number.isNaN(otherPos)) {
              continue;
            }

            const otherHeight = getPlaneHeight(otherPlane);
            curBottom += otherHeight;
            pushedPosition = Math.max(
              pushedPosition,
              curBottom - otherPos - otherHeight / 2,
            );
          }
        }

        stackHeight = Math.max(desiredPos - pushedPosition / 2, stackHeight);
      }

      plane.position.y = stackHeight;
      stackHeight += height;
    }
  }

  return planeGraph;
}

export function PlaneMasterDebug() {
  const { data, act } = useBackend<PlaneDebugData>();
  const {
    mob_name,
    planes,
    tracking_active,
    mob_ref,
    our_ref,
    enable_group_view,
    our_group,
    present_groups,
  } = data;
  const connectionDom = useRef<PlaneConnectorsMap>({});

  const planesProcessed = useMemo(() => mapPlanes(planes), [planes]);

  const [connectionData, setConnectionData] = useState<PlaneConnectionsMap>({});
  const [connectionHighlight, setConnectionHighlight] =
    useState<PlaneHighlight>();

  useLayoutEffect(() => {
    const doms = connectionDom.current;
    const newConnectionData: PlaneConnectionsMap = {};
    for (const our_ref in doms) {
      const connection: PlaneConnectorElement = doms[our_ref];
      if (connection === undefined) {
        continue;
      }
      if (connection.input === undefined || connection.output === undefined) {
        continue;
      }
      newConnectionData[our_ref] = {
        input: getPosition(connection.input),
        output: getPosition(connection.output),
      };
    }
    setConnectionData(newConnectionData);
  }, [planes]);

  const connections: Connection[] = [];
  for (const key in planesProcessed) {
    const plane = planesProcessed[key];
    for (let i = 0; i < plane.outgoing_filters.length; i++) {
      const filter = plane.outgoing_filters[i];
      const targetPlane = filter.target;
      if (
        targetPlane === undefined ||
        connectionData[filter.our_ref] === undefined
      ) {
        continue;
      }

      const highlighted =
        (plane.plane === connectionHighlight?.target &&
          targetPlane.plane === connectionHighlight?.source) ||
        (targetPlane.plane === connectionHighlight?.target &&
          plane.plane === connectionHighlight?.source);

      connections.push({
        color: highlighted ? 'white' : 'purple',
        from: connectionData[filter.our_ref].output,
        to: connectionData[filter.our_ref].input,
        ref: plane.name,
      });
    }

    for (let i = 0; i < plane.outgoing_relays.length; i++) {
      const relay = plane.outgoing_relays[i];
      const targetPlane = relay.target;
      if (
        targetPlane === undefined ||
        connectionData[relay.our_ref] === undefined
      ) {
        continue;
      }

      const highlighted =
        (plane.plane === connectionHighlight?.target &&
          targetPlane.plane === connectionHighlight?.source) ||
        (targetPlane.plane === connectionHighlight?.target &&
          plane.plane === connectionHighlight?.source);

      connections.push({
        color: highlighted ? 'white' : 'blue',
        from: connectionData[relay.our_ref].output,
        to: connectionData[relay.our_ref].input,
        ref: plane.name,
      });
    }
  }

  // Must be a number as Plane objects are recreated whenever plane data changes
  const [activePlane, setActivePlane] = useState<number>();
  const [connectionOpen, setConnectionOpen] = useState<boolean>(false);
  const [infoOpen, setInfoOpen] = useState<boolean>(false);
  const [planeOpen, setPlaneOpen] = useState<boolean>(false);

  return (
    <PlaneDebugContext.Provider
      value={{
        connectionHighlight,
        setConnectionHighlight,
        activePlane,
        setActivePlane,
        connectionOpen,
        setConnectionOpen,
        infoOpen,
        setInfoOpen,
        planeOpen,
        setPlaneOpen,
        planesProcessed,
        act,
      }}
    >
      <Window
        width={planeOpen ? 1500 : 1200}
        height={800}
        title={`Plane Debugging: ${mob_name}`}
        buttons={
          <Stack>
            {!!enable_group_view && (
              <Tooltip
                content="Plane masters are stored in groups, based off where they came from. MAIN is the main group, but if you open something that displays atoms in a new window, it'll show up here."
                position="right"
              >
                <Dropdown
                  options={present_groups}
                  selected={our_group}
                  onSelected={(value) =>
                    act('set_group', { target_group: value })
                  }
                />
              </Tooltip>
            )}
            <Stack.Item>
              <Button
                color="transparent"
                tooltip="Debugger Documentation"
                icon="question"
                selected={infoOpen}
                onClick={() => setInfoOpen(true)}
              />
            </Stack.Item>
            {!!(mob_ref !== our_ref) && (
              <Stack.Item>
                <Button
                  color="transparent"
                  tooltip="Reset Mob Focus"
                  icon="magnifying-glass"
                  onClick={() => act('reset_mob')}
                />
              </Stack.Item>
            )}
            <Stack.Item>
              <Button
                color="transparent"
                tooltip="View Mirroring"
                icon={our_ref !== mob_ref ? 'ghost' : 'eye'}
                selected={tracking_active}
                onClick={() => act('toggle_mirroring')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                color="transparent"
                tooltip="View Mob Variables"
                icon="pen"
                onClick={() => act('vv_mob')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                color="transparent"
                tooltip="Rebuild Plane Masters"
                icon="recycle"
                onClick={() => act('rebuild')}
              />
            </Stack.Item>
          </Stack>
        }
      >
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
            initialLeft={500}
            initialTop={-1350}
          >
            {planes.map((plane) => (
              <PlaneMaster
                key={plane.name}
                plane={planesProcessed[plane.plane]}
                connectionData={connectionDom.current}
              />
            ))}
            <Connections connections={connections} />
          </InfinitePlane>
          {!!planeOpen && <PlaneEditor />}
          <PlaneMenus />
        </Window.Content>
      </Window>
    </PlaneDebugContext.Provider>
  );
}
