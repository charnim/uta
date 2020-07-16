#!/usr/bin/python3
import argparse
import sys
import os

parser = argparse.ArgumentParser()
parser.add_argument('-u', '--url', help="Url, example http://www.google.com", action="store")
args = parser.parse_args()

if len(sys.argv) == 1:  # If no arguments print help
    parser.print_help()

if args.url:  # This is the cors request
    template = f"""
    
    <H3>Clickjacking Poc POC</H3>
    <iframe src="{args.url}" width=1600 height=1200>
    
    """

    with open('jacked.html', 'w') as jack:  # write the jacking
        jack.write(template)

    os.system("firefox jacked.html &")  # Open jack file



