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

using Foldy;

void on_bus_aquired (DBusConnection conn) {
    try {
        var service = new FoldersWatcher ();
        conn.register_object ("/org/altlinux/FoldyService", service);

    } catch (IOError e) {
        warning ("Could not register service: %s\n", e.message);
    }
}

MainLoop ml;

int main (string[] argv) {
    Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
    Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");

    if (!Foldy.locale_init ()) {
        warning ("Locale not supported by C library.\n\tUsing the fallback `C' locale.");
    }

    ml = new MainLoop ();

    Bus.own_name (
        BusType.SESSION, "org.altlinux.FoldyService",
        BusNameOwnerFlags.ALLOW_REPLACEMENT,
        on_bus_aquired,
        () => {},
        () => {
            print (_("Could not acquire name. Stopping...\n"));
            ml.quit ();
        }
    );

    ml.run ();

    return 0;
}
