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

[DBus (name = "org.altlinux.FoldyService")]
public sealed class Foldy.FoldersWatcher : Object {

    Settings folders_settings;

    Gee.ArrayList<FolderData> folder_datas;

    public signal void folders_refreshed ();

    public signal void folder_refreshed (string folder_id);

    Gee.ArrayList<AppInfo> app_info_list;

    construct {
        folders_settings = get_folders_settings ();
        folder_datas = new Gee.ArrayList<FolderData> ((a, b) => {
            return a.folder_id == b.folder_id;
        });

        foreach (string folder_id in get_folders ()) {
            var folder_data = new FolderData (folder_id);
            folder_datas.add (folder_data);
            folder_data.refreshed.connect ((folder_id) => {
                folder_refreshed (folder_id);
            });
        }

        folders_settings.changed["folder-children"].connect (folders_changed);

        AppInfoMonitor.get ().changed.connect (app_info_changed);
        update_app_infos ();
    }

    void update_app_infos () {
        app_info_list = new Gee.ArrayList<AppInfo> ();

        foreach (var app_info in AppInfo.get_all ()) {
            app_info_list.add (app_info);
        }
    }

    void app_info_changed () {
        var old_app_info_list = app_info_list;
        update_app_infos ();

        var removed_apps = new Gee.ArrayList<AppInfo> ();
        removed_apps.add_all (old_app_info_list);
        removed_apps.remove_all (app_info_list);

        var installed_apps = new Gee.ArrayList<AppInfo> ();
        installed_apps.remove_all (old_app_info_list);
        installed_apps.add_all (app_info_list);

        string[] installed_apps_ids = new string[installed_apps.size];
        for (int i = 0; i < installed_apps.size; i++) {
            installed_apps_ids[i] = installed_apps[i].get_id ();
        }

        string[] removed_apps_ids = new string[removed_apps.size];
        for (int i = 0; i < removed_apps.size; i++) {
            removed_apps_ids[i] = removed_apps[i].get_id ();
        }

        foreach (var folder_data in folder_datas) {
            folder_data.change_apps (installed_apps_ids, removed_apps_ids);
        }
    }

    void folders_changed () {
        string[] folders = get_folders ();

        foreach (var folder_data in folder_datas) {
            if (!(folder_data.folder_id in folders)) {
                folder_datas.remove (folder_data);
            }
        }

        foreach (string folder_id in folders) {
            bool has = false;

            foreach (var folder_data in folder_datas) {
                if (folder_data.folder_id == folder_id) {
                    has = true;
                }
            }

            if (!has) {
                var folder_data = new FolderData.with_categories_fix (folder_id);
                folder_datas.add (folder_data);
                folder_data.refreshed.connect ((folder_id) => {
                    folder_refreshed (folder_id);
                });
            }
        }

        Foldy.sync ();

        folders_refreshed ();
        message ("Folders refreshed");
    }
}
