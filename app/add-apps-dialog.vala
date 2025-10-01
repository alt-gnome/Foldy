/*
 * Copyright (C) 2025 Vladimir Romanov <rirusha@altlinux.org>
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

public sealed class Foldy.AddAppsDialog : Adw.Dialog {

    public string folder_id { get; construct; }

    public AddAppsDialog (string folder_id) {
        Object (folder_id: folder_id);
    }

    construct {
        var add_apps_page = new AddAppsPage (folder_id) {
            can_select = false,
            selection_enabled = true
        };

        content_height = 720;
        content_width = 450;

        child = add_apps_page;

        add_apps_page.close_requested.connect (() => {
            close ();
        });
    }
}
