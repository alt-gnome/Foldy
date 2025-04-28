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

public sealed class Foldy.ModelManager : Object {

    Settings settings;

    static ModelManager instance;

    Gtk.StringList folders_model;

    construct {
        settings = new Settings ("org.gnome.desktop.app-folders");
        settings.changed["folder-children"].connect (update_folders_model);
    }

    public static ModelManager get_default () {
        if (instance == null) {
            instance = new ModelManager ();
        }

        return instance;
    }

    public Gtk.StringList get_folders_model () {
        if (folders_model == null) {
            folders_model = new Gtk.StringList ({});
            update_folders_model ();
        }

        return folders_model;
    }

    void update_folders_model () {
        folders_model.splice (0, folders_model.n_items, get_folders ());
    }
}
