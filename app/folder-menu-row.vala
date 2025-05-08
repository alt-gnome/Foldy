/*
 * Copyright (C) 2025 Vladimir Vaskov <rirusha@altlinux.org>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see
 * <https://www.gnu.org/licenses/gpl-3.0-standalone.html>.
 * 
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Foldy.Folder;

public sealed class Foldy.FolderMenuRow : Adw.ActionRow {

    Gtk.PopoverMenu popover;

    public string folder_id { get; set; }

    Settings settings;

    public FolderMenuRow () {
        Object ();
    }

    ~FolderMenuRow () {
        popover.unparent ();
    }

    public FolderMenuRow.with_folder_id (string folder_id) {
        Object (folder_id: folder_id);
    }

    construct {
        activatable = true;

        notify["folder-id"].connect (on_folder_id_changed);

        var menu = new Menu ();
        menu.append (_("Rename"), "row.rename");
        menu.append (_("Delete"), "row.delete");

        popover = new Gtk.PopoverMenu.from_model (menu) {
            has_arrow = false,
            position = Gtk.PositionType.BOTTOM,
            halign = get_direction () == Gtk.TextDirection.RTL ? Gtk.Align.END : Gtk.Align.START
        };

        popover.set_parent (this);

        popover.show.connect (() => {
            add_css_class ("has-open-popup");
        });
        popover.closed.connect (() => {
            remove_css_class ("has-open-popup");
        });

        install_action ("row.rename", null, (widget, action_name) => {
            var row = (FolderMenuRow) widget;

            var dialog = new RenameDialog (row.folder_id);
            dialog.present (row);
        });

        install_action ("row.delete", null, (widget, action_name) => {
            var row = (FolderMenuRow) widget;
            remove_folder (row.folder_id);
        });

        var gslp = new Gtk.GestureLongPress ();
        gslp.pressed.connect ((n_press, x, y) => {
            do_popup (x, y);
        });
        add_controller (gslp);

        var gsc = new Gtk.GestureClick ();
        gsc.button = 3;
        gsc.released.connect ((n_press, x, y) => {
            do_popup (x, y);
        });
        add_controller (gsc);
    }

    void do_popup (double x, double y) {
        var rect = Gdk.Rectangle ();

        if ((x.abs () - 0 < double.EPSILON || x > 0.0) &&
            (y.abs () - 0.0 < double.EPSILON || y > 0.0)) {
            rect.x = (int) x;
            rect.y = (int) y;

        } else {
            rect.x = 0;
            rect.y = get_height ();

            if (this.get_direction () == Gtk.TextDirection.RTL) {
                rect.x += get_width ();
            }
        }

        rect.width = 0;
        rect.height = 0;

        popover.set_pointing_to (rect);
        popover.popup ();
    }

    protected override void size_allocate (int width, int height, int baseline) {
        base.size_allocate (width, height, baseline);

        popover.present ();
    }

    void refresh () {
        title = get_folder_real_name (folder_id);
        subtitle = string.joinv (", ", get_folder_categories (folder_id));
    }

    void on_folder_id_changed () {
        if (settings != null) {
            settings.changed.disconnect (refresh);
            settings = null;
        }

        settings = new Settings.with_path (
            "org.gnome.desktop.app-folders.folder",
            "/org/gnome/desktop/app-folders/folders/%s/".printf (folder_id)
        );
        settings.changed.connect (refresh);

        refresh ();
    }
}
