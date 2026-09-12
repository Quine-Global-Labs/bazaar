/*
 * bz-cosmic-place-applet-dialog.vala
 *
 * Copyright 2026 Alexander Vanhee
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Bz.CosmicPlaceAppletDialog : Adw.AlertDialog {
    public CosmicPlaceAppletDialog () {
        Object (
            heading: _("Place Applet"),
            body: _("Choose where to add this applet.")
        );

        add_response ("cancel", _("Cancel"));
        add_response ("panel", _("Panel"));
        add_response ("dock", _("Dock"));

        set_response_appearance ("panel", Adw.ResponseAppearance.SUGGESTED);
        set_response_appearance ("dock", Adw.ResponseAppearance.SUGGESTED);
        set_default_response ("cancel");
        set_close_response ("cancel");

        response.connect ((response_id) => {
            if (response_id == "panel")
                open_settings ("panel-applet");
            else if (response_id == "dock")
                open_settings ("dock-applet");
        });
    }

    private void open_settings (string page) {
#if SANDBOXED_LIBFLATPAK
        string[] argv = { "flatpak-spawn", "--host", "cosmic-settings", page };
#else
        string[] argv = { "cosmic-settings", page };
#endif
        try {
            new GLib.SubprocessLauncher (SubprocessFlags.NONE).spawnv (argv);
        } catch (Error e) {
            warning ("failed to launch cosmic-settings: %s", e.message);
        }
    }
}
