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

using Foldy.Folder;

[GtkTemplate (ui = "/org/altlinux/Foldy/ui/folders-list-page.ui")]
public sealed class Foldy.FoldersListPage : Adw.NavigationPage {

    [GtkChild]
    unowned Gtk.ListBox list_box_menu;
    [GtkChild]
    unowned Gtk.Stack list_stack;
    [GtkChild]
    unowned Adw.ButtonRow create_new_button;

    Gtk.StringList model;

    public WindowType wintype { get; set; default = WindowType.WIDE; }

    public signal void folder_choosed (string folder_id);

    construct {
        model = ModelManager.get_default ().get_folders_model ();

        update_model ();
    }

    void update_model () {
        list_box_menu.bind_model (model, (obj) => {
            return new FolderMenuRow.with_folder_id (((Gtk.StringObject) obj).string);
        });

        model.items_changed.connect (refresh);

        refresh ();

        list_box_menu.selection_mode = Gtk.SelectionMode.NONE;
    }

    [GtkCallback]
    void on_wintype_changed () {
        if (wintype == WindowType.WIDE) {
            list_box_menu.valign = FILL;
            create_new_button.remove_css_class ("suggested-action");
        } else {
            list_box_menu.valign = END;
            create_new_button.add_css_class ("suggested-action");
        }

        refresh ();
    }

    void refresh () {
        if (model.n_items == 0) {
            list_stack.visible_child_name = "has-not";
        } else {
            list_stack.visible_child_name = "has";
        }
    }

    public void unselect_all () {
        list_box_menu.selection_mode = Gtk.SelectionMode.NONE;
    }

    public void select (string folder_id) {
        list_box_menu.selection_mode = Gtk.SelectionMode.SINGLE;

        for (int i = 0; i < model.n_items; i++) {
            if (((FolderMenuRow) list_box_menu.get_row_at_index (i)).folder_id == folder_id) {
                list_box_menu.select_row (list_box_menu.get_row_at_index (i));
                return;
            }
        }
    }

    [GtkCallback]
    void create_new_button_clicked () {
        var dialog = new FolderDialog.create ();
        dialog.applyed.connect ((folder_id) => {
            for (int i = 0; i < model.n_items; i++) {
                if ((list_box_menu.get_row_at_index (i) as FolderMenuRow)?.folder_id == folder_id) {
                    list_box_menu.select_row (list_box_menu.get_row_at_index (i));
                }
            }
            folder_choosed (folder_id);
        });
        dialog.present (this);
    }

    [GtkCallback]
    void on_row_activated (Gtk.ListBoxRow row) {
        list_box_menu.selection_mode = Gtk.SelectionMode.SINGLE;
        list_box_menu.select_row (row);
        folder_choosed (((FolderMenuRow) row).folder_id);
    }
}
