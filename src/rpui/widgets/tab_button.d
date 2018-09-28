/**
 * Copyright: © 2018 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpui.widgets.tab_button;

import rpui.widget;
import rpui.widgets.button;
import rpui.events;
import rpui.widgets.tab_layout;

final class TabButton : Button {
    @Field bool checked = false;

    private TabLayout parentTabLayout = null;

    this(in string style = "TabButton", in string iconsGroup = "icons") {
        super(style, iconsGroup);

        widthType = SizeType.wrapContent;
        focusable = false;
    }

    protected override void onPostCreate() {
        super.onPostCreate();

        // Because tab places in wrapper called Cell.
        parentTabLayout = cast(TabLayout) parent.parent;
        assert(parentTabLayout !is null);
    }

    override void progress() {
        super.progress();
        isClick = checked;
    }

    override void onMouseDown(in MouseDownEvent event) {
        super.onMouseDown(event);

        if (!isEnter)
            return;

        parentTabLayout.uncheckAllTabs();
        checked = true;
        parentTabLayout.parent.progress();
    }
}
