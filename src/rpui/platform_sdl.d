module rpui.platform_sdl;

version(rpuiSdl2):

import core.stdc.stdio;
import std.conv;
import std.array;
import std.string;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import derelict.sdl2.image;

import gapi.opengl;

import rpui.primitives;
import rpui.events;
import rpui.events_observer;
import rpui.input;
import rpui.platform;

extern(C) void platformShowSystemCursor() {
    SDL_ShowCursor(SDL_ENABLE);
}

extern(C) void platformHideSystemCursor() {
    SDL_ShowCursor(SDL_DISABLE);
}

extern(C) void platformSetMousePosition(void* window, in int x, in int y) {
    SDL_WarpMouseInWindow(cast(SDL_Window*) window, x, y);
}

extern(C) float platformGetTicks() {
    return SDL_GetTicks();
}

extern(C) bool platformEventLoop(void* window, EventsObserver events) {
    SDL_Event event;

    while (SDL_PollEvent(&event)) {
        if (event.type == SDL_QUIT) {
            return false;
        }
        else if (event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED) {
            events.notify(WindowResizeEvent(event.window.data1, event.window.data2));
        }
        else if (event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_EXPOSED) {
            events.notify(WindowExposedEvent());
        }
        else if (event.type == SDL_MOUSEMOTION) {
            const button = createMouseButtonFromSdlState(event.motion.state);
            events.notify(MouseMoveEvent(event.motion.x, event.motion.y, button));
        }
        else if (event.type == SDL_MOUSEBUTTONDOWN) {
            const button = createMouseButtonFromButtonSdlEvent(event);
            events.notify(MouseDownEvent(event.button.x, event.button.y, button));

            switch (event.button.clicks) {
                case 2:
                    events.notify(DblClickEvent(event.button.x, event.button.y, button));
                    break;

                case 3:
                    events.notify(TripleClickEvent(event.button.x, event.button.y, button));
                    break;

                default:
                    // Ignore
            }
        }
        else if (event.type == SDL_MOUSEBUTTONUP) {
            const button = createMouseButtonFromButtonSdlEvent(event);
            events.notify(MouseUpEvent(event.button.x, event.button.y, button));
        }
        else if (event.type == SDL_MOUSEWHEEL) {
            events.notify(MouseWheelEvent(event.wheel.x, event.wheel.y));
        }
        else if (event.type == SDL_TEXTINPUT) {
            import std.stdio;
            puts("INPUT:");
            puts(&event.text.text[0]);
            // writeln(fromStringz(event.text.text));
            // const ch = fromStringz(dtext(event.text.text[0..4]).ptr)[0];
            // events.notify(TextEnteredEvent(ch));
        }
        else if (event.type == SDL_TEXTEDITING) {
            // import std.stdio;
            // if (event.edit.length >= 4) {
                // const ch = fromStringz(dtext(event.edit.text[0..4]).ptr)[0];
                // writeln(ch);
            // }
            import std.stdio;
            puts("EDIT:");
            puts(&event.edit.text[0]);
        }
        else if (event.type == SDL_KEYDOWN) {
            try {
                const key = to!(KeyCode)(to!(int)(event.key.keysym.sym));
                setKeyPressed(key, true);
                events.notify(KeyPressedEvent(key));
            } catch (Exception e) {
            }
        }
        else if (event.type == SDL_KEYUP) {
            try {
                const key = to!(KeyCode)(to!(int)(event.key.keysym.sym));
                events.notify(KeyReleasedEvent(key));
                setKeyPressed(key, false);
            } catch (Exception e) {
            }
        }
    }

    return true;
}

extern(C) void platformSwapWindow(void* window) {
    SDL_GL_SwapWindow(cast(SDL_Window*) window);
}

extern(C) void platformGapiDeleteContext(void* context) {
    SDL_GL_DeleteContext(context);
}

extern(C) void platformDestroyWindow(void* window) {
    SDL_DestroyWindow(cast(SDL_Window*) window);
}

extern(C) void platformShutdown() {
    SDL_Quit();
    TTF_Quit();
}

extern(C) void platformInit() {
    // Load shared libraries
    DerelictGL3.load();
    DerelictSDL2.load();
    DerelictSDL2Image.load();
    DerelictSDL2TTF.load();

    // Init
    if (SDL_Init(SDL_INIT_VIDEO) < 0)
        throw new Error("Failed to init SDL");

    if (TTF_Init() < 0)
        throw new Error("Failed to init SDL TTF");

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetSwapInterval(2);
}

extern(C) Window platformCreateWindow(in string title, uint width, uint height) {
    auto window = SDL_CreateWindow(
        toStringz(title),
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        width,
        height,
        SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE
    );

    if (window == null)
        throw new Error("SDL Error: " ~ to!string(SDL_GetError()));

    auto glContext = SDL_GL_CreateContext(window);

    if (glContext == null)
        throw new Error("SDL Error: " ~ to!string(SDL_GetError()));

    SDL_GL_SwapWindow(window);
    DerelictGL3.reload();

    return Window(window, glContext);
}

extern(C) void platformSetClipboardTextUtf8(in string text) {
    SDL_SetClipboardText(toStringz(text));
}

extern(C) void platformSetClipboardTextUtf32(in dstring text) {
    // writeln("PLATFORM COPY: ", data.charString);

    SDL_SetClipboardText(toStringz(to!string(text)));
}

extern(C) string platformGetClipboardTextUtf8() {
    return to!string(fromStringz(SDL_GetClipboardText()));
}

extern(C) dstring platformGetClipboardTextUtf32() {
    return to!dstring(fromStringz(SDL_GetClipboardText()));
}

extern(C) bool hasClipboardText() {
    return cast(bool) SDL_HasClipboardText();
}

extern(C) void platformSetTextInputRect(in Rect rect) {
    SDL_Rect sdlRect = SDL_Rect(
        cast(int) rect.left,
        cast(int) rect.top,
        cast(int) rect.width,
        cast(int) rect.height
    );
    SDL_SetTextInputRect(&sdlRect);
}
