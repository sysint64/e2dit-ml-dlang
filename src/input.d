module input;

import derelict.sfml2.window;

import std.string;


// break the dependence on SFML Mouse
enum MouseButton {
    mouseNone = -1,
    mouseLeft = sfMouseLeft,
    mouseRight = sfMouseRight,
    mouseMiddle = sfMouseMiddle,
};


// break the dependence on SFML Keyboard
enum KeyCode {
    A = sfKeyA,
    B = sfKeyB,
    C = sfKeyC,
    D = sfKeyD,
    E = sfKeyE,
    F = sfKeyF,
    G = sfKeyG,
    H = sfKeyH,
    I = sfKeyI,
    J = sfKeyJ,
    K = sfKeyK,
    L = sfKeyL,
    M = sfKeyM,
    N = sfKeyN,
    O = sfKeyO,
    P = sfKeyP,
    Q = sfKeyQ,
    R = sfKeyR,
    S = sfKeyS,
    T = sfKeyT,
    U = sfKeyU,
    V = sfKeyV,
    W = sfKeyW,
    X = sfKeyX,
    Y = sfKeyY,
    Z = sfKeyZ,
    Num0 = sfKeyNum0,
    Num1 = sfKeyNum1,
    Num2 = sfKeyNum2,
    Num3 = sfKeyNum3,
    Num4 = sfKeyNum4,
    Num5 = sfKeyNum5,
    Num6 = sfKeyNum6,
    Num7 = sfKeyNum7,
    Num8 = sfKeyNum8,
    Num9 = sfKeyNum9,
    Escape = sfKeyEscape,
    LControl = sfKeyLControl,
    LShift = sfKeyLShift,
    LAlt = sfKeyLAlt,
    LSystem = sfKeyLSystem,
    RControl = sfKeyRControl,
    RShift = sfKeyRShift,
    RAlt = sfKeyRAlt,
    RSystem = sfKeyRSystem,
    Menu = sfKeyMenu,
    LBracket = sfKeyLBracket,
    RBracket = sfKeyRBracket,
    SemiColon = sfKeySemiColon,
    Comma = sfKeyComma,
    Period = sfKeyPeriod,
    Quote = sfKeyQuote,
    Slash = sfKeySlash,
    BackSlash = sfKeyBackSlash,
    Tilde = sfKeyTilde,
    Equal = sfKeyEqual,
    Dash = sfKeyDash,
    Space = sfKeySpace,
    Return = sfKeyReturn,
    Back = sfKeyBack,
    Tab = sfKeyTab,
    PageUp = sfKeyPageUp,
    PageDown = sfKeyPageDown,
    End = sfKeyEnd,
    Home = sfKeyHome,
    Insert = sfKeyInsert,
    Delete = sfKeyDelete,
    Add = sfKeyAdd,
    Subtract = sfKeySubtract,
    Multiply = sfKeyMultiply,
    Divide = sfKeyDivide,
    Left = sfKeyLeft,
    Right = sfKeyRight,
    Up = sfKeyUp,
    Down = sfKeyDown,
    Numpad0 = sfKeyNumpad0,
    Numpad1 = sfKeyNumpad1,
    Numpad2 = sfKeyNumpad2,
    Numpad3 = sfKeyNumpad3,
    Numpad4 = sfKeyNumpad4,
    Numpad5 = sfKeyNumpad5,
    Numpad6 = sfKeyNumpad6,
    Numpad7 = sfKeyNumpad7,
    Numpad8 = sfKeyNumpad8,
    Numpad9 = sfKeyNumpad9,
    F1 = sfKeyF1,
    F2 = sfKeyF2,
    F3 = sfKeyF3,
    F4 = sfKeyF4,
    F5 = sfKeyF5,
    F6 = sfKeyF6,
    F7 = sfKeyF7,
    F8 = sfKeyF8,
    F9 = sfKeyF9,
    F10 = sfKeyF10,
    F11 = sfKeyF11,
    F12 = sfKeyF12,
    F13 = sfKeyF13,
    F14 = sfKeyF14,
    F15 = sfKeyF15,
    Pause = sfKeyPause,
    Count = sfKeyCount,
    Shift,
    Ctrl,
    Alt,
};

private static bool[KeyCode] keyPressed;

void setKeyPressed(in KeyCode key, in bool pressed) {
    keyPressed[key] = pressed;

    with (KeyCode) {
        keyPressed[Shift] = isKeyPressed(LShift) || isKeyPressed(RShift);
        keyPressed[Ctrl] = isKeyPressed(LControl) || isKeyPressed(RControl);
        keyPressed[Alt] = isKeyPressed(LAlt) || isKeyPressed(RAlt);
    }
}

bool isKeyPressed(in KeyCode key) {
    if (key !in keyPressed)
        return false;

    return keyPressed[key];
}

bool testKeyState(in KeyCode key, in bool state) {
    if (key !in keyPressed)
        return false;

    return keyPressed[key] == state;
}
