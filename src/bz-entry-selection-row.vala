/*
 * bz-entry-selection-row.vala
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

public class Bz.EntrySelectionRow : Adw.PreferencesRow {
    private Gtk.CheckButton radio;

    public EntrySelectionRow (Bz.FlatpakEntry entry, Bz.Repository? repository, Bz.EntryGroup entry_group) {
        activatable = true;

        radio = new Gtk.CheckButton () {
            valign = Gtk.Align.CENTER,
            can_target = false,
        };

        var title_label = new Gtk.Label (repository?.title) {
            halign = Gtk.Align.START,
            xalign = 0,
        };

        bool is_eol = entry_group.get_unique_id_is_eol (entry.unique_id);
        string version = entry.flatpak_version ?? "";
        string scope = repository != null && repository.is_user ? _("this user") : _("all users");

        var subtitle_label = new Gtk.Label (
            is_eol ? "%s • %s •".printf (version, scope) : "%s • %s".printf (version, scope)
        ) {
            halign = Gtk.Align.START,
            xalign = 0,
        };
        subtitle_label.add_css_class ("caption");
        subtitle_label.add_css_class ("dim-label");

        var subtitle_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) { halign = Gtk.Align.START };
        subtitle_box.append (subtitle_label);

        if (is_eol) {
            var eol_label = new Gtk.Label (_("End of Life"));
            eol_label.add_css_class ("caption");
            eol_label.add_css_class ("warning");
            subtitle_box.append (eol_label);
        }

        var text_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2) {
            valign = Gtk.Align.CENTER,
            hexpand = true,
        };
        text_box.append (title_label);
        text_box.append (subtitle_box);

        var user_image = new Gtk.Image.from_icon_name ("person-symbolic") {
            tooltip_text = _("For This User Only"),
            valign = Gtk.Align.CENTER,
            can_target = false,
            visible = repository != null && repository.is_user,
        };

        var root_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            margin_top = 8,
            margin_bottom = 8,
            margin_start = 12,
            margin_end = 12,
        };
        root_box.append (radio);
        root_box.append (text_box);
        root_box.append (user_image);

        child = root_box;

        var click = new Gtk.GestureClick ();
        click.released.connect (() => radio.active = true);
        add_controller (click);
    }

    public Gtk.CheckButton get_radio () {
        return radio;
    }
}
