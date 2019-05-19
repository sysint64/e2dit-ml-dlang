module rpui.render_objects;

import gapi.geometry;
import gapi.geometry_quad;
import gapi.texture;
import gapi.shader;
import gapi.vec;
import gapi.transform;
import gapi.text;

struct CameraView {
    mat4 mvpMatrix;
    float viewportWidth;
    float viewportHeight;
}

struct Geometry {
    Buffer indicesBuffer;
    Buffer verticesBuffer;
    Buffer texCoordsBuffer;

    VAO vao;
}

struct QuadMeasure {
    Transform2D transform;
    mat4 modelMatrix;
    mat4 mvpMatrix;
}

struct StatefulTextureQuad {
    Geometry geometry;
    Texture2D texture;
    Texture2DCoords[State] texCoords;
    Texture2DCoords[State] normilizedTexCoords;
}

struct TextureQuad {
    Geometry geometry;
    Texture2D texture;
    Texture2DCoords texCoords;
    Texture2DCoords normilizedTexCoords;
}

struct UiText {
    Geometry geometry;
    Text text;
    Texture2D texture;
    vec4 color = vec4(0, 0, 0, 1);
    vec2 offset = vec2(0, 0);
}

struct UiStatefulText {
    vec4[State] color;
    vec2[State] offset;
}

struct UiTextMeasure {
    vec2 size;
    mat4 mvpMatrix;
}

enum State {
    leave,
    enter,
    click,
}

enum ChainPart {
    left,
    center,
    right,
}

string getStateRdplName(in State state) {
    switch (state) {
        case State.leave:
            return "Leave";

        case State.enter:
            return "Enter";

        case State.click:
            return "Click";

        default:
            throw new Error("Unknown state");
    }
}

string getChainPartRdplName(in ChainPart part) {
    switch (part) {
        case ChainPart.left:
            return "left";

        case ChainPart.center:
            return "center";

        case ChainPart.right:
            return "right";

        default:
            throw new Error("Unknown part");
    }
}
