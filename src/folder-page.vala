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

using Foldy.Folder;

[GtkTemplate (ui = "/space/rirusha/Foldy/ui/folder-page.ui")]
public sealed class Foldy.FolderPage : BasePage {

    [GtkChild]
    unowned Gtk.Stack bottom_stack;
    [GtkChild]
    unowned Gtk.Revealer delete_revealer;
    [GtkChild]
    unowned Gtk.Revealer settings_revealer;
    [GtkChild]
    unowned Gtk.Button folder_settings_button;

    Array<AppRow> app_rows = new Array<AppRow> ();

    public string folder_id { get; construct; }

    Settings settings;

    public FolderPage (Adw.NavigationView nav_view, string folder_id) {
        Object (nav_view: nav_view, folder_id: folder_id);
    }

    construct {
        bind_property (
            "selection-enabled",
            bottom_stack,
            "visible-child-name",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, srcval, ref trgval) => {
                trgval.set_string (srcval.get_boolean () ? "selection-mode" : "default");
            }
        );

        bind_property (
            "selection-enabled",
            delete_revealer,
            "reveal-child",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE | BindingFlags.INVERT_BOOLEAN
        );

        bind_property (
            "selection-enabled",
            settings_revealer,
            "reveal-child",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE | BindingFlags.INVERT_BOOLEAN
        );

        folder_settings_button.clicked.connect (() => {
            new EditFolderDialog (folder_id).present (this);
        });

        settings = new Settings.with_path (
            "org.gnome.desktop.app-folders.folder",
            "/org/gnome/desktop/app-folders/folders/%s/".printf (folder_id)
        );

        settings.changed.connect ((key) => {
            refresh ();
        });

        nav_view.popped.connect (() => {
            Idle.add_once (() => {
                if (get_folder_apps (folder_id).length == 0) {
                    remove_folder (folder_id);
                    nav_view.pop_to_tag ("main");
                }
            });
        });

        if (get_folder_apps (folder_id).length == 0) {
            Idle.add_once (add_apps);
        }
    }

    [GtkCallback]
    void delete_folder () {
        var dialog = new Adw.AlertDialog (_("Are you want to delete folder '%s'?".printf (
            get_folder_name (folder_id)
        )), null);

        dialog.add_response ("no", _("Cancel"));
        dialog.add_response ("yes", _("Delete"));

        dialog.set_response_appearance ("yes", Adw.ResponseAppearance.DESTRUCTIVE);

        dialog.default_response = "no";
        dialog.close_response = "no";

        dialog.response.connect ((resp) => {
            if (resp == "yes") {
                remove_folder (folder_id);
                nav_view.pop ();
            }
        });

        dialog.present (this);
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

    [GtkCallback]
    void delete_selected_apps () {
        remove_folder_apps (folder_id, get_selected_apps ());
        selection_enabled = false;
    }

    [GtkCallback]
    void add_apps () {
        nav_view.push (new AddAppsPage (nav_view, folder_id));
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
        title = _("Folder '%s'").printf (get_folder_name (folder_id));

        app_rows = new Array<AppRow> ();
        row_box.remove_all ();

        update_list_async.begin ();
    }

    async void update_list_async () {
        var app_infos = AppInfo.get_all ();
        var folder_apps = get_folder_apps (folder_id);

        foreach (AppInfo app_info in app_infos) {
            if (app_info.get_id () in folder_apps) {
                var app_row = new AppRowRemove (app_info);

                bind_property (
                    "selection-enabled",
                    app_row,
                    "selection-enabled",
                    BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE
                );

                app_row.notify ["selected"].connect (() => {
                    if (get_selected_apps ().length == 0) {
                        selection_enabled = false;
                    }
                });

                app_rows.append_val (app_row);
                row_box.append (app_row);

                Idle.add (update_list_async.callback);
                yield;
            }
        }
    }

    protected override bool filter (Gtk.ListBoxRow row, string search_text) {
        var app_row = (AppRow) row;

        return search_text.down () in app_row.app_info.get_id ().down ();
    }
}
