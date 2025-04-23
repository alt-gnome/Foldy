/*
 * Copyright (C) 2025 Vladimir Vaskov
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

using Foldy.Folder;

namespace Foldy {
    public AppInfo[] get_unfolder_apps () {
        var app_infos = AppInfo.get_all ();

        var result_app_infos = new Gee.ArrayList<AppInfo> ();
        var good_app_ids = new Gee.ArrayList<string> ();

        foreach (var app_info in app_infos) {
            good_app_ids.add (app_info.get_id ());
        }

        foreach (string folder_id in get_folders ()) {
            foreach (var app_id in get_folder_apps (folder_id)) {
                if (app_id in good_app_ids) {
                    good_app_ids.remove (app_id);
                }
            }
        }

        foreach (var app_info in app_infos) {
            if (app_info.get_id () in good_app_ids && app_info.should_show ()) {
                result_app_infos.add (app_info);
            }
        }

        return result_app_infos.to_array ();
    }

    public string[] get_installed_categories (string? exclude_folder_id) {
        var app_infos = AppInfo.get_all ();

        var categiries = new Gee.HashSet<string> ();

        foreach (var app_info in app_infos) {
            categiries.add_all (get_categories_by_app_id (app_info.get_id ()));
        }

        categiries.remove_all (get_using_categories ());

        if (exclude_folder_id != null) {
            categiries.add_all_array (get_folder_categories (exclude_folder_id));
        }

        return categiries.to_array ();
    }

    public Gee.HashSet<string> get_using_categories () {
        var result = new Gee.HashSet<string> ();

        foreach (var folder_id in get_folders ()) {
            result.add_all_array (get_folder_categories (folder_id));
        }

        return result;
    }

    public Gee.ArrayList<string> get_categories_by_app_id (string app_id) {
        var categories = new Gee.ArrayList<string> ();

        var desktop = new DesktopAppInfo (app_id);
        string? categories_string = desktop.get_categories ();

        if (categories_string == null) {
            return categories;
        }

        if (categories_string.length == 0) {
            return categories;
        }

        var raw_categories = categories_string.split (";");

        foreach (var raw_category in raw_categories) {
            if (raw_category.length > 0) {
                categories.add (raw_category);
            }
        }

        return categories;
    }

    public string[] get_app_ids_by_category (string category) {
        var app_ids = new Array<string> ();

        foreach (AppInfo app_info in AppInfo.get_all ()) {
            string app_id = app_info.get_id ();

            if (category in get_categories_by_app_id (app_id)) {
                app_ids.append_val (app_id);
            }
        }

        return app_ids.data;
    }

    /**
     * Refresh app list of a folder by category.
     */
    public void refresh_folder_category (string folder_id, string[] new_categories, string[] old_categories) {
        var apps = Folder.get_folder_apps (folder_id);
        var excluded_apps = Folder.get_folder_excluded_apps (folder_id);

        var removed_categories = new Gee.ArrayList<string> ();
        var added_categories = new Gee.ArrayList<string> ();

        foreach (string old_category in old_categories) {
            if (!(old_category in new_categories)) {
                removed_categories.add (old_category);
                debug ("Removed %s category", old_category);
            }
        }

        foreach (string new_category in new_categories) {
            if (!(new_category in old_categories)) {
                added_categories.add (new_category);
                debug ("Added %s category", new_category);
            }
        }

        var need_to_remove = new Gee.ArrayList<string> ();
        foreach (string category in removed_categories) {
            var app_ids = get_app_ids_by_category (category);

            foreach (var app_id in app_ids) {
                if (app_id in apps) {
                    need_to_remove.add (app_id);
                }
            }
        }
        Folder.remove_folder_apps (folder_id, need_to_remove.to_array ());

        var need_to_add = new Gee.ArrayList<string> ();
        foreach (string category in added_categories) {
            var app_ids = get_app_ids_by_category (category);

            foreach (var app_id in app_ids) {
                if (!(app_id in excluded_apps) && !(app_id in apps)) {
                    need_to_add.add (app_id);
                }
            }
        }
        Folder.add_folder_apps (folder_id, need_to_add.to_array ());
    }

    public void save_folders (string filepath) throws Error {
        var file = File.new_for_path (filepath);

        if (file.query_exists ()) {
            file.delete ();
        }

        var keyfile = new KeyFile ();

        foreach (var folder_id in get_folders ()) {
            keyfile.set_string (folder_id, "name", Folder.get_folder_name (folder_id));
            keyfile.set_string_list (folder_id, "apps", Folder.get_folder_apps (folder_id));
            keyfile.set_string_list (folder_id, "categories", Folder.get_folder_categories (folder_id));
            keyfile.set_string_list (folder_id, "excluded-apps", Folder.get_folder_excluded_apps (folder_id));
            keyfile.set_boolean (folder_id, "translate", Folder.get_folder_translate (folder_id));
        }

        keyfile.save_to_file (file.peek_path ());
    }

    public void restore_folders (string filepath, bool owerwrite) throws Error {
        var file = File.new_for_path (filepath);

        var keyfile = new KeyFile ();
        keyfile.load_from_file (file.peek_path (), KeyFileFlags.NONE);

        var current_folders = get_folders ();

        foreach (var folder_id in keyfile.get_groups ()) {
            if (folder_id in current_folders && !owerwrite) {
                continue;
            }

            create_folder (folder_id, keyfile.get_string (folder_id, "name"));
            Foldy.sync ();

            set_folder_categories (folder_id, keyfile.get_string_list (folder_id, "categories"));
            Foldy.sync ();

            set_folder_apps (folder_id, keyfile.get_string_list (folder_id, "apps"));
            Foldy.sync ();

            set_folder_excluded_apps (folder_id, keyfile.get_string_list (folder_id, "excluded-apps"));
            Foldy.sync ();

            set_folder_translate (folder_id, keyfile.get_boolean (folder_id, "translate"));
        }
    }

    public async void restore_folders_async (string filepath, bool owerwrite) throws Error {
        var file = File.new_for_path (filepath);

        var keyfile = new KeyFile ();
        keyfile.load_from_file (file.peek_path (), KeyFileFlags.NONE);

        var current_folders = get_folders ();

        foreach (var folder_id in keyfile.get_groups ()) {
            if (folder_id in current_folders && !owerwrite) {
                continue;
            }

            create_folder (folder_id, keyfile.get_string (folder_id, "name"));
            Foldy.sync ();

            Idle.add (restore_folders_async.callback);
            yield;

            set_folder_categories (folder_id, keyfile.get_string_list (folder_id, "categories"));
            Foldy.sync ();

            Idle.add (restore_folders_async.callback);
            yield;

            set_folder_apps (folder_id, keyfile.get_string_list (folder_id, "apps"));
            Foldy.sync ();

            Idle.add (restore_folders_async.callback);
            yield;

            set_folder_excluded_apps (folder_id, keyfile.get_string_list (folder_id, "excluded-apps"));
            Foldy.sync ();

            Idle.add (restore_folders_async.callback);
            yield;

            set_folder_translate (folder_id, keyfile.get_boolean (folder_id, "translate"));

            Idle.add (restore_folders_async.callback);
            yield;
        }
    }
}
