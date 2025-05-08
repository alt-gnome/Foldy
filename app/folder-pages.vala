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

[GtkTemplate (ui = "/org/altlinux/Foldy/ui/folder-pages.ui")]
public sealed class Foldy.FolderPages : Adw.Bin {

    [GtkChild]
    unowned Adw.NavigationView navigation_view;

    Gtk.StringList folders_model;

    public WindowType wintype { get; set; default = WindowType.WIDE; }

    public signal void nothing_to_show ();

    public signal void folder_opened (string folder_id);

    construct {
        folders_model = ModelManager.get_default ().get_folders_model ();
        folders_model.items_changed.connect (() => {
            reset ();
        });
    }

    public async void open_folder (string folder_id) {
        if (get_folder_apps (folder_id).length > 0 ||
            get_folder_categories (folder_id).length > 0) {
            var folder_page = new FolderPage (folder_id);
            show_only (folder_page);

        } else {
            var dialog = new AddAppsDialog (folder_id);

            ulong handler_id2 = dialog.closed.connect (() => {
                if (get_folder_apps (folder_id).length == 0 && get_folder_categories (folder_id).length == 0) {
                    remove_folder (folder_id);
                    reset ();

                } else {
                    var folder_page = new FolderPage (folder_id);
                    show_only (folder_page);
                }

                Idle.add (open_folder.callback);
            });

            dialog.present (this);

            yield;

            folder_opened (folder_id);

            dialog.disconnect (handler_id2);
        }

        folder_opened (folder_id);
    }

    void reset () {
        if (wintype == WindowType.WIDE) {
            var stack = navigation_view.navigation_stack;

            if (stack.get_n_items () == 0) {
                navigation_view.replace ({ new StartPage () });
            } else {
                var start_page = stack.get_item (0) as StartPage;

                if (start_page == null) {
                    navigation_view.replace ({ new StartPage () });
                } else {
                    navigation_view.pop_to_page (start_page);
                }
            }

        } else {
            navigation_view.replace ({});
        }
    }

    void show_only (Adw.NavigationPage page) {
        if (wintype == WindowType.WIDE) {
            navigation_view.replace ({ new StartPage (), page });

        } else {
            navigation_view.replace ({ page });
        }
    }

    [GtkCallback]
    void on_wintype_changed () {
        var current_pages_stack = navigation_view.navigation_stack;

        var current_pages = new Gee.ArrayList<Adw.NavigationPage> ();

        for (uint i = 0; i < current_pages_stack.get_n_items (); i++) {
            var page = (Adw.NavigationPage) current_pages_stack.get_item (i);

            current_pages.add (page);
        }

        if (current_pages.size == 0) {
            current_pages.add (new StartPage ());

        } else if (wintype == WindowType.WIDE) {
            if (current_pages[0].tag != "start-page") {
                current_pages.insert (0, new StartPage ());
            }

        } else {
            if (current_pages[0].tag == "start-page") {
                current_pages.remove_at (0);
            }
        }

        navigation_view.replace (current_pages.to_array ());
    }

    [GtkCallback]
    void on_popped (Adw.NavigationPage page) {
        if (page is FolderPage) {
            var folder_id = ((FolderPage) page).folder_id;

            if (get_folder_apps (folder_id).length == 0 && get_folder_categories (folder_id).length == 0) {
                remove_folder (folder_id);
                reset ();
            }
        }

        if (
            navigation_view.navigation_stack.get_n_items () == 0
            || (navigation_view.navigation_stack.get_n_items () == 1
                && navigation_view.navigation_stack.get_item (0) is StartPage)
        ) {
            nothing_to_show ();
        }
    }
}
