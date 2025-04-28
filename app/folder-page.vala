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
    [GtkChild]
    unowned Adw.ButtonRow delete_selected_button;

    public string folder_id { get; construct; }

    Settings settings;

    public FolderPage (string folder_id) {
        Object (folder_id: folder_id);
    }

    construct {
        model = new Gtk.NoSelection (
            new Gtk.FilterListModel (
                new AppsModel (folder_id),
                get_search_filter ()
            )
        );

        if (settings != null) {
            settings.changed.disconnect (refresh);
            settings = null;
        }

        settings = new Settings.with_path (
            "org.gnome.desktop.app-folders.folder",
            "/org/gnome/desktop/app-folders/folders/%s/".printf (folder_id)
        );
        settings.changed.connect (refresh);

        notify["selection-enabled"].connect (() => {
            bottom_stack.visible_child_name = selection_enabled ? "selection-mode" : "default";
            delete_revealer.reveal_child = !selection_enabled;
            settings_revealer.reveal_child = !selection_enabled;
        });

        folder_settings_button.clicked.connect (() => {
            new FolderDialog.edit (folder_id, get_folder_name (folder_id)).present (this);
        });

        refresh ();
    }
    void refresh () {
        title = get_folder_name (folder_id);
    }

    [GtkCallback]
    void delete_folder () {
        var dialog = new Adw.AlertDialog (_("Are you want to delete folder '%s'?").printf (
            get_folder_name (folder_id)
        ), null);

        dialog.add_response ("no", _("Cancel"));
        dialog.add_response ("yes", _("Delete"));

        dialog.set_response_appearance ("yes", Adw.ResponseAppearance.DESTRUCTIVE);

        dialog.default_response = "no";
        dialog.close_response = "no";

        dialog.response.connect ((resp) => {
            if (resp == "yes") {
                remove_folder (folder_id);
                close_requested ();
            }
        });

        dialog.present (this);
    }

    [GtkCallback]
    void delete_selected_apps () {
        remove_folder_apps (folder_id, get_selected_apps ());
        selection_enabled = false;
    }

    [GtkCallback]
    void add_apps () {
        var add_apps_page = new AddAppsDialog (folder_id);
        add_apps_page.present (this);
    }

    protected override void on_setup (GLib.Object obj) {
        var item = (Gtk.ListItem) obj;
        item.child = new AppRowRemove ();
        item.child.add_css_class ("card");
    }

    protected override void on_bind (GLib.Object obj) {
        var item = (Gtk.ListItem) obj;
        var row = (AppRowRemove) item.child;

        row.app_info = (AppInfo) item.item;

        bind_property (
            "selection-enabled",
            row,
            "selection-enabled",
            BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE
        );
    }

    protected override void on_activate (uint position) {
        var app = (AppInfo) model.get_item (position);

        if (selection_enabled) {
            app.selected = !app.selected;
        } else {
            var dialog = new AppInfoDialog (app);
            dialog.present (this);
        }

        delete_selected_button.sensitive = get_selected_apps ().length > 0;

        if (get_selected_apps ().length == 0) {
            selection_enabled = false;
        }
    }
}
