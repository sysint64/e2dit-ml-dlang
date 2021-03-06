module rpui.shortcuts;

import std.stdio;
import std.string;
import std.conv;
import std.path;

import rpdl;
import rpdl.exception;
import rpui.input;
import rpui.widget;
import rpui.paths;

struct Shortcut {
    bool shift;
    bool ctrl;
    bool alt;
    KeyCode key;

    private this(bool shift, bool ctrl, bool alt, KeyCode key) {
        this.shift = shift;
        this.ctrl = ctrl;
        this.alt = alt;
        this.key = key;
    }

    /**
     * Fill `Shortcut` fields from string.
     *
     * Example:
     * ---
     * readKey("Ctrl");  // will assign `true` to `ctrl`
     * readKey("A");  // will assign `input.KeyCode.A` to `key`
     * ---
     */
    void readKey(in string key) {
        switch (key) {
            case "Ctrl":
                this.ctrl = true;
                break;

            case "Shift":
                this.shift = true;
                break;

            case "Alt":
                this.alt = true;
                break;

            default:
                this.key = to!KeyCode(key);
        }
    }

    /**
     * Parsing shortcut from string - all keys will split by '+' symbol.
     *
     * Example:
     * ---
     * Shortcut("Ctrl+C");  // ctrl = true; key = KeyCode.C;
     * Shortcut("Ctrl+Shift+S");  // ctrl = true; shift = true; key = KeyCode.C;
     * ---
     */
    this(in string shortcut) {
        foreach (string key; shortcut.split("+")) {
            readKey(key);
        }
    }
}

final class Shortcuts {
    private ShortcutAction[string] shortcuts;  /// Available shortcuts.
    private RpdlTree shortcutsData;  /// Shortcuts declared in `rpdl` file.

    /// Action to be invoked when shortcut is pressed.
    struct ShortcutAction {
        /// Not yet used.
        enum Type {
            simpleWidgetListener,
            simpleFunction
        }

        Shortcut[] shortcuts;  /// Composition of shortcuts e.g. Ctrl+X Ctrl+S.

        /**
         * Create action from `shortcutString` - constructor will fill `shortcuts`
         * by parsing string - all shortcuts will split by space symbol.
         *
         * Example:
         * ---
         * // Corresponds to: shortcuts ~= Shortcut("Ctrl+X")
         * ShortcutAction("Ctrl+X")
         *
         * // Corresponds to: shortcuts ~= Shortcut("Ctrl+X") ~ Shortcut("Alt+Shift+C")
         * ShortcutAction("Ctrl+X Alt+C")
         * ---
         */
        this(in string shortcutString, void delegate() action = null) {
            foreach (shortcut; shortcutString.split(" ")) {
                shortcuts ~= Shortcut(shortcut);
            }

            this.action = action;
        }

        void delegate() action;
    }

    /// Load shortcuts from `rpdl` file by `fileName`; `fileName` is absolute.
    this(in string fileName) {
        shortcutsData = new RpdlTree(dirName(fileName));
        shortcutsData.load(baseName(fileName), RpdlTree.FileType.text);
    }

    /// Load shortcuts from `rpdl` file relative to $(I resources/ui/shortcuts).
    static createFromFile(in string fileName) {
        const paths = createPathes();
        const string path = buildPath(paths.resources, "ui", "shortcuts", fileName);
        return new Shortcuts(path);
    }

    /// Handle on key released and invoke action if shortcut is pressed.
    void onKeyReleased(in KeyCode key) {
        foreach (shortcut; shortcuts) {
            if (doShortcut(shortcut))
                return;
        }
    }

    /// Attach `action` to particular shortcut placed by `path` (in `rpdl` file)
    void attachByPath(in string path, void delegate() action) {
        try {
            const shortcut = shortcutsData.data.getString(path ~ ".0");
            auto shortcutAction = Shortcuts.ShortcutAction(shortcut, action);

            shortcuts[path] = shortcutAction;
        } catch (NotFoundException) {
            debug assert(false, "Not found shortcut with path " ~ path);
        }
    }

    /// Attach `action` to particular shortcut
    void attach(in string shortcut, void delegate() action) {
        auto shortcutAction = Shortcuts.ShortcutAction(shortcut, action);
        shortcuts[shortcut] = shortcutAction;
    }

    string getShourtcutString(in string path) {
        return shortcutsData.data.getString(path ~ ".0");
    }

    ///
    void merge(Shortcuts shortcuts) {
        shortcutsData.merge(shortcuts.shortcutsData);
    }

    /// Invoke shortcut action if all keys from shortcut is pressed.
    private bool doShortcut(in ShortcutAction shortcutAction) {
        const Shortcut shortcut = shortcutAction.shortcuts[0];

        if (isKeyPressed(shortcut.key) &&
            testKeyState(KeyCode.Shift, shortcut.shift) &&
            testKeyState(KeyCode.Ctrl, shortcut.ctrl) &&
            testKeyState(KeyCode.Alt, shortcut.alt))
        {
            shortcutAction.action();
            return true;
        }

        return false;
    }
}
