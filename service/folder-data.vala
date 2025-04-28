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

public sealed class Foldy.FolderData : Object {

    public string folder_id { get; construct; }

    public string[] apps { get; set; }

    public string[] categories { get; set; }

    public string[] excluded_apps {
        owned get {
            return Folder.get_folder_excluded_apps (folder_id);
        }
    }

    public string name {
        owned get {
            return Folder.get_folder_name (folder_id);
        }
    }

    public bool translate {
        get {
            return Folder.get_folder_translate (folder_id);
        }
    }

    public bool should_fix_categories { private get; construct; default = false; }

    public signal void refreshed (string folder_id);

    Settings settings;

    public FolderData (string folder_id) {
        Object (folder_id: folder_id);
    }

    public FolderData.with_categories_fix (string folder_id) {
        Object (folder_id: folder_id, should_fix_categories: true);
    }

    AppInfoMonitor mon;

    construct {
        apps = Folder.get_folder_apps (folder_id);
        categories = Folder.get_folder_categories (folder_id);

        settings = Folder.get_folder_settings (folder_id);

        settings.changed.connect (settings_changed);
        settings.changed.connect (settings_changed);
        settings.changed.connect (settings_changed);

        mon = AppInfoMonitor.get ();

        mon.changed.connect (() => {
            AppInfo.get_all ();
            refresh_folder ();
        });

        if (should_fix_categories) {
            var new_apps = new Gee.ArrayList<string> ();
            new_apps.add_all_array (Folder.get_folder_apps (folder_id));

            foreach (string category in categories) {
                foreach (string app_id in get_app_ids_by_category (category)) {
                    if (!(app_id in new_apps) && !(app_id in excluded_apps)) {
                        new_apps.add (app_id);
                    }
                }
            }

            if (!new_apps.is_empty) {
                Folder.set_folder_apps (folder_id, new_apps.to_array ());

                refreshed (folder_id);
            }
        }

        refreshed.connect ((folder_id) => {
            message ("Folder %s refreshed", folder_id);
        });
    }

    void settings_changed (string key) {
        if (key != "apps" && key != "excluded-apps" && key != "categories") {
            return;
        }

        settings.changed.disconnect (settings_changed);
        refresh_folder ();
        settings.changed.connect (settings_changed);
    }

    void refresh_folder () {
        print ("\n");
        message ("Triggered apps refreshing");

        var current_apps = new Gee.HashSet<string> ();
        current_apps.add_all_array (apps);

        var current_categories = new Gee.HashSet<string> ();
        current_categories.add_all_array (categories);

        var new_current_apps = new Gee.HashSet<string> ();
        new_current_apps.add_all_array (Folder.get_folder_apps (folder_id));

        var new_current_categories = new Gee.HashSet<string> ();
        new_current_categories.add_all_array (Folder.get_folder_categories (folder_id));

        var added_apps = new Gee.HashSet<string> ();
        added_apps.add_all (new_current_apps);
        added_apps.remove_all (current_apps);

        var removed_apps = new Gee.HashSet<string> ();
        removed_apps.add_all (current_apps);
        removed_apps.remove_all (new_current_apps);

        var excluded_apps = new Gee.HashSet<string> ();
        excluded_apps.add_all_array (this.excluded_apps);

        message ("Added apps: %s", string.joinv (", ", added_apps.to_array ()));
        message ("Removed apps: %s", string.joinv (", ", removed_apps.to_array ()));

        excluded_apps.remove_all (added_apps);
        excluded_apps.add_all (removed_apps);

        sync ();

        var new_apps = new Gee.HashSet<string> ();
        new_apps.add_all (new_current_apps);
        foreach (var category in current_categories) {
            new_apps.remove_all_array (get_app_ids_by_category (category));
        }
        foreach (var category in new_current_categories) {
            new_apps.add_all_array (get_app_ids_by_category (category));
        }
        new_apps.remove_all (excluded_apps);

        Folder.set_folder_apps (folder_id, new_apps.to_array ());
        Folder.set_folder_excluded_apps (folder_id, excluded_apps.to_array ());
        categories = new_current_categories.to_array ();
        apps = new_apps.to_array ();

        sync ();

        refreshed (folder_id);
    }
}
