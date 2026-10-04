#!/usr/bin/env python3

# SPDX-FileCopyrightText: Robert Ryszard Paciorek <rrp@opcode.eu.org>
# SPDX-License-Identifier: MIT

# Created with Gemini AI, 2026

import sys
import os
import re
import subprocess
from gi.repository import GLib, Gio

PORTAL_XML = """
<node>
  <interface name="org.freedesktop.portal.OpenURI">
    <method name="OpenURI">
      <arg type="s" name="parent_window" direction="in"/>
      <arg type="s" name="uri" direction="in"/>
      <arg type="a{sv}" name="options" direction="in"/>
      <arg type="o" name="path" direction="out"/>
    </method>
  </interface>
</node>
"""

REQUEST_XML = """
<node>
  <interface name="org.freedesktop.portal.Request">
    <method name="Close"/>
    <signal name="Response">
      <arg type="u" name="response"/>
      <arg type="a{sv}" name="results"/>
    </signal>
  </interface>
</node>
"""

class PortalService:
    def __init__(self):
        self.request_counter = 0
        self.connection = None

    def on_bus_acquired(self, connection, name, user_data = None):
        self.connection = connection
        portal_info = Gio.DBusNodeInfo.new_for_xml(PORTAL_XML)
        connection.register_object(
            "/org/freedesktop/portal/desktop",
            portal_info.interfaces[0],
            self.handle_portal_call,
            None, None
        )

    def handle_portal_call(self, connection, sender, object_path, interface_name, method_name, parameters, invocation, user_data = None):
        if method_name == "OpenURI":
            parent_window, uri, options = parameters.unpack()

            if match := re.match("^https?://RUN_GAME/(.*)$", uri, re.IGNORECASE):
                data = match.group(1).split()
                data[0] = "/games/" + data[0]
                data.insert(0, os.environ["HOME"] + "/.bin/games_chroot")
                print("Start:", data)
                subprocess.Popen(data)
            elif match := re.match("^https?://OPEN_DIR/(.*)$", uri, re.IGNORECASE):
                data = match.group(1)
                data = os.environ["HOME"] + "/Games/" + data
                env = os.environ.copy()
                env["DBUS_SESSION_BUS_ADDRESS"] = f"unix:path=/run/user/{os.getuid()}/bus"
                subprocess.Popen(["dolphin", data], env=env)
            elif uri.startswith("http://") or uri.startswith("https://"):
                env = os.environ.copy()
                env["DBUS_SESSION_BUS_ADDRESS"] = f"unix:path=/run/user/{os.getuid()}/bus"
                subprocess.Popen(["firefox", "--private-window", uri], env=env)
            else:
                print("Unsupported URI:", uri)

            self.request_counter += 1
            req_path = f"/org/freedesktop/portal/desktop/request/{self.request_counter}"

            req_info = Gio.DBusNodeInfo.new_for_xml(REQUEST_XML)
            connection.register_object(
                req_path,
                req_info.interfaces[0],
                self.handle_request_call,
                None, None
            )

            invocation.return_value(GLib.Variant("(o)", (req_path,)))
            GLib.timeout_add(10, self.emit_response, sender, req_path)

    def handle_request_call(self, connection, sender, object_path, interface_name, method_name, parameters, invocation, user_data = None):
        if method_name == "Close":
            invocation.return_value(None)

    def emit_response(self, sender, req_path):
        self.connection.emit_signal(
            sender,
            req_path,
            "org.freedesktop.portal.Request",
            "Response",
            GLib.Variant("(ua{sv})", (0, {}))
        )
        return False

if __name__ == "__main__":
    os.environ["DBUS_SESSION_BUS_ADDRESS"] = f"unix:path=/run/user/{os.getuid()}/games_chroot_dbus.sock"
    if not "DISPLAY" in os.environ:
      os.environ["DISPLAY"] = ":0.0"
    if not "QT_QPA_PLATFORMTHEME" in os.environ:
      os.environ["QT_QPA_PLATFORMTHEME"] = "kde"
    
    service = PortalService()
    
    Gio.bus_own_name(
        Gio.BusType.SESSION,
        "org.freedesktop.portal.Desktop",
        Gio.BusNameOwnerFlags.REPLACE,
        service.on_bus_acquired,
        None,
        lambda *args: sys.exit(1)
    )
    GLib.MainLoop().run()
