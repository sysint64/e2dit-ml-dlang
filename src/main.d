module main;

import std.stdio;

import e2ml.data;
import e2ml.stream;
import e2ml.lexer;
import e2ml.token;
import e2ml.node;
import e2ml.value;

import gapi.shader;
import gapi.texture;

import ui.widget;
import ui.cursor;

import editor.mapeditor;

import derelict.opengl3.gl;
import derelict.freetype.ft;

import derelict.sfml2.system;
import derelict.sfml2.window;
import derelict.sfml2.graphics;


void writeindent(in int level = 0) {
    for (int i = 0; i < level*4; ++i) {
        write(" ");
    }
}


void traverse(Node node, in int level = 0) {
    foreach (Node a; node.children) {
        writeindent(level);

        if (cast(Value)a)
            writeln(a.name ~ "(" ~ a.path ~ "): ", a.toString());
        else
            writeln(a.name ~ "(" ~ a.path ~ ")");

        traverse(a, level+1);
    }
}

void handleEvent(sfEventType type) {

}

void main() {
    DerelictSFML2System.load();
    DerelictSFML2Window.load();
    DerelictSFML2Graphics.load();

    DerelictFT.load();
    DerelictGL.load();

    auto app = MapEditor.getInstance();
    app.run();
}
