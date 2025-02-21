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

[GtkTemplate (ui = "/org/altlinux/Foldy/ui/folder-page.ui")]
public sealed class Foldy.FolderPage : BasePage {

    [GtkChild]
    unowned Gtk.Stack bottom_stack;
    [GtkChild]
    unowned Gtk.Revealer delete_revealer;
    [GtkChild]
    unowned Gtk.Revealer settings_revealer;
    [GtkChild]
    unowned Gtk.Button folder_settings_button;

    Gee.ArrayList<AppRow> app_rows = new Gee.ArrayList<AppRow> ();

    ServiceProxy proxy;

    public string folder_id { get; construct; }

    Settings settings;

    public FolderPage (Adw.NavigationView nav_view, string folder_id) {
        Object (nav_view: nav_view, folder_id: folder_id);
    }

    construct {
        notify["selection-enabled"].connect (() => {
            bottom_stack.visible_child_name = selection_enabled ? "selection-mode" : "default";
            delete_revealer.reveal_child = !selection_enabled;
            settings_revealer.reveal_child = !selection_enabled;
        });

        folder_settings_button.clicked.connect (() => {
            new FolderDialog.edit (folder_id, get_folder_name (folder_id)).present (this);
        });

        settings = new Settings.with_path (
            "org.gnome.desktop.app-folders.folder",
            "/org/gnome/desktop/app-folders/folders/%s/".printf (folder_id)
        );

        settings.changed.connect (refresh);

        nav_view.popped.connect ((page) => {
            if (page == this) {
                if (get_folder_apps (folder_id).length == 0) {
                    remove_folder (folder_id);
                }
            }
        });

        try {
            proxy = Bus.get_proxy_sync<ServiceProxy> (
                BusType.SESSION,
                "org.altlinux.FoldyService",
                "/org/altlinux/FoldyService"
            );
    
            proxy.folder_refreshed.connect (on_folder_refreshed);
        } catch (Error e) {
            warning ("Can't get proxy of FoldyService: %s", e.message);
        }
    }

    void on_folder_refreshed (string folder_id) {
        if (folder_id == this.folder_id) {
            refresh ();
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
    async void add_apps () {
        var add_apps_page = new AddAppsPage (nav_view, folder_id);
        add_apps_page.done.connect (() => {
            nav_view.pop_to_page (this);

            Idle.add (add_apps.callback);
        });

        nav_view.push (add_apps_page);
        yield;
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

        app_rows.clear ();
        row_box.remove_all ();

        var app_infos = AppInfo.get_all ();
        var folder_apps = get_folder_apps (folder_id);

        foreach (AppInfo app_info in app_infos) {
            if (app_info.get_id () in folder_apps && app_info.should_show ()) {
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

                app_rows.add (app_row);
                row_box.append (app_row);
            }
        }
    }

    protected override bool filter (Gtk.ListBoxRow row, string search_text) {
        var app_row = (AppRow) row;

        return search_text.down () in app_row.app_info.get_id ().down ();
    }
}
