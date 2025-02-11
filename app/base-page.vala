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

[GtkTemplate (ui = "/org/altlinux/Foldy/ui/base-page.ui")]
public abstract class Foldy.BasePage : Adw.NavigationPage {

    [GtkChild]
    unowned Gtk.ToggleButton search_button;
    [GtkChild]
    unowned Gtk.SearchEntry search_entry;
    [GtkChild]
    unowned Gtk.ToggleButton selection_button;
    [GtkChild]
    unowned Gtk.Stack list_stack;
    [GtkChild]
    unowned Gtk.ListBox list_box;
    [GtkChild]
    unowned Adw.Bin bottom_start;
    [GtkChild]
    unowned Adw.Bin bottom_center;
    [GtkChild]
    unowned Adw.Bin bottom_end;
    [GtkChild]
    unowned Gtk.Revealer search_revealer;

    public Adw.NavigationView nav_view { get; construct; }

    public Gtk.Widget bottom_start_widget {
        get {
            return bottom_start.child;
        }
        set {
            bottom_start.child = value;
        }
    }

    public Gtk.Widget bottom_center_widget {
        get {
            return bottom_center.child;
        }
        set {
            bottom_center.child = value;
        }
    }

    public Gtk.Widget bottom_end_widget {
        get {
            return bottom_end.child;
        }
        set {
            bottom_end.child = value;
        }
    }

    public Gtk.ListBox row_box {
        get {
            return list_box;
        }
    }

    public bool can_select { get; set; default = false; }

    public bool selection_enabled { get; set; default = false; }

    uint32 total_visible_rows = 0;

    construct {
        AppInfoMonitor.get ().changed.connect (refresh);

        assert (nav_view != null);

        showing.connect (() => {
            can_pop = false;
        });

        shown.connect (() => {
            can_pop = true;
        });

        hiding.connect (() => {
            can_pop = false;
        });

        hidden.connect (() => {
            can_pop = true;
        });

        search_revealer.notify["reveal-child"].connect (() => {
            if (search_revealer.reveal_child) {
                Foldy.Application.get_default ().active_window.focus_widget = search_entry;
            }
        });

        search_entry.search_changed.connect (() => {
            apply_filter ();
        });

        search_button.notify["active"].connect (() => {
            if (!search_button.active) {
                search_entry.text = "";
            }
        });

        list_box.set_filter_func ((row) => {
            if (filter (row, search_entry.text)) {
                total_visible_rows += 1;
                return true;
            } else {
                return false;
            }
        });

        refresh ();
    }

    public void refresh () {
        update_list ();
        apply_filter ();
    }

    protected abstract void update_list ();

    [GtkCallback]
    protected abstract void row_activated (Gtk.ListBoxRow row);

    void apply_filter () {
        total_visible_rows = 0;

        list_box.invalidate_filter ();

        if (total_visible_rows == 0) {
            list_stack.visible_child_name = "has-not";
        } else {
            list_stack.visible_child_name = "has";
        }
    }

    protected abstract bool filter (Gtk.ListBoxRow row, string search_text);
}
