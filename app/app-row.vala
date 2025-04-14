/* Copyright 2024 Rirusha
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

[GtkTemplate (ui = "/org/altlinux/Foldy/ui/app-row.ui")]
public abstract class Foldy.AppRow : Adw.ActionRow {

    [GtkChild]
    unowned Gtk.Image icon_image;
    [GtkChild]
    unowned Gtk.Image action_image;

    public AppInfo app_info { get; construct; }

    bool _selection_enabled = false;
    public bool selection_enabled {
        get {
            return _selection_enabled;
        }
        set {
            _selection_enabled = value;

            if (!value) {
                selected = false;
            }
        }
    }

    public abstract string selected_style_class { get; }

    bool _selected = false;
    public new bool selected {
        get {
            return _selected;
        }
        set {
            _selected = value;

            if (selected) {
                add_css_class (selected_style_class);
                action_image.icon_name = "check-symbolic";
                action_image.remove_css_class ("dim-label");

            } else {
                remove_css_class (selected_style_class);
                action_image.icon_name = "uncheck-symbolic";
                action_image.add_css_class ("dim-label");
            }
        }
    }

    construct {
        title = app_info.get_display_name ();
        subtitle = app_info.get_id ();

        icon_image.set_from_gicon (app_info.get_icon ());

        var lp = new Gtk.GestureLongPress ();
        //  lp.delay_factor = 0.8;
        lp.pressed.connect ((x, y) => {
            if (!sensitive) {
                return;
            }

            if (!selection_enabled) {
                selection_enabled = true;
                selected = true;

            } else {
                selected = !selected;
            }
        });
        add_controller (lp);
    }
}
