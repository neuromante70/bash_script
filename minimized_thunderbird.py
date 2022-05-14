import wnck
import gtk
import subprocess
import time

thunderbird = subprocess.Popen(["thunderbird"])

b = True
while b:
    screen = wnck.screen_get_default()
    while gtk.events_pending():
        gtk.main_iteration()
    windows = screen.get_windows()
    for w in windows:
        if w.get_pid() == thunderbird.pid:
            w.maximize()
            b = False
    time.sleep(1)


thunderbird.wait()
