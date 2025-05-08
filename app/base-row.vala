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

[GtkTemplate (ui = "/org/altlinux/Foldy/ui/base-row.ui")]
public abstract class Foldy.BaseRow : Adw.Bin {

    [GtkChild]
    unowned Gtk.Image selection_image;

    public string title { get; set; }

    public string subtitle { get; set; }

    public Icon? gicon { get; set; }

    public string icon_name { get; set; }

    public bool activatable {
        get {
            return has_css_class ("activatable");
        }
        set {
            if (value) {
                add_css_class ("activatable");
            } else {
                remove_css_class ("activatable");
            }
        }
    }

    bool _selection_enabled = false;
    public bool selection_enabled {
        get {
            return _selection_enabled;
        }
        set {
            if (!value) {
                selected = false;
            }

            _selection_enabled = value;
        }
    }

    public abstract string selected_style_class { get; }

    bool _selected = false;
    public new bool selected {
        get {
            return _selected;
        }
        set {
            if (!selection_enabled) {
                return;
            }

            _selected = value;

            if (selected) {
                add_css_class (selected_style_class);
                selection_image.icon_name = "check-symbolic";
                selection_image.remove_css_class ("dimmed");

            } else {
                remove_css_class (selected_style_class);
                selection_image.icon_name = "uncheck-symbolic";
                selection_image.add_css_class ("dimmed");
            }
        }
    }

    public signal void activated ();

    static construct {
        set_css_name ("row");
    }

    [GtkCallback]
    void on_pressed () {
        if (activatable) {
            activated ();
        }
    }

    [GtkCallback]
    bool has_icon (Icon? icon, string? icon_name) {
        if (icon_name == null && icon == null) {
            return false;

        } else if (icon_name != null) {
            return icon_name.length > 0;
        }

        return true;
    }

    [GtkCallback]
    bool string_is_not_empty (string? s) {
        if (s == null) {
            return false;
        }

        return s.length > 0;
    }
}
