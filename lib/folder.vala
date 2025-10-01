/*
 * Copyright (C) 2024-2025 Vladimir Romanov
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

namespace Foldy.Folder {

    public static Settings get_folder_settings (string folder_id) {
        return new Settings.with_path (
            "org.gnome.desktop.app-folders.folder",
            "/org/gnome/desktop/app-folders/folders/%s/".printf (folder_id)
        );
    }

    // Folder name

    public static string get_folder_name (string folder_id) {
        return get_folder_settings (folder_id).get_string ("name");
    }

    public static void set_folder_name (string folder_id, string folder_name) {
        get_folder_settings (folder_id).set_string ("name", folder_name);
    }

    // Folder categories

    public static string[] get_folder_categories (string folder_id) {
        return get_folder_settings (folder_id).get_strv ("categories");
    }

    public static void set_folder_categories (string folder_id, string[] folder_categories) {
        get_folder_settings (folder_id).set_strv ("categories", folder_categories.copy ());
    }

    public static void add_folder_categories (string folder_id, string[] folder_categories) {
        var builder = new StrvBuilder ();

        var current_categories = get_folder_categories (folder_id);

        builder.addv (current_categories);
        foreach (string category in folder_categories) {
            if (!(category in current_categories)) {
                builder.add (category);
            }
        }

        set_folder_categories (folder_id, builder.end ());
    }

    public static void remove_folder_categories (string folder_id, string[] folder_categories) {
        var builder = new StrvBuilder ();

        foreach (string category in get_folder_categories (folder_id)) {
            if (!(category in folder_categories)) {
                builder.add (category);
            }
        }

        set_folder_categories (folder_id, builder.end ());
    }

    // Folder translate

    public static bool get_folder_translate (string folder_id) {
        return get_folder_settings (folder_id).get_boolean ("translate");
    }

    public static void set_folder_translate (string folder_id, bool folder_translate) {
        get_folder_settings (folder_id).set_boolean ("translate", folder_translate);
    }

    // Folder apps

    public static string[] get_folder_apps (string folder_id) {
        return get_folder_settings (folder_id).get_strv ("apps");
    }

    public static void set_folder_apps (string folder_id, string[]? folder_apps) {
        get_folder_settings (folder_id).set_strv ("apps", folder_apps.copy ());
    }

    public static void add_folder_apps (string folder_id, string[] folder_apps) {
        var builder = new StrvBuilder ();

        var current_apps = get_folder_apps (folder_id);

        builder.addv (current_apps);
        foreach (string app in folder_apps) {
            if (!(app in current_apps)) {
                builder.add (app);
            }
        }

        set_folder_apps (folder_id, builder.end ());
    }

    public static void remove_folder_apps (string folder_id, string[] folder_apps) {
        var builder = new StrvBuilder ();

        foreach (string app in get_folder_apps (folder_id)) {
            if (!(app in folder_apps)) {
                builder.add (app);
            }
        }

        set_folder_apps (folder_id, builder.end ());
    }

    // Folder exclude apps

    public static string[] get_folder_excluded_apps (string folder_id) {
        return get_folder_settings (folder_id).get_strv ("excluded-apps");
    }

    public static void set_folder_excluded_apps (string folder_id, string[]? folder_excluded_apps) {
        get_folder_settings (folder_id).set_strv ("excluded-apps", folder_excluded_apps.copy ());
    }

    public static void add_folder_excluded_apps (string folder_id, string[] folder_excluded_apps) {
        var builder = new StrvBuilder ();

        var current_excluded_apps = get_folder_excluded_apps (folder_id);

        builder.addv (current_excluded_apps);
        foreach (string excluded_app in folder_excluded_apps) {
            if (!(excluded_app in current_excluded_apps)) {
                builder.add (excluded_app);
            }
        }

        set_folder_apps (folder_id, builder.end ());
    }

    public static void remove_folder_excluded_apps (string folder_id, string[] folder_excluded_apps) {
        var builder = new StrvBuilder ();

        foreach (string excluded_app in get_folder_excluded_apps (folder_id)) {
            if (!(excluded_app in folder_excluded_apps)) {
                builder.add (excluded_app);
            }
        }

        set_folder_apps (folder_id, builder.end ());
    }
}
