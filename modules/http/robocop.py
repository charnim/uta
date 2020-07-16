#!/usr/bin/python3
# Version 1.0.6
import argparse
import sys
import time
import webbrowser

import requests

parser = argparse.ArgumentParser()
parser.add_argument('-u', '--url', help="Url, example http://www.google.com", action="store")
args = parser.parse_args()

if len(sys.argv) == 1:  # If no arguments print help
    parser.print_help()


def extractor(robots_txt: str) -> list:  # Function returns list of urls that are disallowed

    unallowed_urls = []

    for line in robots_txt.split('\n'):
        if 'disallow:' in line:
            unallowed_urls.append(line.strip('disallow:').strip())
            continue
        elif 'Disallow:' in line:
            unallowed_urls.append(line.strip('Disallow:').strip())
            continue
        elif 'allow:' in line:
            unallowed_urls.append(line.strip('allow:').strip())
            continue
        elif 'Allow:' in line:
            unallowed_urls.append(line.strip('Allow:').strip())
            continue

    return unallowed_urls


def statuser(unallowed_urls: list, url: str) -> list:
    urls_to_check = [url + path for path in unallowed_urls]
    final_links = []
    print('Running...')
    for link_to_check in urls_to_check:
        try:
            check = requests.get(link_to_check)
            print(check.status_code, link_to_check)
            final_links.append(f"{check.status_code} {link_to_check}") if check.status_code in [200, 204, 307, 302, 301] else None
        except requests.exceptions.ConnectionError:
            print(f'The {link_to_check} has returned a connection error.. Trying to continue..')
            time.sleep(1)

    print('\n')
    return final_links


if args.url:
    try:
        if 'http://' not in args.url or 'https://' not in args.url:
            try:
                r = requests.get(args.url.strip() + '/robots.txt')
            except requests.exceptions.ConnectionError:
                print(f'No connection to {args.url + "/robots.txt"} please check if the url is valid.')
                exit(0)
            final = statuser(unallowed_urls=extractor(r.text), url=args.url)
            print('The final list of accessible links:\n', *final, sep='\n')
            [webbrowser.open(url.split()[1]) for url in final]
        else:
            print("Please specify http:// or https:// in the url!", end='')
    except KeyboardInterrupt:
        exit(1)
