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
    protected unowned Adw.ToastOverlay toast_overlay;
    [GtkChild]
    protected unowned Adw.EntryRow folder_name_entry;
    [GtkChild]
    protected unowned Gtk.ListBox list_box;
    [GtkChild]
    protected unowned Gtk.ScrolledWindow scrolled_window;
    [GtkChild]
    protected unowned Gtk.Revealer go_top_button_revealer;
    [GtkChild]
    protected unowned Gtk.Adjustment adj;

    protected CategoriesList categories_list;

    public string folder_id { get; construct; }

    public string header_bar_title { get; construct; }

    public string apply_button_title { get; construct; }

    public string default_name { get; construct; }

    public signal void applyed (string folder_id);

    const double MAX_HEIGHT = 620d;
    const double MIN_HEIGHT = 258d;

    FolderDialog () {}

    public FolderDialog.create () {
        Object (
            header_bar_title: _("Folder creation"),
            apply_button_title: _("Create"),
            default_name: _("Unnamed Folder")
        );
    }

    public FolderDialog.edit (string folder_id, string default_name) {
        Object (
            folder_id: folder_id,
            header_bar_title: _("Folder settings"),
            apply_button_title: _("Apply"),
            default_name: default_name
        );
    }

    construct {
        adj.value_changed.connect (update_button_revealer);
        update_button_revealer ();

        if (folder_id != null) {
            categories_list = new CategoriesList.with_folder_id (folder_id);
        } else {
            categories_list = new CategoriesList ();
        }

        list_box.append (categories_list);

        folder_name_entry.text = default_name;

        categories_list.notify["expanded"].connect (() => {
            var current_height = content_height;
            var target_height = categories_list.expanded ? MAX_HEIGHT : MIN_HEIGHT;

            var target = new Adw.PropertyAnimationTarget (this, "content-height");
            var params = new Adw.SpringParams (1.00, 1.0, 300.0);
            var animation = new Adw.SpringAnimation (
                scrolled_window,
                current_height,
                target_height,
                params,
                target
            );

            animation.play ();
        });
    }

    void update_button_revealer () {
        go_top_button_revealer.reveal_child = adj.value > 64;
    }

    [GtkCallback]
    void on_apply_button_activate () {
        if (check_apply ()) {
            var lfolder_id = folder_id != null ? folder_id : create_folder (
                Uuid.string_random (),
                folder_name_entry.text
            );
            Foldy.sync ();

            set_folder_name (lfolder_id, folder_name_entry.text);
            set_folder_categories (lfolder_id, categories_list.get_selected_categories ());
            Foldy.sync ();

            close ();
            applyed (lfolder_id);
        }
    }

    [GtkCallback]
    void go_top_button_clicked () {
        var target = new Adw.PropertyAnimationTarget (scrolled_window.vadjustment, "value");
        var params = new Adw.SpringParams (1.00, 1.0, 500.0);
        var animation = new Adw.SpringAnimation (
            scrolled_window,
            scrolled_window.vadjustment.value,
            0.0,
            params,
            target
        );

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
}
