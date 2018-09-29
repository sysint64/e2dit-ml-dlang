/**
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.button;

import std.container.array;
import std.algorithm.comparison;

import input;
import gapi;
import math.linalg;
import std.stdio;
import std.math;
import basic_types;

import rpui.widget;
import rpui.manager;
import rpui.render_objects;
import resources.icons;

class Button : Widget {
    @Field bool allowCheck = false;
    @Field Align textAlign = Align.center;
    @Field VerticalAlign textVerticalAlign = VerticalAlign.middle;
    @Field Array!string icons;

    private utf32string p_caption = "Button";

    @Field
    @property void caption(utf32string value) {
        if (manager is null) {
            p_caption = value;
        } else {
            p_caption = value;
            textRenderObject.text = value;
        }
    }

    @property utf32string caption() { return p_caption; }

    this(in string style = "Button", in string iconsGroup = "icons") {
        super(style);

        this.drawChildren = false;
        this.iconsGroup = iconsGroup;

        // TODO: rm hardcode
        size = vec2(50, 21);
    }

    this(bool allowCheck) {
        super();

        this.allowCheck = allowCheck;
        this.drawChildren = false;
    }

    override void progress() {
        locator.updateAbsolutePosition();
        locator.updateLocationAlign();
        locator.updateVerticalLocationAlign();
        locator.updateRegionAlign();
        updateSize();
    }

    override void render(Camera camera) {
        super.render(camera);

        // Background
        renderer.renderHorizontalChain(skinRenderObjects, state, absolutePosition, size);

        if (isFocused) {
            const focusPos = absolutePosition + focusOffsets;
            const focusSize = size + vec2(focusResize, focusResize);

            renderer.renderHorizontalChain(skinFocusRenderObjects, "Focus", focusPos, focusSize);
        }

        renderText();

        // Icons
        foreach (iconRenderObject; iconsRenderObjects) {
            const iconPos = absolutePosition + iconRenderObject.offset;
            renderer.renderQuad(iconRenderObject.renderObject, "default", iconPos);
        }
    }

    protected void renderText() {
        textRenderObject.textAlign = textAlign;
        textRenderObject.textVerticalAlign = textVerticalAlign;
        textRenderObject.text = caption;

        const textSize = size - vec2(iconsAreaSize, 0);
        auto textPosition = vec2(iconsAreaSize, 0) + absolutePosition;

        if (textAlign == Align.left) {
            textPosition.x += textLeftMargin;
        }
        else if (textAlign == Align.right) {
            textPosition.x -= textRightMargin;
        }

        renderer.renderText(textRenderObject, state, textPosition, textSize);
    }

    override void updateSize() {
        super.updateSize();

        if (widthType == SizeType.wrapContent) {
            size.x = iconsAreaSize + textLeftMargin + iconGaps * 2;
            textAlign = Align.right;

            if (getCaptionForMeasure().length != 0) {
                size.x += textRenderObject.textWidth;
                size.x += textRightMargin;
            }
        }
    }

    protected utf32string getCaptionForMeasure() {
        return caption;
    }

private:
    vec2 focusOffsets;
    float focusResize;
    float textLeftMargin;
    float textRightMargin;
    float iconGaps;
    vec2 iconOffsets;

    BaseRenderObject[string] skinRenderObjects;
    BaseRenderObject[string] skinFocusRenderObjects;

    string iconsGroup;
    float iconsAreaSize = 0;

    struct IconRengerObjectData {
        BaseRenderObject renderObject;
        Icon icon;
        vec2 offset = vec2(0, 0);
    }

    Array!IconRengerObjectData iconsRenderObjects;
    TextRenderObject textRenderObject;

    protected override void onCreate() {
        super.onCreate();

        const states = ["Leave", "Enter", "Click"];
        const keys = ["left", "center", "right"];

        foreach (string key; keys) {
            renderFactory.createQuad(skinRenderObjects, style, states, key);
            renderFactory.createQuad(skinFocusRenderObjects, style, "Focus", key);
        }

        const focusKey = style ~ ".Focus";

        with (manager.theme.tree) {
            focusOffsets = data.getVec2f(focusKey ~ ".offsets.0");
            focusResize = data.getNumber(focusKey ~ ".offsets.1");

            textRenderObject = renderFactory.createText(style, states);
            textRenderObject.text = caption;
            textLeftMargin = data.getNumber(style ~ ".textLeftMargin.0");
            textRightMargin = data.getNumber(style ~ ".textRightMargin.0");

            updateIcons();
        }
    }

    public final void updateIcons() {
        iconsRenderObjects.clear();
        iconsAreaSize = 0;

        with (manager.theme.tree) {
            const iconSize = manager.iconsRes.getIconsConfig(iconsGroup).size;
            iconOffsets = data.getVec2f(style ~ ".iconOffsets");
            const iconVerticalOffset = round((size.y - iconSize.y) / 2.0f);
            iconGaps = data.getNumber(style ~ ".iconGaps.0");
            float iconLastOffset = 0;

            foreach (iconName; icons) {
                const icon = manager.iconsRes.getIcon(iconsGroup, iconName);
                const iconOffset = iconLastOffset;
                iconLastOffset = iconOffset + iconSize.x + iconGaps;

                auto iconRenderObject = IconRengerObjectData(
                    renderFactory.createIcon(icon),
                    icon,
                    iconOffsets + vec2(iconOffset, iconVerticalOffset),
                );

                iconsRenderObjects.insert(iconRenderObject);
            }

            if (icons.length > 0)
                iconsAreaSize += iconLastOffset - iconGaps - iconGaps;
        }
    }
}
