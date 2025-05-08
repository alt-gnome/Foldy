/*
 * Copyright (C) 2025 Vladimir Vaskov <rirusha@altlinux.org>
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

public sealed class Foldy.AppsModel : ListModel, Object {

    ListStore store_model = new ListStore (typeof (AppInfo));

    Gtk.FilterListModel real_model { get; private set; }

    ServiceProxy proxy;

    Settings settings;

    Gtk.CustomFilter this_folder_filter;

    public string? folder_id { get; construct; }

    string[] folder_apps;

    public bool exclude { get; construct; default = false; }

    public AppsModel (string? folder_id = null, bool exclude = false) {
        Object (folder_id: folder_id, exclude: exclude);
    }

    construct {
        AppInfoMonitor.get ().changed.connect (update);
        update ();

        var filter = new Gtk.EveryFilter ();

        var should_shown_filter = new Gtk.BoolFilter (new Gtk.PropertyExpression (
            typeof (AppInfo),
            null,
            "should-show"
        ));

        if (folder_id != null) {
            settings = new Settings.with_path (
                "org.gnome.desktop.app-folders.folder",
                "/org/gnome/desktop/app-folders/folders/%s/".printf (folder_id)
            );

            folder_apps = settings.get_strv ("apps");

            this_folder_filter = new Gtk.CustomFilter ((item) => {
                var app = (AppInfo) item;
                if (exclude) {
                    return !(app.id in folder_apps);
                }
                return app.id in folder_apps;
            });

            try {
                proxy = Bus.get_proxy_sync<ServiceProxy> (
                    BusType.SESSION,
                    "org.altlinux.FoldyService",
                    "/org/altlinux/FoldyService"
                );

                proxy.folder_refreshed.connect ((folder_id) => {
                    if (folder_id == this.folder_id) {
                        folder_apps = settings.get_strv ("apps");
                        filter.changed (Gtk.FilterChange.DIFFERENT);
                    }
                });

            } catch (Error e) {
                warning ("Can't get proxy of FoldyService: %s", e.message);
            }

            filter.append (this_folder_filter);
        }

        filter.append (should_shown_filter);

        real_model = new Gtk.FilterListModel (store_model, filter);

        real_model.items_changed.connect ((pos, r, a) => {
            items_changed (pos, r, a);
        });
    }

    void update () {
        for (int i = 0; i < store_model.n_items; i++) {
            store_model.remove (0);
        }

        foreach (var app in GLib.AppInfo.get_all ()) {
            store_model.append (new AppInfo (app));
        }
    }
    public GLib.Object? get_item (uint position) {
        return real_model.get_item (position);
    }

    public GLib.Type get_item_type () {
        return typeof (AppInfo);
    }

    public uint get_n_items () {
        return real_model.get_n_items ();
    }
}
