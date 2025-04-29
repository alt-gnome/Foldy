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

[GtkTemplate (ui = "/org/altlinux/Foldy/ui/folder-dialog.ui")]
public sealed class Foldy.FolderDialog : Adw.Dialog {

    [GtkChild]
    unowned Adw.ToastOverlay toast_overlay;
    [GtkChild]
    unowned Adw.EntryRow folder_name_entry;
    [GtkChild]
    unowned Gtk.ListBox list_box;
    [GtkChild]
    unowned Gtk.ScrolledWindow scrolled_window;
    [GtkChild]
    unowned Gtk.Revealer go_top_button_revealer;
    [GtkChild]
    unowned Gtk.Adjustment adj;
    [GtkChild]
    unowned CategoriesList categories_list;
    [GtkChild]
    unowned Gtk.SearchEntry search_entry;
    [GtkChild]
    unowned Gtk.Stack button_stack;

    public string folder_id { get; construct; }

    public string header_bar_title { get; private set; }

    public string apply_button_title { get; private set; }

    public FolderDialogType type_ { get; construct; }

    public string default_name { get; private set; }

    public signal void applyed (string folder_id);

    public string[] start_categories;

    public string start_name;

    const double MAX_HEIGHT = 620d;
    const double MIN_HEIGHT = 258d;

    FolderDialog () {}

    public FolderDialog.create () {
        Object (
            type_: FolderDialogType.CREATE
        );
    }

    public FolderDialog.edit (string folder_id) {
        Object (
            folder_id: folder_id,
            type_: FolderDialogType.EDIT
        );
    }

    construct {
        adj.value_changed.connect (update_button_revealer);
        update_button_revealer ();

        switch (type_) {
            case FolderDialogType.CREATE:
                header_bar_title = _("Folder creation");
                apply_button_title = _("Create");
                start_name = _("Unnamed Folder");
                break;

            case FolderDialogType.EDIT:
                header_bar_title = _("Folder settings");
                apply_button_title = _("Apply");
                start_name = get_folder_real_name (folder_id);

                folder_name_entry.changed.connect (update_button);

                var start_categories_arr = new Array<string> ();

                var folder_categories = new Gee.HashSet<string> ();
                folder_categories.add_all_array (Folder.get_folder_categories (folder_id));

                foreach (var category in Foldy.get_installed_categories (folder_id)) {
                    if (category in folder_categories) {
                        start_categories_arr.append_val (category);
                    }
                }

                start_categories = start_categories_arr.steal ();
                categories_list.selection_changed.connect (update_button);

                update_button ();
                break;
        }

        folder_name_entry.text = start_name;

        categories_list.notify["expanded"].connect (() => {
            var current_height = content_height;
            var target_height = categories_list.expanded ? MAX_HEIGHT : MIN_HEIGHT;

            var target = new Adw.PropertyAnimationTarget (this, "content-height");
            var animation = new Adw.TimedAnimation (this, current_height, target_height, 150, target);

            animation.play ();
        });

        search_entry.search_changed.connect (() => {
            categories_list.refilter (search_entry.text);
        });
    }

    void update_button_revealer () {
        go_top_button_revealer.reveal_child = adj.value > 64;
    }

    void update_button () {
        bool same = true;

        if (start_name != folder_name_entry.text) {
            same = false;
        }

        var selected_categories = categories_list.get_selected_categories ();

        foreach (var category in start_categories) {
            if (!(category in selected_categories)) {
                same = false;
                break;
            }
        }

        if (start_categories.length != selected_categories.length) {
            same = false;
        }

        button_stack.visible_child_name = same ? "close" : "base";
    }

    [GtkCallback]
    void on_apply_button_activate () {
        if (check_apply ()) {
            string lfolder_id;

            if (folder_id != null) {
                lfolder_id = folder_id;
                set_folder_name (folder_id, folder_name_entry.text);
            } else {
                lfolder_id = folder_id != null ? folder_id : create_folder (
                    Uuid.string_random (),
                    folder_name_entry.text
                );
            }
            Foldy.sync ();

            set_folder_categories (lfolder_id, categories_list.get_selected_categories ());
            Foldy.sync ();

            close ();
            applyed (lfolder_id);
        }
    }

    [GtkCallback]
    void on_close_button_activate () {
        close ();
    }

    [GtkCallback]
    void go_top_button_clicked () {
        scrolled_window.vadjustment.value = scrolled_window.vadjustment.value;

        var target = new Adw.PropertyAnimationTarget (scrolled_window.vadjustment, "value");
        var animation = new Adw.TimedAnimation (scrolled_window, scrolled_window.vadjustment.value, 0.0, 150, target);

        animation.play ();
    }

    bool check_apply () {
        if (folder_name_entry.text == "") {
            toast_overlay.add_toast (new Adw.Toast (_("Name can't be empty")));
            folder_name_entry.focus (Gtk.DirectionType.DOWN);
            return false;
        }

        if (categories_list.get_selected_categories ().length > 2) {
            toast_overlay.add_toast (new Adw.Toast (_("Categories can't be more than 2")));
            categories_list.focus (Gtk.DirectionType.DOWN);
            return false;
        }

        return true;
    }

    [GtkCallback]
    void on_search_revealed () {
        search_entry.text = "";
        search_entry.grab_focus ();
    }
}
