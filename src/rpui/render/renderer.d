module rpui.render.renderer;

import std.math;

import gapi.vec;
import gapi.transform;
import gapi.shader;
import gapi.shader_uniform;
import gapi.texture;
import gapi.geometry;
import gapi.geometry_quad;
import gapi.opengl;
import gapi.font;
import gapi.text;

import rpui.events;
import rpui.theme;
import rpui.widget;
import rpui.render.components;
import rpui.primitives;

interface Renderer {
    void onCreate(Widget widget, in string style);

    void onRender();

    void onProgress(in ProgressEvent event);
}

class DummyRenderer : Renderer {
    override void onCreate(Widget widget, in string style) {
    }

    override void onRender() {
    }

    override void onProgress(in ProgressEvent event) {
    }
}

interface RenderSystem {
    void onRender();
}

void renderTexAtlasQuad(
    in Theme theme,
    in StatefulTexAtlasTextureQuad quad,
    in QuadTransforms transforms,
    in float alpha = 1.0f,
) {
    renderTexAtlasQuad(
        theme,
        quad.geometry,
        quad.texture,
        quad.texCoords[quad.state].normilizedTexCoords,
        transforms,
        alpha
    );
}

void renderTexAtlasQuad(
    in Theme theme,
    in TexAtlasTextureQuad quad,
    in QuadTransforms transforms,
    in float alpha = 1.0f,
) {
    renderTexAtlasQuad(
        theme,
        quad.geometry,
        quad.texture,
        quad.texCoords.normilizedTexCoords,
        transforms,
        alpha
    );
}

void renderTexAtlasQuad(
    in Theme theme,
    in Geometry geometry,
    in Texture2D texture,
    in Texture2DCoords texCoord,
    in QuadTransforms transforms,
    in float alpha = 1.0f,
) {
    const shader = theme.shaders.textureAtlasShader;
    bindShaderProgram(shader);

    setShaderProgramUniformMatrix(shader, "MVP", transforms.mvpMatrix);
    setShaderProgramUniformTexture(shader, "utexture", texture, 0);
    setShaderProgramUniformVec2f(shader,"texOffset", texCoord.offset);
    setShaderProgramUniformVec2f(shader,"texSize", texCoord.size);
    setShaderProgramUniformFloat(shader, "alpha", alpha);

    bindVAO(geometry.vao);
    bindIndices(geometry.indicesBuffer);
    renderIndexedGeometry(cast(uint) quadIndices.length, GL_TRIANGLE_STRIP);
}

void renderColorQuad(
    in Theme theme,
    in Geometry geometry,
    in vec4 color,
    in QuadTransforms transforms
) {
    const shader = theme.shaders.colorShader;
    bindShaderProgram(shader);

    setShaderProgramUniformMatrix(shader, "MVP", transforms.mvpMatrix);
    setShaderProgramUniformVec4f(shader, "color", color);

    bindVAO(geometry.vao);
    bindIndices(geometry.indicesBuffer);
    renderIndexedGeometry(cast(uint) quadIndices.length, GL_TRIANGLE_STRIP);
}

void renderColorLines(
    in Theme theme,
    in LinesGeometry geometry,
    in vec4 color,
    in LinesTransforms transforms
) {
    const shader = theme.shaders.colorShader;
    bindShaderProgram(shader);

    setShaderProgramUniformMatrix(shader, "MVP", transforms.mvpMatrix);
    setShaderProgramUniformVec4f(shader, "color", color);

    bindVAO(geometry.vao);
    bindIndices(geometry.indicesBuffer);

    renderIndexedGeometry(geometry.pointsCount, GL_LINES);
}

void renderBlock(in Theme theme, in Block block, in BlockTransforms transforms, in float alpha = 1.0f) {
    renderHorizontalChain(theme, block.topChain, transforms.topChain, Widget.PartDraws.all, alpha);
    renderHorizontalChain(theme, block.bottomChain, transforms.bottomChain, Widget.PartDraws.all, alpha);
    renderHorizontalChain(theme, block.middleChain, transforms.middleChain, Widget.PartDraws.all, alpha);
}

void renderHorizontalChain(
    in Theme theme,
    in StatefulChain chain,
    in HorizontalChainTransforms transforms,
    in Widget.PartDraws partDraws = Widget.PartDraws.all,
    in float alpha = 1.0f
) {
    renderHorizontalChain(
        theme,
        chain.parts,
        chain.texCoords[chain.state],
        transforms,
        partDraws,
        alpha
    );
}

void renderHorizontalChain(
    in Theme theme,
    in Chain chain,
    in HorizontalChainTransforms transforms,
    in Widget.PartDraws partDraws = Widget.PartDraws.all,
    in float alpha = 1.0f
) {
    renderHorizontalChain(
        theme,
        chain.parts,
        chain.texCoords,
        transforms,
        partDraws,
        alpha
    );
}

void renderHorizontalChain(
    in Theme theme,
    in TextureQuad[ChainPart] parts,
    in Texture2DCoords[ChainPart] texCoords,
    in HorizontalChainTransforms transforms,
    in Widget.PartDraws partDraws = Widget.PartDraws.all,
    in float alpha = 1.0f
) {
    if (partDraws == Widget.PartDraws.left || partDraws == Widget.PartDraws.all) {
        renderTexAtlasQuad(
            theme,
            parts[ChainPart.left].geometry,
            parts[ChainPart.left].texture,
            texCoords[ChainPart.left],
            transforms.quadTransforms[ChainPart.left],
            alpha
        );
    }

    if (partDraws == Widget.PartDraws.right || partDraws == Widget.PartDraws.all) {
        renderTexAtlasQuad(
            theme,
            parts[ChainPart.right].geometry,
            parts[ChainPart.right].texture,
            texCoords[ChainPart.right],
            transforms.quadTransforms[ChainPart.right],
            alpha
        );
    }

    renderTexAtlasQuad(
        theme,
        parts[ChainPart.center].geometry,
        parts[ChainPart.center].texture,
        texCoords[ChainPart.center],
        transforms.quadTransforms[ChainPart.center],
        alpha
    );
}

void renderVerticalChain(
    in Theme theme,
    in TextureQuad[ChainPart] parts,
    in Texture2DCoords[ChainPart] texCoords,
    in HorizontalChainTransforms transforms
) {
    renderTexAtlasQuad(
        theme,
        parts[ChainPart.top].geometry,
        parts[ChainPart.top].texture,
        texCoords[ChainPart.top],
        transforms.quadTransforms[ChainPart.top]
    );

    renderTexAtlasQuad(
        theme,
        parts[ChainPart.bottom].geometry,
        parts[ChainPart.bottom].texture,
        texCoords[ChainPart.bottom],
        transforms.quadTransforms[ChainPart.bottom]
    );

    renderTexAtlasQuad(
        theme,
        parts[ChainPart.middle].geometry,
        parts[ChainPart.middle].texture,
        texCoords[ChainPart.middle],
        transforms.quadTransforms[ChainPart.middle]
    );
}

void renderUiText(
    in Theme theme,
    in StatefulUiText text,
    in UiTextTransforms transforms
) {
    renderUiText(
        theme,
        text.render,
        text.attrs[text.state],
        transforms
    );
}

void renderUiText(
    in Theme theme,
    in UiTextRender text,
    in UiTextAttributes attrs,
    in UiTextTransforms transforms
) {
    bindShaderProgram(theme.shaders.textShader);

    setShaderProgramUniformVec4f(theme.shaders.textShader, "color", attrs.color);
    setShaderProgramUniformTexture(theme.shaders.textShader, "utexture", text.texture, 0);
    setShaderProgramUniformMatrix(theme.shaders.textShader, "MVP", transforms.mvpMatrix);

    bindVAO(text.geometry.vao);
    bindIndices(text.geometry.indicesBuffer);

    renderIndexedGeometry(cast(uint) quadIndices.length, GL_TRIANGLE_STRIP);
}
