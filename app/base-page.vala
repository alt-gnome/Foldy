/* Copyright (C) 2024-2025 Vladimir Romanov
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
    unowned Gtk.Stack list_stack;

    public string subtitle { get; set; }

    public Gtk.NoSelection model { get; set; }

    public Gtk.Widget bottom_start_widget { get; set; }

    public Gtk.Widget bottom_center_widget { get; set; }

    public Gtk.Widget bottom_end_widget { get; set; }

    public bool can_show_more { get; set; default = false; }

    public bool show_more { get; set; default = false; }

    public bool can_select { get; set; default = false; }

    public bool selection_enabled { get; set; default = false; }

    public string search_query { get; set; default = ""; }

    public signal void close_requested ();

    construct {
        notify["model"].connect (() => {
            model.items_changed.connect (update_has_state);
            update_has_state ();
        });

        //  var lp = new Gtk.GestureLongPress ();
        //  lp.pressed.connect ((x, y) => {
        //      if (!selection_enabled) {
        //          selection_enabled = true;
        //      }
        //  });
        //  ((Gtk.Widget) this).add_controller (lp);
    }

    void update_has_state () {
        list_stack.visible_child_name = model.get_n_items () != 0 ? "has" : "has-not";
    }

    protected string[] get_selected_apps () {
        var arr = new Gee.HashSet<string> ();

        for (int i = 0; i < model.get_n_items (); i++) {
            var app = (AppInfo) model.get_item (i);
            if (app.selected) {
                arr.add (app.id);
            }
        }

        return arr.to_array ();
    }

    protected Gtk.Filter get_search_filter () {
        var filter = new Gtk.StringFilter (new Gtk.PropertyExpression (
            typeof (AppInfo),
            null,
            "display-name"
        ));
        filter.bind_property (
            "search",
            this,
            "search-query",
            GLib.BindingFlags.BIDIRECTIONAL
        );

        return filter;
    }

    [GtkCallback]
    protected abstract void on_setup (Object obj);

    [GtkCallback]
    protected abstract void on_bind (Object obj);

    [GtkCallback]
    protected abstract void on_activate (uint position);

    [GtkCallback]
    protected void on_search_button_active () {
        search_query = "";

        if (search_button.active) {
            search_entry.grab_focus ();
        }
    }
}
