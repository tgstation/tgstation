/**
 * @file
 * @author 2026 FeudeyTF
 * @license MIT
 */

import {
  type ReactNode,
  useCallback,
  useEffect,
  useRef,
  useState,
} from 'react';
import { getRoutedComponent } from 'tgui/routes';
import { Box, Button, ImageButton } from 'tgui-core/components';
import { Window } from '../../layouts';
import type { Coordinates } from '../common/Connections';
import { NtosHeader, NtosHeaderIcon } from './NtosHeader';
import { useNtos } from './ntos';

export const NtosCoreDesktop = (props) => {
  const { act, system, api } = useNtos(props);
  const {
    PC_device_theme,
    PC_batteryicon,
    PC_batterypercent,
    PC_ntneticon,
    PC_stationdate,
    PC_stationtime,
    PC_programheaders = [],
    PC_lowpower_mode,
    programs,
  } = system;
  const { run_program, minimize_program, exit_program, shutdown } = api;

  const handleWindowMove = useCallback(
    (x: number, y: number, name: string) =>
      act('move_window', { x, y, name: name }),
    [],
  );

  const handleWindowResize = useCallback(
    (width: number, height: number, name: string) =>
      act('resize_window', { width, height, name: name }),
    [],
  );

  return (
    <Window
      theme={PC_device_theme}
      title={
        (PC_device_theme === 'syndicate' && 'Syndix Main Menu') ||
        'NTOS Desktop Edition'
      }
      width={1200}
      height={800}
    >
      <Window.Content scrollable>
        {programs.map((program) => (
          <ImageButton
            fallbackIcon={program.icon}
            key={program.name}
            tooltip={program.desc}
            onClick={() => run_program(program.name)}
          >
            {program.desc}
          </ImageButton>
        ))}
        {programs
          .filter((program) => program.active)
          .map((program) => {
            return (
              program.metadata && (
                <NtosDesktopWindow
                  key={`program-window-${program.name}`}
                  name={program.name}
                  title={program.desc}
                  x={program.metadata.x}
                  y={program.metadata.y}
                  initialWidth={program.metadata.width}
                  initialHeight={program.metadata.height}
                  interface_id={program.tgui_id}
                  theme={PC_device_theme}
                  buttons={
                    <>
                      <Button
                        color="transparent"
                        icon="window-minimize-o"
                        tooltip="Minimize"
                        tooltipPosition="bottom"
                        onClick={() => minimize_program(program.name)}
                      />
                      <Button
                        color="transparent"
                        icon="window-close-o"
                        tooltip="Close"
                        tooltipPosition="bottom-start"
                        onClick={() => exit_program(program.name)}
                      />
                    </>
                  }
                  onWindowMove={handleWindowMove}
                  onWindowResize={handleWindowResize}
                />
              )
            );
          })}
        <div className="NtosDesktop__footer">
          <div className="NtosDesktop__footer__left">
            <Button
              textAlign="center"
              color="transparent"
              icon="power-off"
              tooltip="Power off"
              tooltipPosition="bottom-start"
              onClick={() => shutdown()}
            />
            {programs
              .filter((program) => program.active || program.idle)
              .map((program) => (
                <Button
                  key={`footer-${program.name}`}
                  color={program.idle ? 'yellow' : 'blue'}
                  icon={program.icon}
                  onClick={() => run_program(program.name)}
                >
                  {program.desc}
                </Button>
              ))}
          </div>
          <div className="NtosDesktop__footer__right">
            <Box inline italic mr={2} opacity={0.33}>
              {(PC_device_theme === 'syndicate' && 'Syndix') || 'NtOS Desktop'}
              {!!PC_lowpower_mode && ' - RUNNING ON LOW POWER MODE'}
            </Box>

            {PC_programheaders.map((header) => (
              <NtosHeaderIcon key={header.icon} mr={1} name={''} />
            ))}
            <NtosHeaderIcon name={PC_ntneticon} />

            {!!PC_batteryicon && (
              <NtosHeaderIcon name={PC_batteryicon} mr={1}>
                {PC_batterypercent}
              </NtosHeaderIcon>
            )}
            <Box inline bold ml={2}>
              {PC_stationtime}
              <Button
                width="26px"
                lineHeight="22px"
                textAlign="left"
                tooltip={PC_stationdate}
                color="transparent"
                icon="calendar"
                tooltipPosition="bottom"
              />
            </Box>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};

type NtosDesktopWindowProps = {
  interface_id: string;
  title: string;
  name: string;
  initialWidth: number;
  initialHeight: number;
  x: number;
  y: number;
  theme: string;
  buttons?: ReactNode;
  minHeight?: 100;
  minWidth?: 100;
  maxHeight?: 800;
  maxWidth?: 1200;
  onWindowMove?: (x: number, y: number, name: string) => void;
  onWindowResize?: (width: number, height: number, name: string) => void;
};

const NtosDesktopWindow = (props: NtosDesktopWindowProps) => {
  const {
    title,
    name,
    interface_id,
    theme,
    x,
    y,
    initialWidth,
    initialHeight,
    buttons = [],
    minHeight = 100,
    minWidth = 100,
    maxHeight = 800,
    maxWidth = 1200,
    onWindowMove,
    onWindowResize,
  } = props;

  const [width, setWidth] = useState(initialWidth);
  const [height, setHeight] = useState(initialHeight);
  const [position, setPosition] = useState<Coordinates>({ x: x, y: y });
  const [isDragging, setIsDragging] = useState(false);

  const [isResizing, setIsResizing] = useState(false);
  const [resizeDirection, setResizeDirection] = useState('');

  const windowRef = useRef<HTMLDivElement>(null);
  const lastPositionRef = useRef<Coordinates | null>(null);

  const Component = getRoutedComponent(interface_id);

  function handleMouseDown(event: React.MouseEvent<HTMLDivElement>) {
    lastPositionRef.current = { x: event.screenX, y: event.screenY };
    setIsDragging(true);
  }

  const handleMouseUp = useCallback(() => {
    setIsDragging(false);
    setIsResizing(false);
    setResizeDirection('');
    onWindowMove?.(position.x, position.y, name);
    onWindowResize?.(width, height, name);
    lastPositionRef.current = null;
  }, [position, width, height, onWindowMove, onWindowResize]);

  useEffect(() => {
    const handleMouseMove = (event: MouseEvent) => {
      event.preventDefault();

      if (isDragging) {
        const last = lastPositionRef.current;
        if (last) {
          const dx = event.screenX - last.x;
          const dy = event.screenY - last.y;
          setPosition((prev) => ({ x: prev.x + dx, y: prev.y + dy }));
        }
        lastPositionRef.current = { x: event.screenX, y: event.screenY };
      }

      if (isResizing) {
        const rect = windowRef.current?.getBoundingClientRect();
        if (!rect) return;

        setWidth((prevWidth) => {
          if (resizeDirection.includes('right')) {
            return Math.max(
              minWidth,
              Math.min(maxWidth, event.clientX - rect.left),
            );
          }
          return prevWidth;
        });

        setHeight((prevHeight) => {
          if (resizeDirection.includes('bottom')) {
            return Math.max(
              minHeight,
              Math.min(maxHeight, event.clientY - rect.top),
            );
          }
          return prevHeight;
        });
      }
    };

    if (isDragging || isResizing) {
      window.addEventListener('mousemove', handleMouseMove);
      window.addEventListener('mouseup', handleMouseUp);
    }

    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('mouseup', handleMouseUp);
    };
  }, [
    isDragging,
    isResizing,
    resizeDirection,
    minWidth,
    maxWidth,
    minHeight,
    maxHeight,
    handleMouseUp,
  ]);

  const handleResizeMouseDown = (e: React.MouseEvent, direction?: string) => {
    if (direction) {
      setResizeDirection(direction);
      setIsResizing(true);
    }
  };

  return (
    <div
      ref={windowRef}
      className={`Window ${theme}`}
      style={{
        width: width,
        height: height,
        position: 'absolute',
        zIndex: 999,
        left: `${position.x}px`,
        top: `${position.y}px`,
      }}
    >
      <NtosHeader
        left={title}
        buttons={buttons}
        onMouseDown={handleMouseDown}
      />

      <Component tgui_id={interface_id} />
      <ResizeHandle onMouseDown={handleResizeMouseDown} direction="right" />
      <ResizeHandle onMouseDown={handleResizeMouseDown} direction="bottom" />
      <ResizeHandle
        onMouseDown={handleResizeMouseDown}
        direction="bottom right"
      />
    </div>
  );
};

type ResizeHandleProps = {
  direction: string;
  onMouseDown: (e: React.MouseEvent, direction: string) => void;
};

function ResizeHandle(props: ResizeHandleProps) {
  const { direction, onMouseDown } = props;
  return (
    <div
      className={`NtosDesktop__resize resize-${direction.replace(' ', '-')}`}
      onMouseDown={(e) => onMouseDown(e, direction)}
    />
  );
}
