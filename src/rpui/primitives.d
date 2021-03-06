module rpui.primitives;

import gapi.vec;
import std.conv : to;
import std.math;
public import rpui.alignment;

alias utf32char = dchar;
alias utf32string = dstring;

enum Orientation {horizontal, vertical}

struct FrameRect {
    float left = 0;
    float top = 0;
    float right = 0;
    float bottom = 0;

    this(in float left, in float top, in float right, in float bottom) {
        this.left = left;
        this.top = top;
        this.right = right;
        this.bottom = bottom;
    }

    this(in vec4 rect) {
        this.left = rect.x;
        this.top = rect.y;
        this.right = rect.z;
        this.bottom = rect.w;
    }

    this(in Rect rect) {
        this.left = rect.left;
        this.top = rect.top;
        this.right = rect.left + rect.width;
        this.bottom = rect.top + rect.height;
    }
}

const emptyRect = Rect(0, 0, 0, 0);
const emptyFrameRect = FrameRect(0, 0, 0, 0);

struct Rect {
    float left;
    float top;
    float width;
    float height;

    @property void point(in vec2 val) {
        left = val.x;
        top = val.y;
    }

    @property void size(in vec2 val) {
        width = val.x;
        height = val.y;
    }

    @property vec2 point() const {
        return vec2(left, top);
    }

    @property vec2 size() const {
        return vec2(width, height);
    }

    // piar of points: (left, top), (right, bottom)
    @property FrameRect absolute() const {
        return FrameRect(left, top, left + width, top + height);
    }

    this(in float left, in float top, in float width, in float height) {
        this.left = left;
        this.top = top;
        this.width = width;
        this.height = height;
    }

    this(in vec4 rect) {
        this.left = rect.x;
        this.top = rect.y;
        this.width = rect.z;
        this.height = rect.w;
    }

    this(in FrameRect rect) {
        this.left = rect.left;
        this.top = rect.top;
        this.width = abs(rect.right - rect.left);
        this.height = abs(rect.bottom - rect.top);
    }

    this(in vec2 point, in vec2 size) {
        this.left = point.x;
        this.top = point.y;
        this.width = size.x;
        this.height = size.y;
    }
}

struct IntRect {
    int left;
    int top;
    int width;
    int height;

    @property void point(in vec2i val) {
        left = val.x;
        top = val.y;
    }

    @property void size(in vec2i val) {
        width = val.x;
        height = val.y;
    }

    this(in int left, in int top, in int width, in int height) {
        this.left = left;
        this.top = top;
        this.width = width;
        this.height = height;
    }

    this(in float left, in float top, in float width, in float height) {
        this.left = to!(int)(left);
        this.top = to!(int)(top);
        this.width = to!(int)(width);
        this.height = to!(int)(height);
    }

    this(in Rect rect) {
        this.left = to!(int)(rect.left);
        this.top = to!(int)(rect.top);
        this.width = to!(int)(rect.width);
        this.height = to!(int)(rect.height);
    }

    this(in vec4i rect) {
        this.left = rect.x;
        this.top = rect.y;
        this.width = rect.z;
        this.height = rect.w;
    }

    this(in vec4 rect) {
        this.left = to!(int)(rect.x);
        this.top = to!(int)(rect.y);
        this.width = to!(int)(rect.z);
        this.height = to!(int)(rect.w);
    }

    this(in vec2i point, in vec2i size) {
        this.left = point.x;
        this.top = point.y;
        this.width = size.x;
        this.height = size.y;
    }

    this(in vec2 point, in vec2 size) {
        this.left = to!(int)(point.x);
        this.top = to!(int)(point.y);
        this.width = to!(int)(size.x);
        this.height = to!(int)(size.y);
    }

    this(in FrameRect rect) {
        this.left = to!int(rect.left);
        this.top = to!int(rect.top);
        this.width = abs(to!int(rect.right - rect.left));
        this.height = abs(to!int(rect.bottom - rect.top));
    }
}
