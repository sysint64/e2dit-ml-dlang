module ui.widgets.panel.widget;

import std.container;
import std.algorithm.comparison;
import std.stdio;

import basic_types;
import math.linalg;
import gapi;
import e2ml;
import log;
import input;
import accessors;

import ui.widget;
import ui.scroll;
import ui.manager;
import ui.cursor;
import ui.render_objects;

import ui.widgets.panel.split;
// import ui.widgets.panel.header;
import ui.widgets.panel.scroll_button;


class Panel : Widget, Scrollable {
    enum Background {transparent, light, dark, action};

    @property
    void showScrollButtons(in bool val) {
        showVerticalScrollButton = val;
        showHorizontalScrollButton = val;
    }

    float minSize = 40;
    float maxSize = 999;
    utfstring caption = "Hello World!";
    Background background = Background.light;
    bool allowResize = false;
    bool allowHide = false;
    bool allowDrag = false;
    bool isOpen = true;
    bool blackSplit = false;
    bool showSplit = true;

    bool showVerticalScrollButton = true;
    bool showHorizontalScrollButton = true;

    this(in string style) {
        super(style);
    }

    override void onProgress() {
        split.isEnter = false;

        handleHorizontalScrollButton();
        handleVerticalScrollButton();
        handleResize();

        // Update render elements position and sizes
        updateRegionAlign();
        updateAbsolutePosition();
        updateRegionOffset();

        split.calculate();
    }

    override void render(Camera camera) {
        onProgress();

        if (background != Background.transparent)
            renderer.renderColorQuad(backgroundRenderObject, backgroundColors[background],
                                     absolutePosition, size);

        renderHeader();

        if (!isOpen) {
            split.render();
            return;
        }

        horizontalScrollButton.render();
        verticalScrollButton.render();

        // Render children widgets
        Rect scissor;
        scissor.point = vec2(absolutePosition.x + regionOffset.left,
                             absolutePosition.y + regionOffset.top);
        scissor.size = vec2(size.x - regionOffset.left - regionOffset.right,
                            size.y - regionOffset.top - regionOffset.bottom);

        // manager.pushScissor(scissor);
        super.render(camera);
        // manager.popScissor();

        split.render();
    }

    class RenderConfigurator {
        Data data;
        Texture skin;

        this() {
            this.data = manager.theme.data;
            this.skin = manager.theme.skin;
        }

        void initHeader() {
            header.height = data.getNumber(style ~ ".Header.height.0");
            renderFactory.createQuad(header.backgroundRenderObject);

            const Texture.Coord headerLeave = data.getTexCoord(style ~ ".Header.leave");
            const Texture.Coord headerEnter = data.getTexCoord(style ~ ".Header.enter");

            header.backgroundRenderObject.addTexCoord("Leave", headerLeave, skin);
            header.backgroundRenderObject.addTexCoord("Enter", headerEnter, skin);

            // Header arrow (open/close)
            renderFactory.createQuad(header.arrowRenderObject);

            const Texture.Coord arrowOpen  = data.getTexCoord(style ~ ".Header.arrowOpen");
            const Texture.Coord arrpwClose = data.getTexCoord(style ~ ".Header.arrowClose");

            header.arrowRenderObject.addTexCoord("Open", headerLeave, skin);
            header.arrowRenderObject.addTexCoord("Close", headerEnter, skin);
        }

    }

    // Create elements for widget rendering (quads, texts etc.)
    // and read data from theme for these elements (background color, split thickness etc.)
    override void onCreate() {
        with (new RenderConfigurator()) {
            initHeader();
        }

        renderFactory.createQuad(backgroundRenderObject);

        with (manager.theme) {
            // Panel background colors
            backgroundColors[Background.light]  = data.getNormColor(style ~ ".backgroundLight");
            backgroundColors[Background.dark]   = data.getNormColor(style ~ ".backgroundDark");
            backgroundColors[Background.action] = data.getNormColor(style ~ ".backgroundAction");

            split.onCreate(this, data, renderer);
            horizontalScrollButton.onCreate(this, data, renderer);
            verticalScrollButton.onCreate(this, data, renderer);
        }
    }

    // Change system cursor when mouse entering split
    override void onCursor() {
        if (!resizable || !isOpen || scrollButtonIsClicked)
            return;

        if (regionAlign == RegionAlign.top || regionAlign == RegionAlign.bottom) {
            const Rect rect = Rect(split.borderPosition.x,
                                   split.borderPosition.y - split.cursorRangeSize / 2.0f,
                                   split.size.x, split.cursorRangeSize);

            if (pointInRect(app.mousePos, rect) || split.isClick) {
                manager.cursor = Cursor.Icon.vDoubleArrow;
                split.isEnter = true;
            }
        } else if (regionAlign == RegionAlign.left || regionAlign == RegionAlign.right) {
            const Rect rect = Rect(split.borderPosition.x - split.cursorRangeSize / 2.0f,
                                   split.borderPosition.y,
                                   split.cursorRangeSize, split.size.y);

            if (pointInRect(app.mousePos, rect) || split.isClick) {
                manager.cursor = Cursor.Icon.hDoubleArrow;
                split.isEnter = true;
            }
        }
    }

    override void onMouseDown(in uint x, in uint y, in MouseButton button) {
        if (split.isEnter && isOpen) {
            lastSize = size;
            split.isClick = true;
        }

        verticalScrollButton.isClick = verticalScrollButton.isEnter;
        horizontalScrollButton.isClick = horizontalScrollButton.isEnter;

        verticalScrollButton.scrollController.onMouseDown(x, y, button);
        horizontalScrollButton.scrollController.onMouseDown(x, y, button);

        super.onMouseDown(x, y, button);
    }

    override void onMouseUp(in uint x, in uint y, in MouseButton button) {
        verticalScrollButton.isClick = false;
        horizontalScrollButton.isClick = false;
        split.isClick = false;

        super.onMouseUp(x, y, button);
    }

protected:
    void updateRegionOffset() {
        if (verticalScrollButton.visible) {
            regionOffset.right = verticalScrollButton.width;
        } else {
            regionOffset.right = 0;
        }

        if (horizontalScrollButton.visible) {
            regionOffset.bottom = horizontalScrollButton.width;
        } else {
            regionOffset.bottom = 0;
        }
    }

    void onMouseWheelHandle(in int dx, in int dy) {
        Scrollable scrollable = cast(Scrollable) parent;

        int horizontalDelta = dx;
        int verticalDelta = dy;

        if (isKeyPressed(KeyCode.Shift)) { // Inverse
            horizontalDelta = dy;
            verticalDelta = dx;
        }

        if (!verticalScrollButton.scrollController.addOffsetInPx(-verticalDelta*20)) {
            if (scrollable && parent.isOver) {
                scrollable.onMouseWheelHandle(0, verticalDelta);
            }
        }

        if (!horizontalScrollButton.scrollController.addOffsetInPx(-horizontalDelta*20)) {
            if (scrollable && parent.isOver) {
                scrollable.onMouseWheelHandle(horizontalDelta, 0);
            }
        }
    }

private:
    BaseRenderObject backgroundRenderObject;
    TextRenderObject textRenderObject;

    vec4[Background] backgroundColors;
    vec2 widgetsOffset;

    struct Header {
        BaseRenderObject backgroundRenderObject;
        BaseRenderObject arrowRenderObject;

        float height = 0;
        bool isEnter = false;

        @property string state() {
            return isEnter ? "Enter" : "Leave";
        }
    }

    Split split;
    Header header;

    float panelSize;
    float currentPanelSize;

    ScrollButton verticalScrollButton   = ScrollButton(Orientation.vertical);
    ScrollButton horizontalScrollButton = ScrollButton(Orientation.horizontal);

    Array!Widget joinedWidgets;

    vec2 lastSize = 0;

    @property
    bool scrollButtonIsClicked() {
        return verticalScrollButton.isClick || horizontalScrollButton.isClick;
    }

    void onResizeScroll() {
        horizontalScrollButton.scrollController.onResize();
        verticalScrollButton.scrollController.onResize();
    }

    // Resize panel when split is clicked
    void handleResize() {
        if (!split.isClick)
            return;

        switch (regionAlign) {
            case RegionAlign.top:
                size.y = lastSize.y + app.mousePos.y - app.mouseClickPos.y;
                break;

            case RegionAlign.bottom:
                size.y = lastSize.y - app.mousePos.y + app.mouseClickPos.y;
                break;

            case RegionAlign.left:
                size.x = lastSize.x + app.mousePos.x - app.mouseClickPos.x;
                break;

            case RegionAlign.right:
                size.x = lastSize.x - app.mousePos.x + app.mouseClickPos.x;
                break;

            default:
                break;
        }

        if (regionAlign == RegionAlign.top || regionAlign == RegionAlign.bottom)
            size.y = clamp(size.y, minSize, maxSize);

        if (regionAlign == RegionAlign.left || regionAlign == RegionAlign.right)
            size.x = clamp(size.x, minSize, maxSize);

        onResizeScroll();
    }

    void renderHeader() {
        // if (!allowHide)
        //     return;

        // header.isEnter = ;
        renderer.renderQuad(header.arrowRenderObject, "Close", absolutePosition, vec2(10, 10));
    }

    void handleHorizontalScrollButton() {
        horizontalScrollButton.visible = innerBoundarySize.x > size.x;
        horizontalScrollButton.isEnter = false;

        with (horizontalScrollButton) {
            const vec2 buttonOffset = vec2(scrollController.buttonOffset,
                                           this.size.y - regionOffset.bottom);
            const Rect rect = Rect(absolutePosition + buttonOffset,
                                   vec2(scrollController.buttonSize, regionOffset.bottom));
            isEnter = pointInRect(app.mousePos, rect);
            updateController(this);

            scrollController.pollButton();
            contentOffset.x = scrollController.contentOffset;
        }
    }

    void handleVerticalScrollButton() {
        verticalScrollButton.visible = innerBoundarySize.y > size.y;
        verticalScrollButton.isEnter = false;

        with (verticalScrollButton) {
            const vec2 buttonOffset = vec2(this.size.x - regionOffset.right,
                                           scrollController.buttonOffset);
            const Rect rect = Rect(absolutePosition + buttonOffset,
                                   vec2(regionOffset.right, scrollController.buttonSize));
            isEnter = pointInRect(app.mousePos, rect);
            updateController(this);

            scrollController.pollButton();
            contentOffset.y = scrollController.contentOffset;
        }
    }

    void scrollToWidget() {
    }
}
