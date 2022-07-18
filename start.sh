set -e

rm -f /var/run/dbus.pid
rm -f /run/dbus/dbus.pid
#mkdir -p /var/run/dbus

dbus-uuidgen --ensure
dbus-daemon --system

avahi-daemon --daemonize --no-chroot

snapserver -c snapserver.conf
