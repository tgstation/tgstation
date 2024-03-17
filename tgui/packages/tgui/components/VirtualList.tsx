import {
  PropsWithChildren,
  useCallback,
  useEffect,
  useRef,
  useState,
} from 'react';

/**
 * A vertical list that renders items to fill space up to the extents of the
 * current window, and then defers rendering of other items until they come
 * into view.
 */
export const VirtualList = (props: PropsWithChildren) => {
  const { children } = props;
  const containerRef = useRef(null as HTMLDivElement | null);
  const [visibleElements, setVisibleElements] = useState(1);
  const [padding, setPadding] = useState(0);

  const adjustExtents = useCallback(() => {
    const { current } = containerRef;

    if (
      !children ||
      !Array.isArray(children) ||
      !current ||
      visibleElements >= children.length
    ) {
      return;
    }

    const unusedArea =
      document.body.offsetHeight - current.getBoundingClientRect().bottom;

    const averageItemHeight = Math.ceil(current.offsetHeight / visibleElements);

    if (unusedArea > 0) {
      const newVisibleElements = Math.min(
        children.length,
        visibleElements +
          Math.max(1, Math.ceil(unusedArea / averageItemHeight)),
      );

      setVisibleElements(newVisibleElements);

      setPadding((children.length - newVisibleElements) * averageItemHeight);
    }
  }, [containerRef, visibleElements, setVisibleElements, setPadding]);

  useEffect(() => {
    adjustExtents();

    const interval = setInterval(adjustExtents, 100);

    return () => clearInterval(interval);
  }, [adjustExtents]);

  return (
    <div className={'VirtualList'}>
      <div className={'VirtualList__Container'} ref={containerRef}>
        {Array.isArray(children) ? children.slice(0, visibleElements) : null}
      </div>
      <div
        className={'VirtualList__Padding'}
        style={{ paddingBottom: `${padding}px` }}
      />
    </div>
  );
};
