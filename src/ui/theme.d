module ui.theme;

import accessors;
import std.path;
import std.file;
import std.exception;
import application;
import e2ml;
import gapi;


class ThemeFont : gapi.Font {
    this(in string fileName, in uint fontSize) {
        super(fileName);
        this.defaultFontSize = fontSize;
    }

    static ThemeFont createFromFile(in string relativeFileName, in uint fontSize) {
        Application app = Application.getInstance();
        const string absoluteFileName = buildPath(app.resourcesDirectory, "fonts",
                                                  relativeFileName);
        ThemeFont font = new ThemeFont(absoluteFileName, fontSize);
        return font;
    }

private:
    @Read @Write("private")
    uint defaultFontSize_;

    mixin(GenerateFieldAccessors);
}


class Theme {
    this(in string theme) {
        app = Application.getInstance();

        if (!load(theme)) {
            load(app.settings.defaultTheme, true);
        }

        loadGeneral();
    }

private:
    @Read @Write("private") {
        e2ml.Data data_;
        gapi.Texture skin_;
        ThemeFont regularFont_;
    }

    mixin(GenerateFieldAccessors);

private:
    Application app;

    bool load(in string theme, in bool critical = false) {
        string dir = buildPath(app.resourcesDirectory, "ui", "themes", theme);
        data = new Data(dir);
        string msg = collectExceptionMsg(data.load("theme.e2t"));
        bool isSuccess = msg is null;

        if (isSuccess) {
            loadSkin(theme);
        } else if (critical) {
            app.criticalError(msg);
        }

        return isSuccess;
    }

    void loadGeneral() {
        string regularFontFileName = data.optString("General.regularFont.0", "ttf-dejavu/DejaVuSans.ttf");
        uint regularFontSize = data.optInteger("General.regularFont.1", 12);
        regularFont = ThemeFont.createFromFile(regularFontFileName, regularFontSize);
    }

    bool loadSkin(in string theme, in bool critical = false) {
        string path = buildPath(app.resourcesDirectory, "ui", "themes", theme, "controls.png");
        skin = new gapi.Texture(path);
        return true;
    }
}
