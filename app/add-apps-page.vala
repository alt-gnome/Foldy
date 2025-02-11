/*
 * Copyright 2024 Rirusha
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

using Foldy.Folder;

[GtkTemplate (ui = "/org/altlinux/Foldy/ui/add-apps-page.ui")]
public sealed class Foldy.AddAppsPage : BasePage {

    [GtkChild]
    unowned Adw.ButtonRow add_button;

    Gee.ArrayList<AppRow> app_rows = new Gee.ArrayList<AppRow> ();

    public string folder_id { get; construct; }

    public signal void done ();

    public AddAppsPage (Adw.NavigationView nav_view, string folder_id) {
        Object (nav_view: nav_view, folder_id: folder_id);
    }

    construct {
        selection_enabled = true;
    }

    [GtkCallback]
    void add_selected_apps () {
        add_folder_apps (folder_id, get_selected_apps ());
        selection_enabled = false;
        done ();
    }

    string[] get_selected_apps () {
        var row_ids = new Array<string> ();

        foreach (var row in app_rows) {
            var app_row = (AppRow) row;

            if (app_row.selected) {
                row_ids.append_val (app_row.app_info.get_id ());
            }
        }

        return row_ids.data;
    }

    protected override void update_list () {
        app_rows.clear ();
        row_box.remove_all ();

        var app_infos = get_unfolder_apps ();
        var folder_apps = get_folder_apps (folder_id);

        foreach (AppInfo app_info in app_infos) {
            if (app_info.should_show ()) {
                var app_row = new AppRowAdd (app_info);

                bind_property (
                    "selection-enabled",
                    app_row,
                    "selection-enabled",
                    BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE
                );

                app_row.notify ["selected"].connect (() => {
                    add_button.sensitive = get_selected_apps ().length != 0;
                });

                app_rows.add (app_row);
                row_box.append (app_row);

                if (app_info.get_id () in folder_apps) {
                    app_row.selected = true;
                    app_row.sensitive = false;
                }
            }
        }
    }

    protected override void row_activated (Gtk.ListBoxRow row) {
        var app_row = (AppRow) row;

        if (app_row.selection_enabled) {
            if (app_row.sensitive) {
                app_row.selected = !app_row.selected;
            }

        } else {
            new AppInfoDialog (app_row.app_info).present (this);
        }
    }

    protected override bool filter (Gtk.ListBoxRow row, string search_text) {
        var app_row = (AppRow) row;

        return search_text.down () in app_row.app_info.get_id ().down ();
    }
}
