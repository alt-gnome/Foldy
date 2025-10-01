/*
 * Copyright (C) 2024-2025 Vladimir Romanov
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

[GtkTemplate (ui = "/org/altlinux/Foldy/ui/add-apps-page.ui")]
public sealed class Foldy.AddAppsPage : BasePage {

    [GtkChild]
    unowned Adw.ButtonRow add_button;

    public string folder_id { get; construct; }

    bool filter_changed = false;

    Gee.HashSet<string> unfolder_app_ids = new Gee.HashSet<string> ();

    Gtk.Filter unfolder_filter;
    Gtk.Filter favorite_filter;

    Settings shell_settings;

    public AddAppsPage (string folder_id) {
        Object (folder_id: folder_id);
    }

    construct {
        shell_settings = get_shell_settings ();

        model = new Gtk.NoSelection (
            new Gtk.FilterListModel (
                new Gtk.SortListModel (
                    new AppsModel (folder_id, true),
                    get_sorter ()
                ),
                get_filter ()
            )
        );

        title = _("Add apps to folder '%s'").printf (get_folder_real_name (folder_id));

        notify["show-more"].connect (update_subtitle);
    }

    void update_subtitle () {
        subtitle = show_more ? _("All apps") : _("Apps without folder");
    }

    Gtk.Filter get_filter () {
        var filter = new Gtk.EveryFilter ();

        unfolder_filter = new Gtk.CustomFilter (update_unfolder_filter);
        notify["show-more"].connect (() => {
            unfolder_filter.changed (Gtk.FilterChange.DIFFERENT);
        });

        favorite_filter = new Gtk.CustomFilter (update_favorite_filter);
        shell_settings.changed["favorite-apps"].connect (() => {
            favorite_filter.changed (Gtk.FilterChange.DIFFERENT);
        });

        filter.changed.connect (() => {
            filter_changed = true;
        });

        filter.append (unfolder_filter);
        filter.append (get_search_filter ());
        filter.append (favorite_filter);

        return filter;
    }

    bool update_unfolder_filter (Object obj) {
        lock (unfolder_app_ids) {
            if (filter_changed) {
                update_unfolder_apps ();

                filter_changed = false;
            }
        }

        if (show_more) {
            return true;
        }

        return ((Foldy.AppInfo) obj).id in unfolder_app_ids;
    }

    bool update_favorite_filter (Object obj) {
        return !(((Foldy.AppInfo) obj).id in get_favorite_apps_ids ());
    }

    void update_unfolder_apps () {
        var unfolder_apps = get_unfolder_apps ();
        unfolder_app_ids.clear ();

        foreach (var app in unfolder_apps) {
            unfolder_app_ids.add (app.get_id ());
        }
    }

    Gtk.Sorter get_sorter () {
        var sorter = new Gtk.StringSorter (new Gtk.PropertyExpression (
            typeof (AppInfo),
            null,
            "display-name"
        ));

        return sorter;
    }

    protected override void on_setup (Object obj) {
        var item = (Gtk.ListItem) obj;
        item.child = new AppRowAdd ();
        item.child.add_css_class ("card");
    }

    protected override void on_bind (Object obj) {
        var item = (Gtk.ListItem) obj;
        var row = (AppRowAdd) item.child;

        row.app_info = (AppInfo) item.item;

        bind_property (
            "selection-enabled",
            row,
            "selection-enabled",
            BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE
        );
    }

    [GtkCallback]
    void add_selected_apps () {
        add_folder_apps (folder_id, get_selected_apps ());
        close_requested ();
    }

    protected override void on_activate (uint position) {
        if (!selection_enabled) {
            return;
        }

        var app = (AppInfo) model.get_item (position);
        app.selected = !app.selected;

        add_button.sensitive = get_selected_apps ().length > 0;
    }
}
