import { useLayoutEffect, useMemo, useRef, useState } from 'react';
import { InfinitePlane } from 'tgui-core/components';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Connection, Connections, Position } from './../common/Connections';
import { ABSOLUTE_Y_OFFSET } from './../IntegratedCircuit/constants';
import { PlaneMaster } from './PlaneMaster';
import {
  Filter,
  Plane,
  PlaneConnectionsMap,
  PlaneConnectorElement,
  PlaneConnectorsMap,
  PlaneData,
  PlaneMap,
  PlaneTargetMap,
  Relay,
} from './types';

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
  const childConnections: Plane[] = plane.outgoing_filters
    .concat(plane.outgoing_relays)
    .map((connection: Filter | Relay) => connection.target)
    .filter(isDefined);

  let checkDepth = 0;
  let toCheck = plane.outgoing_filters
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
        (checkElem as Plane).outgoing_filters
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
  font = fontsize + 'px ' + font;
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
    30
  );
}

export type PlaneDebugData = {
  mob_name: string;
  mob_ref: string;
  our_ref: string;
  tracking_active: boolean;
  enable_group_view: boolean;
  our_group: string;
  present_groups: string[];
  planes: PlaneData[];
};

export function PlaneMasterDebug(props) {
  const { data } = useBackend<PlaneDebugData>();
  const { mob_name, planes } = data;
  const connectionDom = useRef<PlaneConnectorsMap>({});
  const [connectionData, setConnectionData] = useState<PlaneConnectionsMap>({});

  const planesProcessed = useMemo(() => {
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
        force_hidden: planeInfo.force_hidden,
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
    let baseX = 0;
    for (const key in planeStacks) {
      let stack: Plane[] = planeStacks[key];
      stack = stack.sort((first, second) => {
        const firstChildren: Plane[] = first.outgoing_filters
          .concat(first.outgoing_relays)
          .map((connection: Filter | Relay) => connection.target)
          .filter(isDefined)
          .sort((a, b) => a.plane - b.plane);

        const secondChildren: Plane[] = second.outgoing_filters
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

    for (const key in planeStacks) {
      const stack: Plane[] = planeStacks[key];

      let baseY = 0;
      for (let i = 0; i < stack.length; i++) {
        const plane: Plane = stack[i];
        plane.position.x = baseX;
        plane.position.y = baseY + (maxHeight - heightPerDepth[key]) / 2;
        baseY += getPlaneHeight(plane);
      }

      baseX -= widthPerDepth[key] + 150;
    }

    /*
    const depthPositions: Record<number, number> = {};
    for (const key in planeGraph) {
      const plane = planeGraph[key];
      const depth = planeDepths[plane.plane];
      if (depthPositions[depth] === undefined) {
        depthPositions[depth] = 0;
        for (let i = 1; i < depth; i++) {
          if (i in widthPerDepth) {
            depthPositions[depth] -= widthPerDepth[i] + 150;
          }
        }
      }
      // Plane X is assigned purely on their depth
      plane.position.x = depthPositions[depth];
      // Y is a placeholder
      plane.position.y = plane.plane * 40;
    }
    */

    return planeGraph;
  }, [planes]);

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
  }, []);

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

      connections.push({
        color: 'purple',
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

      connections.push({
        color: 'blue',
        from: connectionData[relay.our_ref].output,
        to: connectionData[relay.our_ref].input,
        ref: plane.name,
      });
    }
  }

  return (
    <Window width={1200} height={800} title={'Plane Debugging: ' + mob_name}>
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
          initialLeft={800}
          initialTop={-740}
        >
          {planes.map((plane) => (
            <PlaneMaster
              key={plane.name}
              x={planesProcessed[plane.plane].position.x}
              y={planesProcessed[plane.plane].position.y}
              plane={planesProcessed[plane.plane]}
              connectionData={connectionDom.current}
            />
          ))}
          <Connections connections={connections} />
        </InfinitePlane>
      </Window.Content>
    </Window>
  );
}
