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

[GtkTemplate (ui = "/org/altlinux/Foldy/ui/folders-list-page.ui")]
public sealed class Foldy.FoldersListPage : BasePage {

    Settings settings;

    public FoldersListPage (Adw.NavigationView nav_view) {
        Object (nav_view: nav_view);
    }

    construct {
        settings = new Settings ("org.gnome.desktop.app-folders");

        settings.changed["folder-children"].connect (refresh);
    }

    protected override void row_activated (Gtk.ListBoxRow row) {
        var folder_row = (FolderRow) row;

        if (!(folder_row.folder_id in get_folders ())) {
            refresh ();

            Foldy.Application.get_default ().show_message (_("Can't open folder settings"));

            return;
        }

        open_folder.begin (folder_row.folder_id);
    }

    [GtkCallback]
    async void create_new_button_clicked () {
        var dialog = new FolderDialog.create ();
        dialog.applyed.connect ((folder_id) => {
            open_folder.begin (folder_id);
        });
        dialog.present (this);
    }

    async void open_folder (string new_folder_id) {
        if (get_folder_apps (new_folder_id).length > 0 || get_folder_categories (new_folder_id).length > 0) {
            var folder_page = new FolderPage (nav_view, new_folder_id);
            nav_view.push (folder_page);
            return;
        }

        var add_apps_page = new AddAppsPage (nav_view, new_folder_id);

        ulong handler_id = nav_view.popped.connect ((page) => {
            if (page == add_apps_page) {
                add_apps_page.done ();
            }
        });

        ulong handler_id2 = add_apps_page.done.connect (() => {
            if (get_folder_apps (new_folder_id).length == 0 && get_folder_categories (new_folder_id).length == 0) {
                remove_folder (new_folder_id);
                Idle.add (open_folder.callback);

            } else {
                var folder_page = new FolderPage (nav_view, new_folder_id);
                folder_page.shown.connect (() => {
                    nav_view.replace ({
                        this,
                        folder_page
                    });
                    Idle.add (open_folder.callback);
                });
                nav_view.push (folder_page);
            }
        });

        nav_view.push (add_apps_page);

        yield;

        nav_view.disconnect (handler_id);
        add_apps_page.disconnect (handler_id2);
    }

    protected override void update_list () {
        row_box.remove_all ();

        foreach (string folder_id in get_folders ()) {
            row_box.append (new FolderRow (folder_id));
        }
    }

    protected override bool filter (Gtk.ListBoxRow row, string search_text) {
        var folder_row = (FolderRow) row;

        return search_text.down () in folder_row.folder_id.down () ||
               search_text.down () in get_folder_name (folder_row.folder_id).down ();
    }
}
