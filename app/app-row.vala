/* Copyright (C) 2024-2025 Vladimir Romanov
 *
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

[GtkTemplate (ui = "/org/altlinux/Foldy/ui/app-row.ui")]
public abstract class Foldy.AppRow : BaseRow {

    public AppInfo app_info { get; set; }

    [GtkCallback]
    void on_app_info_changed () {
        if (app_info == null) {
            return;
        }

        bind_property (
            "selected",
            app_info,
            "selected",
            BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL
        );

        title = app_info.display_name;

        if (app_info.icon != null) {
            if (app_info.icon.to_string ().length > 0) {
                gicon = app_info.icon;
            } else {
                icon_name = "image-missing-symbolic";
            }
        } else {
            icon_name = "image-missing-symbolic";
        }
    }
}
