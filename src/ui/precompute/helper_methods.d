module ui.precompute.helper_methods;


mixin template PrecomputeHelperMethods() {
    void precomputeElement(in size_t n, in string element, in string params) {
        immutable string selector = element ~ "." ~ params;
        PrecomputeCoords coord;

        with (manager.theme) {
            coord.offset.x = data.getInteger(selector ~ ".0");
            coord.offset.y = data.getInteger(selector ~ ".1");
            coord.size.x = data.getInteger(selector ~ ".2");
            coord.size.y = data.getInteger(selector ~ ".3");

            coord.normOffset.x = to!float(coord.offset.x) / to!float(skin.width);
            coord.normOffset.y = to!float(coord.offset.y) / to!float(skin.height);
            coord.normSize.x = to!float(coord.size.x) / to!float(skin.width);
            coord.normSize.y = to!float(coord.size.y) / to!float(skin.height);
        }

        precomputeCoords[n] = coord;
    }

    void precomputeText(in size_t n, in string element,
                        in string textColorParam  = "textColor",
                        in string textOffsetParam = "textOffset")
    {
        immutable string textColorSelector  = element ~ "." ~ textColorParam;
        immutable string textOffsetSelector = element ~ "." ~ textOffsetParam;

        PrecomputeText text;

        with (manager.theme) {
            text.color.r = data.getNumber(textColorSelector ~ ".0") / 255.0f;
            text.color.g = data.getNumber(textColorSelector ~ ".1") / 255.0f;
            text.color.b = data.getNumber(textColorSelector ~ ".2") / 255.0f;

            text.offset.x = data.getInteger(textOffsetSelector ~ ".0");
            text.offset.y = data.getInteger(textOffsetSelector ~ ".1");
        }
    }
}
