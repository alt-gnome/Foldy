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

    public string[] excluded_apps { get; set; }

    public string[] categories { get; set; }

    public string name { get; set; }

    public bool translate { get; set; }

    public bool should_fix_categories { private get; construct; default = false; }

    public signal void refreshed (string folder_id);

    Settings settings;

    public FolderData (string folder_id) {
        Object (folder_id: folder_id);
    }

    public FolderData.with_categories_fix (string folder_id) {
        Object (folder_id: folder_id, should_fix_categories: true);
    }

    internal void reset () {
        settings.reset ("name");
        settings.reset ("translate");
        settings.reset ("categories");
        settings.reset ("apps");
        settings.reset ("excluded-apps");
    }

    AppInfoMonitor mon;

    construct {
        apps = Folder.get_folder_apps (folder_id);
        excluded_apps = Folder.get_folder_excluded_apps (folder_id);
        categories = Folder.get_folder_categories (folder_id);
        name = Folder.get_folder_name (folder_id);
        translate = Folder.get_folder_translate (folder_id);

        settings = Folder.get_folder_settings (folder_id);

        settings.changed["name"].connect (() => {
            name = Folder.get_folder_name (folder_id);
        });
        settings.changed["translate"].connect (() => {
            translate = Folder.get_folder_translate (folder_id);
        });
        settings.changed["excluded-apps"].connect (() => {
            excluded_apps = Folder.get_folder_excluded_apps (folder_id);
        });
        settings.changed["apps"].connect (() => {
            apps = Folder.get_folder_apps (folder_id);
        });
        settings.changed["categories"].connect (refresh_categories);

        mon = AppInfoMonitor.get ();

        mon.changed.connect (() => {
            AppInfo.get_all ();
            refresh_apps ();
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

            Folder.set_folder_apps (folder_id, new_apps.to_array ());

            refreshed (folder_id);
        }

        refreshed.connect ((folder_id) => {
            message ("Folder %s refreshed", folder_id);
        });
    }

    void refresh_apps () {
        message ("Triggered apps refreshing");

        var current_apps = new Gee.ArrayList<string>.wrap (apps);

        var new_apps = new Gee.ArrayList<string> ();
        foreach (var category in categories) {
            new_apps.add_all_array (get_app_ids_by_category (category));
        }

        var added_apps = new Gee.ArrayList<string> ();
        added_apps.add_all (new_apps);
        added_apps.remove_all_array (apps);

        var removed_apps = new Gee.ArrayList<string> ();
        removed_apps.add_all_array (apps);
        removed_apps.remove_all (new_apps);

        foreach (var added_app in added_apps) {
            if (!(added_app in excluded_apps)) {
                current_apps.add (added_app);
            }
        }

        foreach (var removed_app in removed_apps) {
            if (!(removed_app in excluded_apps)) {
                current_apps.remove (removed_app);
            }
        }

        message ("Added apps: %s", string.joinv (", ", added_apps.to_array ()));
        message ("Removed apps: %s", string.joinv (", ", removed_apps.to_array ()));

        Folder.set_folder_apps (folder_id, current_apps.to_array ());

        refreshed (folder_id);
    }

    void refresh_categories () {
        var new_categories = Folder.get_folder_categories (folder_id);

        var removed_category = new Gee.ArrayList<string> ();
        var added_category = new Gee.ArrayList<string> ();

        foreach (string old_category in categories) {
            if (!(old_category in new_categories)) {
                removed_category.add (old_category);
                debug ("Removed %s category", old_category);
            }
        }

        foreach (string new_category in new_categories) {
            if (!(new_category in categories)) {
                added_category.add (new_category);
                debug ("Added %s category", new_category);
            }
        }

        var need_to_remove = new Gee.ArrayList<string> ();
        foreach (string category in removed_category) {
            var app_ids = get_app_ids_by_category (category);

            foreach (var app_id in app_ids) {
                if (app_id in apps) {
                    need_to_remove.add (app_id);
                }
            }
        }
        Folder.remove_folder_apps (folder_id, need_to_remove.to_array ());

        var need_to_add = new Gee.ArrayList<string> ();
        foreach (string category in added_category) {
            var app_ids = get_app_ids_by_category (category);

            foreach (var app_id in app_ids) {
                if (!(app_id in excluded_apps) && !(app_id in apps)) {
                    need_to_add.add (app_id);
                }
            }
        }
        Folder.add_folder_apps (folder_id, need_to_add.to_array ());

        categories = new_categories;

        sync ();

        refreshed (folder_id);
    }
}
