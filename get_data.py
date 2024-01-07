#!/usr/bin/env python3

import argparse
import re

from btlewrap import BluepyBackend
from mitemp_bt.mitemp_bt_poller import MiTempBtPoller, \
    MI_TEMPERATURE, MI_HUMIDITY, MI_BATTERY

def valid_mitemp_mac(mac, pat=re.compile(r"[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}")):
    """Check for valid mac adresses."""
    if not pat.match(mac.upper()):
        raise argparse.ArgumentTypeError('The MAC address "{}" seems to be in the wrong format'.format(mac))
    return mac

def poll(args):
    poller = MiTempBtPoller(args.mac, BluepyBackend)
    print("{{\"battery\":\"{}\",\"temperature\":\"{}\",\"humidity\":\"{}\"}}".format(poller.parameter_value(MI_BATTERY), poller.parameter_value(MI_TEMPERATURE), poller.parameter_value(MI_HUMIDITY)))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('mac', type=valid_mitemp_mac)
    args = parser.parse_args()
    poll(args)

if __name__ == '__main__':
    main()
