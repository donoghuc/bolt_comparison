#!/usr/bin/python3

import json
import sys

data = { 'args': sys.argv }
print(json.dumps(data))