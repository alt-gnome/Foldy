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

public sealed class Foldy.FolderRow : Adw.ActionRow {

    public string folder_id { get; construct; }

    Settings settings;

    public FolderRow (string folder_id) {
        Object (folder_id: folder_id);
    }

    construct {
        activatable = true;

        settings = new Settings.with_path ("org.gnome.desktop.app-folders.folder",
                                           "/org/gnome/desktop/app-folders/folders/%s/".printf (folder_id));

        settings.changed.connect (refresh);
        refresh ();
    }

    void refresh () {
        title = get_folder_name (folder_id);
        subtitle = string.joinv (", ", get_folder_categories (folder_id));
    }
}
