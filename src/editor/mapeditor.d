module editor.mapeditor;

import input;
import patterns.singleton;
import application;

import gapi.camera;
import gapi.geometry;
import gapi.geometry_factory;
import gapi.shader;
import gapi.texture;
import gapi.base_object;
import gapi.font;
import gapi.text;

import ui;
import ui.widgets.button;

import math.linalg;
import std.stdio;

import derelict.sfml2.graphics;
import derelict.opengl3.gl;


class MapEditor: Application {
    mixin Singleton!(MapEditor);
    private this() {}

    override void render() {
        onPreRender(camera);
        camera.update();
        // camera.

        // Texture texture = font.getTexture(text.textSize);

        // texture.bind();
        // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	// glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

        shader.bind();
        shader.setUniformMatrix("MVP", sprite.lastMVPMatrix);
        shader.setUniformTexture("texture", texture);

        sprite.render(camera);
        // shader.setUniformTexture("texture", texture);

        sprite.rotate(0.01f);
        // sprite.move(0.0f, 1.0f);
        sprite.render(camera);

        // shader.setUniformMatrix("MVP", text.lastMVPMatrix);
        // shader.setUniformTexture("texture", font.getTexture(text.textSize));
        // text.render(camera);
        // camera.zoom += 0.01f;

        uiManager.render(camera);
        onPostRender(camera);
    }

    Camera camera;
    Geometry spriteGeometry;
    BaseObject sprite;
    Shader shader;
    Texture texture;
    Font font;
    Text text;
    ui.Manager uiManager;

    override void onCreate() {
        camera = new Camera(viewportWidth, viewportHeight);
        // spriteGeometry = new SpriteGeometry(false, true, true);

        spriteGeometry = GeometryFactory.createSprite(false, true);
        sprite = new BaseObject(spriteGeometry);
        shader = new Shader(resourcesDirectory ~ "/shaders/GL2/transform.glsl");
        texture = new Texture(resourcesDirectory ~ "/test.jpg");

        camera.position = vec2(0.0f, 0.0f);
        camera.zoom = 1.0f;

        sprite.position = vec2(200.0f, 100.0f);
        sprite.scaling = vec2(200.0f, 200.0f);
        sprite.rotation = 0.5f;

        // shader.bind();
        // texture.bind();
        spriteGeometry.bind();

        font = new Font(resourcesDirectory ~ "/fonts/ttf-dejavu/DejaVuSans.ttf");
        text = new Text(spriteGeometry, font, "Hello world!");

        text.position = vec2(30.0f, 30.0f);
        uiManager = new ui.Manager(settings.theme);
        Button button = new Button("Button");
        uiManager.addWidget(button);
    }

    override void onKeyPressed(in KeyCode key) {
        super.onKeyPressed(key);
    }

    override void onKeyReleased(in KeyCode key) {
        super.onKeyReleased(key);
    }

    override void onTextEntered(in utfchar key) {
        super.onTextEntered(key);
    }

    override void onMouseDown(in uint x, in uint y, in MouseButton button) {
        super.onMouseDown(x, y, button);
    }

    override void onMouseUp(in uint x, in uint y, in MouseButton button) {
        super.onMouseUp(x, y, button);
    }

    override void onDblClick(in uint x, in uint y, in MouseButton button) {
        super.onDblClick(x, y, button);
    }

    override void onMouseMove(in uint x, in uint y) {
        super.onMouseMove(x, y);
    }

    override void onMouseWheel(in uint dx, in uint dy) {
        super.onMouseWheel(dx, dy);
    }

    override void onResize(in uint width, in uint height) {
        super.onResize(width, height);

        camera.viewportWidth  = viewportWidth;
        camera.viewportHeight = viewportHeight;
    }
}
