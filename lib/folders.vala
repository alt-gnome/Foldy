/*
 * Copyright (C) 2024 Vladimir Vaskov
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
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Foldy {

    Settings folders_settings;

    public static Settings get_folders_settings () {
        if (folders_settings == null) {
            folders_settings = new Settings ("org.gnome.desktop.app-folders");
        }

        return folders_settings;
    }

    public void sync () {
        Settings.sync ();
    }

    public static string[] get_folders () {
        return get_folders_settings ().get_strv ("folder-children");
    }

    public static void set_folders (string[]? new_folders) {
        get_folders_settings ().set_strv ("folder-children", new_folders);
    }

    public static void add_folder (string folder_id) {
        var builder = new StrvBuilder ();

        var current_folders = get_folders ();

        builder.addv (current_folders);
        if (!(folder_id in current_folders)) {
            builder.add (folder_id);
        }

        set_folders (builder.end ());
    }

    public static void remove_folder (string folder_id) {
        var builder = new StrvBuilder ();

        foreach (string folder in get_folders ()) {
            if (folder != folder_id) {
                builder.add (folder);
            }
        }

        set_folders (builder.end ());
    }

    public static string create_folder (
        string? folder_id,
        string folder_name = "Unnamed Folder",
        string[] apps = {},
        string[] categories = {},
        bool translate = false
    ) {
        string fid = folder_id ?? Uuid.string_random ();

        add_folder (fid);
        Folder.set_folder_name (fid, folder_name);
        Folder.set_folder_apps (fid, apps);
        Folder.set_folder_categories (fid, categories);
        Folder.set_folder_translate (fid, translate);


        return fid;
    }

    public static bool folder_exists (string folder_id) {
        return folder_id in get_folders ();
    }
}
