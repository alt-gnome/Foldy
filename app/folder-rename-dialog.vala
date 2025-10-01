/*
 * Copyright (C) 2025 Vladimir Romanov <rirusha@altlinux.org>
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

[GtkTemplate (ui = "/org/altlinux/Foldy/ui/folder-rename-dialog.ui")]
public sealed class Foldy.RenameDialog : Adw.Dialog {

    [GtkChild]
    unowned Adw.WindowTitle window_title;
    [GtkChild]
    unowned Adw.ToastOverlay toast_overlay;
    [GtkChild]
    unowned Adw.EntryRow entry_row;

    public string folder_id { get; construct; }

    public RenameDialog (string folder_id) {
        Object (
            folder_id: folder_id
        );
    }

    construct {
        var old_name = get_folder_real_name (folder_id);

        window_title.title = _("Renaming folder '%s'").printf (old_name);
        entry_row.text = old_name;
    }

    [GtkCallback]
    void on_changed () {
        if (entry_row.text.length == 0) {
            add_css_class ("error");
            entry_row.show_apply_button = false;
        } else {
            remove_css_class ("error");
            entry_row.show_apply_button = true;
        }
    }

    [GtkCallback]
    void on_apply () {
        var new_name = entry_row.text;

        if (new_name.length == 0) {
            toast_overlay.add_toast (new Adw.Toast (_("Name cannot be empty")));
            return;
        }

        set_folder_name (folder_id, new_name);

        close ();
    }
}
